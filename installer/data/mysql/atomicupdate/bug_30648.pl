use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number => "30648",
    description => "Store biblionumber of deleted record in old reserves",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        if ( !column_exists( 'reserves', 'deleted_biblionumber' ) ) {

            $dbh->do(
                q{
                ALTER TABLE `reserves`
                    ADD COLUMN `deleted_biblionumber` int(11) NULL DEFAULT NULL COMMENT 'links the reserve to the deleted bibliographic record (deletedbiblio.biblionumber)' AFTER biblionumber
            }
            );
        }
        say $out "Added column 'reserves.deleted_biblionumber'";
        if ( !column_exists( 'old_reserves', 'deleted_biblionumber' ) ) {

            $dbh->do(
                q{
                ALTER TABLE `old_reserves`
                    ADD COLUMN `deleted_biblionumber` int(11) NULL DEFAULT NULL COMMENT 'links the reserve to the deleted bibliographic record (deletedbiblio.biblionumber)' AFTER biblionumber
            }
            );
        }
        say $out "Added column 'old_reserves.deleted_biblionumber'";
    },
};
