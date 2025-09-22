use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "26993",
    description => "Remove unique constraint on itemnumber in items_last_borrower to allow multiple borrowers per item",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Drop the foreign key constraint temporarily
        if ( index_exists( 'items_last_borrower', 'itemnumber' ) ) {
            $dbh->do(
                q{
                ALTER TABLE items_last_borrower
                DROP FOREIGN KEY items_last_borrower_ibfk_1
            }
            );

            # Drop the unique index
            $dbh->do(
                q{
                ALTER TABLE items_last_borrower DROP INDEX itemnumber
            }
            );

            # Put the FK constraint back, without itemnumber having to be unique
            $dbh->do(
                q{
                ALTER TABLE items_last_borrower
                ADD CONSTRAINT items_last_borrower_ibfk_1
                FOREIGN KEY (itemnumber) REFERENCES items (itemnumber)
                ON DELETE CASCADE ON UPDATE CASCADE
        }
            );

            say_success( $out, "Adjusted foreign key constraints on items_last_borrower table" );
        }

        # Update system preference from YesNo to Integer
        $dbh->do(
            q{
            UPDATE systempreferences
            SET type = 'integer',
                explanation = 'Defines the number of borrowers stored per item in the items_last_borrower table'
            WHERE variable = 'StoreLastBorrower'
        }
        );

        say_success( $out, "Updated StoreLastBorrower system preference to accept numeric values" );

    },
};
