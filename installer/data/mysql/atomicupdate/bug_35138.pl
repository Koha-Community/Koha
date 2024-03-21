use Modern::Perl;

return {
    bug_number  => "35138",
    description => "Make the elastic facets editable",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my $facets = {
            author         => 'Authors',
            itype          => 'Item types',
            location       => 'Location',
            'su-geo'       => 'Places',
            'title-series' => 'Series',
            subject        => 'Topics',
            ln             => 'Languages',
        };
        # Do not update the label if different from the original one
        my $sth = $dbh->prepare(q{
            UPDATE search_field
            SET label = ?
            WHERE name = ? AND label = ?
        });
        while ( my ( $name, $label ) = each %$facets ) {
            $sth->execute( $label, $name, $name );
        }

        $sth->execute( 'Collections', 'ccode', 'collection-code');
        $sth->execute( 'Holding libraries', 'holdingbranch', 'holdinglibrary');
        $sth->execute( 'Home libraries', 'homebranch', 'homelibrary');
    },
};
