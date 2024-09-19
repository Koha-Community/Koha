use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => "BUG_NUMBER",
    description => "A single line description",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        try {
            $dbh->do(q{
                INSERT IGNORE INTO message_transports (`message_attribute_id`, `message_transport_type`, `is_digest`, `letter_module`, `letter_code`) VALUES
                (9, 'phone', 1, 'circulation', 'AUTO_RENEWALS_DGST'),
                (9, 'phone',  0, 'circulation', 'AUTO_RENEWALS');
            });
            say_success( $out, "Added phone messaging transports for auto-renewals" );
        } catch {
            say_failure( $out, "Error adding phone messaging transports for auto-renewals: $_" );
        };
    },
};
