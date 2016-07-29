ALTER TABLE reviews CHANGE COLUMN approved approved tinyint(4) DEFAULT 0;
UPDATE reviews SET approved=0 WHERE approved IS NULL;
