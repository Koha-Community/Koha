ALTER TABLE aqorders ADD COLUMN created_by int(11) NULL DEFAULT NULL AFTER quantityreceived;
UPDATE aqorders, aqbasket SET aqorders.created_by = aqbasket.authorisedby  WHERE aqorders.basketno = aqbasket.basketno;
