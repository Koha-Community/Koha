use Modern::Perl;

return {
    bug_number  => "34789",
    description => "A single line description",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( column_exists( 'erm_eholdings_titles', 'preceeding_publication_title_id' ) ) {
            $dbh->do(
                q{
                ALTER TABLE erm_eholdings_titles RENAME COLUMN preceeding_publication_title_id TO preceding_publication_title_id
            }
            );
            say $out 'Column renamed to preceding_publication_title_id';
        }
        if ( column_exists( 'erm_eholdings_titles', 'publication_title' ) ) {
            $dbh->do(
                q{
                ALTER TABLE erm_eholdings_titles MODIFY COLUMN publication_title mediumtext
            }
            );
            say $out 'Column datatype amended to mediumtext';
        }
        if ( column_exists( 'erm_eholdings_titles', 'notes' ) ) {
            $dbh->do(
                q{
                ALTER TABLE erm_eholdings_titles MODIFY COLUMN notes mediumtext
            }
            );
            say $out 'Column datatype amended to mediumtext';
        }
    },
};
