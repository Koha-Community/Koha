use Date::Calc qw( Add_Delta_Days );
$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    unless( column_exists( 'aqorders', 'estimated_delivery_date' ) ) {
        $dbh->do(q{ ALTER TABLE aqorders ADD estimated_delivery_date date default null AFTER suppliers_report });

        NewVersion( $DBversion, 15348, "Add new column aqorders.estimated_delivery_date" );
    }
}
