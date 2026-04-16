use Modern::Perl;
use Koha::Installer::Output qw(say_success say_info say_warning);

return {
    bug_number  => "41410",
    description => "Add local holds exclusivity period",
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

        # Rename old pref if it exists (upgrade path)
        my ($old_exists) = $dbh->selectrow_array(
            q{SELECT COUNT(*) FROM systempreferences WHERE variable = 'LocalHoldsPriorityExclusivityPeriod'});
        if ($old_exists) {
            $dbh->do(
                q{UPDATE systempreferences SET variable = 'LocalHoldsExclusivityPeriod',
                    explanation = 'For this many days after a hold is placed, only items flagged as a local hold group match by the holds queue may fill the hold. Set to 0 to disable.'
                  WHERE variable = 'LocalHoldsPriorityExclusivityPeriod'}
            );
            say_success(
                $out,
                "Renamed system preference 'LocalHoldsPriorityExclusivityPeriod' to 'LocalHoldsExclusivityPeriod'"
            );
        } else {
            $dbh->do(
                q{
                    INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type)
                    VALUES (
                        'LocalHoldsExclusivityPeriod',
                        '0',
                        NULL,
                        'For this many days after a hold is placed, only items flagged as a local hold group match by the holds queue may fill the hold. Set to 0 to disable.',
                        'Integer'
                    )
                }
            );
            say_success( $out, "Added new system preference 'LocalHoldsExclusivityPeriod'" );
        }

        $dbh->do(
            q{
                INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type)
                VALUES (
                    'LocalHoldsExclusivityPatronControl',
                    'PickupLibrary',
                    'PickupLibrary|HomeLibrary',
                    'Determine local hold group match for exclusivity by comparing the hold pickup library or the patron home library.',
                    'Choice'
                )
            }
        );
        say_success( $out, "Added new system preference 'LocalHoldsExclusivityPatronControl'" );

        $dbh->do(
            q{
                INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type)
                VALUES (
                    'LocalHoldsExclusivityItemControl',
                    'holdingbranch',
                    'homebranch|holdingbranch',
                    'Determine local hold group match for exclusivity by comparing the item home library or holding library.',
                    'Choice'
                )
            }
        );
        say_success( $out, "Added new system preference 'LocalHoldsExclusivityItemControl'" );
    },
};
