use Modern::Perl;

return {
    bug_number  => "25393",
    description => "Create separate 'no automatic renewal before' rule",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my $rules = $dbh->selectall_arrayref(
            q|SELECT * FROM circulation_rules WHERE rule_name = "noautorenewalbefore"|,
            { Slice => {} }
        );

        if ( !scalar @{$rules} ) {
            my $existing_rules = $dbh->selectall_arrayref(
                q|SELECT * FROM circulation_rules WHERE rule_name = "norenewalbefore"|,
                { Slice => {} }
            );

            my $insert_sth = $dbh->prepare(
                q{INSERT INTO circulation_rules ( branchcode, categorycode, itemtype, rule_name, rule_value ) VALUES (?, ?, ?, ?, ?)}
            );

            for my $existing_rule ( @{$existing_rules} ) {
                $insert_sth->execute(
                    $existing_rule->{branchcode},
                    $existing_rule->{categorycode},
                    $existing_rule->{itemtype},
                    'noautorenewalbefore',
                    $existing_rule->{rule_value}
                );
            }
            say $out
                "New circulation rule 'noautorenewalbefore' has been added. Defaulting value to 'norenewalbefore'.";
        } else {
            say $out "Circulation rule 'noautorenewalbefore' found. Skipping update.";
        }

    },
};
