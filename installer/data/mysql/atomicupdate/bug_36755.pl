use Modern::Perl;

return {
    bug_number  => "36755",
    description => "Increase length of 'code' column in borrower_attribute_types",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Drop related tables constraints
        if ( foreign_key_exists( 'pseudonymized_borrower_attributes', 'anonymized_borrower_attributes_ibfk_2' ) ) {
            $dbh->do(
                q{ALTER TABLE pseudonymized_borrower_attributes DROP FOREIGN KEY anonymized_borrower_attributes_ibfk_2}
            );
        }
        if ( foreign_key_exists( 'borrower_attribute_types_branches', 'borrower_attribute_types_branches_ibfk_1' ) ) {
            $dbh->do(
                q{ALTER TABLE borrower_attribute_types_branches DROP FOREIGN KEY borrower_attribute_types_branches_ibfk_1}
            );
        }
        if ( foreign_key_exists( 'borrower_attributes', 'borrower_attributes_ibfk_2' ) ) {
            $dbh->do(q{ALTER TABLE borrower_attributes DROP FOREIGN KEY borrower_attributes_ibfk_2});
        }

        # Update the column we want
        unless ( foreign_key_exists( 'pseudonymized_borrower_attributes', 'anonymized_borrower_attributes_ibfk_2' )
            || foreign_key_exists( 'borrower_attribute_types_branches', 'borrower_attribute_types_branches_ibfk_1' )
            || foreign_key_exists( 'borrower_attributes',               'borrower_attributes_ibfk_2' ) )
        {
            $dbh->do(
                q{ALTER TABLE borrower_attribute_types MODIFY COLUMN code VARCHAR(64) NOT NULL COMMENT 'unique key used to identify each custom field'}
            );
        }

        # Update the related tables
        unless ( foreign_key_exists( 'pseudonymized_borrower_attributes', 'anonymized_borrower_attributes_ibfk_2' ) ) {
            $dbh->do(
                q{ALTER TABLE pseudonymized_borrower_attributes MODIFY COLUMN code VARCHAR(64) NOT NULL COMMENT 'foreign key from the borrower_attribute_types table, defines which custom field this value was entered for'}
            );
        }
        unless ( foreign_key_exists( 'borrower_attribute_types_branches', 'borrower_attribute_types_branches_ibfk_1' ) )
        {
            $dbh->do(q{ALTER TABLE borrower_attribute_types_branches MODIFY COLUMN bat_code VARCHAR(64) DEFAULT NULL});
        }
        unless ( foreign_key_exists( 'borrower_attributes', 'borrower_attributes_ibfk_2' ) ) {
            $dbh->do(
                q{ALTER TABLE borrower_attributes MODIFY COLUMN code VARCHAR(64) NOT NULL COMMENT 'foreign key from the borrower_attribute_types table, defines which custom field this value was entered for'}
            );
        }

        # Restore related tables constraints
        unless ( foreign_key_exists( 'pseudonymized_borrower_attributes', 'anonymized_borrower_attributes_ibfk_2' ) ) {
            $dbh->do(
                q{ALTER TABLE pseudonymized_borrower_attributes ADD CONSTRAINT anonymized_borrower_attributes_ibfk_2 FOREIGN KEY (code) REFERENCES borrower_attribute_types(code) ON DELETE CASCADE ON UPDATE CASCADE}
            );
        }
        unless ( foreign_key_exists( 'borrower_attribute_types_branches', 'borrower_attribute_types_branches_ibfk_1' ) )
        {
            $dbh->do(
                q{ALTER TABLE borrower_attribute_types_branches ADD CONSTRAINT borrower_attribute_types_branches_ibfk_1 FOREIGN KEY (bat_code) REFERENCES borrower_attribute_types(code) ON DELETE CASCADE}
            );
        }
        unless ( foreign_key_exists( 'borrower_attributes', 'borrower_attributes_ibfk_2' ) ) {
            $dbh->do(
                q{ALTER TABLE borrower_attributes ADD CONSTRAINT borrower_attributes_ibfk_2 FOREIGN KEY (code) REFERENCES borrower_attribute_types(code) ON DELETE CASCADE ON UPDATE CASCADE}
            );
        }

        # HTML customizations
        say $out "Increased borrower_attribute_types.code column length from 10 to 64";
    },
};
