use Modern::Perl;

return {
    bug_number  => "28774",
    description => "Delete blank rental discounts",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            DELETE FROM circulation_rules
            WHERE rule_name = 'rentaldiscount' AND rule_value=''
        }
        );
    },
    }
