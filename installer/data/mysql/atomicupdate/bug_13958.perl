$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        SELECT
            'SuspensionsCalendar',
            IF( value='noFinesWhenClosed', 'noSuspensionsWhenClosed', 'ignoreCalendar'),
            'ignoreCalendar|noSuspensionsWhenClosed',
            'Specify whether to use the Calendar in calculating suspensions',
            'Choice'
        FROM systempreferences
        WHERE variable='finesCalendar';
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 13958 - Add a SuspensionsCalendar syspref)\n";
}
