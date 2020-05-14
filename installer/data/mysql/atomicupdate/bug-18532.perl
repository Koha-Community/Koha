$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    $dbh->do( qq{
        INSERT IGNORE INTO letter (module, code, name, title, content, message_transport_type) VALUES ('circulation', 'AUTO_RENEWALS_DGST', 'notification on auto renewing', 'Auto renewals (Digest)',
        "Dear [% borrower.firstname %] [% borrower.surname %],
        [% IF checkout.auto_renew_errors %]
        There were [% checkout.auto_renew_errors %] items that where not correctly renewed.
        [% END %]
        [% IF checkout.auto_renew %]
        There were [% checkout.auto_renew %] items that where correctly renewed.
        [% END %]
        ", 'email');
    });

    $dbh->do( qq{
        INSERT IGNORE INTO `message_attributes`
            (`message_attribute_id`, message_name, `takes_days`)
        VALUES (7, 'Auto_Renewals', 0)
    });

    $dbh->do( qq{
        INSERT IGNORE INTO `message_transports`
            (`message_attribute_id`, `message_transport_type`, `is_digest`, `letter_module`, `letter_code`)
        VALUES  (7, 'email', 0, 'circulation', 'AUTO_RENEWALS'),
                (7, 'sms', 0, 'circulation', 'AUTO_RENEWALS'),
                (7, 'email', 1, 'circulation', 'AUTO_RENEWALS_DGST'),
                (7, 'sms', 1, 'circulation', 'AUTO_RENEWALS_DGST')
    });

    $dbh->do( qq{
        insert into borrower_message_transport_preferences (borrower_message_preference_id, message_transport_type)
        select  p.borrower_message_preference_id, 'email'
        from    borrower_message_preferences p
        left join
                borrower_message_transport_preferences t
        on      p.borrower_message_preference_id = t.borrower_message_preference_id
        where   p.message_attribute_id = 7
                and t.borrower_message_preference_id is null;
    });

     $dbh->do(q{
         INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
         VALUES ('AutoRenewalNotices','cron','cron|preferences|never','How should Koha determine whether to end autorenewal notices','Choice')
     });

    NewVersion( $DBversion, 18532, 'Messaging preferences for auto renewals' );
}
