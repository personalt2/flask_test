import logging
import datetime
from datetime import datetime
import pymysql
import pytz
import cred
import sys  # for passing arguments in
import time
import schedule
from flask import Flask, render_template



pymysql.install_as_MySQLdb()
import MySQLdb
from reports import RequestReport, ProcessReport, logger

from flask import Flask
app = Flask(__name__)

@app.route('/')
def index():
    return 'Hello World!!'

logger = logging.getLogger(__name__)

db = MySQLdb.connect(host=cred.host, user=cred.user, password=cred.password, db=cred.db, port=cred.port)
cursor = db.cursor()  # prepare a cursor object using cursor() method

t2 = ProcessReport()
t2.start()

t1 = RequestReport(t2)
t1.start()

report_test()



def report_on_row(row):
	"""checks to see if report has been recently run, calls call_report as needed"""
	#logger = logging.getLogger(__name__)

	user = (row[0])
	report = (row[1])
	last_report_id = (row[2])  #report id of last good run
	run_interval = (row[3])

	if row[4] is not None:  # for first run
		last_run = (row[4]).replace(tzinfo=pytz.utc)
	else:
		last_run = None

	logger.info('Report -  : %s %s %s %s', report, user, last_run, datetime.utcnow().replace(tzinfo=pytz.utc))

	if last_run is not None:
		time_since_last_request = datetime.utcnow().replace(tzinfo=pytz.utc) - last_run
	else:
		time_since_last_request = None

	if time_since_last_request.total_seconds() > run_interval * 60:
		# check number of mins in db to see if report you want to request has a recent report less then run interval old
		#logger.info("It has been long enough to try and request a new report \n")
		#call_report(report, user)
		t1.add(report, user, last_report_id)  # report you would like to ask for plus id of last good run as some reports are built
											  # periodicly and can you can only check if there is a newer one not request a genration

#	else:
#		logger.info("Report is recent \n")


def report_test():
	print("Querying DB")
	print(sys.argv)
	# if running direct we can pass in arg to pick differnt ways to select which reports to run
	# this should likely become its own thread at some point but need to address issue where report_on_row can add reports to t1
	# the queue to request report while a report is in t2 waiting for report to be done as the last_run field in db doenst update
	# unless report comes back from thread t2.
	if '-d' in sys.argv:
		print("Running With -d Arg")
		cursor.execute("SELECT * FROM tbl_rpt_log where daily_3am='1' order by last_run ASC")
	elif '-l' in sys.argv:
		cursor.execute("SELECT * FROM tbl_rpt_log where use_latest='1' order by last_run ASC")
	elif '-a' in sys.argv:
		cursor.execute("SELECT * FROM tbl_rpt_log where active='1' order by last_run ASC")
	else:
		#cursor.execute("SELECT * FROM tbl_rpt_log where cron='1' order by last_run ASC")
		cursor.execute("SELECT * FROM tbl_rpt_log where daily_3am='1' order by last_run ASC")

	reports_to_run = cursor.fetchall()
	print("reports to run")
	print(reports_to_run)

	for row in reports_to_run:
		report_on_row(row)

if __name__ == '__main__':

	logger = logging.getLogger(__name__)

	db = MySQLdb.connect(host=cred.host, user=cred.user, password=cred.password, db=cred.db, port=cred.port)
	cursor = db.cursor()  # prepare a cursor object using cursor() method

	t2 = ProcessReport()
	t2.start()

	t1 = RequestReport(t2)
	t1.start()

	report_test()


	#time.sleep(6)
	#schedule.every(1).minutes.do(report_test)



	try:
		while 1:
			schedule.run_pending()
			time.sleep(1)
	except (KeyboardInterrupt, SystemExit):
		# Not strictly necessary if daemonic mode is enabled but should be done if possible
			schedule.CancelJob