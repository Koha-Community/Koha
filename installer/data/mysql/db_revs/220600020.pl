use Modern::Perl;

return {
    bug_number  => "31086",
    description => "Do not allow NULL values in branchcodes for reserves",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my $sth = $dbh->prepare(
            q{
            SELECT borrowernumber, biblionumber
            FROM reserves
	        WHERE branchcode IS NULL;
        }
        );
        $sth->execute;
        my $holds_no_branch = $sth->fetchall_arrayref( {} );

        if ( scalar @{$holds_no_branch} > 0 ) {
            say $out "Holds with no branchcode were found and will be updated to the first branch in the system";
            foreach my $hnb ( @{$holds_no_branch} ) {
                say $out "Please review hold for borrowernumber "
                    . $hnb->{borrowernumber}
                    . " on biblionumber "
                    . $hnb->{biblionumber}
                    . " to correct pickup branch if necessary";
            }
        }

        # Ensure we have no NULL's in the branchcode field
        $dbh->do(
            q{
            UPDATE reserves SET branchcode = ( SELECT branchcode FROM branches LIMIT 1) WHERE branchcode IS NULL;
        }
        );

        # Remove FOREIGN KEY CONSTRAINT
        if ( foreign_key_exists( 'reserves', 'reserves_ibfk_4' ) ) {
            $dbh->do(
                q{
                ALTER TABLE reserves DROP FOREIGN KEY reserves_ibfk_4;
            }
            );
        }

        # Set the NOT NULL configuration
        $dbh->do(
            q{
            ALTER TABLE reserves
            MODIFY COLUMN `branchcode` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'foreign key from the branches table defining which branch the patron wishes to pick this hold up at'
        }
        );

        # Replace the constraint
        $dbh->do(
            q{
            ALTER TABLE reserves ADD CONSTRAINT reserves_ibfk_4 FOREIGN KEY (branchcode) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE;
        }
        );

        # Print useful stuff here
        say $out "Removed NULL option from branchcode for reserves";
    },
};
