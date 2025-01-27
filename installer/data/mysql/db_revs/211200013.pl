use Modern::Perl;

return {
    bug_number  => "29605",
    description => "Resync DB structure for existing installations",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if (   !primary_key_exists( 'language_script_mapping', 'language_subtag' )
            and index_exists( 'language_script_mapping', 'language_subtag' ) )
        {

            $dbh->do(
                q{
                ALTER TABLE language_script_mapping
                DROP KEY `language_subtag`;
            }
            );
        }

        if ( !primary_key_exists( 'language_script_mapping', 'language_subtag' ) ) {

            $dbh->do(
                q{
                ALTER TABLE language_script_mapping
                ADD PRIMARY KEY `language_subtag` (`language_subtag`);
            }
            );

            say $out "Added missing primary key on language_script_mapping";
        }

        unless ( foreign_key_exists( 'tmp_holdsqueue', 'tmp_holdsqueue_ibfk_3' ) ) {
            $dbh->do(
                q{
                ALTER TABLE tmp_holdsqueue
                ADD CONSTRAINT `tmp_holdsqueue_ibfk_3` FOREIGN KEY (`borrowernumber`)
                REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
            }
            );

            say $out "Added missing foreign key on tmp_holdsqueue";
        }

        $dbh->do(
            q{
                ALTER TABLE `account_offsets`
                MODIFY COLUMN `type` enum( 'CREATE', 'APPLY', 'VOID', 'OVERDUE_INCREASE', 'OVERDUE_DECREASE' ) NOT NULL
        }
        );
        say $out "Ensure NOT NULL on account_offsets.type";

        $dbh->do(
            q{
                ALTER TABLE `additional_contents`
                MODIFY COLUMN `code` VARCHAR(100) NOT NULL
        }
        );
        say $out "Ensure additional_contents.code is VARCHAR(100)";

        if ( column_exists( 'additional_contents', 'lang' ) ) {
            $dbh->do(
                q{
                    ALTER TABLE `additional_contents`
                    MODIFY COLUMN `lang` VARCHAR(50) NOT NULL DEFAULT ''
            }
            );
            say $out "Ensure additional_contents.lang is VARCHAR(50)";
        }

        $dbh->do(
            q{
            ALTER TABLE search_marc_map MODIFY `marc_type` enum('marc21','unimarc') NOT NULL COMMENT 'what MARC type this map is for'
        }
        );
        say $out "Ensure NOT NULL on search_marc_map.marc_type";

        $dbh->do(
            q{
            alter table
                `branchtransfers`
            modify column
                `cancellation_reason` enum(
                    'Manual',
                    'StockrotationAdvance',
                    'StockrotationRepatriation',
                    'ReturnToHome',
                    'ReturnToHolding',
                    'RotatingCollection',
                    'Reserve',
                    'LostReserve',
                    'CancelReserve',
                    'ItemLost',
                    'WrongTransfer'
                ) DEFAULT NULL
            after `reason`
        }
        );
        say $out "Ensure branchtransfers.cancellation_reason enum values are uppercase";
    },

};
