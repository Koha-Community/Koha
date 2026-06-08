use Modern::Perl;
use Koha::Installer::Output qw(say_success say_info);

return {
    bug_number  => '41898',
    description => "Introduce 'issued' booking status and repurpose 'completed' for post-return",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @{$args}{qw(dbh out)};

        # Extend the enum to include the new 'issued' value.
        # Existing 'completed' rows remain valid during migration below.
        $dbh->do(
            q{
            ALTER TABLE `bookings`
            MODIFY COLUMN `status`
                ENUM('new', 'cancelled', 'issued', 'completed') NOT NULL DEFAULT 'new'
                COMMENT 'current status of the booking'
        }
        );
        say_success( $out, "Updated 'bookings.status' enum to include 'issued'" );

        # In the old scheme 'completed' meant the item had been checked out.
        # Migrate those rows intelligently:
        #   - bookings with an active checkout (in issues) → 'issued'
        #   - bookings whose item has already been returned → 'completed' (unchanged,
        #     which is correct under the new scheme where 'completed' means returned)
        my $updated = $dbh->do(
            q{
            UPDATE bookings b
            INNER JOIN issues i ON i.booking_id = b.booking_id
            SET b.status = 'issued'
            WHERE b.status = 'completed'
        }
        );
        say_success( $out, "Migrated $updated 'completed' bookings to 'issued' (item still on loan)" );
        say_info(
            $out,
            "Remaining 'completed' bookings represent returned items and are correctly classified"
        );
    },
};
