use Modern::Perl;

return {
    bug_number  => "27947",
    description => "Add authorised values list in article requests cancellation",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out column_exists)};
        $dbh->do(
            q{
            INSERT IGNORE INTO authorised_value_categories( category_name, is_system )
            VALUES ('AR_CANCELLATION', 0)
        }
        );
        say $out "Add AR_CANCELLATION category for authorised values";

        $dbh->do(
            q{
            INSERT IGNORE INTO authorised_values (category, authorised_value, lib) VALUES
                ('AR_CANCELLATION','NOT_FOUND','Item could not be located on shelves'),
                ('AR_CANCELLATION','DAMAGED','Item was found to be too damaged to fill article request'),
                ('AR_CANCELLATION','OPAC','Cancelled from the OPAC user page')
        }
        );
        say $out "Add AR_CANCELLATION authorised values";

        $dbh->do(
            q{
            ALTER TABLE `article_requests` ADD COLUMN `cancellation_reason` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'optional authorised value AR_CANCELLATION' AFTER `urls`
        }
        ) unless column_exists( 'article_requests', 'cancellation_reason' );
        say $out "Add cancellation_reason column in article_requests table";

        $dbh->do(
            q{
            UPDATE letter SET content=REPLACE(content, '<<article_requests.notes>>', '<<reason>>')
            WHERE module = 'circulation' AND code = 'AR_CANCELED'
        }
        );
        say $out "Replace notes by reason in notice AR_CANCELED";
    },
    }
