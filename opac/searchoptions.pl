#!/usr/bin/perl
use strict;
require Exporter;
# Searching within results is done by simply adding on parameters onto the query, being careful to have the requried marclist etc fields.
use C4::Database;
use C4::Interface::CGI::Output;
use C4::Context;
use CGI;
my $query = new CGI;
my $newquery='';
my $allitemtypesbool = $query->param("allitemtypes");
my $allbranchesbool = $query->param("allbranches");
my $allcategoriesbool = $query->param("allcategories");
my $allsubcategoriesbool = $query->param("allsubcategories");
my $allmediatypesbool = $query->param("allmediatypes");
my $nbstatements = $query->param("nbstatementsori");
my $orderby = $query->param("orderbyori");
my @keywords = $query->param("keyword");
my @marclist = $query->param('marclist');
my @and_or = $query->param('and_or');
my @excluding = $query->param('excluding');
my @operator = $query->param('operator');
my @value = $query->param('value');
my $searchtype = $query->param('searchtype');
my $category = $query->param('categorylist');
my @itemtypeswanted = $query->param("itemtypeswanted");
my $itemtypessearched = $query->param("itemtypessearched");
my @mediatypeswanted = $query->param("mediatypeswanted");
my @subcategorieswanted = $query->param("subcategorieswanted");
my @brancheswanted = $query->param("brancheswanted");
my $avail = $query->param("avail");

my $brancheslist;
my $count=0;
my $newquery='';
my $subfoundbool=0;
my $itemtypefoundbool=0;
my $branchfoundbool=0;
my $itemtypeslist;
my $itemtypescatlist;
my $itemtypessubcatlist;
my $mediatypeslist;
$count=0;
my $dbh=C4::Context->dbh;
$newquery='op=do_search&nbstatements='.$nbstatements;
if ($allcategoriesbool eq '' && $category ne ''){

    my $sth=$dbh->prepare("select itemtypecodes from categorytable where categorycode=?");
    $sth->execute($category);
    $itemtypescatlist = $sth->fetchrow .'|';
    $sth->finish;
}
if ($allmediatypesbool eq '' && @mediatypeswanted ne ''){
    foreach my $mediatype (@mediatypeswanted){
        my $sth=$dbh->prepare("select itemtypecodes from mediatypetable where mediatypecode=?");
        $sth->execute($mediatype);
        $mediatypeslist .= $sth->fetchrow.'|';
        $sth->finish;

    }
}
if ($allsubcategoriesbool eq '' && @subcategorieswanted ne ''){
    foreach my $subcategory (@subcategorieswanted){
        my $sth=$dbh->prepare("select itemtypecodes from subcategorytable where subcategorycode=?");
        $sth->execute($subcategory);
        $itemtypessubcatlist .= $sth->fetchrow.'|';
        $sth->finish;

    }
}
if ($allitemtypesbool ne ''){
#warn @itemtypeswanted;
$itemtypeslist .=$itemtypescatlist.$itemtypessubcatlist.$mediatypeslist.$itemtypessearched.join ("|", @itemtypeswanted)
} else {
$itemtypeslist .=$itemtypescatlist.$itemtypessubcatlist.$mediatypeslist.$itemtypessearched
}
#warn $itemtypeslist;
if ($allbranchesbool == 0){
   $brancheslist = join("|",@brancheswanted)
}

if ($searchtype eq 'NewSearch'){

     $newquery .= '&marclist=';
     $newquery .= '&and_or=and';
     $newquery .= '&excluding=';
     $newquery .= '&operator=contains';
     $newquery .= '&value=';
     $newquery .=join(" ",@keywords)
} elsif ($searchtype eq 'SearchWithin'){
    foreach my $marclistitem (@marclist) {
         $newquery .= '&marclist='.$marclist[$count];
         $newquery .= '&and_or='.$and_or[$count];
         $newquery .= '&excluding='.$excluding[$count];
         $newquery .= '&operator=';
         $newquery .= $operator[$count];
         $newquery .= '&value='.$value[$count];
         if ($marclist[$count] eq ''){
             if ($subfoundbool=0){
                $subfoundbool=1;
                $newquery .=" ".join(" ",@keywords)
             }
         }
        $count++;

    }
    if ($subfoundbool == 0 && $query->param('keysub') ne ''){
        $newquery .= '&marclist=&and_or=and&excluding=&operator=contains&value=';
        $newquery .=join(" ",@keywords)
    }
}
$newquery .= '&orderby='.$orderby;
if ($itemtypeslist ne ''){
    $newquery .= '&itemtypesstring="'.$itemtypeslist.'"'
}
if ($brancheslist ne ''){
    $newquery .= '&branchesstring="'.$brancheslist.'"';
}
if ($avail ne ''){
    $newquery .= '&avail=1'
}
print $query->redirect("/cgi-bin/koha/opac-search.pl?$newquery");
