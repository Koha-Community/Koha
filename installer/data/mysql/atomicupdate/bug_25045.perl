$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    # Default to the homologous OpacPublic syspref
    my $opac_public = C4::Context->preference('OpacPublic') ? 1 : 0;

    $dbh->do(qq{
        INSERT IGNORE INTO `systempreferences`
            (`variable`,`value`,`explanation`,`options`,`type`)
        VALUES
            ('RESTPublicAnonymousRequests', $opac_public, NULL,'If enabled, the API will allow anonymous access to public routes that don\'t require authenticated access'.','YesNo');
    });

    NewVersion( $DBversion, 25045, "Add a way to restrict anonymous access to public routes (OpacPublic behaviour)");
}
