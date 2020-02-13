select  
   pid1.identifier as PepfarID,
   pid2.identifier as HospID,
   encounter.encounter_datetime as VisitDate,
   person.gender as Sex,
   TIMESTAMPDIFF(YEAR,person.birthdate,curdate()) as Age,
   form.`name` as PmmForm,
   CONCAT(prs1.given_name,' ',prs1.family_name) as EnteredBy,
   CONCAT(prs2.given_name,' ',prs2.family_name) as ServiceProvider
from patient
inner join encounter 
on(encounter.patient_id=patient.patient_id and encounter.voided=0 and patient.voided=0)
left join encounter_provider on(encounter.encounter_id=encounter_provider.encounter_id and encounter.voided=0 and encounter_provider.voided=0)
left join users on(encounter.creator=users.user_id)
left join person_name prs1 on(prs1.person_id=users.person_id and prs1.voided=0)
left join provider on(encounter_provider.provider_id=provider.provider_id) 
left join person_name prs2 on(prs2.person_id=provider.person_id and prs2.voided=0)
left join patient_identifier pid1 on(pid1.patient_id=encounter.patient_id and pid1.identifier_type=4)
left join patient_identifier pid2 on(pid2.patient_id=encounter.patient_id and pid2.identifier_type=5)
left join person on(person.person_id=patient.patient_id and person.voided=0)
left join form on(encounter.form_id=form.form_id and encounter.voided=0)
WHERE encounter.encounter_datetime BETWEEN :startDate and :endDate  and encounter.voided=0 GROUP BY patient.patient_id,CAST (encounter.encounter_datetime AS DATE);
 
  
   
    
