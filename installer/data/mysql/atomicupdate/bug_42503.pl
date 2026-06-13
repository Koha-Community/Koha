use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "42503",
    description => "Add materialized description columns to tmp_holdsqueue",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'tmp_holdsqueue', 'itype_description' ) ) {
            $dbh->do(
                q{
                ALTER TABLE tmp_holdsqueue
                    ADD COLUMN `itype_description` varchar(255) DEFAULT NULL AFTER `local_holdgroup_match`
            }
            );
            say_success( $out, "Added column 'tmp_holdsqueue.itype_description'" );
        }

        unless ( column_exists( 'tmp_holdsqueue', 'ccode_description' ) ) {
            $dbh->do(
                q{
                ALTER TABLE tmp_holdsqueue
                    ADD COLUMN `ccode_description` varchar(255) DEFAULT NULL AFTER `itype_description`
            }
            );
            say_success( $out, "Added column 'tmp_holdsqueue.ccode_description'" );
        }

        unless ( column_exists( 'tmp_holdsqueue', 'location_description' ) ) {
            $dbh->do(
                q{
                ALTER TABLE tmp_holdsqueue
                    ADD COLUMN `location_description` varchar(255) DEFAULT NULL AFTER `ccode_description`
            }
            );
            say_success( $out, "Added column 'tmp_holdsqueue.location_description'" );
        }

        my $rows = $dbh->do(
            q{
            UPDATE columns_settings SET page = 'holds_queue' WHERE module = 'circ' AND page = 'view_holdsqueue'
        }
        );
        if ( $rows && $rows > 0 ) {
            say_success( $out, "Renamed page view_holdsqueue to holds_queue in columns_settings ($rows rows updated)" );
        } else {
            say_info( $out, "No columns_settings rows found for view_holdsqueue" );
        }

        my $renames = {
            pubdetails     => 'publication_details',
            holdingbranch  => 'holding_library',
            homebranch     => 'home_library',
            document_type  => 'item_type',
            callnumber     => 'call_number',
            copynumber     => 'copy_number',
            enumeration    => 'serial_issue_number',
            patroncategory => 'patron_category',
            send_to        => 'pickup_library',
        };
        for my $from ( keys %{$renames} ) {
            $dbh->do(
                q{UPDATE columns_settings SET columnname = ? WHERE module = 'circ' AND page = 'holds_queue' AND tablename = 'holds-table' AND columnname = ?},
                undef, $renames->{$from}, $from
            );
        }
        say_success( $out, "Renamed holds queue column settings to match new column identifiers" );
    },
};
