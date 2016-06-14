INSERT IGNORE INTO systempreferences ( variable, value, options, explanation,type )
VALUES ('OPACXSLTListsDisplay','','','Enable XSLT stylesheet control over lists pages display on OPAC','Free');
INSERT IGNORE INTO systempreferences ( variable, value, options, explanation,type )
VALUES ('XSLTListsDisplay','','','Enable XSLT stylesheet control over lists pages display on intranet','Free');

-- $DBversion = '16.06.00.XXX';
-- if ( CheckVersion($DBversion) ) {
--     $dbh->do(q{
--         INSERT IGNORE INTO systempreferences ( variable, value, options, explanation,type )
--         VALUES ('OPACXSLTListsDisplay','','','Enable XSLT stylesheet control over lists pages display on OPAC','Free')
--     });

--     $dbh->do(q{
--         INSERT IGNORE INTO systempreferences ( variable, value, options, explanation,type )
--         VALUES ('XSLTListsDisplay','','','Enable XSLT stylesheet control over lists pages display on intranet','Free')

--     });

--     print "Upgrade to $DBversion done (Bug 15485: Allow choosing different XSLTs for lists)\n";
--     SetVersion($DBversion);
-- }
