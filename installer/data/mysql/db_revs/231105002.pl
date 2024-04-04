use Modern::Perl;

return {
    bug_number  => "35610",
    description => "Add FK on old_reserves.branchcode",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( foreign_key_exists( 'old_reserves', 'old_reserves_ibfk_branchcode' ) ) {
            $dbh->do(
                q{
                UPDATE old_reserves
                SET branchcode = NULL
                WHERE branchcode NOT IN (SELECT branchcode FROM branches)
            }
            );

            $dbh->do(
                q{
                ALTER TABLE old_reserves
                ADD CONSTRAINT `old_reserves_ibfk_branchcode` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE SET NULL ON UPDATE CASCADE;
            }
            );
            say $out "Added foreign key on 'old_reserves.branchcode'";
        }
    },
};
