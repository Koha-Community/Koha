DELETE FROM authorised_values WHERE category='NOT_LOAN';

INSERT INTO authorised_values (category, authorised_value, lib) VALUES 
('NOT_LOAN','-1','Замовлено'),
('NOT_LOAN','1', 'Не для випожичання'),
('NOT_LOAN','2', 'Зібрання працівника бібліотеки'),
('NOT_LOAN','3', 'У зшитку'),
('NOT_LOAN','4', 'Недоступно');
