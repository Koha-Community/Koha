use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "35639",
    description => "Add the SMSSendMaxChar system preference to limit the number of characters in a SMS message",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
            VALUES ('SMSSendMaxChar','','NULL','Add a limit for the number of characters in SMS messages','Integer');
        }
        ) == 1 and say_success( $out, "Added new system preference 'SMSSendMaxChar'" );
    },
};
