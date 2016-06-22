
INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type )
 SELECT 'OPACXSLTListsDisplay', COALESCE(value,''), '', 'Enable XSLT stylesheet control over lists pages display on OPAC', 'Free'
 FROM systempreferences WHERE variable='OPACXSLTResultsDisplay';

INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type )
 SELECT 'XSLTListsDisplay', COALESCE(value,''), '', 'Enable XSLT stylesheet control over lists pages display on intranet', 'Free'
 FROM systempreferences WHERE variable='XSLTResultsDisplay';

-- $DBversion = '16.06.00.XXX';
-- if ( CheckVersion($DBversion) ) {
--     $dbh->do(q{
--         INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type )
--          SELECT 'OPACXSLTListsDisplay', COALESCE(value,''), '', 'Enable XSLT stylesheet control over lists pages display on OPAC', 'Free'
--          FROM systempreferences WHERE variable='OPACXSLTResultsDisplay';
--     });

--     $dbh->do(q{
--         INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type )
--          SELECT 'XSLTListsDisplay', COALESCE(value,''), '', 'Enable XSLT stylesheet control over lists pages display on intranet', 'Free'
--          FROM systempreferences WHERE variable='XSLTResultsDisplay';
--     });

--     print "Upgrade to $DBversion done (Bug 15485: Allow choosing different XSLTs for lists)\n";
--     SetVersion($DBversion);
-- }
