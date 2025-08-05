use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "35467",
    description => "Rename NewsLog to AdditionalContentLog",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(q{UPDATE systempreferences SET variable = 'AdditionalContentLog' WHERE variable = 'NewsLog'});

        # Other information
        say_success( $out, "Updated system preference 'NewsLog' to 'AdditionalContentLog'" );

    },
};
