package C4::Search; #assumes C4/Search


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

use strict;
require Exporter;
use DBI;
use C4::Database;
use C4::Reserves2;
use Set::Scalar;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.02;
    
@ISA = qw(Exporter);
@EXPORT = qw(&CatSearch &BornameSearch &ItemInfo &KeywordSearch &subsearch
&itemdata &bibdata &GetItems &borrdata &itemnodata &itemcount
&borrdata2 &NewBorrowerNumber &bibitemdata &borrissues
&getboracctrecord &ItemType &itemissues &subject &subtitle
&addauthor &bibitems &barcodes &findguarantees &allissues &systemprefs
&findguarantor &getwebsites &getwebbiblioitems &catalogsearch itemcount2);
# make all your functions, whether exported or not;
sub findguarantees{         
  my ($bornum)=@_;         
  my $dbh=C4Connect;           
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
  $dbh->disconnect;         
  return($i,\@dat);             
}
sub findguarantor{  
  my ($bornum)=@_;  
  my $dbh=C4Connect;    
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
  $dbh->disconnect;          
  return($data);            
}

sub systemprefs {
    my %systemprefs;
    my $dbh=C4Connect;
    my $sth=$dbh->prepare("select variable,value from systempreferences");
    $sth->execute;
    while (my ($variable,$value)=$sth->fetchrow) {
	$systemprefs{$variable}=$value;
    }
    $sth->finish;
    $dbh->disconnect;
    return(%systemprefs);
}

sub NewBorrowerNumber {           
  my $dbh=C4Connect;        
  my $sth=$dbh->prepare("Select max(borrowernumber) from borrowers");     
  $sth->execute;            
  my $data=$sth->fetchrow_hashref;                                  
  $sth->finish;                   
  $data->{'max(borrowernumber)'}++;         
  $dbh->disconnect;
  return($data->{'max(borrowernumber)'}); 
}    

sub catalogsearch {
  my ($env,$type,$search,$num,$offset)=@_;
  my $dbh = C4Connect();
#  foreach my $key (%$search){
#    $search->{$key}=$dbh->quote($search->{$key});
#  }
  my ($count,@results);
#  print STDERR "Doing a search \n";
  if ($search->{'itemnumber'} ne '' || $search->{'isbn'} ne ''){
        print STDERR "Doing a precise search\n";
    ($count,@results)=CatSearch($env,'precise',$search,$num,$offset);

  } else {
    if ($search->{'subject'} ne ''){
      ($count,@results)=CatSearch($env,'subject',$search,$num,$offset);
    } else {
      if ($search->{'keyword'} ne ''){
         ($count,@results)=&KeywordSearch($env,'keyword',$search,$num,$offset);
       } else {
	($count,@results)=CatSearch($env,'loose',$search,$num,$offset);

      }
    }
  }
  if ($env->{itemcount} eq '1') {
    foreach my $data (@results){
      my ($counts) = itemcount2($env, $data->{'biblionumber'}, 'intra');
      my $subject2=$data->{'subject'};
      $subject2=~ s/ /%20/g;
      $data->{'itemcount'}=$counts->{'total'};
      my $totalitemcounts=0;
      foreach my $key (keys %$counts){
        if ($key ne 'total'){
          #$data->{'location'}.="$key $counts->{$key} ";
	  $totalitemcounts+=$counts->{$key};
          $data->{'locationhash'}->{$key}=$counts->{$key};
         }
      }
      my $locationtext='';
      my $notavailabletext='';
      foreach (sort keys %{$data->{'locationhash'}}) {
	  if ($_ eq 'notavailable') {
	      $notavailabletext="Not available";
	      my $c=$data->{'locationhash'}->{$_};
	      if ($totalitemcounts>1) {
		  $notavailabletext.=" ($c)";
	      }
	  } else {
	      $locationtext.="$_";
	      my $c=$data->{'locationhash'}->{$_};
	      if ($totalitemcounts>1) {
		  $locationtext.=" ($c), ";
	      }
	  }
      }
      if ($notavailabletext) {
	  $locationtext.=$notavailabletext;
      } else {
	  $locationtext=~s/, $//;
      }
      $data->{'location'}=$locationtext;
      $data->{'subject2'}=$subject2;
    }
  }
  return ($count,@results);
}

  
sub KeywordSearch {
  my ($env,$type,$search,$num,$offset)=@_;
  my $dbh = &C4Connect;
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
#  print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $i=0;
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
#  print $query;
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
#  print $query;
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
  $sth=$dbh->prepare("Select biblionumber from bibliosubject where subject
  like '%$search->{'keyword'}%' group by biblionumber");
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
       #    print $query;        
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
	    $data2->{'dewey'}=$dewey;
	    $res2[$i3]=$data2;
	    
#	    $res2[$i3]="$data2->{'author'}\t$data2->{'title'}\t$data2->{'biblionumber'}\t$data2->{'copyrightdate'}\t$dewey";	
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
#    print $query;
    $sth->execute;
    if (my $data2=$sth->fetchrow_hashref){
        my $dewey= $data2->{'dewey'};               
        my $subclass=$data2->{'subclass'};                   
	$dewey=~s/\.*0*$//;     
        ($dewey == 0) && ($dewey='');               
        ($dewey) && ($dewey.=" $subclass") ;                      
        $sth->finish;                                             
	$data2->{'dewey'}=$dewey;
	
	$res2[$i]=$data2;
#	$res2[$i]="$data2->{'author'}\t$data2->{'title'}\t$data2->{'biblionumber'}\t$data2->{'copyrightdate'}\t$dewey";
        $i++;
    }
    $i2++;
    
  }
  }
  $dbh->disconnect;

  #$count=$i;
  return($count,@res2);
}

sub KeywordSearch2 {
  my ($env,$type,$search,$num,$offset)=@_;
  my $dbh = &C4Connect;
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
#  print $query;
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
#    print $query;
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
  $count=@results;
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
  $dbh->disconnect;
#  $i--;
#  $i++;
  return($i,@res2);
}

sub CatSearch  {
  my ($env,$type,$search,$num,$offset)=@_;
  my $dbh = &C4Connect;
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
	 if ($search->{'abstract'} ne ''){
	    $query.= " and (abstract like '%$search->{'abstract'}%')";
	 }
	 if ($search->{'date-before'} ne ''){
	    $query.= " and (copyrightdate like '%$search->{'date-before'}%')";
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
	   if ($search->{'abstract'} ne ''){
	    $query.= " and (abstract like '%$search->{'abstract'}%')";
	   }
	   if ($search->{'date-before'} ne ''){
	    $query.= " and (copyrightdate like '%$search->{'date-before'}%')";
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
      	     $query="select * from biblioitems,biblio 
	     where biblio.biblionumber=biblioitems.biblionumber
	     and biblioitems.illus like '%".$search->{'illustrator'}."%'";
	  } elsif ($search->{'publisher'} ne ''){
	    $query.= "Select * from biblio,biblioitems where biblio.biblionumber
	    =biblioitems.biblionumber and (publishercode like '%$search->{'publisher'}%')";
	  } elsif ($search->{'abstract'} ne ''){
	    $query.= "Select * from biblio where abstract like '%$search->{'abstract'}%'";
	  
	  } elsif ($search->{'date-before'} ne ''){
	    $query.= "Select * from biblio where copyrightdate like '%$search->{'date-before'}%'";
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
      
      if ($search->{'item'} ne ''){
        $query="select * from items,biblio ";
        my $search2=uc $search->{'item'};
        $query=$query." where 
        items.biblionumber=biblio.biblionumber 
	and barcode='$search2'";
      }
      if ($search->{'isbn'} ne ''){
        my $search2=uc $search->{'isbn'};
        my $query1 = "select * from biblioitems where isbn='$search2'";
	my $sth1=$dbh->prepare($query1);
#	print STDERR "$query1\n";
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
	   $data->{'dewey'}=$dewey;
	   $results[$i2]=$data;
#           $results[$i2]="$data->{'author'}\t$data->{'title'}\t$data->{'biblionumber'}\t$data->{'copyrightdate'}\t$dewey\t$data->{'isbn'}\t$data->{'itemtype'}";
           $i2++; 
	   $sth->finish;
	}
	$sth1->finish;
      }
  }
#print $query;
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
#print STDERR "$query\n";
my $sth=$dbh->prepare($query);
$sth->execute;
my $count=1;
my $i=0;
my $limit= $num+$offset;
while (my $data=$sth->fetchrow_hashref){
  my $query="select dewey,subclass,publishercode from biblioitems where biblionumber=$data->{'biblionumber'}";
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
	    if ($search->{'publisher'} ne ''){
	    $query.= " and (publishercode like '%$search->{'publisher'}%')";
	    }

  my $sti=$dbh->prepare($query);
  $sti->execute;
  my $dewey;
  my $subclass;
  my $true=0;
  my $publishercode;
  my $bibitemdata;
  if ($bibitemdata = $sti->fetchrow_hashref() || $type eq 'subject'){
    $true=1;
    $dewey=$bibitemdata->{'dewey'};
    $subclass=$bibitemdata->{'subclass'};
    $publishercode=$bibitemdata->{'publishercode'};
  }
  print STDERR "$dewey $subclass $publishercode\n";
  $dewey=~s/\.*0*$//;
  ($dewey == 0) && ($dewey='');
  ($dewey) && ($dewey.=" $subclass");
  $data->{'dewey'}=$dewey;
  $data->{'publishercode'}=$publishercode;
  $sti->finish;
  if ($true == 1){
    if ($count > $offset && $count <= $limit){
      $results[$i]=$data;
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
  my $dbh=C4Connect();
  $subject=$dbh->quote($subject);
  my $query="Select * from biblio,bibliosubject where
  biblio.biblionumber=bibliosubject.biblionumber and
  bibliosubject.subject=$subject group by biblio.biblionumber
  order by biblio.title";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $i=0;
#  print $query;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]="$data->{'title'}\t$data->{'author'}\t$data->{'biblionumber'}";
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return(@results);
}


sub ItemInfo {
    my ($env,$biblionumber,$type) = @_;
    my $dbh   = &C4Connect;
    my $query = "SELECT * FROM items, biblio, biblioitems, itemtypes
                  WHERE items.biblionumber = ?
                    AND biblioitems.biblioitemnumber = items.biblioitemnumber
                    AND biblioitems.itemtype = itemtypes.itemtype
                    AND biblio.biblionumber = items.biblionumber";
  if ($type ne 'intra'){
    $query .= " and ((items.itemlost<>1 and items.itemlost <> 2)
    or items.itemlost is NULL)
    and (wthdrawn <> 1 or wthdrawn is NULL)";
  }
  $query .= " order by items.dateaccessioned desc";
    #warn $query;
  my $sth=$dbh->prepare($query);
  $sth->execute($biblionumber);
  my $i=0;
  my @results;
#  print $query;
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
    if ($data->{'itemlost'} eq '2'){
        $datedue='Very Overdue';
    }
    if ($data->{'itemlost'} eq '1'){
        $datedue='Lost';
    }
    if ($data->{'wthdrawn'} eq '1'){
	$datedue="Cancelled";
    }
    if ($datedue eq ''){
	$datedue="Available";
	my ($restype,$reserves)=CheckReserves($data->{'itemnumber'});
	if ($restype){
	    $datedue=$restype;
	}
    }
    $isth->finish;
#get branch information.....
    my $bquery = "SELECT * FROM branches
                          WHERE branchcode = '$data->{'holdingbranch'}'";
    my $bsth=$dbh->prepare($bquery);
    $bsth->execute;
    if (my $bdata=$bsth->fetchrow_hashref){
	$data->{'branchname'} = $bdata->{'branchname'};
    }

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
    $data->{'datelastseen'}=$date;
    $data->{'datedue'}=$datedue;
    $data->{'class'}=$class;
    $results[$i]=$data;
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
      $data->{'ocount'}=$ocount;
      $data->{'order'}="One Order";
      $results[$i]=$data;
    }
  } 
  $sth2->finish;

  $dbh->disconnect;
  return(@results);
}

sub GetItems {
   my ($env,$biblionumber)=@_;
   #debug_msg($env,"GetItems");
   my $dbh = &C4Connect;
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
   $dbh->disconnect;
   return(@results);
}	     
  
sub itemdata {
  my ($barcode)=@_;
  my $dbh=C4Connect;
  my $query="Select * from items,biblioitems where barcode='$barcode'
  and items.biblioitemnumber=biblioitems.biblioitemnumber";
#  print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return($data);
}


sub bibdata {
    my ($bibnum, $type) = @_;
    my $dbh   = C4Connect;
    my $query = "Select *, biblio.notes  
    from biblio, biblioitems 
    left join bibliosubtitle on
    biblio.biblionumber = bibliosubtitle.biblionumber
    where biblio.biblionumber = $bibnum
    and biblioitems.biblionumber = $bibnum";
    my $sth   = $dbh->prepare($query);
    my $data;

    $sth->execute;
    $data  = $sth->fetchrow_hashref;
    $sth->finish;

    $query = "Select * from bibliosubject where biblionumber = '$bibnum'";
    $sth   = $dbh->prepare($query);
    $sth->execute;
    while (my $dat = $sth->fetchrow_hashref){
        $data->{'subject'} .= " , $dat->{'subject'}";
    } # while

    $sth->finish;
    $dbh->disconnect;
    return($data);
} # sub bibdata


sub bibitemdata {
    my ($bibitem) = @_;
    my $dbh   = C4Connect;
    my $query = "Select *,biblioitems.notes as bnotes from biblio, biblioitems,itemtypes
where biblio.biblionumber = biblioitems.biblionumber
and biblioitemnumber = $bibitem
and biblioitems.itemtype = itemtypes.itemtype";
    my $sth   = $dbh->prepare($query);
    my $data;

    $sth->execute;

    $data = $sth->fetchrow_hashref;

    $sth->finish;
    $dbh->disconnect;
    return($data);
} # sub bibitemdata


sub subject {
  my ($bibnum)=@_;
  my $dbh=C4Connect;
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
  $dbh->disconnect;
  return($i,\@results);
}

sub addauthor {
  my ($bibnum)=@_;
  my $dbh=C4Connect;
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
  $dbh->disconnect;
  return($i,\@results);
}

sub subtitle {
  my ($bibnum)=@_;
  my $dbh=C4Connect;
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
  $dbh->disconnect;
  return($i,\@results);
}



sub itemissues {
    my ($bibitem, $biblio)=@_;
    my $dbh   = C4Connect;
    my $query = "Select * from items where 
items.biblioitemnumber = '$bibitem'";
    my $sth   = $dbh->prepare($query)
      || die $dbh->errstr;
    my $i     = 0;
    my @results;
  
    $sth->execute
      || die $sth->errstr;

    while (my $data = $sth->fetchrow_hashref) {
        my $query2 = "select * from issues,borrowers
where itemnumber = $data->{'itemnumber'}
and returndate is NULL
and issues.borrowernumber = borrowers.borrowernumber";
        my $sth2   = $dbh->prepare($query2);

        $sth2->execute;	
        if (my $data2 = $sth2->fetchrow_hashref) {
            $data->{'date_due'} = $data2->{'date_due'};
            $data->{'card'}     = $data2->{'cardnumber'};
        } else {
            if ($data->{'wthdrawn'} eq '1') {
                $data->{'date_due'} = 'Cancelled';
            } else {
                $data->{'date_due'} = 'Available';
            } # else
        } # else

        $sth2->finish;
        $query2 = "select * from issues, borrowers
where itemnumber = '$data->{'itemnumber'}'
and issues.borrowernumber = borrowers.borrowernumber 
and returndate is not NULL
order by returndate desc,timestamp desc";
        $sth2 = $dbh->prepare($query2)
          || die $dbh->errstr;
        $sth2->execute
          || die $sth2->errstr;

        for (my $i2 = 0; $i2 < 2; $i2++) {
            if (my $data2 = $sth2->fetchrow_hashref) {
                $data->{"timestamp$i2"} = $data2->{'timestamp'};
                $data->{"card$i2"}      = $data2->{'cardnumber'};
                $data->{"borrower$i2"}  = $data2->{'borrowernumber'};
            } # if
        } # for

        $sth2->finish;
        $results[$i] = $data;
        $i++;
    }

    $sth->finish;
    $dbh->disconnect;
    return(@results);
}


sub itemnodata {
  my ($env,$dbh,$itemnumber) = @_;
  $dbh=C4Connect;
  my $query="Select * from biblio,items,biblioitems
    where items.itemnumber = '$itemnumber'
    and biblio.biblionumber = items.biblionumber
    and biblioitems.biblioitemnumber = items.biblioitemnumber";
  my $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;  
  $dbh->disconnect;
  return($data);	       
}

#used by member enquiries from the intranet
#called by member.pl
sub BornameSearch  {
  my ($env,$searchstring,$type)=@_;
  my $dbh = &C4Connect;
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
#  print $query,"\n";
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
  $dbh->disconnect;
  return ($cnt,\@results);
}

sub borrdata {
  my ($cardnumber,$bornum)=@_;
  $cardnumber = uc $cardnumber;
  my $dbh=C4Connect;
  my $query;
  if ($bornum eq ''){
    $query="Select * from borrowers where cardnumber='$cardnumber'";
  } else {
      $query="Select * from borrowers where borrowernumber='$bornum'";
  }
  #print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return($data);
}

sub borrissues {
  my ($bornum)=@_;
  my $dbh=C4Connect;
  my $query;
  $query="Select * from issues,biblio,items where borrowernumber='$bornum' and
items.itemnumber=issues.itemnumber and
items.biblionumber=biblio.biblionumber and issues.returndate is NULL order
by date_due";
  #print $query;
  my $sth=$dbh->prepare($query);
    $sth->execute;
  my @result;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $result[$i]=$data;;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,\@result);
}

sub allissues { 
  my ($bornum,$order,$limit)=@_; 
  my $dbh=C4Connect;   
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
  #print $query;                           
  my $sth=$dbh->prepare($query);          
  $sth->execute;
  my @result;   
  my $i=0;    
  while (my $data=$sth->fetchrow_hashref){                                      
    $result[$i]=$data;; 
    $i++;     
  }         
  $sth->finish;           
  $dbh->disconnect;             
  return($i,\@result);               
}

sub borrdata2 {
  my ($env,$bornum)=@_;
  my $dbh=C4Connect;
  my $query="Select count(*) from issues where borrowernumber='$bornum' and
    returndate is NULL";
    # print $query;
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
  $dbh->disconnect;

return($data2->{'count(*)'},$data->{'count(*)'},$data3->{'sum(amountoutstanding)'});
}
	

sub getboracctrecord {
   my ($env,$params) = @_;
   my $dbh=C4Connect;
   my @acctlines;
   my $numlines=0;
   my $query= "Select * from accountlines where
borrowernumber=$params->{'borrowernumber'} order by date desc,timestamp desc";
   my $sth=$dbh->prepare($query);
#   print $query;
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
   $dbh->disconnect;
   return ($numlines,\@acctlines,$total);
}


sub itemcount { 
  my ($env,$bibnum,$type)=@_; 
  my $dbh=C4Connect;   
  my $query="Select * from items where     
  biblionumber=$bibnum ";
  if ($type ne 'intra'){
    $query.=" and ((itemlost <>1 and itemlost <> 2) or itemlost is NULL) and
    (wthdrawn <> 1 or wthdrawn is NULL)";      
  }
  my $sth=$dbh->prepare($query);         
  #  print $query;           
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
    and items.itemnumber=issues.itemnumber and ((items.itemlost <>1 and
    items.itemlost <> 2) or items.itemlost is NULL) 
    and (wthdrawn <> 1 or wthdrawn is NULL)"; 
    
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
      if ($data->{'itemlost'} eq '2'){
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
  $dbh->disconnect;                   
  return ($count,$lcount,$nacount,$fcount,$scount,$lostcount,$mending,$transit,$ocount); 
}


sub itemcount2 { 
  my ($env,$bibnum,$type)=@_; 
  my $dbh=C4Connect;   
  my $query="Select * from items,branches where     
  biblionumber=$bibnum and items.holdingbranch=branches.branchcode";
  if ($type ne 'intra'){
    $query.=" and ((itemlost <>1 and itemlost <> 2) or itemlost is NULL) and
    (wthdrawn <> 1 or wthdrawn is NULL)";      
  }
  my $sth=$dbh->prepare($query);         
  #  print $query;           
  $sth->execute;           
  my %counts;
  $counts{'total'}=0;
  while (my $data=$sth->fetchrow_hashref){
    $counts{'total'}++;                     
    my $query2="select * from issues,items where issues.itemnumber=                          
    '$data->{'itemnumber'}' and returndate is NULL
    and items.itemnumber=issues.itemnumber and ((items.itemlost <>1 and
    items.itemlost <> 2) or items.itemlost is NULL) 
    and (wthdrawn <> 1 or wthdrawn is NULL)"; 
    
    my $sth2=$dbh->prepare($query2);     
    $sth2->execute;         
    if (my $data2=$sth2->fetchrow_hashref){         
       $counts{'not available'}++;         
    } else {         
       $counts{$data->{'branchname'}}++;
    }                             
    $sth2->finish;     
  } 
  my $query2="Select * from aqorders where biblionumber=$bibnum and
  datecancellationprinted is NULL and quantity > quantityreceived";
  my $sth2=$dbh->prepare($query2);
  $sth2->execute;
  if (my $data=$sth2->fetchrow_hashref){
      $counts{'order'}=$data->{'quantity'} - $data->{'quantityreceived'};
  }
  $sth2->finish;
  $sth->finish; 
  $dbh->disconnect;                   
  return (\%counts); 
}


sub ItemType {
  my ($type)=@_;
  my $dbh=C4Connect;
  my $query="select description from itemtypes where itemtype='$type'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $dat=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return ($dat->{'description'});
}


sub bibitems {
    my ($bibnum) = @_;
    my $dbh   = C4Connect;
    my $query = "SELECT biblioitems.*, itemtypes.*, MIN(items.itemlost) as itemlost
                          FROM biblioitems, itemtypes, items
                         WHERE biblioitems.biblionumber     = ?
                           AND biblioitems.itemtype         = itemtypes.itemtype
                           AND biblioitems.biblioitemnumber = items.biblioitemnumber
                      GROUP BY items.biblioitemnumber";
    my $sth   = $dbh->prepare($query);
    my $count = 0;
    my @results;
    $sth->execute($bibnum);
    while (my $data = $sth->fetchrow_hashref) {
        $results[$count] = $data;
        $count++;
    } # while    
    $sth->finish;
    $dbh->disconnect;
    return($count, @results);
} # sub bibitems

sub barcodes{
    #called from request.pl
    my ($biblioitemnumber)=@_;
    my $dbh=C4Connect;
    my $query="SELECT barcode, itemlost FROM items
                           WHERE biblioitemnumber = ?
                             AND (wthdrawn <> 1 OR wthdrawn IS NULL)";
    my $sth=$dbh->prepare($query);
    $sth->execute($biblioitemnumber);
    my @barcodes;
    my $i=0;
    while (my $data=$sth->fetchrow_hashref){
	$barcodes[$i]=$data;
	$i++;
    }
    $sth->finish;
    $dbh->disconnect;
    return(@barcodes);
}


sub getwebsites {
    my ($biblionumber) = @_;
    my $dbh   = C4Connect;
    my $query = "Select * from websites where biblionumber = $biblionumber";
    my $sth   = $dbh->prepare($query);
    my $count = 0;
    my @results;

    $sth->execute;
    while (my $data = $sth->fetchrow_hashref) {
        $data->{'url'} =~ s/^http:\/\///;
        $results[$count] = $data;
    	$count++;
    } # while

    $sth->finish;
    $dbh->disconnect;
    return($count, @results);
} # sub getwebsites


sub getwebbiblioitems {
    my ($biblionumber) = @_;
    my $dbh   = C4Connect;
    my $query = "Select * from biblioitems where biblionumber = $biblionumber
and itemtype = 'WEB'";
    my $sth   = $dbh->prepare($query);
    my $count = 0;
    my @results;
    
    $sth->execute;
    while (my $data = $sth->fetchrow_hashref) {
        $data->{'url'} =~ s/^http:\/\///;
        $results[$count] = $data;
        $count++;
    } # while
    
    $sth->finish;
    $dbh->disconnect;
    return($count, @results);
} # sub getwebbiblioitems


END { }       # module clean-up code here (global destructor)

=head1 NAME

C4::Search - Module that provides Catalog searching for Koha

=head1 SYNOPSIS

  use C4::Search;
  my ($count,@results)=catalogsearch($env,$type,$search,$num,$offset);

=head1 DESCRIPTION

This module provides the searching facilities for the Catalog.
Here I should go through and document each function thats exported and what it does. But I havent yet.

my ($count,@results)=catalogsearch($env,$type,$search,$num,$offset);
This is a front end to all the other searches, depending on what is passed
to it, it calls the appropriate search

=head2 EXPORT

catalogsearch

=head1 AUTHOR

Koha Developement team <info@koha.org>

=head1 SEE ALSO

L<perl>.

=cut
