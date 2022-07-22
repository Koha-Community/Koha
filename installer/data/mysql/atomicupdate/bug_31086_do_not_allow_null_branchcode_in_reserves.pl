use Modern::Perl;
use Koha::Holds;

return {
    bug_number => "31086",
    description => "Do not allow null values in branchcodes for reserves",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        my $holds_no_branch = Koha::Holds->search({ branchcode => undef });
        if( $holds_no_branch->count > 0 ){
            say $out "Holds with no branchcode were found and will be updated to the first branch in the system";
            while ( my $hnb = $holds_no_branch->next ){
                say $out "Please review hold for borrowernumber " . $hnb->borrowernumber . " on biblionumber " . $hnb->biblionumber . " to correct pickup branch if necessary";
            }
        }

        # Ensure we have no NULL's in the branchcode field
        $dbh->do(q{
            UPDATE reserves SET branchcode = ( SELECT branchcode FROM branches LIMIT 1) WHERE branchcode IS NULL;
        });

        # Set the NOT NULL configuration
        $dbh->do(q{
            ALTER TABLE reserves
            MODIFY COLUMN `branchcode` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'foreign key from the branches table defining which branch the patron wishes to pick this hold up at'
        });

        # Print useful stuff here
        say $out "Removed NULL option from branchcode for reserves";
    },
};
