use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "28633",
    description => "Add preferred_name to borrowers table",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        if ( !column_exists( 'borrowers', 'preferred_name' ) ) {
            $dbh->do(
                q{
                ALTER TABLE borrowers
                ADD COLUMN preferred_name longtext NULL DEFAULT NULL
                COMMENT "patron/borrower's preferred name"
                AFTER firstname
            }
            );
            say_success( $out, "Added column 'borrowers.preferred_name'" );
        }
        if ( !column_exists( 'deletedborrowers', 'preferred_name' ) ) {
            $dbh->do(
                q{
                ALTER TABLE deletedborrowers
                ADD COLUMN preferred_name longtext NULL DEFAULT NULL
                COMMENT "patron/borrower's preferred name"
                AFTER firstname
            }
            );
            say_success( $out, "Added column 'deletedborrowers.preferred_name'" );
        }
        if ( !column_exists( 'borrower_modifications', 'preferred_name' ) ) {
            $dbh->do(
                q{
                ALTER TABLE borrower_modifications
                ADD COLUMN preferred_name longtext NULL DEFAULT NULL
                COMMENT "patron/borrower's preferred name"
                AFTER firstname
            }
            );
            say_success( $out, "Added column 'borrower_modifications.preferred_name'" );
        }
        my @default_patron_search_fields = split( '\|', C4::Context->preference('DefaultPatronSearchFields') );
        unless ( grep /preferred_name/, @default_patron_search_fields ) {
            if ( grep /firstname/, @default_patron_search_fields ) {
                push @default_patron_search_fields, 'preferred_name';
                C4::Context->set_preference( 'DefaultPatronSearchFields', join( '|', @default_patron_search_fields ) );
                say_info( $out, "Added 'preferred_name' to DefaultPatronSearchFields" );
            } else {
                say_info(
                    $out,
                    "Please add 'preferred_name' to 'DefaultPatronSearchFields' if you want it searched by default"
                );
            }
        }
        $dbh->do(
            q{
            UPDATE borrowers
            SET preferred_name = firstname
            WHERE preferred_name IS NULL
        }
        );
        say_success( $out, "Initially set 'preferred_name' to 'firstname'" );
    },
    }
