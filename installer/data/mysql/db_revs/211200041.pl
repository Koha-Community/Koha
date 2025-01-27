use Modern::Perl;

return {
    bug_number  => 30449,
    description => "Check borrower_attribute_types FK constraint",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( foreign_key_exists( 'borrower_attribute_types', 'category_code_fk' ) ) {
            $dbh->do(q|ALTER TABLE borrower_attribute_types DROP FOREIGN KEY category_code_fk|);
            if ( index_exists( 'borrower_attribute_types', 'category_code_fk' ) ) {
                $dbh->do(q|ALTER TABLE borrower_attribute_types DROP INDEX category_code_fk|);
            }
        }

        if ( !foreign_key_exists( 'borrower_attribute_types', 'borrower_attribute_types_ibfk_1' ) ) {

            my $sth = $dbh->prepare(
                q{
                SELECT category_code
                FROM borrower_attribute_types
                WHERE category_code NOT IN (SELECT categorycode FROM categories);
            }
            );

            $sth->execute;

            my @invalid_categories;
            while ( my $row = $sth->fetchrow_arrayref() ) {
                push( @invalid_categories, $row->[0] );
            }

            if (@invalid_categories) {
                die "The 'borrower_attribute_types' table contains "
                    . "references to invalid category codes: "
                    . join( ', ', @invalid_categories );
            }

            if ( !index_exists( 'borrower_attribute_types', 'category_code' ) ) {
                $dbh->do(
                    q|
                    ALTER TABLE borrower_attribute_types ADD INDEX category_code (category_code)
                |
                );
            }
            $dbh->do(
                q|
                ALTER TABLE borrower_attribute_types
                    ADD CONSTRAINT borrower_attribute_types_ibfk_1 FOREIGN KEY (`category_code`) REFERENCES `categories` (`categorycode`)
            |
            );
        }
    },
};
