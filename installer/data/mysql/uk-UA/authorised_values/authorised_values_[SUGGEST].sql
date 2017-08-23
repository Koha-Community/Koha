-- DELETE FROM authorised_values WHERE category='SUGGEST';

-- Reasons for acceptance or rejection of suggestions in acquisitions
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES
 ('SUGGEST','BSELL', 'Бестселлер'),
 ('SUGGEST','SCD',   'Примірник з полиці пошкоджений'),
 ('SUGGEST','LCL',   'Бібліотечний примірник загублено'),
 ('SUGGEST','AVILL', 'Доступний через міжбібліотечний обмін'),
 ('SUGGEST','POLDOC','Примірник, що не відповідає нашим правилам щодо придбання'),
 ('SUGGEST','COST',  'Занадто дорогий примірник'),
 ('SUGGEST','BUDGET','Недостатній бюджет');

