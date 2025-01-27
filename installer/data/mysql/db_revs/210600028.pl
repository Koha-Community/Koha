use Modern::Perl;

return {
    bug_number  => "27944",
    description =>
        "Add REQUESTED as enum element for status column, move AR_PENDING letter to AR_REQUESTED, and add new AR_PENDING letter",
    up => sub {
        my ($args) = @_;
        my ($dbh)  = @$args{qw(dbh)};

        # check if we already added the REQUESTED type in ENUM
        my @row = $dbh->selectrow_array(
            q{
            SHOW COLUMNS FROM article_requests WHERE Field='status' AND Type LIKE "%'REQUESTED'%";
        }
        );

        unless (@row) {
            $dbh->do(
                q{
                ALTER TABLE `article_requests`
                    MODIFY `status` enum('REQUESTED', 'PENDING','PROCESSING','COMPLETED','CANCELED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'REQUESTED'
            }
            );
            $dbh->do(
                q{
                UPDATE article_requests
                SET status='REQUESTED' WHERE status='PENDING'
            }
            );

            $dbh->do(
                q{
                UPDATE  `letter`
                SET     `code` = 'AR_REQUESTED',
                        `name` = REPLACE(name, '- open', '- new')
                WHERE   `module` = 'circulation'
                        AND `code` = 'AR_PENDING'
            }
                )
                if ( $dbh->selectrow_array( 'SELECT COUNT(*) FROM letter WHERE code=?', undef, 'AR_REQUESTED' ) )[0] ==
                0;    # Check to make idempotent

            $dbh->do(
                q{
                INSERT IGNORE INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`) VALUES
                ('circulation', 'AR_PENDING', '', 'Article request - pending', 0, 'Pending article request', 'Dear <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>)\r\n\r\nYour request for an article from <<biblio.title>> (<<items.barcode>>) is now in pending state.\r\n\r\nArticle requested:\r\nTitle: <<article_requests.title>>\r\nAuthor: <<article_requests.author>>\r\nVolume: <<article_requests.volume>>\r\nIssue: <<article_requests.issue>>\r\nDate: <<article_requests.date>>\r\nPages: <<article_requests.pages>>\r\nChapters: <<article_requests.chapters>>\r\nNotes: <<article_requests.patron_notes>>\r\n\r\n\r\nThank you!', 'email')
            }
            );
        }
    },
    }
