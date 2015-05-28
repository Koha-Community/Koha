-- table adjustments for uploaded_files
ALTER TABLE uploaded_files
    CHANGE COLUMN id hashvalue char(40) NOT NULL,
    DROP PRIMARY KEY;
ALTER TABLE uploaded_files
    ADD COLUMN id int NOT NULL AUTO_INCREMENT FIRST,
    ADD CONSTRAINT PRIMARY KEY (id),
    ADD COLUMN filesize int,
    ADD COLUMN dtcreated timestamp,
    ADD COLUMN categorycode tinytext,
    ADD COLUMN owner int;
