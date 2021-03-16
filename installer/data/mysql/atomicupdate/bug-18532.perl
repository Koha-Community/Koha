$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    $dbh->do( q{
        INSERT IGNORE INTO letter (module, code, name, title, content, message_transport_type) VALUES ('circulation', 'AUTO_RENEWALS_DGST', 'Notification on auto renewals', 'Auto renewals (Digest)',
        "Dear [% borrower.firstname %] [% borrower.surname %],
        [% IF error %]
            There were [% error %] items that were not renewed.
        [% END %]
        [% IF success %]
            There were [% success %] items that were renewed.
        [% END %]
        [% FOREACH checkout IN checkouts %]
            [% checkout.item.biblio.title %] : [% checkout.item.barcode %]
            [% IF !checkout.auto_renew_error %]
                was renewed until [% checkout.date_due | $KohaDates as_due_date => 1%]
            [% ELSIF checkout.auto_renew_error == 'too_many' %]
                You have reached the maximum number of checkouts possible.
            [% ELSIF checkout.auto_renew_error == 'on_reserve' %]
                This item is on hold for another patron.
            [% ELSIF checkout.auto_renew_error == 'restriction' %]
                You are currently restricted.
            [% ELSIF checkout.auto_renew_error == 'overdue' %]
                You have overdue items.
            [% ELSIF checkout.auto_renew_error == 'auto_too_late' %]
                It's too late to renew this item.
            [% ELSIF checkout.auto_renew_error == 'auto_too_much_oweing' %]
                Your total unpaid fines are too high.
            [% ELSIF checkout.auto_renew_error == 'too_unseen' %]
                This item must be renewed at the library.
            [% END %]
        [% END %]
        ", 'email');
    });

    $dbh->do( q{
        INSERT IGNORE INTO `message_attributes`
            (`message_attribute_id`, message_name, `takes_days`)
        VALUES (9, 'Auto_Renewals', 0)
    });

    $dbh->do( q{
        INSERT IGNORE INTO `message_transports`
            (`message_attribute_id`, `message_transport_type`, `is_digest`, `letter_module`, `letter_code`)
        VALUES  (9, 'email', 0, 'circulation', 'AUTO_RENEWALS'),
                (9, 'sms', 0, 'circulation', 'AUTO_RENEWALS'),
                (9, 'email', 1, 'circulation', 'AUTO_RENEWALS_DGST'),
                (9, 'sms', 1, 'circulation', 'AUTO_RENEWALS_DGST')
    });

     $dbh->do(q{
         INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
         VALUES ('AutoRenewalNotices','cron','cron|preferences|never','How should Koha determine whether to end autorenewal notices','Choice')
     });

    NewVersion( $DBversion, 18532, 'Messaging preferences for auto renewals' );
}
