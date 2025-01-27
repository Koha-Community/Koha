use Modern::Perl;

return {
    bug_number  => "12446",
    description => "Ability to allow guarantor relationship for all patron category types",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'categories', 'can_be_guarantee' ) ) {
            $dbh->do(
                q{
                ALTER TABLE categories
                    ADD COLUMN `can_be_guarantee` tinyint(1) NOT NULL default 0 COMMENT 'if patrons of this category can be guarantees'
                    AFTER `checkprevcheckout`
            }
            );
            say $out "Added column 'categories.can_be_guarantee'";
        }

        $dbh->do(
            q{
            UPDATE categories
            SET can_be_guarantee = 1
            WHERE category_type = 'P' OR category_type = 'C'
        }
        );
    },
};
