DELETE FROM authorised_values WHERE category='SUPPRESS';

-- TIP: Sometimes it's easier if you create an authorized value entitled 'SUPPRESS' with two values: 
--		  0 for don't suppress and 1 for suppress.  
-- Linking this authorized value to the 942$n field will make it so that catalogers can pick one of these two values.

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES 
	('SUPPRESS','0','Не приховувати в ЕК'),
	('SUPPRESS','1','Приховувати в ЕК');

