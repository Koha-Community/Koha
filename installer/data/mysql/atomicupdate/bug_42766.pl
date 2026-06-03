use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "42766",
    description => "Add ScriptLog system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
            VALUES ( 'ScriptLog', '0', '', 'If enabled, log the start and end of non-cron Koha scripts to the action log (module: SCRIPTS).', 'YesNo' )
        }
        );
        say_success( $out, "Added new system preference 'ScriptLog'" );
    },
};
