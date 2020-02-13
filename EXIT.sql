select  
   pid1.identifier as PepfarID,
   pid2.identifier as HospID,
   person.gender as Sex,
   TIMESTAMPDIFF(YEAR,person.birthdate,curdate()) as Age,
   person.birthdate as DOB,
   IF(person.dead=1,"Dead","") as MarkAsDeseased,
   IF(person.dead=1,person.death_date,"") as MarkAsDeseasedDeathDate,
   encounter.encounter_datetime as TrackorTerminationDate,
   form.`name` as PmmForm,
   CONCAT(prs1.given_name,' ',prs1.family_name) as EnteredBy,
   encounter.date_created as DateCreated,
   MAX(IF(obs.concept_id=165460, cn1.name, NULL)) as  `ReasonForTracking`
   ,MAX(IF(obs.concept_id=165586, cn1.name, NULL)) as `PatientCareTerminated`
   ,MAX(IF(obs.concept_id=165469, obs.value_datetime, NULL)) as  `DateOfTermination`
   ,MAX(IF(obs.concept_id=165470, cn1.name, NULL)) as  `ReasonForTermination`
   ,MAX(IF(obs.concept_id=165889, cn1.name, NULL)) as  `CauseOfDeath`
   ,MAX(IF(obs.concept_id=165915, obs.value_text, NULL)) as  `OtherCauseOfDeath`
   ,MAX(IF(obs.concept_id=165916, obs.value_text, NULL)) as  `DiscontinuedCareReason`
   ,MAX(IF(obs.concept_id=165775, obs.value_datetime, NULL)) as  `DateReturnedToCare`
   ,MAX(IF(obs.concept_id=165776, cn1.name, NULL)) as  `ReferredFor`
      
  FROM encounter 
  left join patient on(encounter.patient_id=patient.patient_id and patient.voided=0 and encounter.voided=0)
  left join person_attribute on(person_attribute.person_id=patient.patient_id and person_attribute.voided=0 and person_attribute.person_attribute_type_id=8 and person_attribute.voided=0)
  left join obs on(obs.encounter_id=encounter.encounter_id)
  left join patient_identifier pid1 on(pid1.patient_id=encounter.patient_id and pid1.identifier_type=4)
  left join patient_identifier pid2 on(pid2.patient_id=encounter.patient_id and pid2.identifier_type=5)
  left join form on(encounter.form_id=form.form_id and encounter.voided=0)
  left join users on(encounter.creator=users.user_id)
  left join person_name prs1 on(prs1.person_id=users.person_id and prs1.voided=0)
  left join person on(person.person_id=patient.patient_id)
  left join concept_name cn1 on(cn1.concept_id=obs.value_coded and cn1.locale='en' and cn1.locale_preferred=1)
 where (encounter.form_id=13  AND encounter.voided=0 AND
 encounter.encounter_datetime BETWEEN :startDate and :endDate) OR (person.dead=1 and person.death_date BETWEEN :startDate and :endDate and person.voided=0) GROUP BY patient.patient_id;
