INSERT INTO account_debit_types ( code, description, can_be_added_manually, is_system ) VALUES
('Pay', 'Payment', 0, 1),
('PAY', 'Payment', 0, 1),
('W', 'Writeoff', 0, 1),
('WO', 'Writeoff', 0, 1),
('FORGIVEN', 'Forgiven', 1, 1),
('CREDIT', 'Credit', 1, 1),
('LOST_RETURN', 'Lost item fee refund', 0, 1);
