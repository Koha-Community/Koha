use Modern::Perl;

return {
    bug_number  => 29943,
    description => "Fix typo in NOTIFY_MANAGER notice",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Correct "[% borrowers." (where present and restricted to specific notice)
        $dbh->do(
            q|
            UPDATE letter SET content = REPLACE(content, '[% borrowers.', '[% borrower.')
            WHERE code = 'NOTIFY_MANAGER'
        |
        );
    },
};
