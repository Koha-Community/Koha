use Modern::Perl;

return {
    bug_number  => "29495",
    description => "Drop issue_id constraint from return_claims table",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        if ( foreign_key_exists( 'return_claims', 'issue_id' ) ) {
            $dbh->do(
                q{
                ALTER TABLE return_claims DROP FOREIGN KEY issue_id
            }
            );
        }
    },
};
