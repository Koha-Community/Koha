use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "42053",
    description => "Add sip2 user flag if needed",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
                INSERT IGNORE INTO userflags (bit, flag, flagdesc, defaulton)
                VALUES (31, 'sip2', 'Manage SIP2 module', 0)
        }
        );

        say $out "Added sip2 to userflags if needed";
    },
};
