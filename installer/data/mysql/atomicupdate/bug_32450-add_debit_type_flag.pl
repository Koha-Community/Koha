use Modern::Perl;

return {
    bug_number => "32450",
    description => "Create a database flag for whether a debit type should be included in the noissuescharge block on circulation and remove redundant sysprefs.",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        if( !column_exists( 'account_debit_types', 'restricts_checkouts' ) ) {
          $dbh->do(q{
              ALTER TABLE account_debit_types ADD COLUMN `restricts_checkouts` tinyint(1) NOT NULL DEFAULT 1
                  COMMENT 'boolean flag to denote if the noissuescharge syspref for this debit type is active'
                  AFTER `archived`;
          });

          say $out "Added column 'account_debit_types.restricts_checkouts'";
        }

        # Before deleting the redundant system preferences we need to check if they had been modified and update the new database flags accordingly
        my @sysprefs = ('ManInvInNoissuesCharge', 'RentalsInNoissuesCharge', 'HoldsInNoissuesCharge');

        # Hardcoded values from sub non_issues_charges
        my @holds = ('RESERVE');
        my @rentals = ('RENT', 'RENT_DAILY', 'RENT_RENEW', 'RENT_DAILY_RENEW');
        my @manual;
        my $sth = $dbh->prepare("SELECT code FROM account_debit_types WHERE is_system = 0");
        $sth->execute;
        while (my $code = $sth->fetchrow_array) {
            push @manual, $code;
        }

        for (@sysprefs){
            # Check if the syspref exists in the database
            my $check_syspref_exists = "SELECT COUNT(*) FROM systempreferences WHERE variable = '$_'";
            my $sth = $dbh->prepare($check_syspref_exists);
            $sth->execute;
            my $exists = $sth->fetchrow();
            $sth->finish;

            if($exists) {
                # If it exists, retrieve its value
                my $find_syspref_value = "SELECT value FROM systempreferences WHERE variable = '$_'";
                my $sth = $dbh->prepare($find_syspref_value);
                $sth->execute;
                my $value = $sth->fetchrow();
                $sth->finish;

                if($value){
                    say $out "$_ is included in the charge, default database value of 1 can be applied.";
                } else {
                    # Update account_debit_types to reflect existing syspref value.
                    my @debit_types_to_update;

                    if($_ eq 'ManInvInNoissuesCharge') { push @debit_types_to_update, @manual};
                    if($_ eq 'RentalsInNoissuesCharge') { push @debit_types_to_update, @rentals};
                    if($_ eq 'HoldsInNoissuesCharge') { push @debit_types_to_update, @holds};

                    my $string = join(",", map { $dbh->quote($_) } @debit_types_to_update);
                    my $update_query = "UPDATE account_debit_types SET restricts_checkouts = 0 WHERE code IN (" . $string . ")";
                    my $sth = $dbh->prepare($update_query);
                    $sth->execute;
                    $sth->finish;

                    say $out "$_ has been updated to not be included in the charge, account_debit_types has been updated to match this.";
                }

                # Delete syspref as it is no longer required and the value has been transferred to account_debit_types
                my $delete_redundant_syspref = "DELETE FROM systempreferences WHERE variable = '$_'";
                $dbh->do($delete_redundant_syspref);

            } else {
                # If it doesn't exist then revert to default value in the database schema
                say $out "$_ was not found in this Koha instance, default value has been applied.";
            }

        }
    },
};
