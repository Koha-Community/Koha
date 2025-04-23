use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "39526",
    description => "Unify system preference variable names for Elasticsearch",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{update systempreferences set variable = REGEXP_REPLACE(variable, '^ES', 'Elasticsearch') where variable like 'ES%'}
        );

        say $out "Renamed system preference 'ES..' to 'Elasticsearch..'";
    },
};
