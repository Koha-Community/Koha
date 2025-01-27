use Modern::Perl;

return {
    bug_number  => "28959",
    description => "virtualshelves.category is really a boolean",
    up          => sub {
        my ($args) = @_;
        my ($dbh)  = @$args{qw(dbh)};

        unless ( column_exists( 'virtualshelves', 'public' ) ) {

            # Add column
            $dbh->do(
                q{
                ALTER TABLE virtualshelves
                    ADD COLUMN `public` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'If the list is public'
                    AFTER `owner`;
            }
            );

            # Set public lists
            $dbh->do(
                q{
                UPDATE virtualshelves
                SET public = 1
                WHERE category = 2;
            }
            );

            # Drop old column
            $dbh->do(
                q{
                ALTER TABLE virtualshelves
                    DROP COLUMN `category`;
            }
            );
        }
    },
    }
