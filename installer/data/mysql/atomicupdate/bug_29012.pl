use Modern::Perl;

return {
    bug_number => "29012",
    description => "Some rules are not saved when left blank while editing a 'rule' line in smart-rules.pl",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        my %default_rule_values = (
            issuelength             => 0,
            hardduedate             => '',
            unseenrenewalsallowed   => '',
            rentaldiscount          => 0,
            decreaseloanholds       => '',
        );
        while (my ($rule_name, $rule_value) = each (%default_rule_values)) {
            $dbh->do(q{
                INSERT IGNORE INTO circulation_rules (branchcode, categorycode, itemtype, rule_name, rule_value)
                    SELECT branchcode, categorycode, itemtype, ?, ? FROM circulation_rules cr
                        WHERE NOT EXISTS (
                            SELECT * FROM circulation_rules cr2
                                WHERE
                                    cr2.rule_name=?
                                    AND ( (cr2.branchcode=cr.branchcode) OR ( ISNULL(cr2.branchcode) AND ISNULL(cr.branchcode) ) )
                                    AND ( (cr2.categorycode=cr.categorycode) OR ( ISNULL(cr2.categorycode) AND ISNULL(cr.categorycode) ) )
                                    AND ( (cr2.itemtype=cr.itemtype) OR ( ISNULL(cr2.itemtype) AND ISNULL(cr.itemtype) ) )
                        )
                        GROUP BY branchcode, categorycode, itemtype
            }, undef, $rule_name, $rule_value, $rule_name);
        }
        say $out "Add default values for blank circulation rules that weren't saved to the database";
    },
}
