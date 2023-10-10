use Modern::Perl;

return {
    bug_number  => "25560",
    description => "Migrating existing UpdateNotForLoanStatusOnCheckin rules to new format",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my ($UpdateNotForLoanStatusOnCheckin) = $dbh->selectrow_array(
            q|
           SELECT value FROM systempreferences WHERE variable='UpdateNotForLoanStatusOnCheckin'
       |
        );

        my ( $new_rules, $updated_rules );
        if ( $UpdateNotForLoanStatusOnCheckin && $UpdateNotForLoanStatusOnCheckin !~ /[0-9a-zA-Z_]:\r/ ) {

            # Split and re-format the existing rules under a single _ALL_ special term to affect all itemtypes
            my @rules = split /\r/, $UpdateNotForLoanStatusOnCheckin;
            foreach my $rule (@rules) {
                $rule =~ s/^\s+|\s+$|\r|\n//g;
                $new_rules .= ' ' . $rule . "\r";
            }
            $updated_rules .= "_ALL_:\r$new_rules\r";
            $dbh->do(
                qq{
               UPDATE systempreferences
               SET value = '$updated_rules', explanation = "This is a list of item types and value pairs.\nExamples:\n_ALL_:\n -1: 0\n\nCR:\n 1: 0\n\nWhen an item is checked in, if its item type matches CR then when the value on the left (1) matches the items' not for loan value it will be updated to the value on the right.\n\nThe special term _ALL_ is used on the left side of the colon (:) to affect all item types. This does not override all other rules\n\nEach item type needs to be defined on a separate line on the left side of the colon (:).\nEach pair of not for loan values, for that item type, should be listed on separate lines below the item type, each indented by a leading space."
               WHERE variable = 'UpdateNotForLoanStatusOnCheckin'
           }
            );
        }
    },
};
