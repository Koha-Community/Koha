use Modern::Perl;

return {
    bug_number  => "35138",
    description => "Make the Elasticsearch facets configurable",
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
        my $sth = $dbh->prepare(
            q{
            UPDATE search_field
            SET label = ?
            WHERE name = ? AND label = ?
        }
        );
        while ( my ( $name, $label ) = each %$facets ) {
            $sth->execute( $label, $name, $name );
        }

        $sth->execute( 'Collections',       'ccode',         'collection-code' );
        $sth->execute( 'Holding libraries', 'holdingbranch', 'holdinglibrary' );
        $sth->execute( 'Home libraries',    'homebranch',    'homelibrary' );

        # Deal with DisplayLibraryFacets
        my ($DisplayLibraryFacets) = $dbh->selectrow_array(
            q{
            SELECT value FROM systempreferences WHERE variable='DisplayLibraryFacets'
        }
        );
        my ( $homebranch, $holdingbranch );
        if ( $DisplayLibraryFacets eq 'both' ) {
            $homebranch    = 1;
            $holdingbranch = 1;
        } elsif ( $DisplayLibraryFacets eq 'holding' ) {
            $holdingbranch = 1;
        } elsif ( $DisplayLibraryFacets eq 'home' ) {
            $homebranch = 1;

        }
        my $faceted_search_field = $dbh->selectall_arrayref(
            q{SELECT * FROM search_field WHERE facet_order IS NOT NULL ORDER BY facet_order},
            { Slice => {} }
        );
        my $facet_order = 1;
        $dbh->do(q{UPDATE search_field SET facet_order = NULL});
        for my $f (@$faceted_search_field) {
            next
                if $f->{name} eq 'homebranch' && !$homebranch;
            next
                if $f->{name} eq 'holdingbranch' && !$holdingbranch;

            $dbh->do( q{UPDATE search_field SET facet_order = ? WHERE name = ?}, undef, $facet_order, $f->{name} );

            $facet_order++;
        }

        say $out "Updated DisplayLibraryFacets and search field configuration";
    },
};
