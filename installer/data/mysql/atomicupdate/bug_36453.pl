use Modern::Perl;

return {
    bug_number  => "36453",
    description => "BlockExpiredPatronOpacActions should allow multiple actions options",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my ($BlockExpiredPatronOpacActions) = $dbh->selectrow_array(
            q{
            SELECT value FROM systempreferences WHERE variable = 'BlockExpiredPatronOpacActions';
        }
        );

        if ( $BlockExpiredPatronOpacActions eq 1 ) {

            # Update system preference settings if 1
            $dbh->do(
                "UPDATE systempreferences SET value='hold,renew' WHERE variable='BlockExpiredPatronOpacActions' and value=1"
            );
            say $out "BlockExpiredPatronOpacActions system preference value updated to 'hold,renew'.";
        } elsif ( $BlockExpiredPatronOpacActions eq 0 ) {

            # Update system preference settings if 0
            $dbh->do(
                "UPDATE systempreferences SET value='' WHERE variable='BlockExpiredPatronOpacActions' and value=0");
            say $out "BlockExpiredPatronOpacActions system preference value updated to empty string.";
        }

        # Update system preference setting to multiple instead of YesNo
        $dbh->do("UPDATE systempreferences SET type='multiple' WHERE variable='BlockExpiredPatronOpacActions'");
        say $out "BlockExpiredPatronOpacActions system preference value updated to multiple.";

        # Update categories database table BlockExpiredPatronOpacActions column settings
        $dbh->do(
            "ALTER TABLE categories MODIFY BlockExpiredPatronOpacActions mediumtext NOT NULL DEFAULT 'follow_syspref_BlockExpiredPatronOpacActions' COMMENT 'specific actions expired patrons of this category are blocked from performing or if the BlockExpiredPatronOpacActions system preference is to be followed'"
        );
        say $out "categories column BlockExpiredPatronOpacActions updated.";

        # Update patron categories using -1
        $dbh->do(
            "UPDATE categories SET BlockExpiredPatronOpacActions = 'follow_syspref_BlockExpiredPatronOpacActions' WHERE BlockExpiredPatronOpacActions = '-1'"
        );
        say $out
            "Patron categories BlockExpiredPatronOpacActions = -1 have been updated to follow the syspref BlockExpiredPatronOpacActions.";

        # Update patron categories using 0
        $dbh->do("UPDATE categories SET BlockExpiredPatronOpacActions = '' WHERE BlockExpiredPatronOpacActions = '0'");
        say $out "Patron categories BlockExpiredPatronOpacActions = 0 have been updated to an empty string ('').";

        # Update patron categories using 1
        $dbh->do(
            "UPDATE categories SET BlockExpiredPatronOpacActions = 'hold,renew' WHERE BlockExpiredPatronOpacActions = '1' "
        );
        say $out "Patron categories BlockExpiredPatronOpacActions = 1 have been updated to hold,renew'.";

    },
};
