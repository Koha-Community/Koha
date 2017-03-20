ALTER TABLE export_format ADD used_for varchar(255) DEFAULT 'export_records' AFTER type;

UPDATE export_format SET used_for = 'late_issues' WHERE type = 'sql';
UPDATE export_format SET used_for = 'export_records' WHERE type = 'marc';
