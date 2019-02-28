INSERT INTO account_debit_types ( code, description, can_be_added_manually, default_amount, is_system ) VALUES
('ACCOUNT', 'Account creation fee', 0, NULL, 1),
('ACCOUNT_RENEW', 'Account renewal fee', 0, NULL, 1),
('HE', 'Hold waiting too long', 0, NULL, 1),
('LOST', 'Lost item', 1, NULL, 1),
('M', 'Manual fee', 1, NULL, 0),
('N', 'New card fee', 1, NULL, 1),
('OVERDUE', 'Overdue fine', 0, NULL, 1),
('PF', 'Lost item processing fee', 0, NULL, 1),
('RENT', 'Rental fee', 0, NULL, 1),
('RENT_DAILY', 'Daily rental fee', 0, NULL, 1),
('RENT_RENEW', 'Renewal of rental item', 0, NULL, 1),
('RENT_DAILY_RENEW', 'Rewewal of daily rental item', 0, NULL, 1),
('Res', 'Hold fee', 0, NULL, 1);
