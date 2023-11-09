use Modern::Perl;

return {
    bug_number  => "34517",
    description => "Add option to specify which patron attributes are searched by default",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        unless ( column_exists( 'borrower_attribute_types', 'searched_by_default' ) ) {
            $dbh->do(
                q{
                ALTER TABLE borrower_attribute_types
                ADD COLUMN `searched_by_default` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'defines if this field is included in "Standard" patron searches in the staff interface (1 for yes, 0 for no)'
                AFTER `staff_searchable`
            }
            );
            say $out "Added column 'borrower_attribute_types.searched_by_default'";
            $dbh->do(
                q{
                UPDATE borrower_attribute_types
                SET searched_by_default = 1 WHERE staff_searchable = 1;
            }
            );
            say $out "Updated values to match staff_searchable columns";
        }
    },
};
