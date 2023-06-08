use Modern::Perl;

return {
    bug_number => "27424",
    description => "Add column to specify an SMTP server as the default",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        unless ( column_exists( 'smtp_servers', 'is_default' ) ) {
            $dbh->do(q{ALTER TABLE smtp_servers ADD COLUMN `is_default` tinyint(1) NOT NULL DEFAULT 0 AFTER debug});
        }
    },
};
