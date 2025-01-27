use Modern::Perl;

return {
    bug_number  => "25735",
    description => "Add Elasticsearch field 'available'",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            qq{
            INSERT IGNORE INTO search_field (name, label, type)
            VALUES ('available', 'available', 'boolean')
        }
        );
    },
};
