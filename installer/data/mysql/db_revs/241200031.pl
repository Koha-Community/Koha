use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "33473",
    description => "Allow to send email receipts for payments/writeoff manually instead of automatically",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
                UPDATE systempreferences SET variable = 'AutomaticEmailReceipts' WHERE variable = 'UseEmailReceipts';
            }
        );
        say_success( $out, "Renamed system preference 'UseEmailReceipts' to 'AutomaticEmailReceipts'" );
    },
};

