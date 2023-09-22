use Modern::Perl;

return {
    bug_number  => 34843,
    description => "Restore comment on article_requests.toc_request",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
                ALTER TABLE article_requests MODIFY COLUMN toc_request tinyint(4) NOT NULL DEFAULT 0
                COMMENT 'borrower requested table of contents'
                AFTER updated_on
        }
        );
    },
};
