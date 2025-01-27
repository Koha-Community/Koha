use Modern::Perl;

return {
    bug_number  => "31569",
    description => "Add primary key for import_biblios",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        unless ( primary_key_exists('import_biblios') ) {
            $dbh->do(q{ALTER TABLE import_biblios ADD PRIMARY KEY (import_record_id)});
            say $out "Added primary key to import_biblios table";
        }
    },
};
