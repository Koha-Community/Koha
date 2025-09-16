use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "39526",
    description => "Unify system preference variable names for Elasticsearch",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{UPDATE systempreferences SET variable = 'ElasticsearchPreventAutoTruncate' WHERE variable = 'ESPreventAutoTruncate'}
            ) == 1
            && say $out "Renamed system preference 'ESPreventAutoTruncate' to 'ElasticsearchPreventAutoTruncate'";
    },
};
