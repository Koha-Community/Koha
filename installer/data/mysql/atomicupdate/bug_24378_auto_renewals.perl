$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    # $dbh->do( "ALTER TABLE biblio ADD COLUMN badtaste int" );

    $dbh->do(q{
        UPDATE letter SET
        name = REPLACE(name, "notification on auto renewing", "Notification of automatic renewal"),
        title = REPLACE(title, "Auto renewals", "Automatic renewal notice"),
        content = REPLACE(content, "You have reach the maximum of checkouts possible.", "You have reached the maximum number of checkouts possible.")
        WHERE code = 'AUTO_RENEWALS';
    });
    $dbh->do(q{
        UPDATE letter SET
        content = REPLACE(content, "You have overdues.", "You have overdue items.")
        WHERE code = 'AUTO_RENEWALS';
    });
    $dbh->do(q{
        UPDATE letter SET
        content = REPLACE(content, "It\'s too late to renew this checkout.", "It\'s too late to renew this item.")
        WHERE code = 'AUTO_RENEWALS';
    });
    $dbh->do(q{
        UPDATE letter SET
        content = REPLACE(content, "You have too much unpaid fines.", "Your total unpaid fines are too high.")
        WHERE code = 'AUTO_RENEWALS';
    });
    $dbh->do(q{
        UPDATE letter SET
        content = REPLACE(content, "The following item [% biblio.title %] has correctly been renewed and is now due [% checkout.date_due %]", "The following item, [% biblio.title %], has correctly been renewed and is now due on [% checkout.date_due %]
")
        WHERE code = 'AUTO_RENEWALS';
    });
    NewVersion( $DBversion, 24378, "Fix some grammatical errors in default auto renewal notice");
}
