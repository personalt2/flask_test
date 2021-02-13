import time
import datetime
from datetime import datetime, timedelta
import pymysql
import warnings
# noinspection PyUnresolvedReferences
import MySQLdb
import pytz
import logging
import dateutil.parser  # test for time parsing, user to convert amazon iso 8601 time to mysql time
from mws import mws
from multiprocessing import current_process  # used for process id
from httplib2 import Http
from threading import *
import threading
from json import dumps
import maya
# import get_reports.cred                       # need to change ref for django
import cred

from requests.exceptions import HTTPError
from logging.handlers import RotatingFileHandler
# for codementor testing
import random

import itertools
import pprint as pp

pymysql.install_as_MySQLdb()

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
handler = RotatingFileHandler('./logs/mws.log', maxBytes=10000000, backupCount=10)
logger.addHandler(handler)




def run_query_with_warnings(warn_type, query_string, **kargs):

	db = MySQLdb.connect(host=cred.host, user=cred.user, password=cred.password, db=cred.db, port=cred.port, charset='latin1')
	cursor = db.cursor()

	try:
		with warnings.catch_warnings(record=True) as w:
			if warn_type == 2:
				logger.debug('QueryString Warn #2 : %s', query_string)
				logger.debug('field split Warn #2 : %s', kargs['field_split'])
				cursor.executemany(query_string, kargs['field_split'] + kargs['user'])

			elif warn_type == 3:
				logger.debug('QueryString Warn #3 : %s', query_string)
				cursor.execute(query_string, (kargs['reportid'], kargs['timestamp'], kargs['reportid'], kargs['reportid'], kargs['timestamp']))

			elif warn_type == 4:
				logger.debug('QueryString Warn #4 : %s', query_string)
				cursor.execute(query_string, (kargs['timestamp'], kargs['reportid'], kargs['reportid']))

			else:
				logger.debug('QueryString Warn #1 qs : %s', query_string)
				logger.debug('QueryString Warn #1 fs : %s',  kargs['field_split'])
				cursor.executemany(query_string, kargs['field_split'])

			db.commit()
			logger.debug('last executed : %s', cursor._last_executed)

			if w:
				logger.warning('Mysql Warning : %s', w[-1])
				logger.warning('Statement : %s', str(cursor._last_executed))
				logger.warning(kargs['field_split'])
				# noinspection PyUnresolvedReferences
				#string_google = 'Warning - ' + str(w[-1].message) + ' - ' + str(cursor._last_executed)
				#string_google = string_google[:500]
				#googlechat(string_google)


	except pymysql.err.InternalError as e:
		logger.warning('Mysql Error : %s', e)
		logger.warning('Statement : %s', cursor._last_executed)
		#string_a = 'Error - ' + str(e.args[1] + ' - ' + cursor._last_executed)
		#googlechat(string_google)
		return  # exit rather then marking report run good


class RequestReport(Thread):
	def __init__(self, process_report_thread):
	#def __init__(self):
		Thread.__init__(self)
		self.reports_to_call = {}
		self.process_report_thread = process_report_thread

	def add(self, report, user, last_report_id):
		self.reports_to_call.update({(user, report): {}})
		self.reports_to_call[user, report]['last_report_id'] = last_report_id
		#print(self.reports_to_call)

	def run(self):
		print("Request Report Thread")
		#googlechat("Start")
		access_key = cred.access_key
		secret_key = cred.secret_key

		# ========================  Database Init =========================================================================
		# Open database connection
		db = MySQLdb.connect(host=cred.host, user=cred.user, password=cred.password, db=cred.db, port=cred.port)
		cursor = db.cursor()  # prepare a cursor object using cursor() method

		# gets some info from amazon about the type of reports, their packing, how often they can be asked for, table to store data
		cursor.execute("SELECT * FROM tbl_rpt_list")
		mysql_reports = cursor.fetchall()

		report_list_keys = {}
		for row in mysql_reports:
			report_list_keys[row[0]]=(row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8])

		# ============================   Get user Keys ==================================
		# when requesting a report from amazon you need the user keys to do it on their behalf
		cursor2 = db.cursor()
		cursor2.execute("SELECT * FROM tbl_user_keys")
		user_keys_cursor = cursor2.fetchall()

		user_keys = {}
		for row in user_keys_cursor:
			user_keys[row[0]] = (row[1], row[2])

		time.sleep(2)
		lock = threading.Lock()

		requested_report_id = 0;

		while True:

			with lock:  #copy dict to prevent contenion  <- Not sure if really needed??????
				reports_to_call_copy = self.reports_to_call.copy()

			for line in reports_to_call_copy:
				user = line[0]  #user from original mysql query
				report_name = line[1]  #report from original query
				reports_to_call_val_tup = reports_to_call_copy[line]
				last_report_id = reports_to_call_val_tup.get("last_report_id") # id from db, id of a given report the lasat time it was runast report for user.  This is so you dont get process same report twice for reports you cant request

				access_key_tup = user_keys[user]
				seller_id = access_key_tup[0]
				auth_token = access_key_tup[1]


				#for testing simuiate some reports being able to be requested and soem needing to wait for another pass
				if random.randint(0,100)  < 50:
					requested_report_id = requested_report_id + 1;  # for testing only
					print("t1 - requested - ", report_name, user, requested_report_id)
					self.process_report_thread.add(user, report_name, requested_report_id)  # to thread two

					with lock:  # delete request to call this report from dict in this thread
						del self.reports_to_call[user, report_name]
				else:
					print("t1 - didnt request -", report_name, user)

			time.sleep(180)


class ProcessReport(Thread):
	def __init__(self):
		Thread.__init__(self)
		self.reports_requested = {}

	def add(self, user, report_name, requested_report_id):
		self.reports_requested.update({(user, report_name, requested_report_id): {}})


	def run(self):
		#logger = logging.getLogger(__name__)
		#logger.setLevel(logging.DEBUG)
		#handler = RotatingFileHandler('./logs/process_report.log', maxBytes=10000000, backupCount=10)
		#logger.addHandler(handler)
		print("Process Report Thread")

		db = MySQLdb.connect(host=cred.host, user=cred.user, password=cred.password, db=cred.db, port=cred.port)
		cursor = db.cursor()  # prepare a cursor object using cursor() method

		access_key = cred.access_key
		secret_key = cred.secret_key


		# ========================  Database Init =========================================================================
		cursor.execute("SELECT * FROM tbl_rpt_list")
		mysql_reports = cursor.fetchall()

		report_list_keys = {}
		for row in mysql_reports:
			report_list_keys[row[0]] = (row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8])

		# ============================   Get user Keys ==================================


		cursor2 = db.cursor()
		cursor2.execute("SELECT * FROM tbl_user_keys")
		user_keys_cursor = cursor2.fetchall()

		user_keys = {}
		for row in user_keys_cursor:
			user_keys[row[0]] = (row[1], row[2])

		lock2 = threading.Lock()

		time.sleep(25)

		while True:

			with lock2:  #copy dict to prevent contenion
				#reports_to_call_values = list(self.reports_to_call.values())
				#print(self.reports_requested)
				reports_requested_copy = self.reports_requested.copy()

			for line in reports_requested_copy:
				user = line[0]  #user from original mysql query
				report = line[1]  #report from original query
				report_name = report #dupe the query rather then change code - should fix
				requested_report_id = line[2]

				report_list_tup = report_list_keys[report_name]  # tbl_rpt_list
				line_ending = report_list_tup[2]
				report_db_type = report_list_tup[1]
				table_name = report_list_tup[0]

				access_key_tup = user_keys[user]
				seller_id = access_key_tup[0]
				auth_token = access_key_tup[1]


				#code in this area polls to see if report is ready using test code
				#for testing simuiate some reports being not being processed
				current_time = datetime.utcnow().replace(tzinfo=pytz.utc)
				if random.randint(0,100)  < 25:
					cursor.execute("UPDATE tbl_rpt_log SET last_run=%s, report_id=%s where user=%s and report=%s",
								   (current_time, requested_report_id, user, report_name))
					db.commit()
					print("t2 - Processed  - ", report_name, user, requested_report_id, current_time)
					del self.reports_requested[user, report_name, requested_report_id]
				else:
					print("t2 - Didnt Process  - ", report_name, user, requested_report_id, current_time)


			time.sleep(60)



