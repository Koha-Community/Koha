use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);
use Try::Tiny;

return {
    bug_number  => "37511",
    description => "Add a new column p_cs_precedes to the table currency",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !column_exists( 'currency', 'p_cs_precedes' ) ) {
            $dbh->do(
                q{
 ALTER TABLE `currency` ADD COLUMN `p_cs_precedes` tinyint(1) DEFAULT 1 AFTER p_sep_by_space
            }
            );
            say_success( $out, "Added column 'currency.p_cs_precedes'" );
        } else {
            say_info( $out, "Column 'currency.p_cs_precedes' already exists" );
        }
    },
};
