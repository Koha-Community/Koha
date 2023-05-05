use Modern::Perl;

return {
    bug_number => "33262",
    description => "Store biblionumber of deleted record in acquisition orders",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        if ( !column_exists( 'aqorders', 'deleted_biblionumber' ) ) {

            $dbh->do(
                q{
                ALTER TABLE `aqorders`
                    ADD COLUMN `deleted_biblionumber` int(11) NULL DEFAULT NULL COMMENT 'links the order to the deleted bibliographic record (deletedbiblio.biblionumber)' AFTER biblionumber
            }
            );
        }
        say $out "Added column 'aqorders.deleted_biblionumber'";
    },
};
