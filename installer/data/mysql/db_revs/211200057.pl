use Modern::Perl;

return {
    bug_number  => "30852",
    description => "Add index to article_requests.debit_id",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        unless ( index_exists( 'article_requests', 'debit_id' ) ) {
            $dbh->do(
                q{
                ALTER TABLE `article_requests`
                ADD KEY `debit_id` (`debit_id`)
            }
            );
        }
    },
};
