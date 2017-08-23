-- Status of item borrowing posibilities, instance associated with items.notforloan.

-- DELETE FROM authorised_values WHERE category='NOT_LOAN';

-- loanability status of an item, linked to items.notforloan
INSERT INTO authorised_values (category, authorised_value, lib) VALUES
 ('NOT_LOAN','-1','замовлено'),
 ('NOT_LOAN','1', 'не для випожичання'),
 ('NOT_LOAN','2', 'зібрання працівника бібліотеки'),
 ('NOT_LOAN','3', 'у переплетенні'),
 ('NOT_LOAN','4', 'недоступно'),
 ('NOT_LOAN','5', 'в обробці'),
 ('NOT_LOAN','6', 'не повідомляється');

