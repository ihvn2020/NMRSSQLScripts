select 
global_property.property_value as DatimCode,
pid1.identifier as `PatientUniqueID`,
pid2.identifier as  `PatientHospitalNo`,
person.gender as `Sex`,
MAX(IF(obs.concept_id=159599,IF(TIMESTAMPDIFF(YEAR,person.birthdate,obs.value_datetime)>=5,TIMESTAMPDIFF(YEAR,person.birthdate,obs.value_datetime),@ageAtStart:=0),null)) as  `AgeAtStartOfARTYears`,
MAX(IF(obs.concept_id=159599,IF(TIMESTAMPDIFF(YEAR,person.birthdate,obs.value_datetime)<5,TIMESTAMPDIFF(MONTH,person.birthdate,obs.value_datetime),null),null)) as `AgeAtStartOfARTMonths`,
MAX(IF(obs.concept_id=165242,cn1.name,null)) as TransferInStatus,
MAX(IF(obs.concept_id=159599,DATE_FORMAT(obs.value_datetime,'%d-%b-%Y'),null)) as `ARTStartDate`,
MAX(IF((obs.concept_id=165708 and enc.form_id=27),DATE_FORMAT(sinner.last_date,'%d-%b-%Y'),null)) as `LastPickupDate`,
getconceptval(MAX(IF(obs.concept_id=162240,obs.obs_id,null) ),159368,patient.patient_id) as `DaysOfARVRefil`,
MAX(IF(obs2.concept_id=165708,cn2.name,null)) as `InitialRegimenLine`,
MAX(IF(obs2.concept_id in(164506,164507), cn2.name,null)) as `InitialFirstLineRegimen`,
MAX(IF(obs2.concept_id in(164506,164507), obs2.obs_datetime,null)) as `InitialFirstLineRegimenDate`,
MAX(IF(obs2.concept_id in(164513,164514), cn2.name,null)) as `InitialSecondLineRegimen`,
MAX(IF(obs2.concept_id in(164513,164514), obs2.obs_datetime,null)) as `InitialSecondLineRegimenDate`,
MAX(IF((obs.concept_id=165708 and enc.form_id=27),cn1.name,null)) as `CurrentRegimenLine`,
MAX(IF((obs.concept_id in(164506,164507) and enc.form_id=27), cn1.name,null)) as `CurrentFirstLineRegimen`,
MAX(IF((obs.concept_id in(164506,164507) and enc.form_id=27), obs.obs_datetime,null)) as `CurrentFirstLineRegimenDate`,
MAX(IF((obs.concept_id in(164513,164514) and enc.form_id=27), cn1.name,null)) as `CurrentSecondLineRegimen`,
MAX(IF((obs.concept_id in(164513,164514) and enc.form_id=27), obs.obs_datetime,null)) as `CurrentSecondLineRegimenDate`,
MAX(IF((obs.concept_id=165050 AND person.gender='F'),cn1.name,null)) as `PregnancyStatus`,
MAX(IF(obs.concept_id=856,obs.value_numeric,null)) as `CurrentViralLoad(c/ml)`,
MAX(IF(obs.concept_id=856,DATE_FORMAT(obs.obs_datetime,'%d-%b-%Y'),NULL)) as `ViralLoadSampleCollectionDate`,
IF(

MAX(IF(obs.concept_id=856,obs.value_numeric,NULL)) is not null,

MAX(IF(obs.concept_id=165414,DATE_FORMAT(obs.value_datetime,'%d-%b-%Y'),null)),

null

) as `ViralLoadReportedDate`,

IF(
MAX(IF(obs.concept_id=856,obs.value_numeric,NULL)) is not null,
MAX(IF(obs.concept_id=164980,cn1.name,null)),
null

) as `ViralLoadIndication`,

IFNULL(MAX(IF(obs.concept_id=165470,cn1.name,null)) ,
getoutcome(
MAX(IF((obs.concept_id=165708 and enc.form_id=27),sinner.last_date,null)),
getconceptval(MAX(IF(obs.concept_id=162240,obs.obs_id,null) ),159368,patient.patient_id) ,
28,
IF(:endDate IS NULL or :endDate = '', CURDATE(),:endDate)
) ) as `CurrentARTStatus`,
IF(TIMESTAMPDIFF(YEAR,person.birthdate,curdate())>=5,TIMESTAMPDIFF(YEAR,person.birthdate,curdate()),null) as `CurrentAgeYears`,
IF(TIMESTAMPDIFF(YEAR,person.birthdate,curdate())<5,TIMESTAMPDIFF(MONTH,person.birthdate,curdate()),null) as `CurrentAgeMonths`,
DATE_FORMAT(person.birthdate,'%d-%b-%Y') as `DateOfBirth`,
IF(person.dead=1,"Dead","") as MarkAsDeseased,
IF(person.dead=1,person.death_date,"") as MarkAsDeseasedDeathDate,
CONCAT("+234-",psn_atr.value) AS RegistrationPhoneNo,
MAX(IF(obs.concept_id=159635,CONCAT("+234-",obs.value_text),null)) as `ContactPhoneNo`,
IF(biometrictable.patient_Id IS NOT NULL,'Yes','No') as BiometricCaptured,
MAX(IF(obs.concept_id=5089,obs.value_numeric,null)) as `CurrentWeight(Kg)`,
MAX(IF(obs.concept_id=5089,DATE_FORMAT(obs.obs_datetime,'%d-%b-%Y'),null)) as `CurrentWeightDate`,
MAX(IF(obs.concept_id=1659,cn1.name,null)) as `TBStatus`,
MAX(IF(obs.concept_id=1659,DATE_FORMAT(obs.obs_datetime,'%d-%b-%Y'),null)) as `TBStatusDate`,
MAX(IF(obs.concept_id=164852,cn1.name,null)) as `INHStartDate`,
MAX(IF(obs.concept_id=166096,cn1.name,null)) as `INHStopDate`,
MAX(IF(obs.concept_id=165727 AND obs.value_coded=1679,obs.obs_datetime,null)) as LastINHDispensedDate,
MAX(IF(obs.concept_id=1113,cn1.name,null)) as `TBTreatmentStartDate`,
MAX(IF(obs.concept_id=159431,cn1.name,null)) as `TBTreatmentStopDate`,
MAX(IF(enc.form_id=67, DATE_FORMAT(@lastSampleDate:=enc.encounter_datetime,'%d-%b-%Y'),NULL)) as `LastViralLoadSampleCollectionFormDate`,
MAX(IF(obs.concept_id=166156,DATE_FORMAT(obs.value_datetime,'%d-%b-%Y'),null)) as `OTZStartDate`,
MAX(IF(obs.concept_id=166158,DATE_FORMAT(obs.value_datetime,'%d-%b-%Y'),null)) as `OTZStopDate`,
DATE_FORMAT(pprg.date_enrolled,'%d-%b-%Y') as EnrollmentDate

  from patient
  LEFT JOIN person on(person.person_id=patient.patient_id and patient.voided=0)
  LEFT JOIN patient_identifier pid1 on(pid1.patient_id=patient.patient_id and patient.voided=0 and pid1.identifier_type=4 and pid1.voided=0)
  LEFT JOIN person_attribute psn_atr ON (person.person_id=psn_atr.person_id and psn_atr.person_attribute_type_id=8) 
  LEFT JOIN patient_program pprg on(pprg.patient_id=patient.patient_id and pprg.voided=0 and patient.voided=0 and pprg.program_id=1)
  LEFT JOIN patient_identifier pid2 on(pid2.patient_id=patient.patient_id and patient.voided=0 and pid2.identifier_type=5 and pid2.voided=0)
  LEFT JOIN
  (select 
obs.person_id,
obs.concept_id,
 MAX(obs.obs_datetime) as last_date, 
MIN(obs.obs_datetime) as first_date
from obs where obs.voided=0 and obs.obs_datetime<=:endDate and concept_id in(159599,165708,159368,164506,164513,164507,164514,165702,165703,165050,
856,164980,165470,159635,5089,165988,1659,164852,166096,1113,159431,162240,165242,165724,166156,166158,165727,164982,165414) GROUP BY obs.person_id, obs.concept_id) as sinner on (sinner.person_id=patient.patient_id and patient.voided=0)
INNER JOIN obs on(obs.person_id=patient.patient_id and obs.concept_id=sinner.concept_id and obs.obs_datetime=sinner.last_date and obs.voided=0 and obs.obs_datetime<=:endDate)
INNER JOIN obs obs2 on(obs2.person_id=patient.patient_id and obs2.concept_id=sinner.concept_id and obs2.obs_datetime=sinner.first_date and obs2.voided=0 and obs2.obs_datetime<=:endDate)
LEFT join encounter enc on(enc.encounter_id=obs.encounter_id and enc.voided=0 and obs.voided=0)
left join concept_name cn1 on(obs.value_coded=cn1.concept_id and cn1.locale='en' and cn1.locale_preferred=1)
left join concept_name cn2 on(obs2.value_coded=cn2.concept_id and cn2.locale='en' and cn2.locale_preferred=1)
LEFT JOIN (
   select 
   DISTINCT biometricinfo.patient_Id
   from 
   biometricinfo
) as biometrictable 
on(patient.patient_id=biometrictable.patient_Id and patient.voided=0)
LEFT JOIN global_property on(global_property.property='facility_datim_code')
WHERE patient.voided=0 
GROUP BY patient.patient_id ;
