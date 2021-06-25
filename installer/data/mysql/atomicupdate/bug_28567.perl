$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

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
    for my $f ( @fields ) {
        $dbh->do(qq{
            UPDATE branches
            SET $f = NULL
            WHERE $f = ""
        });
    }

    NewVersion( $DBversion, 28567, "Set to NULL empty branches fields");
}
