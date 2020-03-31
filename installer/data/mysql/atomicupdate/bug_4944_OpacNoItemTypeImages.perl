$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do( q|
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
            SELECT 'OpacNoItemTypeImages', value, NULL, 'If ON, disables itemtype images in the OPAC','YesNo'
            FROM (SELECT value FROM systempreferences WHERE variable="NoItemTypeImages") tmp
    | );
    $dbh->do( "UPDATE systempreferences SET explanation = 'If ON, disables itemtype images in the staff interface'
        WHERE variable = 'noItemTypeImages' ");

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 4944, "Add new system preference OpacNoItemTypeImages");
}
