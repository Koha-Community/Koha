use Modern::Perl;

return {
    bug_number  => "29605",
    description => "Resync DB structure for existing installations",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

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

            say $out "Added missing primary key on language_script_mapping"
        }

        unless ( foreign_key_exists('tmp_holdsqueue', 'tmp_holdsqueue_ibfk_3') ) {
            $dbh->do(q{
                ALTER TABLE tmp_holdsqueue
                ADD CONSTRAINT `tmp_holdsqueue_ibfk_3` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
            });

            say $out "Added missing foreign key on tmp_holdsqueue"
        }

    },
}
