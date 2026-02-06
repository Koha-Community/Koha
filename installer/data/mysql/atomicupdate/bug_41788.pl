use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "41788",
    description => "Add UseHoldsQueueFilterOptions system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
                INSERT IGNORE INTO systempreferences (variable,value)
                VALUES ('UseHoldsQueueFilterOptions','1')
            }
        );
        say_success( $out, "UseHoldsQueueFilterOptions system preference added" );
    },
};
