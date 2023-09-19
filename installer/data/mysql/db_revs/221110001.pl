use Modern::Perl;

return {
    bug_number  => "34789",
    description => "Correct datatypes and column name in table erm_eholdings_titles",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( column_exists( 'erm_eholdings_titles', 'preceeding_publication_title_id' ) ) {
            $dbh->do(
                q{
                ALTER TABLE erm_eholdings_titles CHANGE COLUMN preceeding_publication_title_id preceding_publication_title_id varchar(255) DEFAULT NULL
            }
            );
            say $out 'Column preceeding_publication_title renamed to preceding_publication_title_id';
        }
        if ( column_exists( 'erm_eholdings_titles', 'publication_title' ) ) {
            $dbh->do(
                q{
                ALTER TABLE erm_eholdings_titles MODIFY COLUMN publication_title mediumtext
            }
            );
            say $out 'Column publication_title datatype amended to mediumtext';
        }
        if ( column_exists( 'erm_eholdings_titles', 'notes' ) ) {
            $dbh->do(
                q{
                ALTER TABLE erm_eholdings_titles MODIFY COLUMN notes mediumtext
            }
            );
            say $out 'Column notes datatype amended to mediumtext';
        }
    },
};
