#!/usr/bin/perl
#origninally script to provide intranet (librarian) advanced search facility
#now script to do searching for acquisitions

use strict;
use C4::Search;
use CGI;
use C4::Output;
use C4::Catalogue;
use C4::Biblio;

my $env;
my $input = new CGI;
print $input->header;
#whether it is called from the opac of the intranet                                                            
my $type=$input->param('type');                                                  
if ($type eq ''){
  $type = 'intra';
}
#setup colours                                                                                                 
my $main;                                                                                                      
my $secondary;                                                                                                 
  $main='#cccc99';                                                                                             
  $secondary='#ffffcc';                                                                                        


#print $input->dump;
my $blah;
my %search;
#build hash of users input
my $title=$input->param('search');
$search{'title'}=$title;
my $keyword=$input->param('d');
$search{'keyword'}=$keyword;
my $author=$input->param('author');
$search{'author'}=$author;

my @results;
my $offset=$input->param('offset');
if ($offset eq ''){
  $offset=0;
}
my $num=$input->param('num');
if ($num eq ''){
  $num=10;
}
my $id=$input->param('id');
my $basket=$input->param('basket');
my $sub=$input->param('sub');
my $donation;
if ($id == 72){
  $donation='yes';
}
#print $sub;
my ($count,@booksellers)=bookseller($id);

print startpage();
print startmenu('acquisitions');
print mkheadr(1,"Shopping Basket For: $booksellers[0]->{'name'}");

if ($donation ne 'yes'){
  print "<a href=newbiblio.pl?id=$id&basket=$basket&sub=$sub>";
} else {
  print "<a href=newdonation.pl?id=$id&basket=$basket&sub=$sub>";
}
print <<printend
<img src=/images/add-biblio.gif width=187 heigth=42 border=0 align=right alt="Add New Biblio"></a>
<a href=basket.pl?basket=$basket><img src=/images/view-basket.gif width=187 heigth=42 border=0 align=right alt="View Basket"></a>

<FORM ACTION="/cgi-bin/koha/acqui/newbasket2.pl">
<input type=hidden name=id value="$id">
<input type=hidden name=basket value="$basket">
<b>New Search: </b><INPUT TYPE="text"  SIZE="25"   NAME="search"></form>
<br clear=all>

printend
;

print center();


    if ($keyword ne ''){
#      print "hey";
      ($count,@results)=KeywordSearch(undef,'intra',\%search,$num,$offset);
    } elsif ($search{'front'} ne '') {
    ($count,@results)=FrontSearch(undef,'intra',\%search,$num,$offset);
    }else {
      ($count,@results)=CatSearch(undef,'loose',\%search,$num,$offset);
#            print "hey";
    }

print "You searched on ";
while ( my ($key, $value) = each %search) {                                 
  if ($value ne ''){
    $value=~ s/\\//g;
    print bold("$key $value,");
  }                          
}
print " $count results found";
my $offset2=$num+$offset;
my $dispnum=$offset+1;
print "<br> Results $dispnum to $offset2 displayed";
print mktablehdr;


print mktablerow(6,$main,'<b>TITLE</b>','<b>AUTHOR</b>',bold('&copy;'),'<b>COUNT</b>',bold('LOCATION'),'','/images/background-mem.gif');


my $count2=@results;
if ($keyword ne '' && $offset > 0){
  $count2=$count-$offset;
  if ($count2 > 10){
    $count2=10;
  }
}
#print $count2;
my $i=0;
my $colour=1;
while ($i < $count2){
#    print $results[$i]."\n";
#    my @stuff=split('\t',$results[$i]);
    my $result=$results[$i];
    $result->{'title'}=~ s/\`/\\\'/g;
    my $title2=$result->{'title'};
    my $author2=$result->{'author'};
    my $copyright=$result->{'copyrightdate'};
    $author2=~ s/ /%20/g;
    $title2=~ s/ /%20/g;
    $title2=~ s/\#/\&\#x23;/g;
    $title2=~ s/\"/\&quot\;/g;
    my $itemcount;
    my $location='';
    if ($donation eq 'yes'){
      $result->{'title'}=mklink("/cgi-bin/koha/acqui/newdonation.pl?author=$author2&copyright=$copyright&id=$id&basket=$basket&biblio=$result->{'biblionumber'}&title=$title2",$result->{'title'});
    } else {
      $result->{'title'}=mklink("/cgi-bin/koha/acqui/newbiblio.pl?sub=$sub&author=$author2&copyright=$copyright&id=$id&basket=$basket&biblio=$result->{'biblionumber'}&title=$title2",$result->{'title'});
    }  
    my $word=$result->{'author'};
      $word=~ s/([a-z]) +([a-z])/$1%20$2/ig;
      $word=~ s/  //g;
      $word=~ s/ /%20/g;
      $word=~ s/\,/\,%20/g;
      $word=~ s/\n//g;
      my $url="/cgi-bin/koha/search.pl?author=$word&type=$type";
      $result->{'author'}=mklink($url,$result->{'author'});
      my ($count,$lcount,$nacount,$fcount,$scount,$lostcount,$mending,$transit)=C4::Search::itemcount($env,$result->{'biblionumber'},$type);
      $itemcount=$count;
      if ($nacount > 0){
        $location=$location."On Loan";
	if ($nacount >1 ){                                                                                                         
	  $location=$location." ($nacount)";                                                                                            
         }                                                                                                                         
	 $location.=" ";
      }
      if ($lcount > 0){
         $location=$location."Levin";
         if ($lcount >1 ){                                                                                                         
	  $location=$location." ($lcount)";                                                                                            
         }                                                                                                                         
	 $location.=" ";
      }
      if ($fcount > 0){
        $location=$location."Foxton";
         if ($fcount >1 ){                                                                                                         
	  $location=$location." ($fcount)";                                                                                            
         }                                                                                                                         
	 $location.=" ";	
      }
      if ($scount > 0){
        $location=$location."Shannon";
         if ($scount >1 ){                                                                                                         
	  $location=$location." ($scount)";                                                                                            
         }                                                                                                                         
	 $location.=" ";	
      }
      if ($lostcount > 0){
        $location=$location."Lost";
         if ($lostcount >1 ){                                                                                                         
	  $location=$location." ($lostcount)";                                                                                            
         }                                                                                                                         
	 $location.=" ";	
      }
      if ($mending > 0){
        $location=$location."Mending";
         if ($mending >1 ){                                                                                                         
	  $location=$location." ($mending)";                                                                                            
         }                                                                                                                         
	 $location.=" ";	
      }
      if ($transit > 0){
        $location=$location."In Transiit";
         if ($transit >1 ){                                                                                                         
	  $location=$location." ($transit)";                                                                                            
         }                                                                                                                         
	 $location.=" ";	
      }
      
    if ($colour == 1){
      print mktablerow(6,$secondary,$result->{'title'},$result->{'author'},$result->{'copyrightdate'},$itemcount,$location);
      $colour=0;
    } else{
      print mktablerow(6,'white',$result->{'title'},$result->{'author'},$result->{'copyrightdate'},$itemcount,$location);
      $colour=1;
    }
    $i++;
}
$offset=$num+$offset;

 print mktablerow(6,$main,' &nbsp; ',' &nbsp; ',' &nbsp;',' &nbsp;','','','/images/background-mem.gif');

print mktableft();
if ($offset < $count){
    my $search="num=$num&offset=$offset&type=$type&id=$id&basket=$basket&search=$title&author=$author";
    my $stuff=mklink("/cgi-bin/koha/acqui/newbasket2.pl?$search",'Next');
    print $stuff;
}

print endcenter();
print endmenu('acquisitions');
print endpage();
