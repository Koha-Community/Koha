CREATE TABLE authorised_value_categories (
    category_name VARCHAR(32) NOT NULL,
    primary key (category_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci ;

-- Add authorised value categories
INSERT INTO authorised_value_categories (category_name )
    SELECT DISTINCT category FROM authorised_values;

-- Add special categories
INSERT IGNORE INTO authorised_value_categories( category_name )
    VALUES
    ('Asort1'),
    ('Asort2'),
    ('Bsort1'),
    ('Bsort2'),
    ('SUGGEST'),
    ('DAMAGED'),
    ('LOST'),
    ('REPORT_GROUP'),
    ('REPORT_SUBGROUP'),
    ('DEPARTMENT'),
    ('TERM'),
    ('SUGGEST_STATUS'),
    ('ITEMTYPECAT');

-- Add very special categories
INSERT IGNORE INTO authorised_value_categories( category_name )
    VALUES
    ('branches'),
    ('itemtypes'),
    ('cn_source');

INSERT IGNORE INTO authorised_value_categories( category_name )
    VALUES
    ('WITHDRAWN'),
    ('RESTRICTED'),
    ('NOT_LOAN'),
    ('CCODE'),
    ('LOC'),
    ('STACK');

-- Update the FK
ALTER TABLE items_search_fields
    DROP FOREIGN KEY items_search_fields_authorised_values_category;
ALTER TABLE items_search_fields
    ADD CONSTRAINT `items_search_fields_authorised_values_category` FOREIGN KEY (`authorised_values_category`) REFERENCES `authorised_value_categories` (`category_name`) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE authorised_values
    ADD CONSTRAINT `authorised_values_authorised_values_category` FOREIGN KEY (`category`) REFERENCES `authorised_value_categories` (`category_name`) ON DELETE CASCADE ON UPDATE CASCADE;
