use Modern::Perl;

return {
    bug_number => 30571,
    description => "Table z3950servers: three cols NOT NULL",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{
alter table z3950servers
    change column `host` `host` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'target''s host name',
    change column `syntax` `syntax` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'marc format provided by this target',
    change column `encoding` `encoding` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'characters encoding provided by this target';
        });
    },
};
