use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "39142",
    description => "Adding a Debug User permission",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO userflags (bit, flag, flagdesc, defaulton)
            VALUES (32, 'debug', 'Show Debug Interface', 0)
        }
        );

        say $out "Added new permission 'Debug'";
    },
};
