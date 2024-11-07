use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "35597",
    description => "Add SuggestionsLog system preference ",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # sysprefs
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
            VALUES ('SuggestionsLog', '0', 'If enabled, log purchase suggestion changes', '' , 'YesNo')
        }
        ) == 1 and say_success( $out, "Added new system preference 'SuggestionsLog'" );
    },
};
