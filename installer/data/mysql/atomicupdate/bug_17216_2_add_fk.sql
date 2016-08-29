INSERT IGNORE INTO authorised_value_categories( category_name ) SELECT DISTINCT(authorised_value) FROM marc_subfield_structure;

UPDATE marc_subfield_structure SET authorised_value = NULL WHERE authorised_value = ';';

ALTER TABLE marc_subfield_structure
    MODIFY COLUMN authorised_value VARCHAR(32) DEFAULT NULL,
    ADD CONSTRAINT marc_subfield_structure_ibfk_1 FOREIGN KEY (authorised_value) REFERENCES authorised_value_categories (category_name) ON UPDATE CASCADE ON DELETE SET NULL;
