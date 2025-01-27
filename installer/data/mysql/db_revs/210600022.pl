use Modern::Perl;

return {
    bug_number  => "28972",
    description => "Add missing foreign key constraints to holds queue table",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        unless ( foreign_key_exists( 'tmp_holdsqueue', 'tmp_holdsqueue_ibfk_2' ) ) {
            $dbh->do(
                q{
                ALTER TABLE tmp_holdsqueue
                ADD CONSTRAINT `tmp_holdsqueue_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
            }
            );
        }
        unless ( foreign_key_exists( 'tmp_holdsqueue', 'tmp_holdsqueue_ibfk_3' ) ) {
            $dbh->do(
                q{
                ALTER TABLE tmp_holdsqueue
                ADD CONSTRAINT `tmp_holdsqueue_ibfk_3` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
            }
            );
        }
    },
    }
