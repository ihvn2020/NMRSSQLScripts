select
pid1.identifier as PepfarID,
pid2.identifier as HospID,
pn3.given_name as FirstName,
pn3.family_name as FamilyName,
person.gender as Sex,
psn_atr.value AS PhoneNo,
person.birthdate as DOB,
TIMESTAMPDIFF(YEAR,person.birthdate,CURDATE()) as Age,
patient_program.date_enrolled as EnrollDate
,MAX(IF(obsnextapptdate.concept_id=5096,obsnextapptdate.appointment_date, NULL)) as  `NextAppointmentDate`
,MAX(IF(obs.concept_id=856,obs.value_numeric, NULL))as `LastViralLoad`
,MAX(IF(obs.concept_id=856,@lastViralLoadDate:=obsmax.last_date, @lastViralLoadDate:=NULL)) as `LastViralLoadDate`
,MAX(IF(obs.concept_id=165988,DATE_FORMAT(@lastSampleDate:=obs.value_datetime,'%d-%b-%Y'),@lastSampleDate:=null)) as `LastSpecimenCollectionDate`
,MAX(IF(biometrictable.patient_Id IS NOT NULL,'Yes','No')) as BiometricCaptured
from patient
left join patient_identifier pid1 on(pid1.patient_id=patient.patient_id and pid1.identifier_type=4 and pid1.voided=0)
left join patient_identifier pid2 on(pid2.patient_id=patient.patient_id and pid2.identifier_type=5 and pid2.voided=0)
left join person_name pn3 on(patient.patient_id=pn3.person_id and pn3.voided=0)
left join person on(person.person_id=patient.patient_id)
LEFT JOIN person_attribute psn_atr ON (person.person_id=psn_atr.person_id and psn_atr.person_attribute_type_id=8) 
left join patient_program on(patient_program.patient_id=person.person_id and patient_program.voided=0 and patient_program.program_id=1)
LEFT join obs on(obs.person_id=patient.patient_id 
and obs.concept_id IN (5096,856,165988))
left join concept_name cn1 on(obs.value_coded=cn1.concept_id and cn1.locale='en' and cn1.locale_preferred=1)
left join 
(
   select obs.person_id,obs.concept_id, MAX(obs.obs_datetime) as last_date from obs where obs.voided=0 and obs.concept_id IN(5096,856,165988)  
   GROUP BY obs.person_id,obs.concept_id
) as obsmax on(obs.person_id=obsmax.person_id and 
obs.concept_id=obsmax.concept_id and obs.obs_datetime=obsmax.last_date)
left join
(
   select 
   obs.person_id,
   obs.concept_id,
   obs.obs_datetime,
   obs.value_datetime as appointment_date
   from
   obs where 
   obs.concept_id=5096 and obs.voided=0 and 
   obs.value_datetime BETWEEN :startDate and :endDate
) as obsnextapptdate 
on(obsnextapptdate.person_id=patient.patient_id)
LEFT JOIN (
   select 
   DISTINCT biometricinfo.patient_Id
   from 
   biometricinfo
) as biometrictable 
on(patient.patient_id=biometrictable.patient_Id and patient.voided=0)
where 
patient.voided=0 and obs.voided=0 and 
obsnextapptdate.appointment_date BETWEEN :startDate and :endDate
GROUP BY patient.patient_id,obsnextapptdate.appointment_date;