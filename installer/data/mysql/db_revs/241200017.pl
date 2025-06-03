use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "32630",
    description => "Don't delete illrequests when borrower is deleted",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my $sth = $dbh->prepare(
            q{
            SELECT COUNT(*) FROM illrequests WHERE borrowernumber NOT IN (SELECT borrowernumber FROM borrowers)
        }
        );
        $sth->execute;
        my $count = $sth->fetchrow_array;

        if ($count) {
            say_warning( $out, "Found $count illrequests with a borrowernumber that doesn't exist in borrowers" );
            $dbh->do(
                q{ UPDATE illrequests SET borrowernumber = NULL WHERE borrowernumber NOT IN (SELECT borrowernumber FROM borrowers) }
            );
            say_info( $out, "Set those borrowernumbers to NULL" );
        }

        $dbh->do(q{ ALTER TABLE illrequests DROP FOREIGN KEY illrequests_bnfk });
        $dbh->do(
            q{
                ALTER TABLE illrequests ADD CONSTRAINT illrequests_bnfk
                FOREIGN KEY(`borrowernumber`)
                REFERENCES `borrowers` (`borrowernumber`)
                ON DELETE SET NULL ON UPDATE CASCADE;
            }
        );

        # Other information
        say_success( $out, "Updated borrowernumber constraint on illrequests table" );
    },
};
