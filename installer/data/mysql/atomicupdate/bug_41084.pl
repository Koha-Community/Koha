use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "41084",
    description => "Add EnableZotero system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable,value) VALUES
            ('EnableZotero','1')
        }
        );

        say_success( $out, "Added new system preference 'EnableZotero'" );
    },
};
