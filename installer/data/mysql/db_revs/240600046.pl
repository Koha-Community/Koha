use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "38222",
    description => "Add cancellation reasons to bookings",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO authorised_value_categories (category_name, is_system)
            VALUES
                ('BOOKING_CANCELLATION', 1)
            }
        );
        say_success( $out, "Added new authorized value category 'BOOKING_CANCELLATION'" );
    },
};
