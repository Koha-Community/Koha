$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        UPDATE letter SET
        content = REPLACE(content, "You have reached the maximum number of checkouts possible." , "You have reached the maximum number of renewals possible.")
        WHERE ( code = 'AUTO_RENEWALS' OR code = 'AUTO_RENEWALS_DGST' );
    });

    NewVersion( $DBversion, 28263, "Update AUTO_RENEWAL too_many message");
}
