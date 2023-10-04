use Modern::Perl;

return {
    bug_number  => "9525",
    description => "Add option to set group as local float group",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'library_groups', 'ft_local_float_group' ) ) {
            $dbh->do(
                q{
                ALTER TABLE library_groups
                    ADD COLUMN `ft_local_float_group` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Use this group to identify libraries as part of float group'
                    AFTER ft_local_hold_group
                    }
            );

            say $out "Added column 'library_groups.ft_local_float_group'";
        }
    },
};
