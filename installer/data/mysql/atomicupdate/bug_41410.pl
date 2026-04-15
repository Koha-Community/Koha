use Modern::Perl;
use Koha::Installer::Output qw(say_success say_info say_warning);

return {
    bug_number  => "41410",
    description => "Add local holds priority exclusivity period",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( column_exists( 'hold_fill_targets', 'local_holdgroup_match' ) ) {
            say_warning( $out, "Column 'hold_fill_targets.local_holdgroup_match' already exists, skipping." );
        } else {
            $dbh->do(
                q{
                    ALTER TABLE hold_fill_targets
                        ADD COLUMN `local_holdgroup_match` tinyint(1) NOT NULL DEFAULT 0
                        COMMENT 'set when the queue targeted this item as a local hold group match for the reserve'
                        AFTER reserve_id
                }
            );
            say_success( $out, "Added column 'hold_fill_targets.local_holdgroup_match'" );
        }

        if ( column_exists( 'tmp_holdsqueue', 'local_holdgroup_match' ) ) {
            say_warning( $out, "Column 'tmp_holdsqueue.local_holdgroup_match' already exists, skipping." );
        } else {
            $dbh->do(
                q{
                    ALTER TABLE tmp_holdsqueue
                        ADD COLUMN `local_holdgroup_match` tinyint(1) NOT NULL DEFAULT 0
                        COMMENT 'set when the queue targeted this item as a local hold group match for the reserve'
                        AFTER item_level_request
                }
            );
            say_success( $out, "Added column 'tmp_holdsqueue.local_holdgroup_match'" );
        }

        $dbh->do(
            q{
                INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type)
                VALUES (
                    'LocalHoldsPriorityExclusivityPeriod',
                    '0',
                    NULL,
                    'When LocalHoldsPriority is set, for this many days after a hold is placed, only items flagged as a local hold group match by the holds queue may fill the hold. Set to 0 to disable.',
                    'Integer'
                )
            }
        );
        say_success( $out, "Added new system preference 'LocalHoldsPriorityExclusivityPeriod'" );

        say_info(
            $out,
            "The LocalHoldsPriorityExclusivityPeriod feature only takes effect when LocalHoldsPriority is set to something other than 'None'."
        );
    },
};
