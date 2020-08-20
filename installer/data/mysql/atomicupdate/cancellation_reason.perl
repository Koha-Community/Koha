$DBversion = 'XXX'; # will be replaced by the RM
if ( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO authorised_value_categories( category_name, is_system ) VALUES ('HOLD_CANCELLATION', 0);
    });

    $dbh->do(q{
INSERT IGNORE INTO `letter` VALUES ('reserves','HOLD_CANCELLATION','','Hold Cancellation',0,'Your hold was canceled.','[%- USE AuthorisedValues -%]\r\nDear [% borrower.firstname %] [% borrower.surname %],\r\n\r\nYour hold for [% biblio.title %] was canceled for the following reason: [% AuthorisedValues.GetByCode( \'HOLD_CANCELLATION\', hold.cancellation_reason ) %]','email','default');
    });

    if ( !column_exists( 'reserves', 'cancellation_reason' ) ) {
        $dbh->do(q{
            ALTER TABLE reserves ADD COLUMN `cancellation_reason` varchar(80) default NULL AFTER cancellationdate;
        });
    }

    if ( !column_exists( 'old_reserves', 'cancellation_reason' ) ) {
        $dbh->do(q{
            ALTER TABLE old_reserves ADD COLUMN `cancellation_reason` varchar(80) default NULL AFTER cancellationdate;
        });
    }

    NewVersion( $DBversion, 25534, "Add ability to send an email specifying a reason when canceling a hold");
}
