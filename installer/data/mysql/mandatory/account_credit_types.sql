INSERT INTO account_credit_types ( code, description, can_be_added_manually, is_system ) VALUES
('OVERPAYMENT', 'Overpayment refund', 0, 1),
('PAYMENT', 'Payment', 0, 1),
('WRITEOFF', 'Writeoff', 0, 1),
('FORGIVEN', 'Forgiven', 1, 1),
('CREDIT', 'Credit', 1, 1),
('DISCOUNT', 'A discount applied to a patrons fine', 0, 1),
('REFUND', 'Refund', 0, 1),
('LOST_FOUND', 'Lost item fee refund', 0, 1),
('PURCHASE', 'Purchase', 0, 1),
('CANCELLATION', 'Cancellation', 0, 1);

INSERT INTO authorised_values (category,authorised_value,lib) VALUES ('PAYMENT_TYPE','CASH','Cash');
