select
    DISTINCT
    pid1.identifier as HospID,
	pid2.identifier as PepfarID,
	person.gender as Sex,
	person.birthdate as DOB,
	TIMESTAMPDIFF(YEAR,person.birthdate,curdate()) as Age,
	patient_program.date_enrolled as EnrollmentDate,
	arttable.art_start_date as ARTStartDate
	from 
	patient 
	left join patient_identifier pid1 on(pid1.patient_id=patient.patient_id and pid1.identifier_type=5)
	left join patient_identifier pid2 on(pid2.patient_id=patient.patient_id and pid2.identifier_type=4)
	left join person on(person.person_id=patient.patient_id and person.voided=0)
	left join patient_program on(patient_program.patient_id=patient.patient_id and patient_program.program_id=1 and patient_program.voided=0)
	left join
	(
	   select 
	   obs.person_id,
	   obs.concept_id,
	   obs.value_datetime as art_start_date
	   from obs 
	   where 
	   obs.concept_id=159599
	   and obs.voided=0 
	   and value_datetime BETWEEN :startDate and :endDate
	) as arttable on(arttable.person_id=patient.patient_id and 
	patient.voided=0)
	where arttable.art_start_date BETWEEN :startDate and :endDate
	GROUP BY patient.patient_id;
	