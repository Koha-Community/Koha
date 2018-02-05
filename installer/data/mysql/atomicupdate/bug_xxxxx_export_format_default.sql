ALTER TABLE export_format MODIFY csv_separator VARCHAR(2) NOT NULL DEFAULT ',', MODIFY field_separator VARCHAR(2), MODIFY subfield_separator VARCHAR(2);
ALTER TABLE export_format MODIFY encoding VARCHAR(255) DEFAULT 'utf8';

