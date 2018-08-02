INSERT IGNORE INTO authorised_value_categories( category_name )
    VALUES
    (''),
    ('Asort1'),
    ('Asort2'),
    ('Bsort1'),
    ('Bsort2'),
    ('SUGGEST'),
    ('SUGGEST_STATUS'),
    ('SUGGEST_FORMAT'),
    ('DAMAGED'),
    ('LOST'),
    ('REPORT_GROUP'),
    ('REPORT_SUBGROUP'),
    ('DEPARTMENT'),
    ('TERM'),
    ('ITEMTYPECAT'),
    ('PAYMENT_TYPE'),
    ('ROADTYPE');

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
    ('MANUAL_INV'),
    ('BOR_NOTES'),
    ('OPAC_SUG'),
    ('SIP_MEDIA_TYPE'),
    ('ORDER_CANCELLATION_REASON'),
    ('RELTERMS'),
    ('YES_NO'),
    ('LANG'),
    ('HINGS_UT'),
    ('HINGS_PF'),
    ('HINGS_C'),
    ('HINGS_AS'),
    ('HINGS_RD'),
    ('STACK');

-- UNIMARC specific?
INSERT IGNORE INTO authorised_value_categories( category_name ) VALUES
    ('ETAT'),
    ('CAND'),
    ('COUNTRY'),
    ('qualif');

-- For Housebound
INSERT IGNORE INTO authorised_value_categories( category_name ) VALUES
    ('HSBND_FREQ');
