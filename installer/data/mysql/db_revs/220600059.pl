use Modern::Perl;

return {
    bug_number  => "25936",
    description => "A password change notification feature",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Add PASSWORD_CHANGE notice
        my $message = "Dear [% borrower.firstname %] [% borrower.surname %],\r\n\r\n"
            . "We want to notify you that your password has been changed. If you did not change it yourself (or requested that change), please contact library staff.\r\n\r\nYour library.";
        $dbh->do(
            q{INSERT IGNORE INTO letter (module, code, name, title, content, message_transport_type) VALUES ('members', 'PASSWORD_CHANGE', 'Notification of password change', 'Library account password change notification',?, 'email');},
            undef,
            $message
        );

        say $out "Added new letter 'PASSWORD_CHANGE' (email)";

        # Add systempreference
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
            VALUES ('NotifyPasswordChange','0','','Notify patrons whenever their password is changed.','YesNo')
        }
        );

        say $out "Added new system preference 'NotifyPasswordChange'";
    },
};
