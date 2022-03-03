use Modern::Perl;

return {
    bug_number => "25936",
    description => "A password change notification feature",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        # Add PASSCHANGE notice
        $dbh->do( q{
            INSERT IGNORE INTO letter (module, code, name, title, content, message_transport_type) VALUES ('members', 'PASSCHANGE', 'Notification of password change', 'Library account password change notification',
            "Dear [% borrower.firstname %] [% borrower.surname %],

            Someone has changed your library user account password.

            If this is unexpected, please contact the library.
            ", 'email');
        });

        # Add systempreference
        $dbh->do(q{
            INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
            VALUES ('NotifyPasswordChange','0','','Notify patrons whenever their password is changed.','YesNo')
        });
    },
};
