SELECT
pid1.identifier AS PepfarID,
pid2.identifier AS HospID,
pn3.given_name AS FirstName,
pn3.family_name AS FamilyName,
person.gender AS Sex,
CONCAT(person_address.address1," ",person_address.city_village) as PatientAddress,
COALESCE(CONCAT("234-",psn_atr.value),MAX(IF(target.concept_id=159635, CONCAT("234-",obs.value_text), NULL)),MAX(IF(target.concept_id=164946, CONCAT("234-",obs.value_text), NULL))) AS PhoneNo,
CAST(person.birthdate AS DATE) AS DOB,
TIMESTAMPDIFF(YEAR,person.birthdate,CURDATE()) AS Age,
CAST(patient_program.date_enrolled AS DATE) AS EnrollmentDate,
IF(person.gender='F',MAX(IF(target.concept_id=165050, cn1.name, NULL)),null) AS  `PregnancyStatus`,
IF(person.gender='F',MAX(IF(target.concept_id=165050, CAST(target.last_date AS DATE), NULL)),null) AS  `PregnancyStatusDate`
,MAX(IF(target.concept_id=159599, @artStartDate:=CAST(obs.obs_datetime AS DATE), NULL)) AS  `ARTStartDate`
,MAX(IF(target.concept_id=164989, @lastPickupDate:=CAST(target.last_date AS DATE), NULL)) AS  `LastDrugPickUpDate`
,MAX(IF(target.concept_id=159368, obs.value_numeric, NULL)) AS  
`DaysOfARVRefill`

,MAX(IF(target.concept_id=856,obs.value_numeric, NULL)) AS  `LastViralLoad`
,MAX(IF(target.concept_id=856,@lastViralLoadDate:=CAST(target.last_date AS DATE), NULL)) AS  `LastViralLoadDate`
,MAX(IF(obs.concept_id=159951,@lastSampleDate:=CAST(obs.obs_datetime AS DATE),null)) as LastSampleCollectionDate
,MAX(IF(target.concept_id=165708, cn1.name, NULL)) AS  ` LastRegimenLine`
,MAX(IF(target.concept_id=165708, CAST(target.last_date AS DATE), NULL)) AS  ` LastRegimenLineDate`
,MAX(IF(target.concept_id=164506,cn1.name, IF(target.concept_id=164507,cn1.name, NULL))) AS  `LastFirstLineRegimen`
,MAX(IF(target.concept_id=164506,CAST(target.last_date AS DATE), IF(target.concept_id=164507,CAST(target.last_date AS DATE), NULL))) AS  `LastFirstLineRegimenDate`
,MAX(IF(target.concept_id=164513,cn1.name, IF(target.concept_id=164514,cn1.name, NULL)))  AS  `LastSecondLineRegimen`
,MAX(IF(target.concept_id=164513,CAST(target.last_date AS DATE), IF(target.concept_id=164514,CAST(target.last_date AS DATE), NULL))) AS  `LastSecondLineRegimenDate`
,MAX(IF(target.concept_id=164702,cn1.name, IF(target.concept_id=165703,cn1.name, NULL)))  AS  `LastThirdLineRegimen`
,MAX(IF(target.concept_id=164702,CAST(target.last_date AS DATE), IF(target.concept_id=165703,CAST(target.last_date AS DATE), NULL))) AS  `LastThirdLineRegimenDate`
,MAX(IF(target.concept_id= 165470,cn1.name, NULL)) AS  `LastPatientOutcome`
,MAX(IF(target.concept_id= 165470,CAST(target.last_date AS DATE), NULL)) AS  `LastPatientOutcomeDate`
FROM patient
LEFT JOIN patient_identifier pid1 ON(pid1.patient_id=patient .patient_id AND pid1.identifier_type=4 AND pid1.voided=0)
LEFT JOIN patient_identifier pid2 ON(pid2.patient_id=patient .patient_id AND pid2.identifier_type=5 AND pid2.voided=0)
LEFT JOIN person_address on(person_address.person_id=patient.patient_id and person_address.voided=0)
LEFT JOIN person_name pn3 ON(patient .patient_id=pn3.person_id AND pn3.voided=0)
LEFT JOIN person ON(person.person_id=patient .patient_id)
LEFT JOIN person_attribute psn_atr ON (person.person_id=psn_atr.person_id) 
LEFT JOIN patient_program ON(patient_program.patient_id=person.person_id AND patient_program.voided=0)
LEFT JOIN
(
SELECT obs.person_id, obs.concept_id, MAX(obs.obs_datetime) AS last_date FROM obs where obs.voided=0 and obs.concept_id IN(159599,165050,856,165708,164506,164507,164513,164514,165702,165703,165470,164989,7778430,159951,159635,164946,159951,159368) GROUP BY obs.person_id, obs.concept_id)
target ON (target.person_id=patient.patient_id)
INNER JOIN obs ON(obs.person_id=target.person_id AND obs.concept_id=target.concept_id AND obs.obs_datetime=target.last_date AND obs.concept_id IN(159599,165050,856,165708,164506,164507,164513,164514,165702,165703,165470,164989,7778430,159951,159635,164946,159951,159368))
LEFT JOIN concept_name cn1 ON(obs.value_coded=cn1.concept_id AND cn1.locale='en' AND cn1.locale_preferred=1)
where patient.voided=0
GROUP BY patient.patient_id
HAVING 
TIMESTAMPDIFF(MONTH,MAX(IF(target.concept_id=164989,target.last_date, NULL)),curdate())<5
AND
TIMESTAMPDIFF(MONTH,MAX(IF(target.concept_id=159599,obs.obs_datetime, NULL)),curdate())>=6
AND
TIMESTAMPDIFF(MONTH,MAX(IF(target.concept_id=159951,obs.obs_datetime, NULL)),curdate())>=12
AND
(
(
TIMESTAMPDIFF(MONTH,MAX(IF(target.concept_id=856,target.last_date, NULL)),curdate())>=12
AND 
MAX(IF(target.concept_id=856,obs.value_numeric, NULL))<1000
)
OR
(
TIMESTAMPDIFF(MONTH,MAX(IF(target.concept_id=856,target.last_date, NULL)),curdate())>=3
AND 
MAX(IF(target.concept_id=856,obs.value_numeric, NULL))>1000
)
OR
MAX(IF(target.concept_id=856,obs.value_numeric, NULL)) IS NULL
)
