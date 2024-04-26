use Modern::Perl;

return {
    bug_number  => "33478",
    description => "Customise the format of notices when they are printed",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !column_exists( 'letter', 'style' ) ) {
            $dbh->do(
                q{
              ALTER TABLE letter ADD COLUMN `style` mediumtext DEFAULT NULL AFTER `updated_on`
          }
            );

            say $out "Added column 'letter.style'";
        }
    },
};
