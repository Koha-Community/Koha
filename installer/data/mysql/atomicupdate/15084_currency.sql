ALTER TABLE suggestions
    MODIFY COLUMN currency varchar(10) default NULL;
ALTER TABLE aqbooksellers
    MODIFY COLUMN currency varchar(10) default NULL;
