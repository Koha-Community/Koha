-- truncate message_attributes;

insert into message_attributes
 (message_attribute_id, message_name,     takes_days) values
 (1,                    'Item_Due'      , 0),
 (2,                    'Advance_Notice', 1),
 (4,                    'Hold_Filled'   , 0),
 (5,                    'Item_Check_in' , 0),
 (6,                    'Item_Checkout' , 0);
-- Наразі не перекладено (за прикладом інших мовних файлів)
-- (1, 'Одиниця заборгована'   , 0),
-- (2, 'Завчасне повідомлення',  1),
-- (4, 'Резервування виконано' , 0),
-- (5, 'Повернення примірника',  0),
-- (6, 'Видача примірника'     , 0);
