TRUNCATE z3950servers;

INSERT INTO `z3950servers` (`host`, `port`, `db`, `userid`, `password`, `name`, `id`, `checked`, `rank`, `syntax`, `icon`, `position`, `type`, `description`) 
VALUES ('z3950.bnf.fr', 2211, 'TOUT', 'Z3950', 'Z3950_BNF', 'BNF2', 2, 1, 2, 'UNIMARC', NULL, 'primary', 'zed', '');