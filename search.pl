#!/usr/bin/perl
#script to provide intranet (librarian) advanced search facility

use strict;
use C4::Search;
use CGI;
use C4::Output;

my $env;
my $input = new CGI;
print $input->header;
#print $input->dump;

#whether it is called from the opac or the intranet
my $type=$input->param('type');if ($type eq ''){
  $type = 'intra';
}

my $ttype=$input->param('ttype');

#setup colours                 
my $main;
my $secondary;

if ($type eq 'opac'){
  $main='#99cccc';    
  $secondary='#efe5ef';
} else {
  $main='#cccc99';
  $secondary='#ffffcc';
}       

#print $input->Dump;
my $blah;
my %search;

#build hash of users input
my $title=validate($input->param('title'));
$search{'title'}=$title;

my $keyword=validate($input->param('keyword'));
$search{'keyword'}=$keyword;

$search{'front'}=validate($input->param('front'));

my $author=validate($input->param('author'));
$search{'author'}=$author;

my $illustrator=validate($input->param('illustrator'));
$search{'illustrator'}=$illustrator;

my $subject=validate($input->param('subject'));
$search{'subject'}=$subject;

my $itemnumber=validate($input->param('item'));
$search{'item'}=$itemnumber;

my $isbn=validate($input->param('isbn'));
$search{'isbn'}=$isbn;

my $datebefore=validate($input->param('date-before'));
$search{'date-before'};

my $class=$input->param('class');
$search{'class'}=$class;

$search{'ttype'}=$ttype;

my $dewey=validate($input->param('dewey'));
$search{'dewey'}=$dewey;

my $branch=validate($input->param('branch'));
$search{'branch'}=$branch;

my @results;
my $offset=$input->param('offset');
if ($offset eq ''){
  $offset=0;
}
my $num=$input->param('num');
if ($num eq ''){
  $num=10;
}
print startpage();
print startmenu($type);
#print $type;
#print $search{'ttype'};
if ($type eq 'intra'){
  print mkheadr(1,'Catalogue Search Results');
} elsif ($type eq 'catmain'){
  print mkheadr(1,'Catalogue Maintenance');
} else {
  print mkheadr(1,'Opac Search Results');
}
print center();
my $count;
my @results;
if ($itemnumber ne '' || $isbn ne ''){
    ($count,@results)=&CatSearch(\$blah,'precise',\%search,$num,$offset);
} else {
  if ($subject ne ''){
    ($count,@results)=&CatSearch(\$blah,'subject',\%search,$num,$offset);
  } else {
    if ($keyword ne ''){
      ($count,@results)=&KeywordSearch(\$blah,'intra',\%search,$num,$offset);
    }elsif ($title ne '' || $author ne '' || $illustrator ne '' || $dewey ne '' || $class ne '') {
      ($count,@results)=&CatSearch(\$blah,'loose',\%search,$num,$offset);
    }
  }
}
print "You searched on ";
while ( my ($key, $value) = each %search) {                                 
  if ($value ne '' && $key ne 'ttype'){
    $value=~ s/\\//g;
    print bold("$key $value,");
  }                          
}
print " $count results found";
my $offset2=$num+$offset;
my $dispnum=$offset+1;
print "<br> Results $dispnum to $offset2 displayed";
print mktablehdr;
if ($type ne 'opac'){
  if ($subject ne ''){
   print mktablerow(1,$main,'<b>SUBJECT</b>','/images/background-mem.gif');
  } elsif ($illustrator ne '') {
   print mktablerow(7,$main,'<b>TITLE</b>','<b>AUTHOR</b>', '<b>ILLUSTRATOR<b>', bold('&copy;'),'<b>COUNT</b>',bold('LOCATION'),'','/images/background-mem.gif');
  } else {
   print mktablerow(6,$main,'<b>TITLE</b>','<b>AUTHOR</b>',bold('&copy;'),'<b>COUNT</b>',bold('LOCATION'),'','/images/background-mem.gif');
  }
} else {
  if ($subject ne ''){
   print mktablerow(6,$main,'<b>SUBJECT</b>',' &nbsp; ',' &nbsp; ');
  } elsif ($illustrator ne '') {
   print mktablerow(7,$main,'<b>TITLE</b>','<b>AUTHOR</b>','<b>ILLUSTRATOR</b>', bold('&copy;'),'<b>COUNT</b>',bold('BRANCH'),'');
  } else {
   print mktablerow(6,$main,'<b>TITLE</b>','<b>AUTHOR</b>',bold('&copy;'),'<b>COUNT</b>',bold('BRANCH'),'');
  }
}
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
    $title2=~ s/ /%20/g;
    my $location='';
    my $itemcount;
    if ($subject eq ''){
      $result->{'title'}=mklink("/cgi-bin/koha/detail.pl?type=$type&bib=$result->{'biblionumber'}&title=$title2",$result->{'title'});
      my $word=$result->{'author'};
      $word=~ s/([a-z]) +([a-z])/$1%20$2/ig;
      $word=~ s/  //g;
      $word=~ s/ /%20/g;
      $word=~ s/\,/\,%20/g;
      $word=~ s/\n//g;
      my $url="/cgi-bin/koha/search.pl?author=$word&type=$type";
      $result->{'author'}=mklink($url,$result->{'author'});
      my ($count,$lcount,$nacount,$fcount,$scount,$lostcount,$mending,$transit,$ocount)=itemcount($env,$result->{'biblionumber'},$type);
      $itemcount=$count;
      ####
      # Fix this chunk below, remove all hardcoded branch references
      # need to fix itemcount as well
      ###
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
      if ($ocount > 0){
        $location=$location."On Order";
         if ($ocount >1 ){                                                                                                         
	  $location=$location." ($ocount)";                                                                                            
         }                                                                                                                         
	 $location.=" ";	
      }
      
#      if ($type ne 'opac'){
#        $result->{'request'}=mklink("/cgi-bin/koha/request.pl?bib=$stuff[2]","Request");
#      }
    } else {
      my $word=$result->{'subject'};
      $word=~ s/ /%20/g;
      
        $result->{'title'}=mklink("/cgi-bin/koha/subjectsearch.pl?subject=$word&type=$type",$result->{'subject'});

    }

    if ($colour == 1){
      if ($illustrator) {
	  print mktablerow(7,$secondary,$result->{'title'},$result->{'author'},$result->{'illus'},$result->{'copyrightdate'},$itemcount,$location);
      } else {
	  print mktablerow(6,$secondary,$result->{'title'},$result->{'author'},$result->{'copyrightdate'},$itemcount,$location);
      }
      $colour=0;
    } else {
      if ($illustrator) {
	  print mktablerow(7,'white',$result->{'title'},$result->{'author'},$result->{'illus'},$result->{'copyrightdate'},$itemcount,$location);
      } else {
	  print mktablerow(6,'white',$result->{'title'},$result->{'author'},$result->{'copyrightdate'},$itemcount,$location);
      }
      $colour=1;
    }
    $i++;
}
$offset=$num+$offset;
if ($type ne 'opac'){
    if ($illustrator) {
	 print mktablerow(7,$main,' &nbsp; ',' &nbsp; ',' &nbsp;',' &nbsp;','','','','/images/background-mem.gif');
    } else {
	 print mktablerow(6,$main,' &nbsp; ',' &nbsp; ',' &nbsp;',' &nbsp;','','','/images/background-mem.gif');
    }
} else {
 if ($illustrator) {
     print mktablerow(7,$main,' &nbsp; ',' &nbsp; ',' &nbsp;',' &nbsp; ','', '','');
 } else {
     print mktablerow(6,$main,' &nbsp; ',' &nbsp; ',' &nbsp;',' &nbsp; ','','');
 }
}
print mktableft();
my $search;

    $search="num=$num&offset=$offset&type=$type";
    if ($subject ne ''){
      $subject=~ s/ /%20/g;
      $search=$search."&subject=$subject";
    }
    if ($title ne ''){
      $title=~ s/ /%20/g;
      $search=$search."&title=$title";
    }
    if ($author ne ''){
      $author=~ s/ /%20/g;
      $search=$search."&author=$author";
    }
    if ($keyword ne ''){
      $keyword=~ s/ /%20/g;
      $search=$search."&keyword=$keyword";
    }
    if ($class ne ''){
      $keyword=~ s/ /%20/g;
      $search=$search."&class=$class";
    }
    if ($dewey ne ''){
      $search=$search."&dewey=$dewey";
    }
    $search.="&ttype=$ttype";    
if ($offset < $count){    
    my $stuff=mklink("/cgi-bin/koha/search.pl?$search",'Next');
    print $stuff;
}
print "<br>";
my $pages=$count/10;
$pages++;
for (my $i=1;$i<$pages;$i++){
  my $temp=$i*10;
  $temp=$temp-10;
  $search=~ s/offset=[0-9]+/offset=$temp/;
  my $stuff=mklink("/cgi-bin/koha/search.pl?$search",$i);
  print "$stuff ";
}
  
print endcenter();
print endmenu($type);
print endpage();


sub validate {
  my ($input)=@_;
  $input=~ s/\<[a-z]+\>//gi;
  $input=~ s/\<\/[a-z]+\>//gi;
  $input=~ s/\<//g;
  $input=~ s/\>//g;
  $input=~ s/^%//g;
  return($input);
}
