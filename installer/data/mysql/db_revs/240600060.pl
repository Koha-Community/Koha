use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "33766",
    description => "Add system preference to determine label of userid input on login form",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable,value) VALUES ('OPACLoginLabelTextContent','cardnumberorusername')  }
        );

        # sysprefs
        say_success( $out, "Added new system preference 'OPACLoginLabelTextContent'" );
    },
};
