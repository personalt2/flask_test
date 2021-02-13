# flask_test
report_scheduler.py runs fine if you run code in main directly.  Woud like to have the two threads that run there ProcessReport and RequestReport run in a way that the the objects hold their queue of work can be displayed on a simple website

**Simple Code/Goal Explaination**
I have two threads that maintain a list of objects which is the work they want to handle.  I want to make a single webpage that shows the list of objects being matained by each thread.   That is primary goal of what I am looking for help on.   But there is also a list of questions at the bottom of the read me that we could disucess as a paid code review or work out some other way to dicuss


**More Details - Explanation of how the code currently works.**

The project was born as two scripts report_scheduler.py and reports.py.
report_scheduler.py queries a table in a mysql database tbl_rpt_log which lists a set of reports with some metadata including their last_run date. From tbl_rpt_log the script requests, via an api, new versions of the reports that are considered ‘old’. More specifically, the main function in report_sceduler.py does a simple check to see what reports need to be refreshed. It passes the request to the RequestReportClass via t1.add(report, user, last_report_id). This class calls an api to request the report and keeps looping to check with the API every few minutes to see if the report is ready for download. When the report is ready the RequestReport Class passes these parameters to the ProcessReport class via process_report_thread.add(user, report_name, requested_report_id). report and report_name both represent the same name of the report I want to request/process. The ProcessReport class loops through all the reports that are considered done, request the completed data, and processes it. The requesting and processing logic in these classes is complicated(but works) and are not the area that I currently need help with. In order to make things easier, I simplified that code using a random number generator so that during each loop about half the objects are considered complete and are passed to the next stage/class.

**What do I want to accomplish as a primary goal**

Convert the code in report_scheduler.py so that it runs when the application starts up. These two code files currently live in the get_reports django app folder but it is not currently integrated into django. The scripts due work if you call report_scheduler.py manually.
As part of getting it to run I want to display the objects above on a page in django so that as the script loops the page updates showing the objects being queued in each class

**Thoughts and areas of concern I would like to discuss**

* Right now main in report_scheduler is designed to be called once as part of a nightly job. It then passes the list of reports to t1/RequestReportClass. In order to make this app-friendly this needs to be refactored to be able to loop. Before any report is added to t1/ReqestReport Class I should make sure the report is not already queued in t1/RequestReportClass or t2/ProcessReportClass so I am not re-requesting any report that is already in the pipeline. I think I understand the code base enough to do add this but as we refactor report_scheduler main this should be a goal to add protection for calling the same report that is already being requested.

* Review my use of threads. This is something that new to me. The code does work in that it spawns two threads and iterates through until the work is done but am I doing this in the best way possible

* I think my use of cursors and separate database connections for each thread is set up in a proper manner but would like to review how I connect to database and use cursors.

* As each class is about to loop through its active dictionary to process its items I make a copy of that dictionary. It then iterates over a copy of that dictionary deleting the value from the original dictionary if it completes the need work on that pass. The thought was that there might be some contention between the class looping over the dict and the other thread/class looking to add values to it. Is this needed? Overall want to review my handling of this type of code including my use of ‘with lock’

* I would think it is likely there are blocks of code in this code base that work but are not implemented in the best way possible. Would like to spend to time with mentor reviewing the rest of the code

* Right now page that shows the objects in progress will run on an internal server but as I move this process to AWS I want to protect this page. I have used auth0 on other projects and would likely integrate it with them.
