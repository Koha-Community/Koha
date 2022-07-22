use Modern::Perl;

return {
    bug_number => "31086",
    description => "Do not allow null values in branchcodes for reserves",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        # Ensure we have no NULL's in the branchcode field
        $dbh->do(q{
            UPDATE reserves SET branchcode = ( SELECT branchcode FROM branches LIMIT 1) WHERE branchode IS NULL;
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
