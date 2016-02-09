-- Add issue_id to accountlines table
ALTER TABLE accountlines ADD issue_id INT(11) NULL DEFAULT NULL AFTER accountlines_id;

-- Close out any accruing fines with no current issue
UPDATE accountlines LEFT JOIN issues USING ( itemnumber, borrowernumber ) SET accounttype = 'F' WHERE accounttype = 'FU' and issues.issue_id IS NULL;

-- Close out any extra not really accruing fines, keep only the latest accring fine
UPDATE accountlines a1
    LEFT JOIN (SELECT MAX(accountlines_id) AS keeper,
                      borrowernumber,
                      itemnumber
               FROM   accountlines
               WHERE  accounttype = 'FU'
               GROUP BY borrowernumber, itemnumber
              ) a2 USING ( borrowernumber, itemnumber )
SET    a1.accounttype = 'F'
WHERE  a1.accounttype = 'FU'
  AND  a1.accountlines_id != a2.keeper;

-- Update the unclosed fines to add the current issue_id to them
UPDATE accountlines LEFT JOIN issues USING ( itemnumber ) SET accountlines.issue_id = issues.issue_id WHERE accounttype = 'FU';
