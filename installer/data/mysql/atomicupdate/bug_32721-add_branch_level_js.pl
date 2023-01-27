use Modern::Perl;

return {
    bug_number => "32721",
    description => "Allow branch specific javascript and css to be injected into the OPAC depending on a branchcode",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        if( !column_exists( 'branches', 'userjs' ) ) {
          $dbh->do(q{
              ALTER TABLE branches ADD COLUMN `userjs` longtext DEFAULT NULL AFTER `public`
          });

          say $out "Added column 'branches.userjs'";
        }
        if( !column_exists( 'branches', 'usercss' ) ) {
          $dbh->do(q{
              ALTER TABLE branches ADD COLUMN `usercss` longtext DEFAULT NULL AFTER `userjs`
          });

          say $out "Added column 'branches.usercss'";
        }
    },
};