update encounter
INNER JOIN visit on(DATE(visit.date_started)=DATE(encounter.encounter_datetime) AND visit.patient_id=encounter.patient_id AND visit.voided=0)
set encounter.visit_id=visit.visit_id
where 
encounter.visit_id is null 
and encounter.voided=0 and visit.voided=0;

insert into visit
(
patient_id,
visit_type_id,
date_started,
date_stopped,
location_id,
creator,
date_created,
uuid
)
select
encounter.patient_id,
1,
DATE(encounter.encounter_datetime),
DATE(encounter.encounter_datetime),
encounter.location_id,
encounter.creator,
encounter.date_created,
uuid()
from encounter 
where 
encounter.visit_id is null
and 
voided=0;

update encounter
INNER JOIN visit on(DATE(visit.date_started)=DATE(encounter.encounter_datetime) AND visit.patient_id=encounter.patient_id AND visit.voided=0)
set encounter.visit_id=visit.visit_id
where 
encounter.visit_id is null 
and encounter.voided=0 and visit.voided=0;