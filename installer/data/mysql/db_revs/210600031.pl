use Modern::Perl;

return {
    bug_number  => "18984",
    description => "Remove NORMARC from search_marc_map.marc_type",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(q{DELETE FROM search_marc_map WHERE marc_type='normarc'});
        $dbh->do(
            q{ALTER TABLE search_marc_map MODIFY `marc_type` enum('marc21','unimarc') NOT NULL COMMENT 'what MARC type this map is for'}
        );
    },
    }
