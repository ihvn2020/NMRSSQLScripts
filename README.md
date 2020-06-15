# IHVN HEALTH INFORMATICS UNIT
These SQL scripts was created by IHVN health informatics unit
# NMRSSQLScripts
Useful SQL scripts for extracting popular reports from the NMRS 2.0 Platform.
These SQL scripts should be embedded into the NMRS 2.0 Reporting module.
# NMRS 2.0
The NMRS 2.0 platform is a customized OpenMRS Reference App 2.7.0 on platform 2.0.6 built with Nigeria specific 
National Tools for managing clients on ART. It runs on OpenMRS platform 2.0.6 and uses the Reference Application
version 2.7.0
# CLINIC VISITS
This reports exports a line list (patient by patient record) of patients who 
had a clinic visit (had at least one PMM form or encounter) entered for them in the 
reporting period.
# EXITS
This is a line list (patient by patient record) of patients who are confirmed to be no longer 
in care. A patient is confirmed to have exited care if any of the following events happen to you
Dead, Transferred out, LTFU. This script exports all patients who have a Contact Tracking and Termination Form
filled for them.
# MISSED APPOINTMENTS
This is a line listing of all patients who have an appointment within a period :startDate and :endDate but did not have 
a corresponding encounter within that period :startDate and :endDate. A patient missing appointment is an early warning that
the patient could be a potential LTFU (Lost to Follow Up).
# RADET9
This is line listing generation of key patient information, especially those required for generating key aggregate program level 
indicators. RADET means Retention in Care Audit Determination Tool and this is the version 4 of it.
# SCHEDULED APPOINTMENT
This is a line listing of patients who have been scheduled to come to the clinic for a given period (:startDate and :endDate) specified
by the user. This SQL uses the nextAppointmentDate variable to determine patients who are scheduled to have a contact with any service provider in a given date range.
# TX_NEW
This is a line listing of all patients who newly started ART in a given period :startDate and :endDate. This SQL script usses the ARTStartDate as the selection criteria for the patient that is new on treatment.
# VIRAL LOAD ELIGIBILITY
This is a line listing of patients who are due for viral load test. The SQL script uses an eligibility criteria of the following;
- Patient must be active
- Patient must have been on ART for 6 months and above
- Your last sample collection date is more than 12 months old
- Your last viral load was done more than 12 months ago if you are suppressed
- Your last viral load was done more than 6 months ago if you are unsuppressed
# VIRAL LOADS
This is a line listing of viral loads done within a given time period :startDate and :endDate specified by the user.
The selection criteria is based on viral loads with SampleCollectionDate falling within a period.
# ADD PAST VISIT SCRIPT
This script automatically assigns visit_id to an encounter that does not have visit_id
