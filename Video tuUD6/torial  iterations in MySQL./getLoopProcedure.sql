CREATE DEFINER=`root`@`localhost` PROCEDURE `getLoopProcedure`()

BEGIN

 -- I do the declares, important doing them before of all

 DECLARE x INT ; -- 

 DECLARE string_value varchar(20);

 -- I give initial values to them 

 SET x=1;-- 

 SET string_value =""; -- 

 -- I BEGIN THE WHILE

 WHILE x <=5 DO

 SET string_value = CONCAT(string_value,x," , ");

 SET x=x+1;

 END WHILE;

 SELECT string_value;

END
