$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    unless ( column_exists('letter', 'updated_on') ) {
        $dbh->do(
            qq{
                ALTER TABLE letter ADD COLUMN updated_on timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER lang
              }
        );
    }
    NewVersion( $DBversion, 25776, "Add letter.updated_on");

}
