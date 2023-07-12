use Modern::Perl;

return {
    bug_number => 30472, # adjusted on bug 33671
    description => "borrower_relationships.guarantor_id NOT NULL",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        # Delete bad/empty guarantors. No longer possible to add them via interface. Have no use.
        my $cnt = $dbh->do(q{
DELETE borrower_relationships FROM borrower_relationships LEFT JOIN borrowers bo ON bo.borrowernumber=guarantor_id WHERE guarantor_id IS NULL OR bo.borrowernumber IS NULL;
        });
        say $out "Removed $cnt bad guarantor relationship records" if $cnt && $cnt =~ /^\d+$/;

        # Make column NOT NULL, disable FK checks while doing so
        $dbh->do('SET FOREIGN_KEY_CHECKS=0');
        $dbh->do(q{
ALTER TABLE borrower_relationships CHANGE COLUMN guarantor_id guarantor_id int(11) NOT NULL
        });
        $dbh->do('SET FOREIGN_KEY_CHECKS=1');
    },
};
