# New installer helper file
# Copies detail, moredetail, search, subjectsearch and logout from intranet to opac

$dest = $ARGV[0];
$src = $dest;
$src =~ s/opac/intranet/;
system("cp","-v",$src,$dest);
