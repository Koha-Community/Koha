use Modern::Perl;

return {
    bug_number  => "28924",
    description => "Adds columns to patron categories to allow category level values for the no issue charge sysprefs",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'categories', 'noissuescharge' ) ) {
            $dbh->do(
                q{ ALTER TABLE categories ADD COLUMN `noissuescharge` int(11) AFTER `exclude_from_local_holds_priority` }
            );

            say $out "Added column 'noissuescharge' to categories";
        }
        unless ( column_exists( 'categories', 'noissueschargeguarantees' ) ) {
            $dbh->do(q{ ALTER TABLE categories ADD COLUMN `noissueschargeguarantees` int(11) AFTER `noissuescharge` });

            say $out "Added column 'noissueschargeguarantees' to categories";
        }
        unless ( column_exists( 'categories', 'noissueschargeguarantorswithguarantees' ) ) {
            $dbh->do(
                q{ ALTER TABLE categories ADD COLUMN `noissueschargeguarantorswithguarantees` int(11) AFTER `noissueschargeguarantees` }
            );

            say $out "Added column 'noissueschargeguarantorswithguarantees' to categories";
        }
    },
};
