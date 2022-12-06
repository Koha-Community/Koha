use Modern::Perl;

return {
    bug_number => "BUG_30642",
    description => "Record whether a renewal has been done manually or automatically.",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        if( !column_exists( 'checkout_renewals', 'renewal_type' ) ) {
          $dbh->do(q{
              ALTER TABLE checkout_renewals ADD COLUMN `renewal_type` varchar(9) NOT NULL AFTER `timestamp`
          });

          say $out "Added column 'checkout_renewals.column_name'";
        }
    },
};