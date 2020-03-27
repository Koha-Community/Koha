$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    my $noItemTypeImages = C4::Context->preference('noItemTypeImages');
    $dbh->do( "INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
        VALUES('OpacNoItemTypeImages',$noItemTypeImages,NULL,'If ON, disables itemtype images in the OPAC','YesNo')" );
    $dbh->do( "UPDATE systempreferences SET explanation = 'If ON, disables itemtype images in the staff interface'
        WHERE variable = 'noItemTypeImages' ");

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 4944, "Add new system preference OpacNoItemTypeImages");
}
