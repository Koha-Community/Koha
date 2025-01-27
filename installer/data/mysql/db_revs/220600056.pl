use Modern::Perl;

return {
    bug_number  => 30571,
    description => "Table z3950servers: three cols NOT NULL",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Preliminary data checks
        my $sql = "SELECT COUNT(*) FROM z3950servers WHERE host IS NULL";
        my ($cnt) = $dbh->selectrow_array($sql);
        if ($cnt) {    # No host is really bad data! Remove it.
            $dbh->do("DELETE FROM z3950servers WHERE host IS NULL");
            say $out "Found bad data in table z3950servers: removed $cnt records with host undefined";
        }
        $sql = "SELECT host FROM z3950servers WHERE syntax IS NULL OR encoding IS NULL";
        my $hosts = $dbh->selectcol_arrayref($sql);
        if (@$hosts) {    # This is bad data too. We choose a default here.
            $dbh->do(
                q|UPDATE z3950servers SET syntax = COALESCE(syntax, 'USMARC'), encoding = COALESCE(encoding, 'utf8')
                WHERE syntax IS NULL OR encoding IS NULL|
            );
            say $out "Corrected empty syntax or encoding for the following hosts. Please check after upgrade.";
            say $out "Updated hosts: " . ( join ',', @$hosts );
        }

        # Actual dbrev
        $dbh->do(
            q{
alter table z3950servers
    change column `host` `host` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'target''s host name',
    change column `syntax` `syntax` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'MARC format provided by this target',
    change column `encoding` `encoding` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'characters encoding provided by this target';
        }
        );
    },
};
