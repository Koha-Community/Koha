SET FOREIGN_KEY_CHECKS=0;

INSERT INTO `currency` (currency, rate, symbol, active) VALUES
('USD', 1.4, '$', 0),
('GBP', .8, '£', 0),
('EUR', 1, '€', 1);

SET FOREIGN_KEY_CHECKS=1;
