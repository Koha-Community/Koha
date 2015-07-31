ALTER TABLE authorised_values_branches
    CHANGE av_id av_id INT( 11 ) NOT NULL,
    CHANGE branchcode branchcode VARCHAR( 10 ) NOT NULL;

/*
$DBversion = "3.21.00.XXX";
if ( CheckVersion($DBversion) ) {
   $dbh->do(q{
       ALTER TABLE authorised_values_branches
         CHANGE av_id av_id INT( 11 ) NOT NULL,
         CHANGE branchcode branchcode VARCHAR( 10 ) NOT NULL
   });
   print "Upgrade to $DBversion done (Bug 10363: There is no package for authorised values)\n";
   SetVersion($DBversion);
}
*/
