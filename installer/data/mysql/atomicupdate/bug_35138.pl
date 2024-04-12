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

        $sth->execute( 'Collections', 'ccode', 'collection-code' );

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
        $sth->execute( 'Holding libraries', 'holdingbranch', 'holdinglibrary' ) if $holdingbranch;
        $sth->execute( 'Home libraries',    'homebranch',    'homelibrary' )    if $homebranch;

    },
};
