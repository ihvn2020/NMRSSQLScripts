SET @sn:=0;
SELECT  (@sn:=@sn+1) AS 'S/N',
gp1.property_value as DatimCode,
gp2.property_value as FacilityName,
IFNULL(patid.identifier,'') as 'PEPFARId',
IFNULL(recid.identifier,'') as 'RecencyID',
MAX(IF(pidentifier.identifier_type=5,  pidentifier.identifier,'')) 'HospitalNo',
person.gender AS 'Sex',
DATE_FORMAT(person.birthdate,'%d/%m/%Y') AS 'DateofBirth',
MIN(DATE_FORMAT(art_date.value_datetime,'%d-%b-%Y')) AS 'artStartDate',
pad.address1 as 'Address1',
pad.address2 as 'Address2',
pad.city_village as 'City',
pad.state_province as 'State',
ahe.name as 'keyCity',
ahe2.name as 'keyState'

FROM patient pat
LEFT JOIN  (SELECT patient_identifier.patient_id, patient_identifier.identifier, identifier_type FROM patient_identifier)
AS pidentifier ON (pidentifier.patient_id = pat.patient_id)
INNER JOIN person ON(person.person_id=pat.patient_id)
LEFT JOIN (SELECT person_id AS person_id, MIN(value_datetime) AS value_datetime FROM obs
WHERE  obs.concept_id=159599 AND obs.voided = 0 GROUP BY person_id)
AS art_date ON (art_date.person_id = pat.patient_id)   
LEFT JOIN person_address pad on(pad.person_id=pat.patient_id)
LEFT JOIN address_hierarchy_entry ahe on(ahe.name=pad.city_village)
LEFT JOIN address_hierarchy_entry ahe2 on(ahe2.name=pad.state_province)
LEFT JOIN patient_identifier patid on(patid.patient_id=pat.patient_id and pat.voided=0 and patid.identifier_type=4 and patid.voided=0)
LEFT JOIN patient_identifier recid on(recid.patient_id=pat.patient_id and pat.voided=0 and recid.identifier_type=10 and recid.voided=0)
LEFT JOIN global_property gp1 on(gp1.property='facility_datim_code')
LEFT JOIN global_property gp2 on(gp2.property='Facility_Name')
where pat.voided=0 and patid.identifier IS NOT NULL OR recid.identifier IS NOT NULL GROUP BY pat.patient_id