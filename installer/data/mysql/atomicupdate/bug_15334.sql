-- Add issue_id to accountlines table
ALTER TABLE accountlines ADD issue_id INT(11) NULL DEFAULT NULL AFTER accountlines_id;

-- Close out any accruing fines with no current issue
UPDATE accountlines LEFT JOIN issues USING ( itemnumber, borrowernumber ) SET accounttype = 'F' WHERE accounttype = 'FU' and issues.issue_id IS NULL;

-- Close out any extra not really accruing fines, keep only the latest accring fine
UPDATE accountlines SET accounttype = 'F' WHERE accountlines_id NOT IN ( SELECT accountlines_id FROM ( SELECT * FROM accountlines WHERE accounttype = 'FU' ORDER BY accountlines_id DESC ) a2 GROUP BY borrowernumber, itemnumber );

-- Update the unclosed fines to add the current issue_id to them
UPDATE accountlines LEFT JOIN issues USING ( itemnumber ) SET accountlines.issue_id = issues.issue_id WHERE accounttype = 'FU';
