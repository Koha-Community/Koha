INSERT IGNORE INTO authorised_value_categories( category_name, is_system )
    VALUES
    ('', 1),
    ('Asort1', 1),
    ('Asort2', 1),
    ('Bsort1', 1),
    ('Bsort2', 1),
    ('SUGGEST', 0),
    ('SUGGEST_STATUS', 0),
    ('SUGGEST_FORMAT', 0),
    ('DAMAGED', 1),
    ('LOST', 1),
    ('REPORT_GROUP', 0),
    ('REPORT_SUBGROUP', 0),
    ('DEPARTMENT', 0),
    ('TERM', 0),
    ('ITEMTYPECAT', 0),
    ('PAYMENT_TYPE', 0),
    ('PA_CLASS', 0),
    ('HOLD_CANCELLATION', 0),
    ('ROADTYPE', 0),
    ('AR_CANCELLATION', 0);

INSERT IGNORE INTO authorised_value_categories( category_name, is_system )
    VALUES
    ('branches', 1),
    ('itemtypes', 1),
    ('cn_source', 1);

INSERT IGNORE INTO authorised_value_categories( category_name, is_system )
    VALUES
    ('WITHDRAWN', 1),
    ('RESTRICTED', 0),
    ('NOT_LOAN', 1),
    ('CCODE', 1),
    ('LOC', 1),
    ('BOR_NOTES', 1),
    ('OPAC_SUG', 0),
    ('SIP_MEDIA_TYPE', 0),
    ('ORDER_CANCELLATION_REASON', 0),
    ('RELTERMS', 0),
    ('YES_NO', 0),
    ('LANG', 0),
    ('HINGS_UT', 0),
    ('HINGS_PF', 0),
    ('HINGS_C', 0),
    ('HINGS_AS', 0),
    ('HINGS_RD', 0),
    ('STACK', 0),
    ('CONTROL_NUM_SEQUENCE' ,0);

-- UNIMARC specific?
INSERT IGNORE INTO authorised_value_categories( category_name ) VALUES
    ('ETAT'),
    ('CAND'),
    ('COUNTRY'),
    ('TYPEDOC'),
    ('qualif');

-- For Housebound
INSERT IGNORE INTO authorised_value_categories( category_name ) VALUES
    ('HSBND_FREQ');

-- For Interlibrary loans
INSERT IGNORE INTO authorised_value_categories( category_name ) VALUES
    ('ILLSTATUS');

-- For Claims returned
INSERT IGNORE INTO authorised_value_categories( category_name ) VALUES
    ('RETURN_CLAIM_RESOLUTION');

-- For file uploads
INSERT IGNORE INTO authorised_value_categories(  category_name, is_system  ) VALUES
    ('UPLOAD', 1);

-- For ERM
INSERT IGNORE INTO authorised_value_categories (category_name, is_system)
VALUES
    ('ERM_AGREEMENT_STATUS', 1),
    ('ERM_AGREEMENT_CLOSURE_REASON', 1),
    ('ERM_AGREEMENT_RENEWAL_PRIORITY', 1),
    ('ERM_AGREEMENT_USER_ROLES', 1),
    ('ERM_LICENSE_TYPE', 1),
    ('ERM_LICENSE_STATUS', 1),
    ('ERM_AGREEMENT_LICENSE_STATUS', 1),
    ('ERM_AGREEMENT_LICENSE_LOCATION', 1);

INSERT IGNORE INTO authorised_values (category, authorised_value, lib)
VALUES
    ('ERM_AGREEMENT_STATUS', 'active', 'Active'),
    ('ERM_AGREEMENT_STATUS', 'in_negotiation', 'In negotiation'),
    ('ERM_AGREEMENT_STATUS', 'closed', 'Closed'),
    ('ERM_AGREEMENT_CLOSURE_REASON', 'expired', 'Expired'),
    ('ERM_AGREEMENT_CLOSURE_REASON', 'cancelled', 'Cancelled'),
    ('ERM_AGREEMENT_RENEWAL_PRIORITY', 'for_review', 'For review'),
    ('ERM_AGREEMENT_RENEWAL_PRIORITY', 'renew', 'Renew'),
    ('ERM_AGREEMENT_RENEWAL_PRIORITY', 'cancel', 'Cancel'),
    ('ERM_AGREEMENT_USER_ROLES', 'librarian', 'ERM librarian'),
    ('ERM_AGREEMENT_USER_ROLES', 'subject_specialist', 'Subject specialist'),
    ('ERM_LICENSE_TYPE', 'local', 'Local'),
    ('ERM_LICENSE_TYPE', 'consortial', 'Consortial'),
    ('ERM_LICENSE_TYPE', 'national', 'National'),
    ('ERM_LICENSE_TYPE', 'alliance', 'Alliance'),
    ('ERM_LICENSE_STATUS', 'in_negotiation', 'In negociation'),
    ('ERM_LICENSE_STATUS', 'not_yet_active', 'Not yet active'),
    ('ERM_LICENSE_STATUS', 'active', 'Active'),
    ('ERM_LICENSE_STATUS', 'rejected', 'Rejected'),
    ('ERM_LICENSE_STATUS', 'expired', 'Expired'),
    ('ERM_AGREEMENT_LICENSE_STATUS', 'controlling', 'Controlling'),
    ('ERM_AGREEMENT_LICENSE_STATUS', 'future', 'Future'),
    ('ERM_AGREEMENT_LICENSE_STATUS', 'history', 'Historic'),
    ('ERM_AGREEMENT_LICENSE_LOCATION', 'filing_cabinet', 'Filing cabinet'),
    ('ERM_AGREEMENT_LICENSE_LOCATION', 'cupboard', 'Cupboard');
