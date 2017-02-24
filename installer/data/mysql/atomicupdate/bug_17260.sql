ALTER TABLE search_field CHANGE COLUMN type type ENUM('', 'string', 'date', 'number', 'boolean', 'sum') NOT NULL COMMENT 'what type of data this holds, relevant when storing it in the search engine';
