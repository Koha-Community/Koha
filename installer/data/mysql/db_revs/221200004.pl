use Modern::Perl;

return {
    bug_number  => "30642",
    description => "Record whether a renewal has been done manually or automatically.",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !column_exists( 'checkout_renewals', 'renewal_type' ) ) {
            $dbh->do(
                q{
              ALTER TABLE checkout_renewals ADD COLUMN `renewal_type` enum('Automatic', 'Manual') NOT NULL DEFAULT 'Manual' AFTER `timestamp`
          }
            );

            say $out "Added column 'checkout_renewals.column_name'";
        }
    },
};
