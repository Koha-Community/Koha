use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "35539",
    description => "Remove unused columns from 'categories' table",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( column_exists( 'categories', 'bulk' ) ) {
            my ($bulkdata) = $dbh->selectrow_array(
                q|
                SELECT bulk FROM categories WHERE bulk IS NOT NULL;
            |
            );
            if ($bulkdata) {
                say_warning(
                    $out,
                    "Data was found in 'bulk' column in 'categories' table. Please remove this data and run the update again."
                );
            } else {
                $dbh->do("ALTER TABLE categories DROP COLUMN bulk");
                say_info( $out, "Removed 'bulk' column from 'categories' table" );
            }
        }

        if ( column_exists( 'categories', 'finetype' ) ) {
            my ($bulkdata) = $dbh->selectrow_array(
                q|
                SELECT finetype FROM categories WHERE finetype IS NOT NULL;
            |
            );
            if ($bulkdata) {
                say_warning(
                    $out,
                    "Data was found in 'finetype' column in 'categories' table. Please remove this data and run the update again."
                );

            } else {
                $dbh->do("ALTER TABLE categories DROP COLUMN finetype");
                say_info( $out, "Removed 'finetype' column from 'categories' table" );
            }
        }

        if ( column_exists( 'categories', 'issuelimit' ) ) {
            my ($bulkdata) = $dbh->selectrow_array(
                q|
                SELECT issuelimit FROM categories WHERE issuelimit IS NOT NULL;
            |
            );
            if ($bulkdata) {
                say_warning(
                    $out,
                    "Data was found in 'issuelimit' column in 'categories' table. Please remove this data and run the update again."
                );
            } else {
                $dbh->do("ALTER TABLE categories DROP COLUMN issuelimit");
                say_info( $out, "Removed 'issuelimit' column from 'categories' table" );
            }
        }
    },
};
