use Modern::Perl;

return {
    bug_number  => "32707",
    description => "Add 'ESPreventAutoTruncate' system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        my ($pref_exists) = $dbh->selectrow_array(
            q{SELECT COUNT(*) FROM systempreferences WHERE variable = 'ElasticsearchPreventAutoTruncate'});

        # The pref is renamed in 250600017.pl, do not insert it if it has been renamed already
        unless ($pref_exists) {
            $dbh->do(
                q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
            VALUES ('ESPreventAutoTruncate', 'barcode|control-number|control-number-identifier|date-of-acquisition|date-of-publication|date-time-last-modified|identifier-standard|isbn|issn|itype|lc-card-number|number-local-acquisition|other-control-number|record-control-number', NULL, 'List of searchfields (separated by | or ,) that should not be autotruncated by Elasticsearch even if QueryAutoTruncate is set to Yes', 'Free')
        }
            );
            say $out "Added new system preference 'ESPreventAutoTruncate'";
        }
    },
};
