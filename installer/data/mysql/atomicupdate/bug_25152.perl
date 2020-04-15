$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "ALTER TABLE subscription MODIFY COLUMN closed tinyint(1) not null default 0" );

    NewVersion( $DBversion, 25152, "Description");
}
