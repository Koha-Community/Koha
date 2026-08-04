use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "43072",
    description => "Create fill_other_biblios_hold_policy value where holdallowed value exists",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
            INSERT INTO circulation_rules (itemtype,rule_name,rule_value)
            SELECT itemtype,'fill_other_biblio_holds_policy',1 FROM circulation_rules
            WHERE branchcode IS NULL AND categorycode IS NULL and rule_name='holdallowed' AND
            itemtype NOT IN (
                SELECT itemtype FROM circulation_rules
                WHERE branchcode IS NULL AND categorycode IS NULL and rule_name='fill_other_biblio_holds_policy'
            )
        }
        );

        say $out "Set default fill_other_biblio_holds_policy rule for itemtypes with other policies set";
    },
};
