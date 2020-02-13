select
pid1.identifier as PepfarID,
pid2.identifier as HospID,
pn3.given_name as FirstName,
pn3.family_name as FamilyName,
person.gender as Sex,
psn_atr.value AS PhoneNo,
person.birthdate as DOB,
CONCAT(person_address.address1," ",person_address.city_village) as PatientAddress,
TIMESTAMPDIFF(YEAR,person.birthdate,CURDATE()) as Age,
appointmentquery.appointmentdate as AppointmentDate,
visitquery.visitdate as VisitDate
from patient
left join patient_identifier pid1 on(pid1.patient_id=patient.patient_id and pid1.identifier_type=4 and pid1.voided=0)
left join patient_identifier pid2 on(pid2.patient_id=patient.patient_id and pid2.identifier_type=5 and pid2.voided=0)
left join person_name pn3 on(patient.patient_id=pn3.person_id and pn3.voided=0)
left join person on(person.person_id=patient.patient_id and person.voided=0)
left join person_address on(person_address.person_id=person.person_id and person_address.voided=0)
LEFT JOIN person_attribute psn_atr ON (person.person_id=psn_atr.person_id and psn_atr.person_attribute_type_id=8) 
left join
(
    select 
	   DISTINCT 
	   obs.person_id,
	   obs.concept_id,
	   obs.value_datetime as appointmentdate
	   from 
	obs where obs.concept_id=5096 and obs.voided=0 and obs.value_datetime BETWEEN :startDate and :endDate GROUP BY obs.person_id,obs.concept_id,obs.value_datetime
	   
) as appointmentquery on(appointmentquery.person_id=patient.patient_id)
left join 
(
    select 
	  DISTINCT 
	  encounter.patient_id,
	  encounter.encounter_datetime as visitdate
    from encounter 
	  where 
	  encounter.voided=0 
	  and 
	  encounter.encounter_datetime BETWEEN :startDate and :endDate
	  GROUP BY encounter.patient_id,encounter.encounter_datetime
	  
) as visitquery on(visitquery.patient_id=appointmentquery.person_id)
where patient.voided=0 
and appointmentquery.appointmentdate BETWEEN :startDate  and :endDate
AND 
visitquery.visitdate is null
GROUP BY patient.patient_id