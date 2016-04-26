ALTER TABLE edifact_messages
  DROP FOREIGN KEY emfk_vendor,
  DROP FOREIGN KEY emfk_edi_acct,
  DROP FOREIGN KEY emfk_basketno;

ALTER TABLE edifact_messages
  ADD CONSTRAINT emfk_vendor FOREIGN KEY ( vendor_id ) REFERENCES aqbooksellers ( id ) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT emfk_edi_acct FOREIGN KEY ( edi_acct ) REFERENCES vendor_edi_accounts ( id ) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT emfk_basketno FOREIGN KEY ( basketno ) REFERENCES aqbasket ( basketno ) ON DELETE CASCADE ON UPDATE CASCADE;
