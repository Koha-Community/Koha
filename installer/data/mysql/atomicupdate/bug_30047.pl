use Modern::Perl;

return {
    bug_number  => "30047",
    description => "Add thesaurus and heading fields to auth_header table",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !column_exists( 'auth_header', 'heading' ) ) {
            $dbh->do(
                q{
              ALTER TABLE auth_header ADD COLUMN `heading` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `modification_time`
          }
            );
            say $out "Added column 'auth_header.heading'";
        }

    },
};
