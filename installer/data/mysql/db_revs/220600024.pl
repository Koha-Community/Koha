use Modern::Perl;

return {
    bug_number  => "29012/33847",    # dbrev fixed on report 33847
    description => "Some rules are not saved when left blank while editing a 'rule' line in smart-rules.pl",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        my %default_rule_values = (
            issuelength             => 0,
            hardduedate             => q{},
            unseen_renewals_allowed => q{},
            rentaldiscount          => 0,
            decreaseloanholds       => q{},
        );

        my $sth = $dbh->prepare(
            q{
            SELECT codes.branchcode, codes.categorycode, codes.itemtype
                FROM circulation_rules codes
            WHERE codes.rule_name = 'fine'
                AND NOT EXISTS
                    (SELECT NULL FROM circulation_rules cr
                    WHERE cr.rule_name = ?
                    AND cr.branchcode <=> codes.branchcode
                    AND cr.categorycode <=> codes.categorycode
                    AND cr.itemtype <=> codes.itemtype)
        }
        );
        my $insert_sth = $dbh->prepare(
            q{
            INSERT IGNORE INTO circulation_rules (branchcode, categorycode, itemtype, rule_name, rule_value)
            SELECT codes.branchcode, codes.categorycode, codes.itemtype, ?, IFNULL(effective.rule_value, ?)
                FROM circulation_rules codes
            LEFT JOIN circulation_rules effective
                ON effective.rule_name = ?
                AND (effective.branchcode <=> codes.branchcode OR effective.branchcode IS NULL)
                AND (effective.categorycode <=> codes.categorycode OR effective.categorycode IS NULL)
                AND (effective.itemtype <=> codes.itemtype OR effective.itemtype IS NULL)
            WHERE codes.branchcode <=> ? AND codes.categorycode <=> ? AND codes.itemtype <=> ? AND codes.rule_name = 'fine'
            ORDER BY effective.branchcode DESC, effective.categorycode DESC, effective.itemtype DESC
            LIMIT 1
        }
        );
        my ( $branchcode, $categorycode, $itemtype );
        while ( my ( $rule_name, $rule_value ) = each(%default_rule_values) ) {
            $sth->execute($rule_name);
            $sth->bind_columns( \( $branchcode, $categorycode, $itemtype ) );
            while ( $sth->fetch ) {
                $insert_sth->execute( $rule_name, $rule_value, $rule_name, $branchcode, $categorycode, $itemtype );
            }
        }

        say $out "Set derived values for blank circulation rules that weren't saved to the database";
    },
};
