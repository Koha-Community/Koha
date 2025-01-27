use Modern::Perl;

return {
    bug_number  => "23352",
    description => "Adding new column 'subscription.ccode'",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !column_exists( 'subscription', 'ccode' ) ) {
            $dbh->do(
                q{
              ALTER TABLE subscription ADD COLUMN `ccode` varchar(80) DEFAULT NULL AFTER `mana_id`
          }
            );
        }
    },
};
