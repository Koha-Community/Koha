use Modern::Perl;

return {
    bug_number  => "28787",
    description => "Send a notice with the TOTP token",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            INSERT IGNORE INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`) VALUES
            ('members', '2FA_OTP_TOKEN', '', 'two-authentication step token', 0, 'Two-authentication step token', 'Dear [% borrower.firstname %] [% borrower.surname %] ([% borrower.cardnumber %])\r\n\r\nYour authentication token is [% otp_token %]. \r\nIt is valid one minute.', 'email')
        }
        );

        say $out "Added new letter '2FA_OTP_TOKEN' (email)";
    },
};
