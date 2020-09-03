-- ----------------------------
-- Function structure for getreporteddate
-- ----------------------------
DROP FUNCTION IF EXISTS `getreporteddate`;
DELIMITER ;;
CREATE DEFINER=`openmrs`@`localhost` FUNCTION `getreporteddate`(`encounter_id` int,`reporteddateconcept_id` int,`patientid` int) RETURNS date
BEGIN
	#Routine body goes here...
DECLARE val_date date;
select obs.value_datetime into val_date from obs where 
concept_id=reporteddateconcept_id 
and
obs.encounter_id=encounter_id
and
obs.person_id=patientid
and
voided=0 LIMIT 1;
RETURN val_date;
END
;;
DELIMITER ;
