use Modern::Perl;

return {
    bug_number => "29648",
    description => "Allow tables_settings.default_display_length to be NULL",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{
            ALTER TABLE tables_settings
            MODIFY COLUMN default_display_length smallint(6) DEFAULT NULL
        });
    },
}
