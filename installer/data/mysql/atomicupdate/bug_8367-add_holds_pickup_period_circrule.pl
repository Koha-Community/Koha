use Modern::Perl;

return {
    bug_number  => "8367",
    description => "Set hold pickup period circulation rule",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO circulation_rules ( branchcode, categorycode, itemtype, rule_name, rule_value )
            SELECT u.* FROM (SELECT NULL as branchcode, NULL as categorycode, NULL as itemtype, 'holds_pickup_period' as rule_name, '' as rule_value) u
            WHERE NOT EXISTS ( SELECT rule_name FROM circulation_rules where rule_name = 'holds_pickup_period' )
        }
        );

        say $out "Added default circulation rule for holds_pickup_period";
    },
};
