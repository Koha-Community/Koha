$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    $dbh->do( qq{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
        VALUES  ('OPACShowMusicalInscripts','0','','Display musical inscripts on the OPAC record details page when available.','YesNo'),
                ('OPACPlayMusicalInscripts','0','','If displayed musical inscripts, play midi conversion on the OPAC record details page.','YesNo')
    } );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22581 - add new OPACShowMusicalInscripts and OPACPlayMusicalInscripts system preferences)\n";
}
