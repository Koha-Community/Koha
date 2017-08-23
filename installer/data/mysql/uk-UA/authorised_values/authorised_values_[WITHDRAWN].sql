-- DELETE FROM authorised_values WHERE category='WITHDRAWN';

-- withdrawn status of an item, linked to items.withdrawn
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES
 ('WITHDRAWN', '1', 'Вилучено з обігу');
-- INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('WITHDRAWN','0','Не вилучено');

