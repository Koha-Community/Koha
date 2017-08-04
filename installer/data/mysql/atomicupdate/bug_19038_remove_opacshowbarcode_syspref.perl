$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    my $hide_barcode = C4::Context->preference('OPACShowBarcode') ? 0 : 1;

    $dbh->do(q{
        DELETE FROM systempreferences
        WHERE
            variable='OPACShowBarcode'
    });

    # Configure column visibility if it isn't
    $dbh->do(q{
        INSERT IGNORE INTO columns_settings
            (module,page,tablename,columnname,cannot_be_toggled,is_hidden)
        VALUES
            ('opac','biblio-detail','holdingst','item_barcode',0,?)
    }, undef, $hide_barcode);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19038: Remove OPACShowBarcode syspref)\n";
}