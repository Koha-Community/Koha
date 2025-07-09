use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "35211",
    description => "",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
                INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
                VALUES ('SeparateHoldingsByGroup',NULL,'','Separate current branch holdings and holdings from libraries in the same group','YesNo')
                }
        );

        # Other information
        say_success( $out, "Added new system preference 'SeparateHoldingsByGroup'" );
    },
};
