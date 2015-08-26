ALTER TABLE virtualshelves CHANGE COLUMN sortfield sortfield VARCHAR(16) DEFAULT 'title';

UPDATE virtualshelves SET sortfield='title' WHERE sortfield IS NULL;
