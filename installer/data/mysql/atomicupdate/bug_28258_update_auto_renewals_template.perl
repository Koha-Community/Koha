$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        UPDATE letter SET
        content = REPLACE(content, "The following item, [% biblio.title %], has correctly been renewed and is now due on [% checkout.date_due as_due_date => 1 %]" , "The following item, [% biblio.title %], has correctly been renewed and is now due on [% checkout.date_due | $KohaDates as_due_date => 1 %]")
        WHERE code = 'AUTO_RENEWALS';
    });

    NewVersion( $DBversion, 28258, "Update AUTO_RENEWAL content");
}
