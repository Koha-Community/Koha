use Modern::Perl;

return {
    bug_number => 30449,
    description => "Check borrower_attribute_types FK constraint",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        if( foreign_key_exists('borrower_attribute_types', 'category_code_fk') ) {
            $dbh->do( q|ALTER TABLE borrower_attribute_types DROP CONSTRAINT category_code_fk| );
            if( index_exists('borrower_attribute_types', 'category_code_fk') ) {
                $dbh->do( q|ALTER TABLE borrower_attribute_types DROP INDEX category_code_fk| );
            }
        }
        if( !foreign_key_exists('borrower_attribute_types', 'borrower_attribute_types_ibfk_1') ) {
            if( !index_exists('borrower_attribute_types', 'category_code') ) {
                $dbh->do( q|ALTER TABLE borrower_attribute_types ADD INDEX category_code (category_code)| );
            }
            $dbh->do( q|ALTER TABLE borrower_attribute_types ADD CONSTRAINT borrower_attribute_types_ibfk_1 FOREIGN KEY (`category_code`) REFERENCES `categories` (`categorycode`)| );
        }
    },
};
