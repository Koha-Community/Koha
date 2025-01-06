use Modern::Perl;

return {
    bug_number  => "37446",
    description => "Fix holdingbranch and homebranch facet labels",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do not update the label if different from the original one
        my $sth = $dbh->prepare(
            q{
            UPDATE search_field
            SET label = ?
            WHERE name = ? AND label = ?
        }
        );
        $sth->execute( 'Holding libraries', 'holdingbranch', 'holdinglibrary' );
        $sth->execute( 'Home libraries',    'homebranch',    'homelibrary' );

        say $out "Updated search field configuration for holdingbranch and homebranch";
    },
};
