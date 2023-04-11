use Modern::Perl;

return {
    bug_number => "33488",
    description => "Add index to fromBranch for branch_transfer_limits",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        # Do you stuffs here
        unless ( index_exists( 'branch_transfer_limits', 'fromBranch_idx' ) ) {
            $dbh->do(q{CREATE INDEX fromBranch_idx ON branch_transfer_limits ( fromBranch )});
            say $out "Added new index on branch_transfer_limits.fromBranch";
        }
    },
};
