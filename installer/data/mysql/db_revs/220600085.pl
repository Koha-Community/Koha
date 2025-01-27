use Modern::Perl;

return {
    bug_number  => "32030",
    description => "Add primary key to erm_user_roles",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'erm_user_roles', 'user_role_id' ) ) {
            $dbh->do(
                q{
                ALTER TABLE `erm_user_roles`
                ADD COLUMN `user_role_id` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key' FIRST,
                ADD PRIMARY KEY(`user_role_id`);
            }
            );
        }
    }
};
