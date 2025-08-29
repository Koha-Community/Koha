use Modern::Perl;

return {
    bug_number  => "20644",
    description => "Add the column checkprevcheckout to itemtypes table",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !column_exists( 'itemtypes', 'checkprevcheckout' ) ) {
            $dbh->do(
                q{
                ALTER TABLE itemtypes
                ADD COLUMN checkprevcheckout enum('yes', 'no', 'inherit') NOT NULL DEFAULT 'inherit' COMMENT 'produce a warning for a patron if a item of this type has previously been checked out to the same patron if ''yes'', not if ''no'', defer to category setting if ''inherit''.'
                AFTER bookable;
            }
            );
        }

        say $out "Added column 'itemtypes.checkprevcheckout'";
    },
};
