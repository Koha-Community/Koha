use Modern::Perl;

return {
    bug_number => 30483,
    description => "Make issues.borrowernumber and itemnumber NOT NULL",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        # Count bad records (expecting zero..)
        my ( $cnt ) = $dbh->selectrow_array(q{
            SELECT COUNT(issue_id) FROM issues
            LEFT JOIN borrowers USING (borrowernumber)
            LEFT JOIN items USING (itemnumber)
            WHERE items.itemnumber IS NULL OR borrowers.borrowernumber IS NULL });

        # If we found bad records, we will not continue
        if( $cnt ) {
            say $out "ERROR: Your issues table contains $cnt records violating foreign key constraints to the borrowers or items table.";
            say $out "We recommend to remove them with a statement like:";
            say $out "    DELETE issues FROM issues LEFT JOIN borrowers bo USING (borrowernumber) WHERE bo.borrowernumber IS NULL;";
            say $out "    DELETE issues FROM issues LEFT JOIN items it USING (itemnumber) WHERE it.itemnumber IS NULL;";
            die "Interrupting installer process: database revision for bug 30483 fails!";
        }

        # Green zone: remove FK constraints while changing columns (needed for some SQL server versions)
        if( foreign_key_exists('issues', 'issues_ibfk_1') ) {
            $dbh->do( q|ALTER TABLE issues DROP FOREIGN KEY issues_ibfk_1| );
        }
        if( foreign_key_exists('issues', 'issues_ibfk_2') ) {
            $dbh->do( q|ALTER TABLE issues DROP FOREIGN KEY issues_ibfk_2| );
        }
        $dbh->do( q|ALTER TABLE issues ADD CONSTRAINT `issues_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE RESTRICT ON UPDATE CASCADE| );
        $dbh->do( q|ALTER TABLE issues ADD CONSTRAINT `issues_ibfk_2` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE RESTRICT ON UPDATE CASCADE| );
        my $sql = "ALTER TABLE issues MODIFY COLUMN borrowernumber int(11) NOT NULL COMMENT 'foreign key, linking this to the borrowers table for the patron this item was checked out to', MODIFY COLUMN itemnumber int(11) NOT NULL COMMENT 'foreign key, linking this to the items table for the item that was checked out'";
        $dbh->do($sql);
    },
};
