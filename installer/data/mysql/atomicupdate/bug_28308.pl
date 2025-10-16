use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "28308",
    description => "Remove unnecessary message preference entries",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Remove message transport types entries for Advance notice (id=2) if "Days in advance" is 0 or NULL
        $dbh->do(
            q{
            DELETE bmtp
            FROM borrower_message_transport_preferences bmtp
            JOIN borrower_message_preferences bmp
              ON bmtp.borrower_message_preference_id = bmp.borrower_message_preference_id
            WHERE bmp.message_attribute_id = 2
              AND (bmp.days_in_advance = 0 OR bmp.days_in_advance IS NULL);
        }
        );
    },
};
