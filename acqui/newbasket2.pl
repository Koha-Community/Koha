#!/usr/bin/perl
#origninally script to provide intranet (librarian) advanced search facility
#now script to do searching for acquisitions

use strict;
use C4::Search;
use CGI;
use C4::Output;
use C4::Acquisitions;

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
my $keyword=$input->param('search');
$search{'keyword'}=$keyword;
my $author=$input->param('search');
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

my ($count,@booksellers)=bookseller($id);
																																   print startpage();       

print startpage();
print startmenu('acquisitions');
print mkheadr(1,"Shopping Basket For: $booksellers[0]->{'name'}");

print <<printend

<a href=newbiblio.pl?id=$id&basket=$basket><img src=/images/add-biblio.gif width=187 heigth=42 border=0 align=right alt="Add New Biblio"></a>
<a href=basket.pl?basket=$basket><img src=/images/view-basket.gif width=187 heigth=42 border=0 align=right alt="View Basket"></a>

<FORM ACTION="/cgi-bin/koha/acqui/newbasket2.pl">
<input type=hidden name=id value="$id">
<input type=hidden name=basket value="$basket">
<b>New Search: </b><INPUT TYPE="text"  SIZE="25"   NAME="search"></form>
<br clear=all>

printend
;

print center();
my $count;
my @results;

    if ($keyword ne ''){
#      print "hey";
      ($count,@results)=&KeywordSearch(\$blah,'intra',\%search,$num,$offset);
    } elsif ($search{'front'} ne '') {
    ($count,@results)&FrontSearch(\$blah,'intra',\%search,$num,$offset);
    }else {
      ($count,@results)=&CatSearch(\$blah,'loose',\%search,$num,$offset);
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
    my @stuff=split('\t',$results[$i]);
    $stuff[1]=~ s/\`/\\\'/g;
    my $title2=$stuff[1];
    my $author2=$stuff[0];
    my $copyright=$stuff[3];
    $author2=~ s/ /%20/g;
    $title2=~ s/ /%20/g;
    $title2=~ s/\#/\&\#x23;/g;
      $stuff[1]=mklink("/cgi-bin/koha/acqui/newbiblio.pl?title=$title2&author=$author2&copyright=$copyright&id=$id&basket=$basket&biblio=$stuff[2]",$stuff[1]);
      my $word=$stuff[0];
#      print $word;
      $word=~ s/([a-z]) +([a-z])/$1%20$2/ig;
      $word=~ s/  //g;
      $word=~ s/ /%20/g;
      $word=~ s/\,/\,%20/g;
      $word=~ s/\n//g;
      my $url="/cgi-bin/koha/search.pl?author=$word&type=$type";
      $stuff[0]=mklink($url,$stuff[0]);
      my ($count,$lcount,$nacount,$fcount,$scount,$lostcount,$mending,$transit)=itemcount($env,$stuff[2],$type);
      $stuff[4]=$count;
      if ($nacount > 0){
        $stuff[5]=$stuff[5]."On Loan";
	if ($nacount >1 ){                                                                                                         
	  $stuff[5]=$stuff[5]." ($nacount)";                                                                                            
         }                                                                                                                         
	 $stuff[5].=" ";
      }
      if ($lcount > 0){
         $stuff[5]=$stuff[5]."Levin";
         if ($lcount >1 ){                                                                                                         
	  $stuff[5]=$stuff[5]." ($lcount)";                                                                                            
         }                                                                                                                         
	 $stuff[5].=" ";
      }
      if ($fcount > 0){
        $stuff[5]=$stuff[5]."Foxton";
         if ($fcount >1 ){                                                                                                         
	  $stuff[5]=$stuff[5]." ($fcount)";                                                                                            
         }                                                                                                                         
	 $stuff[5].=" ";	
      }
      if ($scount > 0){
        $stuff[5]=$stuff[5]."Shannon";
         if ($scount >1 ){                                                                                                         
	  $stuff[5]=$stuff[5]." ($scount)";                                                                                            
         }                                                                                                                         
	 $stuff[5].=" ";	
      }
      if ($lostcount > 0){
        $stuff[5]=$stuff[5]."Lost";
         if ($lostcount >1 ){                                                                                                         
	  $stuff[5]=$stuff[5]." ($lostcount)";                                                                                            
         }                                                                                                                         
	 $stuff[5].=" ";	
      }
      if ($mending > 0){
        $stuff[5]=$stuff[5]."Mending";
         if ($mending >1 ){                                                                                                         
	  $stuff[5]=$stuff[5]." ($mending)";                                                                                            
         }                                                                                                                         
	 $stuff[5].=" ";	
      }
      if ($transit > 0){
        $stuff[5]=$stuff[5]."In Transiit";
         if ($transit >1 ){                                                                                                         
	  $stuff[5]=$stuff[5]." ($transit)";                                                                                            
         }                                                                                                                         
	 $stuff[5].=" ";	
      }
      
    if ($colour == 1){
      print mktablerow(6,$secondary,$stuff[1],$stuff[0],$stuff[3],$stuff[4],$stuff[5],$stuff[6]);
      $colour=0;
    } else{
      print mktablerow(6,'white',$stuff[1],$stuff[0],$stuff[3],$stuff[4],$stuff[5],$stuff[6]);
      $colour=1;
    }
    $i++;
}
$offset=$num+$offset;

 print mktablerow(6,$main,' &nbsp; ',' &nbsp; ',' &nbsp;',' &nbsp;','','','/images/background-mem.gif');

print mktableft();
if ($offset < $count){
    my $search="num=$num&offset=$offset&type=$type&id=$id&basket=$basket&search=$keyword";
    my $stuff=mklink("/cgi-bin/koha/acqui/newbasket2.pl?$search",'Next');
    print $stuff;
}

print endcenter();
print endmenu('acquisitions');
print endpage();
