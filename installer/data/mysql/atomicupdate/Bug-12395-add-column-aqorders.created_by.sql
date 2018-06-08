ALTER TABLE aqorders ADD COLUMN created_by int(11) NULL DEFAULT NULL AFTER quantityreceived;
ALTER TABLE aqorders ADD CONSTRAINT aqorders_created_by FOREIGN KEY (created_by) REFERENCES borrowers (borrowernumber) ON DELETE SET NULL ON UPDATE CASCADE;
UPDATE aqorders, aqbasket SET aqorders.created_by = aqbasket.authorisedby  WHERE aqorders.basketno = aqbasket.basketno;
