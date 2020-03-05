/*
   PepfarID,HospID,FirstName,LastName,DOB,Sex,Phone,Address,LastVisitDate
*/
select
    patient.patient_id,
	pid1.identifier as PepfarID,
	pid2.identifier as HospID,
	person_name.given_name as FirstName,
	person_name.family_name as LastName,
	person.gender as Sex,
	DATE_FORMAT(person.birthdate,'%D-%b-%Y') as DOB,
	TIMESTAMPDIFF(YEAR,person.birthdate,CURDATE()) AS AgeYrs,
	CONCAT (
	person_address.address1,
	" ",
	person_address.address2,
	" ",
	person_address.city_village,
	" ",
	person_address.state_province) as FullAddress,
	myinnertable.last_visit_date as LastVisitDate
	
from 

patient
LEFT JOIN patient_identifier pid1 on(pid1.patient_id=patient.patient_id and pid1.identifier_type=4)
LEFT JOIN patient_identifier pid2 on(pid2.patient_id=patient.patient_id and pid2.identifier_type=5)
LEFT JOIN person_name on(person_name.person_id=patient.patient_id)
LEFT JOIN person on(person.person_id=patient.patient_id)
LEFT JOIN person_address on(person_address.person_id=patient.patient_id)

LEFT JOIN (
  select encounter.patient_id, MAX(encounter.encounter_datetime) as last_visit_date
  
  from encounter GROUP BY encounter.patient_id


) as myinnertable on(myinnertable.patient_id=patient.patient_id)

LIMIT 10;