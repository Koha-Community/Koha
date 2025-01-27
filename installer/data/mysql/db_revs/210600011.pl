use Modern::Perl;

return {
    bug_number  => "28567",
    description => "Set to NULL empty branches fields",
    up          => sub {
        my ($args) = @_;
        my $dbh = $args->{dbh};

        my @fields = qw(
            branchname
            branchaddress1
            branchaddress2
            branchaddress3
            branchzip
            branchcity
            branchstate
            branchcountry
            branchphone
            branchfax
            branchemail
            branchillemail
            branchreplyto
            branchreturnpath
            branchurl
            branchip
            branchnotes
            opac_info
            marcorgcode
        );

        for my $f (@fields) {
            $dbh->do(
                qq{
                UPDATE branches
                SET $f = NULL
                WHERE $f = ""
            }
            );
        }
    },
    }
