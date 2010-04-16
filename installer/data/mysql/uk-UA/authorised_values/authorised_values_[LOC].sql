DELETE FROM authorised_values WHERE category='LOC';

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES 
('LOC','FIC',    'Художня література'),
('LOC','SCIENCE','Науковий фонд'),
('LOC','CHILD',  'Дитяча область'),
('LOC','DISPLAY','На демонстрації'),
('LOC','NEW',    'Нова поличка матеріалів'),
('LOC','STAFF',  'Офіс працівників бібліотеки'),
('LOC','GEN',    'Загальні фонди'),
('LOC','AV',     'Аудіо-візуальні матеріали'),
('LOC','REF',    'Довідник');
