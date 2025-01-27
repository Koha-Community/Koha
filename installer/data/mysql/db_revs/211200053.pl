use Modern::Perl;

return {
    bug_number  => "30611",
    description => "Add STAFF_PASSWORD_RESET notice",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Add STAFF_PASSWORD_RESET notice
        $dbh->do(
            q{
            INSERT IGNORE INTO letter (module, code, name, is_html, title, content, message_transport_type) VALUES ('members', 'STAFF_PASSWORD_RESET', 'Online password reset', 1, "Koha password reset", "<html>\r\n<p>A librarian has reset the password for the account <strong><<user>></strong>.\r\n</p>\r\n<p>\r\nPlease create your new password using the following link:\r\n<br/><a href=\"<<passwordreseturl>>\"><<passwordreseturl>></a>\r\n</p>\r\n<p>This link will be valid for 5 days from this email's reception, then you must reapply if you do not change your password.</p>\r\n<p>Thank you.</p>\r\n</html>", 'email');
        }
        );
    },
};
