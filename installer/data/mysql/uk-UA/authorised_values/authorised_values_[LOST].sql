-- Availability status.

-- DELETE FROM authorised_values WHERE category='LOST';

-- availability statuses
INSERT INTO authorised_values (category, authorised_value, lib) VALUES
 ('LOST','1','Втрачено'),
 ('LOST','2','Тривале прострочення (втрачено)'),
 ('LOST','3','Втрачено і заплачено за примірник'),
 ('LOST','4','Відсутнє при інвентаризації'),
 ('LOST','5','Відсутнє при запиті на резервування');
-- INSERT INTO authorised_values (category, authorised_value, lib) VALUES ('LOST','0','Не втрачено');

