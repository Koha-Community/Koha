INSERT INTO systempreferences ( variable, value, options, explanation,type ) VALUES
('OPACEnhancedMessagingPreferences', '1', NULL, 'If ON, show patrons messaging setting on the OPAC.', 'YesNo') ON DUPLICATE KEY UPDATE value ='1';
INSERT INTO systempreferences ( variable, value, options, explanation,type ) VALUES
('EnhancedMessagingPreferences', '1', NULL, 'If ON, allows patrons to select to receive additional messages about items due or nearly due.', 'YesNo') ON DUPLICATE KEY UPDATE value ='1';
