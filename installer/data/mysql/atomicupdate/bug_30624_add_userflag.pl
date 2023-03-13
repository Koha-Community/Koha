use Modern::Perl;

return {
    bug_number => "30624",
    description => "Add loggedinlibrary permission",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{
            INSERT IGNORE INTO userflags (bit, flag, flagdesc, defaulton) VALUES (29, 'loggedinlibrary', 'Allow staff to change logged in library', 0)
        });

        my $IndependentBranches = C4::Context->preference('IndependentBranches');
        unless ( $IndependentBranches ) {
            $dbh->do(q{
                UPDATE borrowers SET flags = flags + (1<<29) WHERE ( flags & 4 AND !(flags & 1<<29) ) ;
           });
        }
    },
};
