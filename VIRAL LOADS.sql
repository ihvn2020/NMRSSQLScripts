select
obs.person_id as PatientID,
pid1.identifier as PepfarID,
pid2.identifier as HospID,
person.gender as Sex,
person.birthdate as DoB,
TIMESTAMPDIFF(YEAR,person.birthdate,curdate()) as Age,
DATE_FORMAT(encounter.encounter_datetime,'%d-%b-%Y') as VisitDateSameAsSampleCollectionDate,
form.name as PMMForm,
CONCAT(pn2.given_name,'',pn2.family_name) as Provider,
MAX(IF(obs.concept_id=856,obs.value_numeric, NULL)) AS ViralLoad,
MAX(IF(obs.concept_id=164989,obs.value_text, NULL)) AS OrderedBy,
MAX(IF(obs.concept_id=164983,obs.value_text, NULL)) AS CheckedBy,
MAX(IF(obs.concept_id=164982,obs.value_text, NULL)) AS ReportedBy,
MAX(IF(obs.concept_id=164989,obs.value_datetime, NULL)) AS OrderedDate,
MAX(IF(obs.concept_id=159951,obs.value_datetime, NULL)) AS SampleCollectionDate,
MAX(IF(obs.concept_id=164984,obs.value_datetime, NULL)) AS CheckedDate,
MAX(IF(obs.concept_id=165414,obs.value_datetime, NULL)) AS ReportedDate
FROM
obs
inner join patient on(patient.patient_id=obs.person_id and patient.voided=0)
left join patient_identifier pid1 on(pid1.patient_id=obs.person_id and pid1.identifier_type=4 and pid1.voided=0)
left join patient_identifier pid2 on(pid2.patient_id=obs.person_id and pid2.identifier_type=5 and pid2.voided=0)
left join encounter on(encounter.encounter_id=obs.encounter_id and encounter.voided=0)
left join encounter_provider on(encounter_provider.encounter_id=encounter.encounter_id and encounter.voided=0)
left join users usr1 on(usr1.user_id=encounter.creator and encounter.voided=0)
left join person_name pn1 on(usr1.person_id=pn1.person_id and pn1.voided=0)
left join form on(form.form_id=encounter.form_id and encounter.voided=0)
left join concept_name cn1 on(obs.value_coded=cn1.concept_id and cn1.locale='en' and cn1.locale_preferred=1)
left join person_name pn2 on(pn2.person_id=encounter_provider.provider_id)
left join person on(person.person_id=obs.person_id and person.voided=0)
where 
encounter.form_id =21
 and
encounter.encounter_datetime BETWEEN :startDate and :endDate
and
obs.concept_id in (856,164989,164983,164982,164989,164984,165414,159951)
GROUP BY encounter.patient_id,obs.encounter_id;