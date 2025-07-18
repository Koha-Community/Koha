use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "40337",
    description => "Define checkprevcheckout as ENUM",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my $col_type_borrowers = $dbh->selectrow_array(
            q{
              SELECT COLUMN_TYPE
              FROM INFORMATION_SCHEMA.COLUMNS
              WHERE TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = 'borrowers'
                AND COLUMN_NAME = 'checkprevcheckout'
            }
        );

        if ( $col_type_borrowers !~ /^enum/i ) {
            $dbh->do(
                q{
                    UPDATE borrowers
                    SET checkprevcheckout = 'inherit'
                    WHERE checkprevcheckout NOT IN ('yes','no','inherit');
                }
            );
            $dbh->do(
                q{
                    ALTER TABLE borrowers
                    MODIFY COLUMN `checkprevcheckout` enum('yes', 'no', 'inherit') NOT NULL DEFAULT 'inherit' COMMENT 'produce a warning for this patron if this item has previously been checked out to this patron if ''yes'', not if ''no'', defer to category setting if ''inherit''.'
                }
            );
        }

        my $col_type_categories = $dbh->selectrow_array(
            q{
              SELECT COLUMN_TYPE
              FROM INFORMATION_SCHEMA.COLUMNS
              WHERE TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = 'categories'
                AND COLUMN_NAME = 'checkprevcheckout'
            }
        );

        if ( $col_type_categories !~ /^enum/i ) {
            $dbh->do(
                q{
                    UPDATE categories
                    SET checkprevcheckout = 'inherit'
                    WHERE checkprevcheckout NOT IN ('yes','no','inherit');
                }
            );
            $dbh->do(
                q{
                    ALTER TABLE categories
                    MODIFY COLUMN `checkprevcheckout` enum('yes', 'no', 'inherit') NOT NULL DEFAULT 'inherit' COMMENT 'produce a warning for this patron category if this item has previously been checked out to this patron if ''yes'', not if ''no'', defer to syspref setting if ''inherit''.'
                }
            );
        }

        my $col_type_deletedborrowers = $dbh->selectrow_array(
            q{
              SELECT COLUMN_TYPE
              FROM INFORMATION_SCHEMA.COLUMNS
              WHERE TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = 'deletedborrowers'
                AND COLUMN_NAME = 'checkprevcheckout'
            }
        );

        if ( $col_type_deletedborrowers !~ /^enum/i ) {
            $dbh->do(
                q{
                    UPDATE deletedborrowers
                    SET checkprevcheckout = 'inherit'
                    WHERE checkprevcheckout NOT IN ('yes','no','inherit');
                }
            );
            $dbh->do(
                q{
                    ALTER TABLE deletedborrowers
                    MODIFY COLUMN `checkprevcheckout` enum('yes', 'no', 'inherit') NOT NULL DEFAULT 'inherit' COMMENT 'produce a warning for this patron if this item has previously been checked out to this patron if ''yes'', not if ''no'', defer to category setting if ''inherit''.'
                }
            );
        }
    },
};
