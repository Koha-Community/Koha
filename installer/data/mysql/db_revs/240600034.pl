use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "37967",
    description => "Add auto renewal message_transport for phone",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO message_transports (`message_attribute_id`, `message_transport_type`, `is_digest`, `letter_module`, `letter_code`) VALUES
            (9, 'phone', 1, 'circulation', 'AUTO_RENEWALS_DGST'),
            (9, 'phone',  0, 'circulation', 'AUTO_RENEWALS');
        }
        );
        say_success( $out, "Added phone messaging transports for auto-renewals" );
    },
};
