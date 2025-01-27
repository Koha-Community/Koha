use Modern::Perl;

return {
    bug_number  => "29648",
    description => "Move NumSavedReports to table settings and allow tables_settings.default_display_length to be NULL",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            ALTER TABLE tables_settings
            MODIFY COLUMN default_display_length smallint(6) DEFAULT NULL
        }
        );

        my $NumSavedReports = C4::Context->preference('NumSavedReports');
        $dbh->do(
            q{
            DELETE FROM systempreferences
            WHERE variable="NumSavedReports"
        }
        );

        if ($NumSavedReports) {
            $dbh->do(
                q{
                INSERT IGNORE INTO tables_settings (module, page, tablename, default_display_length, default_sort_order)
                VALUES('reports', 'saved-sql', 'table_reports', ?, 1)
            }, undef, $NumSavedReports
            );
            say $out "NumSavedReports value '$NumSavedReports' moved to table settings";
        }
    },
};
