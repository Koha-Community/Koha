use Modern::Perl;

return {
    bug_number  => "30327",
    description => "Add biblionumber to ComponentSortField",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            UPDATE systempreferences set options="call_number|pubdate|acqdate|title|author|biblionumber"
            WHERE variable = 'ComponentSortField'
        }
        );
        say $out "Added biblionumber option to ComponentSortField";
    },
};
