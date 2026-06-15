use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "31391",
    description => "Staff-side recalls",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{INSERT IGNORE INTO authorised_values (category, authorised_value, lib) VALUES ('HOLD_CANCELLATION','RECALLED','Hold was converted to a recall')}
        );

        say_success( $out, "Add new RECALLED value to HOLD_CANCELLATION authorised value category" );
    },
};
