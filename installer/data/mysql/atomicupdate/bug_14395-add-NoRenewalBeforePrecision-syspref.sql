INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
VALUES ('NoRenewalBeforePrecision', 'date', 'Calculate "No renewal before" based on date or exact time. Only relevant for loans calculated in days, hourly loans are not affected.', 'date|exact_time', 'Choice');
