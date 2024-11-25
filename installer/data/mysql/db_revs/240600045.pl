use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "35906",
    description => "Add bookable column on itemtypes table",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !column_exists( 'itemtypes', 'bookable' ) ) {
            $dbh->do(
                q{
                ALTER TABLE itemtypes ADD COLUMN bookable tinyint(1) NOT NULL DEFAULT 0
                COMMENT "Activate bookable feature for items related to this item type"
                AFTER automatic_checkin
            }
            );

            say_success( $out, "Added column 'itemtypes.bookable'" );
        }

        $dbh->do(
            q{
            ALTER TABLE items MODIFY COLUMN bookable tinyint(1) DEFAULT NULL COMMENT 'nullable boolean value defining whether this this item is available for bookings or not'
        }
        );

        say_success( $out, "Updated column 'items.bookable' allow nullable" );

        $dbh->do(
            q{
            ALTER TABLE deleteditems MODIFY COLUMN bookable tinyint(1) DEFAULT NULL COMMENT 'nullable boolean value defining whether this this item is available for bookings or not'
        }
        );

        say_success( $out, "Updated column 'deleteditems.bookable' allow nullable" );

    },
};
