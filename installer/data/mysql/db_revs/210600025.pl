use Modern::Perl;

return {
    bug_number  => "28826",
    description => "A system preference FacetOrder",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences
            ( variable, value, options, explanation, type ) VALUES
            ('FacetOrder','Alphabetical','Alphabetical|Usage','Specify the order of facets within each category','Choice')
        }
        );
    },
    }
