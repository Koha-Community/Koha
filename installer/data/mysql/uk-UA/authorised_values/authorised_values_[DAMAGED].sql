-- Item damage status.

-- DELETE FROM authorised_values WHERE category='DAMAGED';

-- damaged status of an item
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES
 ('DAMAGED','1','Пошкоджено');
-- INSERT INTO authorised_values  (category, authorised_value, lib) VALUES ('DAMAGED','0','Не ушкоджено');

