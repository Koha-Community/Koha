-- Item restrict access status associated with items.restricted.

-- DELETE FROM authorised_values WHERE category='RESTRICTED';

-- restricted status of an item, linked to items.restricted
INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES
 ('RESTRICTED','1','доступ обмежений');
--INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('RESTRICTED','0','немає обмежень');

