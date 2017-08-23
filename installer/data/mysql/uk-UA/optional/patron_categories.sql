-- Default classification sources and filing rules for Koha.

-- TRUNCATE categories;

-- Повнолітні відвідувачі

INSERT INTO categories (categorycode, description, enrolmentperiod, upperagelimit, dateofbirthrequired, finetype, bulk, enrolmentfee, overduenoticerequired, issuelimit, reservefee, category_type) VALUES
(            'HB',                  'Відвідувачі, що знаходяться вдома',                99,              999,                    18,         NULL,     NULL,             '0.000000',                      1,           NULL,           '0.000000',              'A')
ON DUPLICATE KEY UPDATE description='Відвідувачі, що знаходяться вдома',enrolmentperiod=99,upperagelimit=999,dateofbirthrequired=18,finetype=NULL,bulk=NULL,enrolmentfee='0.000000',overduenoticerequired=1,issuelimit=NULL,reservefee='0.000000',category_type='A';

INSERT INTO categories (categorycode, description, enrolmentperiod, upperagelimit, dateofbirthrequired, finetype, bulk, enrolmentfee, overduenoticerequired, issuelimit, reservefee, category_type) VALUES
(            'ST',                  'Студент',                99,              999,                    18,         NULL,     NULL,             '0.000000',                      1,           NULL,           '0.000000',              'A')
ON DUPLICATE KEY UPDATE description='Студент',enrolmentperiod=99,upperagelimit=999,dateofbirthrequired=18,finetype=NULL,bulk=NULL,enrolmentfee='0.000000',overduenoticerequired=1,issuelimit=NULL,reservefee='0.000000',category_type='A';

INSERT INTO categories (categorycode, description, enrolmentperiod, upperagelimit, dateofbirthrequired, finetype, bulk, enrolmentfee, overduenoticerequired, issuelimit, reservefee, category_type) VALUES
(            'PT',                  'Відвідувач',                99,              999,                    18,         NULL,     NULL,             '0.000000',                      1,           NULL,           '0.000000',              'A')
ON DUPLICATE KEY UPDATE description='Відвідувач',enrolmentperiod=99,upperagelimit=999,dateofbirthrequired=18,finetype=NULL,bulk=NULL,enrolmentfee='0.000000',overduenoticerequired=1,issuelimit=NULL,reservefee='0.000000',category_type='A';

INSERT INTO categories (categorycode, description, enrolmentperiod, upperagelimit, dateofbirthrequired, finetype, bulk, enrolmentfee, overduenoticerequired, issuelimit, reservefee, category_type) VALUES
(            'EXT',                  'Міжвузівський читач',                99,              999,                    18,         NULL,     NULL,             '0.000000',                      1,           NULL,           '0.000000',              'A')
ON DUPLICATE KEY UPDATE description='Міжвузівський читач',enrolmentperiod=99,upperagelimit=999,dateofbirthrequired=18,finetype=NULL,bulk=NULL,enrolmentfee='0.000000',overduenoticerequired=1,issuelimit=NULL,reservefee='0.000000',category_type='A';

INSERT INTO categories (categorycode, description, enrolmentperiod, upperagelimit, dateofbirthrequired, finetype, bulk, enrolmentfee, overduenoticerequired, issuelimit, reservefee, category_type) VALUES
(            'TEMP',                  'Тимчасовий читач',                1,              999,                    18,         NULL,     NULL,             '0.000000',                      1,           NULL,           '0.000000',              'A')
ON DUPLICATE KEY UPDATE description='Тимчасовий читач',enrolmentperiod=1,upperagelimit=999,dateofbirthrequired=18,finetype=NULL,bulk=NULL,enrolmentfee='0.000000',overduenoticerequired=1,issuelimit=NULL,reservefee='0.000000',category_type='A';

INSERT INTO categories (categorycode, description, enrolmentperiod, upperagelimit, dateofbirthrequired, finetype, bulk, enrolmentfee, overduenoticerequired, issuelimit, reservefee, category_type) VALUES
(            'ASP',                  'Аспірант',                99,              999,                    18,         NULL,     NULL,             '0.000000',                      1,           NULL,           '0.000000',              'A')
ON DUPLICATE KEY UPDATE description='Аспірант',enrolmentperiod=99,upperagelimit=999,dateofbirthrequired=18,finetype=NULL,bulk=NULL,enrolmentfee='0.000000',overduenoticerequired=1,issuelimit=NULL,reservefee='0.000000',category_type='A';


-- Діти

INSERT INTO categories (categorycode, description, enrolmentperiod, upperagelimit, dateofbirthrequired, finetype, bulk, enrolmentfee, overduenoticerequired, issuelimit, reservefee, category_type) VALUES
(            'J',                   'Неповнолітній',                99,              17,                    5,         NULL,     NULL,             '0.000000',                      1,           NULL,           '0.000000',              'C')
ON DUPLICATE KEY UPDATE description='Неповнолітній',enrolmentperiod=99,upperagelimit=17,dateofbirthrequired=5,finetype=NULL,bulk=NULL,enrolmentfee='0.000000',overduenoticerequired=1,issuelimit=NULL,reservefee='0.000000',category_type='C';

INSERT INTO categories (categorycode, description, enrolmentperiod, upperagelimit, dateofbirthrequired, finetype, bulk, enrolmentfee, overduenoticerequired, issuelimit, reservefee, category_type) VALUES
(            'K',                   'Дитина',                99,              17,                    5,         NULL,     NULL,             '0.000000',                      1,           NULL,           '0.000000',              'C')
ON DUPLICATE KEY UPDATE description='Дитина',enrolmentperiod=99,upperagelimit=17,dateofbirthrequired=5,finetype=NULL,bulk=NULL,enrolmentfee='0.000000',overduenoticerequired=1,issuelimit=NULL,reservefee='0.000000',category_type='C';

INSERT INTO categories (categorycode, description, enrolmentperiod, upperagelimit, dateofbirthrequired, finetype, bulk, enrolmentfee, overduenoticerequired, issuelimit, reservefee, category_type) VALUES
(            'YA',                  'Юнак',                99,              17,                    5,         NULL,     NULL,             '0.000000',                      1,           NULL,           '0.000000',              'C')
ON DUPLICATE KEY UPDATE description='Юнак',enrolmentperiod=99,upperagelimit=17,dateofbirthrequired=5,finetype=NULL,bulk=NULL,enrolmentfee='0.000000',overduenoticerequired=1,issuelimit=NULL,reservefee='0.000000',category_type='C';


-- Член колективу, організації, об’єднання

INSERT INTO categories (categorycode, description, enrolmentperiod, upperagelimit, dateofbirthrequired, finetype, bulk, enrolmentfee, overduenoticerequired, issuelimit, reservefee, category_type) VALUES
(            'B',                   'Рада',                99,              17,                    5,         NULL,     NULL,             '0.000000',                      1,           NULL,           '0.000000',              'P')
ON DUPLICATE KEY UPDATE description='Рада',enrolmentperiod=99,upperagelimit=17,dateofbirthrequired=5,finetype=NULL,bulk=NULL,enrolmentfee='0.000000',overduenoticerequired=1,issuelimit=NULL,reservefee='0.000000',category_type='P';

INSERT INTO categories (categorycode, description, enrolmentperiod, upperagelimit, dateofbirthrequired, finetype, bulk, enrolmentfee, overduenoticerequired, issuelimit, reservefee, category_type) VALUES
(            'T',                   'Викладач',                99,              999,                    18,         NULL,     NULL,             '0.000000',                      0,           NULL,           '0.000000',              'P')
ON DUPLICATE KEY UPDATE description='Викладач',enrolmentperiod=99,upperagelimit=999,dateofbirthrequired=18,finetype=NULL,bulk=NULL,enrolmentfee='0.000000',overduenoticerequired=0,issuelimit=NULL,reservefee='0.000000',category_type='P';


-- Колектив, організація, об’єднання

INSERT INTO categories (categorycode, description, enrolmentperiod, upperagelimit, dateofbirthrequired, finetype, bulk, enrolmentfee, overduenoticerequired, issuelimit, reservefee, category_type) VALUES
(            'IL',                  'Міжбібліотечний обмін (колектив)',                99,              999,                    18,         NULL,     NULL,             '0.000000',                      1,           NULL,           '0.000000',              'I')
ON DUPLICATE KEY UPDATE description='Міжбібліотечний обмін (колектив)',enrolmentperiod=99,upperagelimit=999,dateofbirthrequired=18,finetype=NULL,bulk=NULL,enrolmentfee='0.000000',overduenoticerequired=1,issuelimit=NULL,reservefee='0.000000',category_type='I';

INSERT INTO categories (categorycode, description, enrolmentperiod, upperagelimit, dateofbirthrequired, finetype, bulk, enrolmentfee, overduenoticerequired, issuelimit, reservefee, category_type) VALUES
(            'SC',                  'Школа (колектив)',                99,              999,                    18,         NULL,     NULL,             '0.000000',                      1,           NULL,           '0.000000',              'I')
ON DUPLICATE KEY UPDATE description='Школа (колектив)',enrolmentperiod=99,upperagelimit=999,dateofbirthrequired=18,finetype=NULL,bulk=NULL,enrolmentfee='0.000000',overduenoticerequired=1,issuelimit=NULL,reservefee='0.000000',category_type='I';


INSERT INTO categories (categorycode, description, enrolmentperiod, upperagelimit, dateofbirthrequired, finetype, bulk, enrolmentfee, overduenoticerequired, issuelimit, reservefee, category_type) VALUES
(            'L',                   'Бібліотека (колектив)',                99,              999,                    18,         NULL,     NULL,             '0.000000',                      1,           NULL,           '0.000000',              'I')
ON DUPLICATE KEY UPDATE description='Бібліотека (колектив)',enrolmentperiod=99,upperagelimit=999,dateofbirthrequired=18,finetype=NULL,bulk=NULL,enrolmentfee='0.000000',overduenoticerequired=1,issuelimit=NULL,reservefee='0.000000',category_type='I';


-- Працівник бібліотеки

INSERT INTO categories (categorycode, description, enrolmentperiod, upperagelimit, dateofbirthrequired, finetype, bulk, enrolmentfee, overduenoticerequired, issuelimit, reservefee, category_type) VALUES
(            'S',                   'Персонал бібліотеки',                99,              999,                    18,         NULL,     NULL,             '0.000000',                      0,           NULL,           '0.000000',              'S')
ON DUPLICATE KEY UPDATE description='Персонал бібліотеки',enrolmentperiod=99,upperagelimit=999,dateofbirthrequired=18,finetype=NULL,bulk=NULL,enrolmentfee='0.000000',overduenoticerequired=0,issuelimit=NULL,reservefee='0.000000',category_type='S';
