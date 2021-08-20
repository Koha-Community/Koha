use Modern::Perl;

return {
    bug_number => "27947",
    description => "Add authorised values list in article requests cancellation",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out column_exists)};
        # Do you stuffs here
        $dbh->do(q{
            INSERT IGNORE INTO authorised_value_categories( category_name, is_system )
            VALUES ('AR_CANCELLATION', 0)
        });
        # Print useful stuff here
        say $out "Add AR_CANCELLATION category for authorised values";

        $dbh->do(q{
            INSERT IGNORE INTO authorised_values (category, authorised_value, lib) VALUES ('AR_CANCELLATION','NOT_FOUND','Item could not be located on shelves');
        });

        $dbh->do(q{
            INSERT IGNORE INTO authorised_values (category, authorised_value, lib) VALUES ('AR_CANCELLATION','DAMAGED','Item was found to be too damaged to fill article request');
        });

        say $out "Add AR_CANCELLATION authorised values";

        $dbh->do(q{
            ALTER TABLE `article_requests` ADD COLUMN `cancellation_reason` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'optional authorised value AR_CANCELLATION' AFTER `urls`
        }) unless column_exists('article_requests', 'cancellation_reason');

        # Print useful stuff here
        say $out "Add cancellation_reason column in article_requests table";

        $dbh->do(q{
            UPDATE `letter`
            SET    `content` = 'Dear <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>),\r\n\r\nYour request for an article from <<biblio.title>> (<<items.barcode>>) has been canceled for the following reason:\r\n\r\n<<reason>>\r\n\r\nArticle requested:\r\nTitle: <<article_requests.title>>\r\nAuthor: <<article_requests.author>>\r\nVolume: <<article_requests.volume>>\r\nIssue: <<article_requests.issue>>\r\nDate: <<article_requests.date>>\r\nPages: <<article_requests.pages>>\r\nChapters: <<article_requests.chapters>>\r\nNotes: <<article_requests.patron_notes>>\r\nFormat: [% IF article_request.format == ''PHOTOCOPY'' %]Copy[% ELSIF article_request.format == ''SCAN'' %]Scan[% END %]\r\n\r\nYour library'
            WHERE   `module` = 'circulation'
                    AND `code` = 'AR_CANCELED'
        })
    },
}