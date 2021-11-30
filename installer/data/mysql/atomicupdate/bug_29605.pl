use Modern::Perl;

return {
    bug_number  => "29605",
    description => "Add language_script_mapping primary key",
    up => sub {
        my ($args) = @_;
        my ($dbh) = @$args{qw(dbh)};

        if (   !primary_key_exists( 'language_script_mapping', 'language_subtag' )
            and index_exists( 'language_script_mapping', 'language_subtag' ) ) {

            $dbh->do(q{
                ALTER TABLE language_script_mapping
                    DROP KEY `language_subtag`;
            });
        }

        if ( !primary_key_exists( 'language_script_mapping', 'language_subtag' ) ) {

            $dbh->do(q{
                ALTER TABLE language_script_mapping
                    ADD PRIMARY KEY `language_subtag` (`language_subtag`);
            });
        }
    },
}
