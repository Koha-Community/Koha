use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "36996",
    description => "Add z3950Status system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('z3950Status','','','This syspref allows to define custom YAML based rules for marking items unavailable in z3950 results.','Textarea')
        }
            ) != '0E0'
            ? say_success( $out, "Added new system preference 'Z3950Status'" )
            : say_info( $out, "System preference 'Z3950Status' already exists" );
    },
};
