$DBversion = 'XXX';
if ( CheckVersion($DBversion ) ) {
    $dbh->do(q{
            INSERT IGNORE INTO systempreferences (`variable`,`value`,`options`,`explanation`,`type`)
            VALUES ('EmailOverduesNoEmail','0','','Set mail sending to staff for patron has overdues but no email address', 'YesNo')
            });

    NewVersion( $DBversion,'20076','Add system preference EmailOverduesNoEmail');
}
