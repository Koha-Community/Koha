ALTER TABLE uploaded_files
    ADD COLUMN public tinyint,
    ADD COLUMN permanent tinyint;
-- Any records already there are public and permanent storage
UPDATE uploaded_files SET public=1, permanent=1;
