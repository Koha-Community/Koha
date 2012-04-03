DELETE FROM authorised_values WHERE category='LOST';

INSERT INTO authorised_values (id, category, authorised_value, lib) VALUES (LAST_INSERT_ID( ) + 0,'LOST','2','Длительная просрочка (утрачено)');
INSERT INTO authorised_values (id, category, authorised_value, lib) VALUES (LAST_INSERT_ID( ) + 1,'LOST','1','Утрачено');
INSERT INTO authorised_values (id, category, authorised_value, lib) VALUES (LAST_INSERT_ID( ) + 2,'LOST','3','Потеряны и заплачено за экземпляр');
INSERT INTO authorised_values (id, category, authorised_value, lib) VALUES (LAST_INSERT_ID( ) + 3,'LOST','5','Отсутствует при запросе на резервирование');
INSERT INTO authorised_values (id, category, authorised_value, lib) VALUES (LAST_INSERT_ID( ) + 4,'LOST','4','Отсутствует при инвентиризации');

