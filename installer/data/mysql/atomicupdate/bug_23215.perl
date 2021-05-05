$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q{
        DELETE FROM systempreferences
        WHERE variable IN
            ('EnablePayPalOpacPayments',
             'PayPalChargeDescription',
             'PayPalPwd',
             'PayPalReturnURL',
             'PayPalSandboxMode',
             'PayPalSignature',
             'PayPalUser');
    });

    NewVersion( $DBversion, 23215, "Remove core PayPal support in favor of the use of plugins");
}
