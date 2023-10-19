use Modern::Perl;

return {
    bug_number  => "32721",
    description => "Allow branch specific javascript and css to be injected into the OPAC depending on a branchcode",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !column_exists( 'branches', 'opacuserjs' ) ) {
            $dbh->do(
                q{
              ALTER TABLE branches
                ADD COLUMN `opacuserjs` longtext DEFAULT NULL COMMENT 'branch specific javascript for the OPAC'
                AFTER `public`
          }
            );

            say $out "Added column 'branches.opacuserjs'";
        }
        if ( !column_exists( 'branches', 'opacusercss' ) ) {
            $dbh->do(
                q{
              ALTER TABLE branches
                ADD COLUMN `opacusercss` longtext DEFAULT NULL COMMENT 'branch specific css for the OPAC'
                AFTER `opacuserjs`
          }
            );

            say $out "Added column 'branches.opacusercss'";
        }
    },
};
