use Modern::Perl;

return {
    bug_number  => "28854",
    description => "Add new 'item_issue' unique index to return claims",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        if ( !unique_key_exists( 'return_claims', 'item_issue' ) ) {
            $dbh->do(
                q{
                ALTER TABLE return_claims
                ADD UNIQUE KEY item_issue (`itemnumber`,`issue_id`)
            }
            );
        }
    },
};
