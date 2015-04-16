UPDATE borrowers
SET flags = flags - ( flags & (1<<7) )
WHERE flags IS NOT NULL
    AND flags > 0;

DELETE FROM userflags WHERE bit=7;

-- $DBversion = "3.19.00.XXX";
-- if ( CheckVersion($DBversion) ) {
--     # Remove the borrow permission flag (bit 7)
--     $dbh->do(q|
--         UPDATE borrowers
--         SET flags = flags - ( flags & (1<<7) )
--         WHERE flags IS NOT NULL
--             AND flags > 0
--     |);
--     $dbh->do(q|
--         DELETE FROM userflags WHERE bit=7;
--     |);
--     print "Upgrade to $DBversion done (Bug 7976 - Remove the 'borrow' permission)\n";
--     SetVersion($DBversion);
-- }
