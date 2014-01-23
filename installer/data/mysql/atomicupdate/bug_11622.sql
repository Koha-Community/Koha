INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type ) VALUES
( 'EnablePayPalOpacPayments',  '0', NULL ,  'Enables the ability to pay fees and fines from  the OPAC via PayPal',  'YesNo' ),
( 'PayPalChargeDescription',  'Koha fee payment', NULL ,  'This preference defines what the user will see the charge listed as in PayPal',  'Free' ),
( 'PayPalPwd',  '', NULL ,  'Your PayPal API password',  'Free' ),
( 'PayPalSandboxMode',  '1', NULL ,  'If enabled, the system will use PayPal''s sandbox server for testing, rather than the production server.',  'YesNo' ),
( 'PayPalSignature',  '', NULL ,  'Your PayPal API signature',  'Free' ),
( 'PayPalUser',  '', NULL ,  'Your PayPal API username ( email address )',  'Free' );
