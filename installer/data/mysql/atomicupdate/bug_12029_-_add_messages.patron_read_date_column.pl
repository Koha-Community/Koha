use Modern::Perl;

return {
    bug_number => "12029",
    description => "Enable users to dismiss their patron messages",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        if( !column_exists( 'messages', 'patron_read_date' ) ) {
          $dbh->do(q{
              ALTER TABLE messages ADD COLUMN `patron_read_date` timestamp NULL DEFAULT NULL AFTER `manager_id`
          });

          say $out "Added column 'messages.patron_read_date'";
        }
    },
};
