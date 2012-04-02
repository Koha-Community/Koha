DELETE FROM authorised_values WHERE category='NOT_LOAN';

INSERT INTO authorised_values (category, authorised_value, lib) VALUES 
('NOT_LOAN','-1','Заказано'),
('NOT_LOAN','1', 'Не для займа'),
('NOT_LOAN','2', 'Собрание работника библиотеки'),
('NOT_LOAN','3', 'В переплете с другими'),
('NOT_LOAN','4', 'Недоступно');
