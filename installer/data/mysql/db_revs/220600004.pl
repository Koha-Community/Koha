use Modern::Perl;

return {
    bug_number  => "12446",
    description => "Ability to allow guarantor relationship for all patron category types",
    up => sub {
        my ($args) = @_;
        my ($dbh) = @$args{qw(dbh)};

        unless ( column_exists( 'categories', 'canbeguarantee' ) ) {
            $dbh->do(q{
                ALTER TABLE categories
                    ADD COLUMN `canbeguarantee` tinyint(1) NOT NULL default 0 COMMENT 'if patrons of this category can be guarantees'
                    AFTER `checkprevcheckout`
            });
        }

        $dbh->do(q{
            UPDATE categories
            SET canbeguarantee = 1
            WHERE category_type = 'P' OR category_type = 'C'
        });
    },
};
