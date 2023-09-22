use Modern::Perl;

return {
    bug_number => "29093",
    description => "Add column article_requests.toc_request",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        if( !column_exists('article_requests', 'toc_request') ) {
            $dbh->do( q|
                ALTER TABLE article_requests ADD COLUMN toc_request tinyint(4) NOT NULL DEFAULT 0
                COMMENT 'borrower requested table of contents'
                AFTER updated_on
            |);
        }
    },
}
