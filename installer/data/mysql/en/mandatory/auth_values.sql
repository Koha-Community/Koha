INSERT INTO authorised_values (category,authorised_value,lib,lib_opac) VALUES ('YES_NO','0','No','No');
INSERT INTO authorised_values (category,authorised_value,lib,lib_opac) VALUES ('YES_NO','1','Yes','Yes');
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
INSERT IGNORE INTO authorised_value_categories( category_name )
    VALUES
    ('branches'),
    ('itemtypes'),
    ('cn_source');
