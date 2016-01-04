INSERT INTO systempreferences ( value, variable, options, explanation,type )
select value ,'EnhancedMessagingPreferencesOPAC', NULL, 'If ON, allows patrons to select to receive additional messages about items due or nearly due.', 'YesNo' from systempreferences where variable='EnhancedMessagingPreferences';
