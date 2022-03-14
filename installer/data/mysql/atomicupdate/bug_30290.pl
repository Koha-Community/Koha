use Modern::Perl;

return {
    bug_number => 30290,
    description => "Modify AR notices, include TOC line",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        my $sql = q|
UPDATE letter
SET content=REPLACE(content, '\nPages:', '\nTOC: [% IF article_request.toc_request %]Include TOC[% ELSE %]No[% END %]\nPages:')
WHERE code RLIKE '^AR_'  AND module='circulation' AND content NOT RLIKE '\nTOC:';
        |;
        $dbh->do( $sql );
    },
};
