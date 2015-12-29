ALTER TABLE issuingrules ADD COLUMN holds_per_record SMALLINT(6) NOT NULL DEFAULT 1 AFTER reservesallowed;
