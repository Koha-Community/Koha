INSERT INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
('decreaseLoanHighHoldsControl', 'static', 'static|dynamic', "Chooses between static and dynamic high holds checking", 'Choice'),
('decreaseLoanHighHoldsIgnoreStatuses', '', 'damaged|itemlost|notforloan|withdrawn', "Ignore items with these statuses for dynamic high holds checking", 'Choice');
