ALTER TABLE patron_lists ADD COLUMN shared tinyint(1) default 0 AFTER owner;
