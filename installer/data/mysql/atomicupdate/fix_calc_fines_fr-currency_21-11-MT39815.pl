use Modern::Perl;

return {
    bug_number => "BUG_33028",
    description =>
"Fix calculations around fines and values with comma as decimal separator",
    up => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my $rules = $dbh->selectall_arrayref(
q|select * from circulation_rules where rule_name IN ('fine', 'overduefinescap')|,
            { Slice => {} }
        );

        my $query = $dbh->prepare(
            "UPDATE circulation_rules SET rule_value = ? where id = ?");

        foreach my $rule ( @{$rules} ) {
            my $rule_id    = $rule->{'id'};
            my $rule_value = $rule->{'rule_value'};
            if ( $rule_value =~ /[a-zA-Z]/ ) {
                die(
                    sprintf(
                        'No only numbers in rule id %s ("%s") - fix it before restart this update',
                        $rule_id, $rule_value
                    )
                );
            }
            else {
                if ( $rule_value =~ /,/ ) {
                    if ( $rule_value !~ /,.*?,/ ) {
                        $rule_value =~ s/,/./;
                        $rule_value =~ s/\.0+$//;
                        $query->execute( $rule_value, $rule_id );
                    }
                    else {
                        die(
                            sprintf(
                                'Many commas in rule id %s ("%s") - fix it before restart this update',
                                $rule_id, $rule_value
                            )
                        );
                    }
                }
            }

        }
        say $out
        "BUG_33028 - Patch applied";
    },
  }
