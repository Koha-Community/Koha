$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
   #Get value from AllowPurchaseSuggestionBranchChoice system preference
   my ( $allowpurchasesuggestionbranchchoice ) = C4::Context->preference('AllowPurchaseSuggestionBranchChoice');
   if ( $allowpurchasesuggestionbranchchoice ) {
       $dbh->do(q{
            INSERT IGNORE INTO systempreferences
            (`variable`, `value`, `options`, `explanation`, `type`)
            VALUES
            ('OPACSuggestionUnwantedFields','branch', NULL,'Define the hidden fields for a patron purchase suggestions made via OPAC.','multiple');
        });
   } else {
       $dbh->do(q{
            INSERT IGNORE INTO systempreferences
            (`variable`, `value`, `options`, `explanation`, `type`)
            VALUES
            ('OPACSuggestionUnwantedFields','', NULL,'Define the hidden fields for a patron purchase suggestions made via OPAC.','multiple');
        });
   }
    #Remove the  AllowPurchaseSuggestionBranchChoice system preference
    $dbh->do("DELETE FROM systempreferences WHERE variable='AllowPurchaseSuggestionBranchChoice'");
    NewVersion($DBversion, 23420, "Allow configuration of hidden fields on the suggestion form in OPAC");
}
