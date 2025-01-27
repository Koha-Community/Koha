use Modern::Perl;

return {
    bug_number  => "20472",
    description => "Add columns format and urls in article_requests table",
    up          => sub {
        my ($args) = @_;
        my $dbh = $args->{dbh};

        unless ( column_exists( 'article_requests', 'format' ) ) {
            $dbh->do(
                q|
                ALTER TABLE article_requests
                ADD COLUMN `format` enum('PHOTOCOPY', 'SCAN') NOT NULL DEFAULT 'PHOTOCOPY' AFTER notes
            |
            );
        }
        unless ( column_exists( 'article_requests', 'urls' ) ) {
            $dbh->do(
                q|
                ALTER TABLE article_requests
                ADD COLUMN `urls` MEDIUMTEXT AFTER format
            |
            );
        }
    },
    }
