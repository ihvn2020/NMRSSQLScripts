drop function if exists getconceptval;
drop function if exists getoutcome;
drop procedure if exists drugduration;
drop function if exists daysofarvrefil;
drop function if exists getdaysofarvrefil;

DELIMITER ;;
CREATE DEFINER=`openmrs`@`localhost` FUNCTION `getconceptval`(`obsid` int,`cid` int, pid int) RETURNS decimal(10,0)
BEGIN

	#Routine body goes here...

   DECLARE value_num INT;

    SELECT DISTINCT obs.value_numeric into value_num from obs WHERE  obs.obs_group_id is not null and obs.obs_group_id=obsid and obs.concept_id=cid and obs.person_id=pid and obs.voided=0 LIMIT 1;

	RETURN value_num;

END ;;
DELIMITER ;

DELIMITER ;;
CREATE DEFINER=`openmrs`@`localhost` FUNCTION `getdaysofarvrefil`(`obsid` numeric,`obsgroupid` numeric,`valuenumeric` numeric) RETURNS decimal(10,0)
BEGIN

	#Routine body goes here...

DECLARE ans NUMERIC;


IF obsid=obsgroupid THEN

        SET ans = valuenumeric;

ELSE

         SET ans = null;

END IF;

RETURN ans;

END ;;
DELIMITER ;

DELIMITER ;;
CREATE DEFINER=`openmrs`@`localhost` FUNCTION `getoutcome`(`lastpickupdate` date,`daysofarvrefill` numeric,`ltfudays` numeric, `enddate` date) RETURNS text CHARSET utf8
BEGIN

DECLARE  ltfudate DATE;

DECLARE  ltfunumber NUMERIC;

DECLARE  daysdiff NUMERIC;

DECLARE outcome text;

SET ltfunumber=daysofarvrefill+ltfudays;

SELECT DATE_ADD(lastpickupdate, INTERVAL ltfunumber DAY) INTO ltfudate;

SELECT DATEDIFF(ltfudate,enddate) into daysdiff;

SELECT IF(daysdiff >=0,"Active","LTFU") into outcome;

RETURN outcome;

END ;;
DELIMITER ;

DELIMITER ;;
CREATE DEFINER=`openmrs`@`localhost` PROCEDURE `drugduration`(IN `enddate` date)
BEGIN

	#Routine body goes here...

drop table if exists arvmedication;

create   table  arvmedication as 

select  DISTINCT obs.person_id, obs.obs_id from obs where concept_id=162240 and voided=0 and obs.obs_datetime <=enddate

GROUP BY obs.person_id,obs.concept_id ORDER BY  obs.obs_datetime DESC;

CREATE  INDEX pid ON arvmedication(person_id);



END ;;
DELIMITER ;

