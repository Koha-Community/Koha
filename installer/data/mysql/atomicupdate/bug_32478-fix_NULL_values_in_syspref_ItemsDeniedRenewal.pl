use Modern::Perl;
use C4::Context;

return {
    bug_number => "32478",
    description => "Remove usage of Koha::Config::SysPref->find since bypasses cache",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        $dbh->do(q{UPDATE `systempreferences` SET `value` = REPLACE(`value`, 'NULL', 'null') WHERE `variable` = 'ItemsDeniedRenewal'});
        say $out "Replace 'NULL' with 'null' in ItemsDeniedRenewal system preference";

        C4::Context->clear_syspref_cache();
        say $out "Clear system preference cache";
    },
};
