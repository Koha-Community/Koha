package C4::Search; #asummes C4/Search

#requires DBI.pm to be installed
#uses DBD:Pg


# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

# FIXME - This file is very similar to C4/Search.pm (and they both
# claim to be package C4::Search). So shouldn't this file be nuked?

use strict;
require Exporter;
use DBI;
use C4::Context;
use C4::Reserves2;
use Set::Scalar;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&CatSearch &BornameSearch &ItemInfo &KeywordSearch &subsearch
&itemdata &bibdata &GetItems &borrdata &itemnodata &itemcount
&borrdata2 &NewBorrowerNumber &bibitemdata &borrissues
&getboracctrecord &ItemType &itemissues &subject &subtitle
&addauthor &bibitems &barcodes &findguarantees &allissues &systemprefs
&findguarantor); 
%EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],
		  
# your exported package globals go here,
# as well as any optionally exported functions

@EXPORT_OK   = qw($Var1 %Hashit);


# non-exported package globals go here
use vars qw(@more $stuff);
	
# initalize package globals, first exported ones

my $Var1   = '';
my %Hashit = ();
		    
# then the others (which are still accessible as $Some::Module::stuff)
my $stuff  = '';
my @more   = ();
	
# all file-scoped lexicals must be created before
# the functions below that use them.
		
# file-private lexicals go here
my $priv_var    = '';
my %secret_hash = ();
			    
# here's a file-private function as a closure,
# callable as &$priv_func;  it cannot be prototyped.
my $priv_func = sub {
  # stuff goes here.
};
						    
# make all your functions, whether exported or not;
sub findguarantees{         
  my ($bornum)=@_;         
  my $dbh = C4::Context->dbh;           
  my $query="select cardnumber,borrowernumber from borrowers where    
  guarantor='$bornum'";               
  my $sth=$dbh->prepare($query);                 
  $sth->execute;                   
  my @dat;                     
  my $i=0;                       
  while (my $data=$sth->fetchrow_hashref){    
    $dat[$i]=$data;                           
    $i++;                               
  }                                   
  $sth->finish; 
  return($i,\@dat);             
}
sub findguarantor{  
  my ($bornum)=@_;  
  my $dbh = C4::Context->dbh;    
  my $query="select guarantor from borrowers where      
  borrowernumber='$bornum'";        
  my $sth=$dbh->prepare($query);          
  $sth->execute;            
  my $data=$sth->fetchrow_hashref;              
  $sth->finish;                
  $query="Select * from borrowers where
  borrowernumber='$data->{'guarantor'}'";  
  $sth=$dbh->prepare($query);  
  $sth->execute;    
  $data=$sth->fetchrow_hashref;      
  $sth->finish;        
  return($data);            
}

sub systemprefs {
    my %systemprefs;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("select variable,value from systempreferences");
    $sth->execute;
    while (my ($variable,$value)=$sth->fetchrow) {
	$systemprefs{$variable}=$value;
    }
    $sth->finish;
    return(%systemprefs);
}

sub NewBorrowerNumber {           
  my $dbh = C4::Context->dbh;        
  my $sth=$dbh->prepare("Select max(borrowernumber) from borrowers");     
  $sth->execute;            
  my $data=$sth->fetchrow_hashref;                                  
  $sth->finish;                   
  $data->{'max(borrowernumber)'}++;         
  return($data->{'max(borrowernumber)'}); 
}    

  
sub KeywordSearch {
  my ($env,$type,$search,$num,$offset)=@_;
  my $dbh = C4::Context->dbh;
  my $resulthash;
  $search->{'keyword'}=~ s/ +$//;
  $search->{'keyword'}=~ s/'/\\'/;
  my @key=split(' ',$search->{'keyword'});
  my $count=@key;
  my $i=1;
  my @results;
  my $query="Select biblionumber from biblio
  where ((title like '$key[0]%' or title like '% $key[0]%')";
  while ($i < $count){                                                  
      $query=$query." and (title like '$key[$i]%' or title like '% $key[$i]%')";                                                   
      $i++;                                                  
  }
  $query.= ") or ((biblio.notes like '$key[0]%' or biblio.notes like '% $key[0]%')";                                             
  for ($i=1;$i<$count;$i++){                                                  
      $query.=" and (biblio.notes like '$key[$i]%' or biblio.notes like '% $key[$i]%')";                                           
  }
   $query.= ") or ((seriestitle like '$key[0]%' or seriestitle like '% $key[0]%')";                                               
  for ($i=1;$i<$count;$i++){                                                  
      $query.=" and (seriestitle like '$key[$i]%' or seriestitle like '% $key[$i]%')";                                             
  }
  $query.=" )";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $i=0;
  while (my @res=$sth->fetchrow_array){
    $results[$i]=$res[0];
    $i++;
  }
  $sth->finish;
  my $set1=Set::Scalar->new(@results);
  $query="Select biblionumber from bibliosubtitle where
  ((subtitle like '$key[0]%' or subtitle like '% $key[0]%')";                 
  for ($i=1;$i<$count;$i++){   
        $query.= " and (subtitle like '$key[$i]%' or subtitle like '% $key[$i]%')";                                                  
  }                   
  $query.=" )";
  $sth=$dbh->prepare($query);
  $sth->execute;
  $i=0;
  while (my @res=$sth->fetchrow_array){
    $results[$i]=$res[0];
    $i++;
  }
  $sth->finish;
  my $set2=Set::Scalar->new(@results);
  if ($i > 0){
    $set1=$set1+$set2;
  }
  $query ="Select biblionumber from biblioitems where
  ((biblioitems.notes like '$key[0]%' or biblioitems.notes like '% $key[0]%')";                                   
  for ($i=1;$i<$count;$i++){                                                  
      $query.=" and (biblioitems.notes like '$key[$i]%' or biblioitems.notes like '% $key[$i]%')";                                 
  }            
  $query.=" )";
  $sth=$dbh->prepare($query);
  $sth->execute;
  $i=0;
  while (my @res=$sth->fetchrow_array){
    $results[$i]=$res[0];
    $i++;
  }
  $sth->finish;
  my $set3=Set::Scalar->new(@results);    
  if ($i > 0){
    $set1=$set1+$set3;
  }
  $query="Select biblionumber from bibliosubject where subject like '%$search->{'keyword'}%' group by biblionumber";
  $sth=$dbh->prepare($query);
  $sth->execute;
  $i=0;
  while (my @res=$sth->fetchrow_array){
    $results[$i]=$res[0];
    $i++;
  }
  $sth->finish;
  my $set4=Set::Scalar->new(@results);    
  if ($i > 0){
    $set1=$set1+$set4;
  }
  my $i2=0;
  my $i3=0;
  my $i4=0;

  my @res2;
  my @res = $set1->members;
  $count=@res;
#  print $set1;
  $i=0;
#  print "count $count";
  if ($search->{'class'} ne ''){ 
    while ($i2 <$count){
      my $query="select * from biblio,biblioitems where 
      biblio.biblionumber='$res[$i2]' and     
      biblio.biblionumber=biblioitems.biblionumber ";         
      if ($search->{'class'} ne ''){             
      my @temp=split(/\|/,$search->{'class'});
      my $count=@temp;                       
      $query.= "and ( itemtype='$temp[0]'";     
      for (my $i=1;$i<$count;$i++){     
        $query.=" or itemtype='$temp[$i]'";                                     
      } 
      $query.=")"; 
      }
       my $sth=$dbh->prepare($query);    
       $sth->execute;        
       if (my $data2=$sth->fetchrow_hashref){            
         my $dewey= $data2->{'dewey'};                
         my $subclass=$data2->{'subclass'};          
         $dewey=~s/\.*0*$//;           
         ($dewey == 0) && ($dewey=''); 
         ($dewey) && ($dewey.=" $subclass") ;                                    
          $sth->finish;
	  my $end=$offset +$num;
	  if ($i4 <= $offset){
	    $i4++;
	  }
#	  print $i4;
	  if ($i4 <=$end && $i4 > $offset){
	    $res2[$i3]="$data2->{'author'}\t$data2->{'title'}\t$data2->{'biblionumber'}\t$data2->{'copyrightdate'}\t$dewey";	
            $i3++;
            $i4++;
#	    print "in here $i3<br>";
	  } else {
#	    print $end;
	  }
	  $i++; 
        }         
     $i2++;
     }
     $count=$i;
  
   } else {
      while ($i2 < $num && $i2 < $count){
	my $query="select * from biblio,biblioitems where
	biblio.biblionumber='$res[$i2+$offset]' and        
	biblio.biblionumber=biblioitems.biblionumber ";
	if ($search->{'class'} ne ''){
	  my @temp=split(/\|/,$search->{'class'});
	  my $count=@temp;
	  $query.= "and ( itemtype='$temp[0]'";
	  for (my $i=1;$i<$count;$i++){
	    $query.=" or itemtype='$temp[$i]'";
	  }
	  $query.=")"; 
	}
	if ($search->{'dewey'} ne ''){
	  $query.= "and (dewey like '$search->{'dewey'}%') ";
	}

	my $sth=$dbh->prepare($query);
	$sth->execute;
	if (my $data2=$sth->fetchrow_hashref){
	    my $dewey= $data2->{'dewey'};               
	    my $subclass=$data2->{'subclass'};                   
	    $dewey=~s/\.*0*$//;     
	    ($dewey == 0) && ($dewey='');               
	    ($dewey) && ($dewey.=" $subclass") ;                      
	    $sth->finish;                                                        
	    $data2->{dewey}=~s/[\.0]*$//;
	    ($data2->{dewey}==0) && ($data2->{dewey}='');
	    push @$resulthash, $data2;
	    $res2[$i]="$data2->{'author'}\t$data2->{'title'}\t$data2->{'biblionumber'}\t$data2->{'copyrightdate'}\t$dewey";
	    $i++;
	}
	$i2++;
      }
  }

  #$count=$i;
  return($count,$resulthash,@res2);
}

sub KeywordSearch2 {
  my ($env,$type,$search,$num,$offset)=@_;
  my $dbh = C4::Context->dbh;
  $search->{'keyword'}=~ s/ +$//;
  $search->{'keyword'}=~ s/'/\\'/;
  my @key=split(' ',$search->{'keyword'});
  my $count=@key;
  my $i=1;
  my @results;
  my $query ="Select * from biblio,bibliosubtitle,biblioitems where
  biblio.biblionumber=biblioitems.biblionumber and
  biblio.biblionumber=bibliosubtitle.biblionumber and
  (((title like '$key[0]%' or title like '% $key[0]%')";
  while ($i < $count){
    $query=$query." and (title like '$key[$i]%' or title like '% $key[$i]%')";
    $i++;
  }
  $query.= ") or ((subtitle like '$key[0]%' or subtitle like '% $key[0]%')";
  for ($i=1;$i<$count;$i++){
    $query.= " and (subtitle like '$key[$i]%' or subtitle like '% $key[$i]%')";
  }
  $query.= ") or ((seriestitle like '$key[0]%' or seriestitle like '% $key[0]%')";
  for ($i=1;$i<$count;$i++){
    $query.=" and (seriestitle like '$key[$i]%' or seriestitle like '% $key[$i]%')";
  }
  $query.= ") or ((biblio.notes like '$key[0]%' or biblio.notes like '% $key[0]%')";
  for ($i=1;$i<$count;$i++){
    $query.=" and (biblio.notes like '$key[$i]%' or biblio.notes like '% $key[$i]%')";
  }
  $query.= ") or ((biblioitems.notes like '$key[0]%' or biblioitems.notes like '% $key[0]%')";
  for ($i=1;$i<$count;$i++){
    $query.=" and (biblioitems.notes like '$key[$i]%' or biblioitems.notes like '% $key[$i]%')";
  }
  if ($search->{'keyword'} =~ /new zealand/i){
    $query.= "or (title like 'nz%' or title like '% nz %' or title like '% nz' or subtitle like 'nz%'
    or subtitle like '% nz %' or subtitle like '% nz' or author like 'nz %' 
    or author like '% nz %' or author like '% nz')"
  }
  if ($search->{'keyword'} eq  'nz' || $search->{'keyword'} eq 'NZ' ||
  $search->{'keyword'} =~ /nz /i || $search->{'keyword'} =~ / nz /i ||
  $search->{'keyword'} =~ / nz/i){
    $query.= "or (title like 'new zealand%' or title like '% new zealand %'
    or title like '% new zealand' or subtitle like 'new zealand%' or
    subtitle like '% new zealand %'
    or subtitle like '% new zealand' or author like 'new zealand%' 
    or author like '% new zealand %' or author like '% new zealand' or 
    seriestitle like 'new zealand%' or seriestitle like '% new zealand %'
    or seriestitle like '% new zealand')"
  }
  $query=$query."))";
  if ($search->{'class'} ne ''){
    my @temp=split(/\|/,$search->{'class'});
    my $count=@temp;
    $query.= "and ( itemtype='$temp[0]'";
    for (my $i=1;$i<$count;$i++){
      $query.=" or itemtype='$temp[$i]'";
     }
  $query.=")"; 
  }
  if ($search->{'dewey'} ne ''){
    $query.= "and (dewey like '$search->{'dewey'}%') ";
  }
   $query.="group by biblio.biblionumber";
   #$query.=" order by author,title";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $i=0;
  while (my $data=$sth->fetchrow_hashref){
#    my $sti=$dbh->prepare("select dewey,subclass from biblioitems where biblionumber=$data->{'biblionumber'}
#    ");
#    $sti->execute;
#    my ($dewey, $subclass) = $sti->fetchrow;
    my $dewey=$data->{'dewey'};
    my $subclass=$data->{'subclass'};
    $dewey=~s/\.*0*$//;
    ($dewey == 0) && ($dewey='');
    ($dewey) && ($dewey.=" $subclass");
#    $sti->finish;
    $results[$i]="$data->{'author'}\t$data->{'title'}\t$data->{'biblionumber'}\t$data->{'copyrightdate'}\t$dewey";
#      print $results[$i];
    $i++;
  }
  $sth->finish;
  $sth=$dbh->prepare("Select biblionumber from bibliosubject where subject
  like '%$search->{'keyword'}%' group by biblionumber");
  $sth->execute;
  while (my $data=$sth->fetchrow_hashref){
    $query="Select * from biblio,biblioitems where
    biblio.biblionumber=$data->{'biblionumber'} and
    biblio.biblionumber=biblioitems.biblionumber ";
    if ($search->{'class'} ne ''){
      my @temp=split(/\|/,$search->{'class'});
      my $count=@temp;
      $query.= " and ( itemtype='$temp[0]'";
      for (my $i=1;$i<$count;$i++){
        $query.=" or itemtype='$temp[$i]'";
      }
      $query.=")"; 
      
    }
    if ($search->{'dewey'} ne ''){
      $query.= "and (dewey like '$search->{'dewey'}%') ";
    }
    my $sth2=$dbh->prepare($query);
    $sth2->execute;
    while (my $data2=$sth2->fetchrow_hashref){
      my $dewey= $data2->{'dewey'};
      my $subclass=$data2->{'subclass'};
      $dewey=~s/\.*0*$//;          
      ($dewey == 0) && ($dewey='');              
      ($dewey) && ($dewey.=" $subclass") ;                  
#      $sti->finish;              
       $results[$i]="$data2->{'author'}\t$data2->{'title'}\t$data2->{'biblionumber'}\t$data2->{'copyrightdate'}\t$dewey";
#      print $results[$i];
      $i++;   
    }
    $sth2->finish;
  }    
  my $i2=1;
  @results=sort @results;
  my @res;
  my $count=@results;
  $i=1;
  if ($count > 0){
    $res[0]=$results[0];
  }
  while ($i2 < $count){
    if ($results[$i2] ne $res[$i-1]){
      $res[$i]=$results[$i2];
      $i++;
    }
    $i2++;
  }
  $i2=0;
  my @res2;
  $count=@res;
  while ($i2 < $num && $i2 < $count){
    $res2[$i2]=$res[$i2+$offset];
#    print $res2[$i2];
    $i2++;
  }
  $sth->finish;
#  $i--;
#  $i++;
  return($i,@res2);
}

sub CatSearch  {
  my ($env,$type,$search,$num,$offset)=@_;
  my $dbh = C4::Context->dbh;
  my $query = '';
    my @results;
  $search->{'title'}=~ s/'/\\'/g;
  $search->{'author'}=~ s/'/\\'/g;
  $search->{'illustrator'}=~ s/'/\\'/g;
  my $title = lc($search->{'title'}); 
  
  if ($type eq 'loose') {
      if ($search->{'author'} ne ''){
        my @key=split(' ',$search->{'author'});
	my $count=@key;
	my $i=1;
        $query="select *,biblio.author,biblio.biblionumber from
         biblio
	 left join additionalauthors
	 on additionalauthors.biblionumber =biblio.biblionumber
	 where
         ((biblio.author like '$key[0]%' or biblio.author like '% $key[0]%' or
	 additionalauthors.author like '$key[0]%' or additionalauthors.author 
	 like '% $key[0]%'
	 	 )";    
	 while ($i < $count){ 
           $query=$query." and (
	   biblio.author like '$key[$i]%' or biblio.author like '% $key[$i]%' or
	   additionalauthors.author like '$key[$i]%' or additionalauthors.author like '% $key[$i]%'
	   )";
           $i++;       
	 }   
	 $query=$query.")";
         if ($search->{'title'} ne ''){ 
	   my @key=split(' ',$search->{'title'});
	   my $count=@key;
           my $i=0;
	   $query.= " and (((title like '$key[0]%' or title like '% $key[0]%' or title like '% $key[0]')";
            while ($i<$count){            
	      $query=$query." and (title like '$key[$i]%' or title like '% $key[$i]%' or title like '% $key[$i]')";
              $i++; 
	    }                       
#	    $query.=") or ((subtitle like '$key[0]%' or subtitle like '% $key[0] %' or subtitle like '% $key[0]')"; 
#            for ($i=1;$i<$count;$i++){
#	      $query.=" and (subtitle like '$key[$i]%' or subtitle like '% $key[$i] %' or subtitle like '% $key[$i]')";   
#            }
	    $query.=") or ((seriestitle like '$key[0]%' or seriestitle like '% $key[0]%' or seriestitle like '% $key[0]')";  
            for ($i=1;$i<$count;$i++){                    
	        $query.=" and (seriestitle like '$key[$i]%' or seriestitle like '% $key[$i]%')";
            }                                                             
	    $query.=") or ((unititle like '$key[0]%' or unititle like '% $key[0]%' or unititle like '% $key[0]')";                         
            for ($i=1;$i<$count;$i++){                    
	        $query.=" and (unititle like '$key[$i]%' or unititle like '% $key[$i]%')";   
            }                                                             
	    $query=$query."))"; 
	   #$query=$query. " and (title like '%$search->{'title'}%' 
	   #or seriestitle like '%$search->{'title'}%')";
	 }
	 	 
	 $query.=" group by biblio.biblionumber";
      } else {
          if ($search->{'title'} ne '') {
	   if ($search->{'ttype'} eq 'exact'){
	     $query="select * from biblio
	     where                            
	     (biblio.title='$search->{'title'}' or (biblio.unititle = '$search->{'title'}'
	     or biblio.unititle like '$search->{'title'} |%' or 
	     biblio.unititle like '%| $search->{'title'} |%' or
	     biblio.unititle like '%| $search->{'title'}') or
	     (biblio.seriestitle = '$search->{'title'}' or
	     biblio.seriestitle like '$search->{'title'} |%' or
	     biblio.seriestitle like '%| $search->{'title'} |%' or
	     biblio.seriestitle like '%| $search->{'title'}')
	     )";
	   } else {
	    my @key=split(' ',$search->{'title'});
	    my $count=@key;
	    my $i=1;
            $query="select * from biblio
	    left join bibliosubtitle on
	    biblio.biblionumber=bibliosubtitle.biblionumber
	    where
	    (((title like '$key[0]%' or title like '% $key[0]%' or title like '% $key[0]')";
	    while ($i<$count){
	      $query=$query." and (title like '$key[$i]%' or title like '% $key[$i]%' or title like '% $key[$i]')";
	      $i++;
	    }
	    $query.=") or ((subtitle like '$key[0]%' or subtitle like '% $key[0]%' or subtitle like '% $key[0]')";
	    for ($i=1;$i<$count;$i++){
	      $query.=" and (subtitle like '$key[$i]%' or subtitle like '% $key[$i]%' or subtitle like '% $key[$i]')";
	    }
	    $query.=") or ((seriestitle like '$key[0]%' or seriestitle like '% $key[0]%' or seriestitle like '% $key[0]')";
	    for ($i=1;$i<$count;$i++){
	      $query.=" and (seriestitle like '$key[$i]%' or seriestitle like '% $key[$i]%')";
	    }
	    $query.=") or ((unititle like '$key[0]%' or unititle like '% $key[0]%' or unititle like '% $key[0]')";
	    for ($i=1;$i<$count;$i++){
	      $query.=" and (unititle like '$key[$i]%' or unititle like '% $key[$i]%')";
	    }
	    $query=$query."))";
	   }
	  } elsif ($search->{'class'} ne ''){
	     $query="select * from biblioitems,biblio where biblio.biblionumber=biblioitems.biblionumber";
	     my @temp=split(/\|/,$search->{'class'});
	      my $count=@temp;
	      $query.= " and ( itemtype='$temp[0]'";
	      for (my $i=1;$i<$count;$i++){
	       $query.=" or itemtype='$temp[$i]'";
	      }
	      $query.=")";
	      if ($search->{'illustrator'} ne ''){
	        $query.=" and illus like '%".$search->{'illustrator'}."%' ";
	      }
	      if ($search->{'dewey'} ne ''){
	        $query.=" and biblioitems.dewey like '$search->{'dewey'}%'";
	      }
	  } elsif ($search->{'dewey'} ne ''){
	     $query="select * from biblioitems,biblio 
	     where biblio.biblionumber=biblioitems.biblionumber
	     and biblioitems.dewey like '$search->{'dewey'}%'";
	  } elsif ($search->{'illustrator'} ne '') {
	  if ($search->{'illustrator'} ne ''){
	     $query="select * from biblioitems,biblio 
	     where biblio.biblionumber=biblioitems.biblionumber
	     and biblioitems.illus like '%".$search->{'illustrator'}."%'";
	  }
	}
          $query .=" group by biblio.biblionumber";	 
      }
  } 
  if ($type eq 'subject'){
    my @key=split(' ',$search->{'subject'});
    my $count=@key;
    my $i=1;
    $query="select distinct(subject) from bibliosubject where( subject like
    '$key[0]%' or subject like '% $key[0]%' or subject like '% $key[0]' or subject like '%($key[0])%')";
    while ($i<$count){
      $query.=" and (subject like '$key[$i]%' or subject like '% $key[$i]%'
      or subject like '% $key[$i]'
      or subject like '%($key[$i])%')";
      $i++;
    }
    if ($search->{'subject'} eq 'NZ' || $search->{'subject'} eq 'nz'){ 
      $query.= " or (subject like 'NEW ZEALAND %' or subject like '% NEW ZEALAND %'
      or subject like '% NEW ZEALAND' or subject like '%(NEW ZEALAND)%' ) ";
    } elsif ( $search->{'subject'} =~ /^nz /i || $search->{'subject'} =~ / nz /i || $search->{'subject'} =~ / nz$/i){
      $query=~ s/ nz/ NEW ZEALAND/ig;
      $query=~ s/nz /NEW ZEALAND /ig;
      $query=~ s/\(nz\)/\(NEW ZEALAND\)/gi;
    }  
  }
  if ($type eq 'precise'){
      $query="select * from items,biblio ";
      if ($search->{'item'} ne ''){
        my $search2=uc $search->{'item'};
        $query=$query." where 
        items.biblionumber=biblio.biblionumber 
	and barcode='$search2'";
      }
      if ($search->{'isbn'} ne ''){
        my $search2=uc $search->{'isbn'};
        my $query1 = "select * from biblioitems where isbn='$search2'";
	my $sth1=$dbh->prepare($query1);
	$sth1->execute;
        my $i2=0;
	while (my $data=$sth1->fetchrow_hashref) {
	   $query="select * from biblioitems,biblio where
           biblio.biblionumber = $data->{'biblionumber'}
           and biblioitems.biblionumber = biblio.biblionumber";
	   my $sth=$dbh->prepare($query);
	   $sth->execute;
	   my $data=$sth->fetchrow_hashref;
	   my ($dewey, $subclass) = ($data->{'dewey'}, $data->{'subclass'});
	   $dewey=~s/\.*0*$//;
	   ($dewey == 0) && ($dewey='');
	   ($dewey) && ($dewey.=" $subclass");
           $results[$i2]="$data->{'author'}\t$data->{'title'}\t$data->{'biblionumber'}\t$data->{'copyrightdate'}\t$dewey\t$data->{'isbn'}\t$data->{'itemtype'}";
           $i2++; 
	   $sth->finish;
	}
	$sth1->finish;
      }
  }
if ($type ne 'precise' && $type ne 'subject'){
  if ($search->{'author'} ne ''){   
      $query=$query." order by biblio.author,title";
  } else {
      $query=$query." order by title";
  }
} else {
  if ($type eq 'subject'){
      $query=$query." order by subject";
  }
}
my $sth=$dbh->prepare($query);
$sth->execute;
my $count=1;
my $i=0;
my $limit= $num+$offset;
while (my $data=$sth->fetchrow_hashref){
  my $query="select dewey,subclass from biblioitems where biblionumber=$data->{'biblionumber'}";
  	    if ($search->{'class'} ne ''){
	      my @temp=split(/\|/,$search->{'class'});
	      my $count=@temp;
	      $query.= " and ( itemtype='$temp[0]'";
	      for (my $i=1;$i<$count;$i++){
	       $query.=" or itemtype='$temp[$i]'";
	      }
	      $query.=")";
	    }
	    if ($search->{'dewey'} ne ''){
	      $query.=" and dewey='$search->{'dewey'}' ";
	    }
	    if ($search->{'illustrator'} ne ''){
	      $query.=" and illus like '%".$search->{'illustrator'}."%' ";
	    }
  my $sti=$dbh->prepare($query);
  $sti->execute;
  my $dewey;
  my $subclass;
  my $true=0;
  if (($dewey, $subclass) = $sti->fetchrow || $type eq 'subject'){
    $true=1;
  }
  $dewey=~s/\.*0*$//;
  ($dewey == 0) && ($dewey='');
  ($dewey) && ($dewey.=" $subclass");
  $sti->finish;
  if ($true == 1){
  if ($count > $offset && $count <= $limit){
    if ($type ne 'subject' && $type ne 'precise'){
       $results[$i]="$data->{'author'}\t$data->{'title'}\t$data->{'biblionumber'}\t$data->{'copyrightdate'}\t$dewey\t$data->{'illus'}";
    } elsif ($search->{'isbn'} ne '' || $search->{'item'} ne ''){
       $results[$i]="$data->{'author'}\t$data->{'title'}\t$data->{'biblionumber'}\t$data->{'copyrightdate'}\t$dewey\t$data->{'illus'}";
    } else {  
     $results[$i]="$data->{'author'}\t$data->{'subject'}\t$data->{'biblionumber'}\t$data->{'copyrightdate'}\t$dewey\t$data->{'illus'}";
    }
    $i++;
  }
  $count++;
  }
}
$sth->finish;
#if ($type ne 'precise'){
  $count--;
#}
#$count--;
return($count,@results);
}

sub updatesearchstats{
  my ($dbh,$query)=@_;
  
}

sub subsearch {
  my ($env,$subject)=@_;
  my $dbh = C4::Context->dbh;
  $subject=$dbh->quote($subject);
  my $query="Select * from biblio,bibliosubject where
  biblio.biblionumber=bibliosubject.biblionumber and
  bibliosubject.subject=$subject group by biblio.biblionumber
  order by biblio.title";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]="$data->{'title'}\t$data->{'author'}\t$data->{'biblionumber'}";
    $i++;
  }
  $sth->finish;
  return(@results);
}


sub ItemInfo {
  my ($env,$biblionumber,$type)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from items,biblio,biblioitems,branches 
  where (items.biblioitemnumber = biblioitems.biblioitemnumber)
  and biblioitems.biblionumber=biblio.biblionumber
  and biblio.biblionumber='$biblionumber' and branches.branchcode=
  items.holdingbranch ";
#  print $type;
  if ($type ne 'intra'){
    $query.=" and (items.itemlost<>1 or items.itemlost is NULL)
    and (wthdrawn <> 1 or wthdrawn is NULL)";
  }
  $query=$query."order by items.dateaccessioned desc";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
    my $iquery = "Select * from issues
    where itemnumber = '$data->{'itemnumber'}'
    and returndate is null";
    my $datedue = '';
    my $isth=$dbh->prepare($iquery);
    $isth->execute;
    if (my $idata=$isth->fetchrow_hashref){
      my @temp=split('-',$idata->{'date_due'});
      $datedue = "$temp[2]/$temp[1]/$temp[0]";
    }
    if ($data->{'itemlost'} eq '1'){
        $datedue='Itemlost';
    }
    if ($data->{'wthdrawn'} eq '1'){
      $datedue="Cancelled";
    }
    if ($datedue eq ''){
       my ($rescount,$reserves)=Findgroupreserve($data->{'biblioitemnumber'},$biblionumber);

       if ($rescount >0){                                
          $datedue='Request';
       }
    }
    $isth->finish;
    my $class = $data->{'classification'};
    my $dewey = $data->{'dewey'};
    $dewey =~ s/0+$//;
    if ($dewey eq "000.") { $dewey = "";};    
    if ($dewey < 10){$dewey='00'.$dewey;}
    if ($dewey < 100 && $dewey > 10){$dewey='0'.$dewey;}
    if ($dewey <= 0){
      $dewey='';
    }
    $dewey=~ s/\.$//;
    $class = $class.$dewey;
    if ($dewey ne ''){
      $class = $class.$data->{'subclass'};
    }
 #   $results[$i]="$data->{'title'}\t$data->{'barcode'}\t$datedue\t$data->{'branchname'}\t$data->{'dewey'}";
    my @temp=split('-',$data->{'datelastseen'});
    my $date="$temp[2]/$temp[1]/$temp[0]";
    $results[$i]="$data->{'title'}\t$data->{'barcode'}\t$datedue\t$data->{'branchname'}\t$class\t$data->{'itemnumber'}\t$data->{'itemtype'}\t$date\t$data->{'biblioitemnumber'}\t$data->{'volumeddesc'}";
#    print "$results[$i] <br>";
    $i++;
  }
 $sth->finish;
  my $query2="Select * from aqorders where biblionumber=$biblionumber";
  my $sth2=$dbh->prepare($query2);         
  $sth2->execute;                                        
  my $data;
  my $ocount;
  if ($data=$sth2->fetchrow_hashref){                   
    $ocount=$data->{'quantity'} - $data->{'quantityreceived'};                                                  
    if ($ocount > 0){
      $results[$i]="$data->{'title'}\t$data->{'barcode'}\t$ocount\tOn Order\t\t$data->{'itemnumber'}\t$data->{'itemtype'}\t\t$data->{'biblioitemnumber'}\t$data->{'volumeddesc'}";
    }
  } 
  $sth2->finish;

  return(@results);
}

sub GetItems {
   my ($env,$biblionumber)=@_;
   #debug_msg($env,"GetItems");
   my $dbh = C4::Context->dbh;
   my $query = "Select * from biblioitems where (biblionumber = $biblionumber)";
   #debug_msg($env,$query);
   my $sth=$dbh->prepare($query);
   $sth->execute;
   #debug_msg($env,"executed query");      
   my $i=0;
   my @results;
   while (my $data=$sth->fetchrow_hashref) {
      #debug_msg($env,$data->{'biblioitemnumber'});
      my $dewey = $data->{'dewey'};
      $dewey =~ s/0+$//; 
      my $line = $data->{'biblioitemnumber'}."\t".$data->{'itemtype'};
      $line = $line."\t$data->{'classification'}\t$dewey";
      $line = $line."\t$data->{'subclass'}\t$data->{isbn}";
      $line = $line."\t$data->{'volume'}\t$data->{number}";
      my $isth= $dbh->prepare("select * from items where biblioitemnumber = $data->{'biblioitemnumber'}");
      $isth->execute;
      while (my $idata = $isth->fetchrow_hashref) {
        my $iline = $idata->{'barcode'}."[".$idata->{'holdingbranch'}."[";
	if ($idata->{'notforloan'} == 1) {
	  $iline = $iline."NFL ";
	}
	if ($idata->{'itemlost'} == 1) {
	  $iline = $iline."LOST ";
	}        
        $line = $line."\t$iline"; 
      }
      $isth->finish;
      $results[$i] = $line;
      $i++;      
   }
   $sth->finish;
   return(@results);
}	     
  
sub itemdata {
  my ($barcode)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from items,biblioitems where barcode='$barcode'
  and items.biblioitemnumber=biblioitems.biblioitemnumber";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data);
}

sub bibdata {
  my ($bibnum,$type)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select *,biblio.notes  
  from biblio,biblioitems 
  left join bibliosubtitle on                                                
  biblio.biblionumber=bibliosubtitle.biblionumber
  
  where biblio.biblionumber=$bibnum
  and biblioitems.biblionumber=$bibnum"; 
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $query="Select * from bibliosubject where biblionumber='$bibnum'";
  $sth=$dbh->prepare($query);
  $sth->execute;
  while (my $dat=$sth->fetchrow_hashref){
    $data->{'subject'}.=" | $dat->{'subject'}";

  }
  $sth->finish;
  return($data);
}

sub bibitemdata {
  my ($bibitem)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select *,biblioitems.notes as bnotes from biblio,biblioitems,itemtypes where biblio.biblionumber=
  biblioitems.biblionumber and biblioitemnumber=$bibitem and
  biblioitems.itemtype=itemtypes.itemtype";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data);
}

sub subject {
  my ($bibnum)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from bibliosubject where biblionumber=$bibnum";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  return($i,\@results);
}

sub addauthor {
  my ($bibnum)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from additionalauthors where biblionumber=$bibnum";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  return($i,\@results);
}

sub subtitle {
  my ($bibnum)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from bibliosubtitle where biblionumber=$bibnum";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  return($i,\@results);
}



sub itemissues {
  my ($bibitem,$biblio)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from items where 
  items.biblioitemnumber='$bibitem'";
  my $sth=$dbh->prepare($query) || die $dbh->errstr;
  $sth->execute || die $sth->errstr;
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref) {
    my $query2="select * from issues,borrowers where itemnumber=$data->{'itemnumber'}
    and returndate is NULL and issues.borrowernumber=borrowers.borrowernumber";
    my $sth2=$dbh->prepare($query2);
    $sth2->execute;
    if (my $data2=$sth2->fetchrow_hashref) {
      $data->{'date_due'}=$data2->{'date_due'};
      $data->{'card'}=$data2->{'cardnumber'};
    } else {
      if ($data->{'wthdrawn'} eq '1') {
        $data->{'date_due'}='Cancelled';
      } else {
          $data->{'date_due'}='Available';
      }
    }
    $sth2->finish;
    $query2="select * from issues,borrowers where itemnumber='$data->{'itemnumber'}'
    and issues.borrowernumber=borrowers.borrowernumber 
    order by date_due desc";
    my $sth2=$dbh->prepare($query2) || die $dbh->errstr;
    $sth2->execute || die $sth2->errstr;
    for (my $i2=0;$i2<2;$i2++){
      if (my $data2=$sth2->fetchrow_hashref){
        $data->{"timestamp$i2"}=$data2->{'timestamp'};
        $data->{"card$i2"}=$data2->{'cardnumber'};
	$data->{"borrower$i2"}=$data2->{'borrowernumber'};
      }
    }
    $sth2->finish;
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  return(@results);
}

sub itemnodata {
  my ($env,$dbh,$itemnumber) = @_;
  $dbh = C4::Context->dbh;
  my $query="Select * from biblio,items,biblioitems
    where items.itemnumber = '$itemnumber'
    and biblio.biblionumber = items.biblionumber
    and biblioitems.biblioitemnumber = items.biblioitemnumber";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;  
  return($data);	       
}

#used by member enquiries from the intranet
#called by member.pl
sub BornameSearch  {
  my ($env,$searchstring,$type)=@_;
  my $dbh = C4::Context->dbh;
  $searchstring=~ s/\'/\\\'/g;
  my @data=split(' ',$searchstring);
  my $count=@data;
  my $query="Select * from borrowers 
  where ((surname like \"$data[0]%\" or surname like \"% $data[0]%\" 
  or firstname  like \"$data[0]%\" or firstname like \"% $data[0]%\" 
  or othernames like \"$data[0]%\" or othernames like \"% $data[0]%\")
  ";
  for (my $i=1;$i<$count;$i++){
    $query=$query." and (surname like \"$data[$i]%\" or surname like \"% $data[$i]%\"                  
    or firstname  like \"$data[$i]%\" or firstname like \"% $data[$i]%\"                    
    or othernames like \"$data[$i]%\" or othernames like \"% $data[$i]%\")";
  }
  $query=$query.") or cardnumber = \"$searchstring\"
  order by surname,firstname";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $cnt=0;
  while (my $data=$sth->fetchrow_hashref){
    push(@results,$data);
    $cnt ++;
  }
#  $sth->execute;
  $sth->finish;
  return ($cnt,\@results);
}

sub borrdata {
  my ($cardnumber,$bornum)=@_;
  $cardnumber = uc $cardnumber;
  my $dbh = C4::Context->dbh;
  my $query;
  if ($bornum eq ''){
    $query="Select * from borrowers where cardnumber='$cardnumber'";
  } else {
      $query="Select * from borrowers where borrowernumber='$bornum'";
  }
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data);
}

sub borrissues {
  my ($bornum)=@_;
  my $dbh = C4::Context->dbh;
  my $query;
  $query="Select * from issues,biblio,items where borrowernumber='$bornum' and
items.itemnumber=issues.itemnumber and
items.biblionumber=biblio.biblionumber and issues.returndate is NULL order
by date_due";
  my $sth=$dbh->prepare($query);
    $sth->execute;
  my @result;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $result[$i]=$data;;
    $i++;
  }
  $sth->finish;
  return($i,\@result);
}

sub allissues { 
  my ($bornum,$order,$limit)=@_; 
  my $dbh = C4::Context->dbh;   
  my $query;     
  $query="Select * from issues,biblio,items,biblioitems       
  where borrowernumber='$bornum' and         
  items.biblioitemnumber=biblioitems.biblioitemnumber and           
  items.itemnumber=issues.itemnumber and             
  items.biblionumber=biblio.biblionumber";               
  $query.=" order by $order";                 
  if ($limit !=0){                   
    $query.=" limit $limit";                     
  }                         
  my $sth=$dbh->prepare($query);          
  $sth->execute;
  my @result;   
  my $i=0;    
  while (my $data=$sth->fetchrow_hashref){                                      
    $result[$i]=$data;; 
    $i++;     
  }         
  $sth->finish;           
  return($i,\@result);               
}

sub borrdata2 {
  my ($env,$bornum)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select count(*) from issues where borrowernumber='$bornum' and
    returndate is NULL";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $sth=$dbh->prepare("Select count(*) from issues where
    borrowernumber='$bornum' and date_due < now() and returndate is NULL");
  $sth->execute;
  my $data2=$sth->fetchrow_hashref;
  $sth->finish;
  $sth=$dbh->prepare("Select sum(amountoutstanding) from accountlines where
    borrowernumber='$bornum'");
  $sth->execute;
  my $data3=$sth->fetchrow_hashref;
  $sth->finish;

return($data2->{'count(*)'},$data->{'count(*)'},$data3->{'sum(amountoutstanding)'});
}
	

sub getboracctrecord {
   my ($env,$params) = @_;
   my $dbh = C4::Context->dbh;
   my @acctlines;
   my $numlines=0;
   my $query= "Select * from accountlines where
borrowernumber=$params->{'borrowernumber'} order by date desc,timestamp desc";
   my $sth=$dbh->prepare($query);
   $sth->execute;
   my $total=0;
   while (my $data=$sth->fetchrow_hashref){
#      if ($data->{'itemnumber'} ne ''){
#        $query="Select * from items,biblio where items.itemnumber=
#	'$data->{'itemnumber'}' and biblio.biblionumber=items.biblionumber";
#	my $sth2=$dbh->prepare($query);
#	$sth2->execute;
#	my $data2=$sth2->fetchrow_hashref;
#	$sth2->finish;
#	$data=$data2;
 #     }
      $acctlines[$numlines] = $data;
      $numlines++;
      $total = $total+ $data->{'amountoutstanding'};
   }
   $sth->finish;
   return ($numlines,\@acctlines,$total);
}

sub itemcount { 
  my ($env,$bibnum,$type)=@_; 
  my $dbh = C4::Context->dbh;   
  my $query="Select * from items where     
  biblionumber=$bibnum ";
  if ($type ne 'intra'){
    $query.=" and (itemlost <>1 or itemlost is NULL) and
    (wthdrawn <> 1 or wthdrawn is NULL)";      
  }
  my $sth=$dbh->prepare($query);         
  $sth->execute;           
  my $count=0;             
  my $lcount=0;               
  my $nacount=0;                 
  my $fcount=0;
  my $scount=0;
  my $lostcount=0;
  my $mending=0;
  my $transit=0;
  my $ocount=0;
  while (my $data=$sth->fetchrow_hashref){
    $count++;                     
    my $query2="select * from issues,items where issues.itemnumber=                          
    '$data->{'itemnumber'}' and returndate is NULL
    and items.itemnumber=issues.itemnumber and (items.itemlost <>1 or
    items.itemlost is NULL)"; 
    my $sth2=$dbh->prepare($query2);     
    $sth2->execute;         
    if (my $data2=$sth2->fetchrow_hashref){         
       $nacount++;         
    } else {         
      if ($data->{'holdingbranch'} eq 'C'){         
        $lcount++;               
      }                       
      if ($data->{'holdingbranch'} eq 'F' || $data->{'holdingbranch'} eq 'FP'){         
        $fcount++;               
      }                       
      if ($data->{'holdingbranch'} eq 'S' || $data->{'holdingbranch'} eq 'SP'){         
        $scount++;               
      }                       
      if ($data->{'itemlost'} eq '1'){
        $lostcount++;
      }
      if ($data->{'holdingbranch'} eq 'FM'){
        $mending++;
      }
      if ($data->{'holdingbranch'} eq 'TR'){
        $transit++;
      }
    }                             
    $sth2->finish;     
  } 
#  if ($count == 0){
    my $query2="Select * from aqorders where biblionumber=$bibnum";
    my $sth2=$dbh->prepare($query2);
    $sth2->execute;
    if (my $data=$sth2->fetchrow_hashref){
      $ocount=$data->{'quantity'} - $data->{'quantityreceived'};
    }
#    $count+=$ocount;
    $sth2->finish;
  $sth->finish; 
  return ($count,$lcount,$nacount,$fcount,$scount,$lostcount,$mending,$transit,$ocount); 
}

sub ItemType {
  my ($type)=@_;
  my $dbh = C4::Context->dbh;
  my $query="select description from itemtypes where itemtype='$type'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $dat=$sth->fetchrow_hashref;
  $sth->finish;
  return ($dat->{'description'});
}

sub bibitems {
  my ($bibnum)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from biblioitems,itemtypes,items where
  biblioitems.biblionumber='$bibnum' and biblioitems.itemtype=itemtypes.itemtype and
  biblioitems.biblioitemnumber=items.biblioitemnumber group by
  items.biblioitemnumber";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  return($i,@results);
}

sub barcodes{
  my ($biblioitemnumber)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select barcode from items where
   biblioitemnumber='$biblioitemnumber'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @barcodes;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $barcodes[$i]=$data->{'barcode'};
    $i++;
  }
  $sth->finish;
  return(@barcodes);
  
}
END { }       # module clean-up code here (global destructor)






