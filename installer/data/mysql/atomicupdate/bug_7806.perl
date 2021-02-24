$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    sanitize_zero_date('aqorders', 'datecancellationprinted');
    sanitize_zero_date('old_issues', 'returndate');

    NewVersion( $DBversion, 7806, "Remove remaining possible 0000-00-00 values");
}
