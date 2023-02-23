use Modern::Perl;

return {
    bug_number  => "31948",
    description => "Add timestamp to tmp_holdsqueue table",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        unless ( column_exists( 'tmp_holdsqueue', 'timestamp' ) ) {
            $dbh->do(q{
                ALTER TABLE `tmp_holdsqueue`
                    ADD `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP AFTER item_level_request
            });
        }
    },
};
