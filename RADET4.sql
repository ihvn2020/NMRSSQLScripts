select 
  pid1.identifier as `Patient Unique ID/ART No`,
  pid2.identifier as  `Patient Hospital No`,
  person.gender as `Sex`,
MAX(IF(obs.concept_id=159599,IF(TIMESTAMPDIFF(YEAR,person.birthdate,obs.value_datetime)>=5,@ageAtStart:=TIMESTAMPDIFF(YEAR,person.birthdate,obs.value_datetime),@ageAtStart:=0),null)) as
  `Age at Start of ART(Years)`,
  MAX(IF(obs.concept_id=159599,IF(TIMESTAMPDIFF(YEAR,person.birthdate,obs.value_datetime)<5,TIMESTAMPDIFF(MONTH,person.birthdate,obs.value_datetime),null),null) ) as `Age at Start of ART(Months)`,
  MAX(IF(obs.concept_id=159599,DATE_FORMAT(obs.value_datetime,'%d-%b-%Y'),null)) as `ART Start Date`,
 MAX(IF(obs.concept_id=165708,DATE_FORMAT(sinner.last_date,'%d-%b-%Y'),null)) as `Last Pickup Date`,
  MAX(IF(obs.concept_id=159368,@daysOfARVRefill:=obs.value_numeric,@daysOfARVRefill:=0)) as `DaysOfARVRefil`,
 MAX(IF(obs2.concept_id=165708,cn2.name,null)) as `Regimen Line at ART Start`,
MAX(
   IF(obs2.concept_id=164506,cn2.`name`,
   IF(obs2.concept_id=164513,cn2.`name`,
   IF(obs2.concept_id=164507,cn2.name,
   IF(obs2.concept_id=164514,cn2.name,
   IF(obs2.concept_id=165702,cn2.name,
   IF(obs2.concept_id=165703,cn2.name,null
   ))))))) as `Regimen at ART Start`,
MAX(IF(obs.concept_id=165708,cn1.name,null) ) as `Current Regimen Line`,
MAX(IF(obs.concept_id in(
164506,164513,165702,164507,164514,165703) ,cn1.`name`,null)) as `Current ART Regimen`,
MAX(IF(obs.concept_id=165050,cn1.name,null)) as `Pregnancy Status`,
MAX(IF(obs.concept_id=856,obs.value_numeric,null)) as `Current Viral Load (c/ml)`,
MAX(IF(obs.concept_id=856,DATE_FORMAT(@lastViralLoadDate:=obs.obs_datetime,'%d-%b-%Y'),@lastViralLoadDate:=NULL)) as `Date of Current Viral Load (dd/mm/yy)`,
MAX(IF(obs.concept_id=164980,cn1.name,null) ) as `Viral Load Indication`,
MAX(IF(obs.concept_id=165470,cn1.name,IF(obs.concept_id=165708,IF(TIMESTAMPDIFF(DAY,sinner.last_date,:endDate)<=28+@daysOfARVRefill,"Active","LTFU"),null))) as `Current ART Status`,
IF(TIMESTAMPDIFF(YEAR,person.birthdate,curdate())>=5,TIMESTAMPDIFF(YEAR,person.birthdate,curdate()),null) as `CurrentAge(Years)`,
IF(TIMESTAMPDIFF(YEAR,person.birthdate,curdate())<5,TIMESTAMPDIFF(MONTH,person.birthdate,curdate()),null) as `CurrentAge(Months)`,
DATE_FORMAT(person.birthdate,'%d-%b-%Y') as `DateOfBirth`,
IF(person.dead=1,"Dead","") as MarkAsDeseased,
IF(person.dead=1,person.death_date,"") as MarkAsDeseasedDeathDate,
psn_atr.value AS RegistrationPhoneNo,
MAX(IF(obs.concept_id=169635,obs.value_text,null)) as `ContactPhoneNo`,
IF(biometrictable.patient_Id IS NOT NULL,'Yes','No') as BiometricCaptured,
MAX(IF(obs.concept_id=5089,obs.value_numeric,null)) as `CurrentWeight(Kg)`,
MAX(IF(obs.concept_id=1659,cn1.name,null)) as `TBStatus`,
MAX(IF(obs.concept_id=5089,DATE_FORMAT(obs.obs_datetime,'%d-%b-%Y'),null)) as `CurrentWeightDate`,
MAX(IF(obs.concept_id=165988,DATE_FORMAT(@lastSampleDate:=obs.value_datetime,'%d-%b-%Y'),NULL)) as `LastSpecimenCollectionDate`

  from patient
  LEFT JOIN person on(person.person_id=patient.patient_id and patient.voided=0)
  LEFT JOIN patient_identifier pid1 on(pid1.patient_id=patient.patient_id and patient.voided=0 and pid1.identifier_type=4)
  LEFT JOIN person_attribute psn_atr ON (person.person_id=psn_atr.person_id and psn_atr.person_attribute_type_id=8) 
  LEFT JOIN patient_identifier pid2 on(pid2.patient_id=patient.patient_id and patient.voided=0 and pid2.identifier_type=5)
  LEFT JOIN
  (select 
obs.person_id,
obs.concept_id,
 MAX(obs.obs_datetime) as last_date, 
MIN(obs.obs_datetime) as first_date
from obs where obs.voided=0 and obs.obs_datetime<=:endDate and concept_id in(159599,165708,159368,164506,164513,164507,164514,165702,165703,165050,
856,164980,165470,159635,5089,165988,1659) GROUP BY obs.person_id, obs.concept_id ) as sinner
on (sinner.person_id=patient.patient_id)
INNER JOIN obs on(obs.person_id=patient.patient_id and obs.concept_id=sinner.concept_id and obs.obs_datetime=sinner.last_date and obs.voided=0 )
INNER JOIN obs obs2 on(obs2.person_id=patient.patient_id and obs2.concept_id=sinner.concept_id and obs2.obs_datetime=sinner.first_date and obs2.voided=0)
left join concept_name cn1 on(obs.value_coded=cn1.concept_id and cn1.locale='en' and cn1.locale_preferred=1)
left join encounter enc on(enc.encounter_id=obs.encounter_id and encounter.voided=0 and obs.voided=0)
left join concept_name cn2 on(obs2.value_coded=cn2.concept_id and cn2.locale='en' and cn2.locale_preferred=1)
LEFT JOIN (
   select 
   DISTINCT biometricinfo.patient_Id
   from 
   biometricinfo
) as biometrictable 
on(patient.patient_id=biometrictable.patient_Id and patient.voided=0)
WHERE patient.voided=0 and obs.concept_id in(159599,165708,159368,164506,164513,164507,164514,165702,165703,165050,856,164980,165470,159635,159635,5089,165988,1659) and obs2.concept_id in(159599,165708,159368,164506,164513,164507,164514,165702,165703,165050,856,164980,165470,159635,159635,5089,165988,1659) GROUP BY patient.patient_id ;
