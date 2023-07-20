use Modern::Perl;

return {
    bug_number  => 33379,
    description => "Remove unused column virtualshelfcontents.flags",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        if ( column_exists( 'virtualshelfcontents', 'flags' ) ) {
            $dbh->do(
                q{
ALTER TABLE virtualshelfcontents DROP COLUMN flags;
            }
            );
            say $out "Removed column 'virtualshelfcontents.flags'";
        }
    },
};
