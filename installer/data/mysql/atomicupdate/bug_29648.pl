use Modern::Perl;

return {
    bug_number => "29648",
    description => "Move NumSavedReports to table settings",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        my $NumSavedReports = C4::Context->preference('NumSavedReports');
        $dbh->do(q{
            DELETE FROM systempreferences
            WHERE variable="NumSavedReports"
        });

        if ( $NumSavedReports ) {
            $dbh->do(q{
                INSERT IGNORE INTO tables_settings (module, page, tablename, default_display_length, default_sort_order)
                VALUES('reports', 'saved-sql', 'table_reports', ?, 1)
            }, undef, $NumSavedReports);
        }
    },
}
