DELETE FROM authorised_values WHERE category='SUGGEST';

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES 
('SUGGEST','BSELL','Бестселлер'),
('SUGGEST','SCD'  ,'Примірник з полиці пошкоджений'),
('SUGGEST','LCL'  ,'Бібліотечний примірник загублено'),
('SUGGEST','AVILL','Доступний через міжбібліотечний обмін');