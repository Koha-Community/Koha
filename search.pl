#!/usr/bin/perl
#script to provide intranet (librarian) advanced search facility

use strict;
use C4::Search;
use CGI;
use C4::Output;
use C4::Acquisitions;

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
$search{'date-before'}=$datebefore;

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
    my @stuff=split('\t',$results[$i]);
    $stuff[1]=~ s/\`/\\\'/g;
    my $title2=$stuff[1];
    $title2=~ s/ /%20/g;
    if ($subject eq ''){
#      print $stuff[0];
      $stuff[1]=mklink("/cgi-bin/koha/detail.pl?type=$type&bib=$stuff[2]&title=$title2",$stuff[1]);
      my $word=$stuff[0];
#      print $word;
      $word=~ s/([a-z]) +([a-z])/$1%20$2/ig;
      $word=~ s/  //g;
      $word=~ s/ /%20/g;
      $word=~ s/\,/\,%20/g;
      $word=~ s/\n//g;
      my $url="/cgi-bin/koha/search.pl?author=$word&type=$type";
      $stuff[7]=$stuff[5];
      $stuff[5]='';
      $stuff[0]=mklink($url,$stuff[0]);
      my ($count,$lcount,$nacount,$fcount,$scount,$lostcount,$mending,$transit,$ocount,$branchcount)=itemcount($env,$stuff[2],$type);
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
      $stuff[5]='';
      my ($numbranches, @branches) = branches();
      my $branchinfo;
      foreach (@branches) {
	      my $branchcode=$_->{'branchcode'};
	      my $branchname=$_->{'branchname'};
	      $branchinfo->{$branchcode}=$branchname;
      }
      if ($numbranches>1) {
	      foreach my $branchcode (sort keys %$branchcount) {
		  my $c=$branchcount->{$branchcode};
		  $stuff[5].=$branchinfo->{$branchcode};
		  if ($c>1) {
		      $stuff[5].=" ($c)";
		  }
		  $stuff[5].=" ";
	      }
      } else {
	      my $shelfcount=$count-$nacount-$lostcount-$mending-$transit;
	      if ($nacount) {
		      $stuff[5]="On Loan ";
		      if ($count>1) {
			      $stuff[5].="($nacount) ";
		      }
	      }
	      if ($shelfcount) {
		      $stuff[5].="Shelf ";
		      if ($count>1) {
			      $stuff[5].="($shelfcount) ";
		      }
	      }
      }
      if ($lostcount > 0) {
        $stuff[5]=$stuff[5]."Lost";
         if ($count >1 ){                                                                                                         
	  $stuff[5]=$stuff[5]." ($lostcount)";                                                                                            
         }                                                                                                                         
	 $stuff[5].=" ";	
      }
      if ($mending > 0){
        $stuff[5]=$stuff[5]."Mending";
         if ($count >1 ){                                                                                                         
	  $stuff[5]=$stuff[5]." ($mending)";                                                                                            
         }                                                                                                                         
	 $stuff[5].=" ";	
      }
      if ($transit > 0){
        $stuff[5]=$stuff[5]."In Transiit";
         if ($count >1 ){                                                                                                         
	  $stuff[5]=$stuff[5]." ($transit)";                                                                                            
         }                                                                                                                         
	 $stuff[5].=" ";	
      }
      if ($ocount > 0){
        $stuff[5]=$stuff[5]."On Order";
         if ($ocount >1 ){                                                                                                         
	  $stuff[5]=$stuff[5]." ($ocount)";                                                                                            
         }                                                                                                                         
	 $stuff[5].=" ";	
      }
      
      if ($type ne 'opac'){
        $stuff[6]=mklink("/cgi-bin/koha/request.pl?bib=$stuff[2]","Request");
      }
    } else {
      my $word=$stuff[1];
      $word=~ s/ /%20/g;
      
        $stuff[1]=mklink("/cgi-bin/koha/subjectsearch.pl?subject=$word&type=$type",$stuff[1]);

    }

    if ($colour == 1){
      if ($illustrator) {
	  print mktablerow(7,$secondary,$stuff[1],$stuff[0],$stuff[7],$stuff[3],$stuff[4],$stuff[5],$stuff[6]);
      } else {
	  print mktablerow(6,$secondary,$stuff[1],$stuff[0],$stuff[3],$stuff[4],$stuff[5],$stuff[6]);
      }
      $colour=0;
    } else {
      if ($illustrator) {
	  print mktablerow(7,'white',$stuff[1],$stuff[0],$stuff[7],$stuff[3],$stuff[4],$stuff[5],$stuff[6]);
      } else {
	  print mktablerow(6,'white',$stuff[1],$stuff[0],$stuff[3],$stuff[4],$stuff[5],$stuff[6]);
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
