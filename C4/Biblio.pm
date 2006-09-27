package C4::Biblio;
# New XML API added by tgarip@neu.edu.tr 25/08/06
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
use C4::Context;
use XML::Simple;
use Encode;
use utf8;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 2.01;

@ISA = qw(Exporter);

# &itemcount removed, now  resides in Search.pm
#
@EXPORT = qw(

&getitemtypes
&getkohafields
&getshelves

&NEWnewbiblio 
&NEWnewitem
&NEWmodbiblio 
&NEWmoditem
&NEWdelbiblio 
&NEWdelitem
&NEWmodbiblioframework


&MARCfind_marc_from_kohafield
&MARCfind_frameworkcode
&MARCfind_itemtype
&MARCgettagslib
&MARCitemsgettagslib

&MARCfind_attr_from_kohafield
&MARChtml2xml 


&XMLgetbiblio 
&XMLgetbibliohash
&XMLgetitem 
&XMLgetitemhash
&XMLgetallitems 
&XML_xml2hash 
&XML_xml2hash_onerecord
&XML_hash2xml 
&XMLmarc2koha
&XMLmarc2koha_onerecord
&XML_readline
&XML_readline_onerecord
&XML_readline_asarray
&XML_writeline
&XML_writeline_id
&XMLmoditemonefield
&XMLkoha2marc
&XML_separate
&XML_record_header
&ZEBRAdelbiblio
&ZEBRAgetrecord   
&ZEBRAop 
&ZEBRAopserver 
&ZEBRA_readyXML 
&ZEBRA_readyXML_noheader

&newbiblio
&modbiblio
&DisplayISBN

);

#################### XML XML  XML  XML ###################
### XML Read- Write functions
sub XML_readline_onerecord{
my ($xml,$kohafield,$recordtype,$tag,$subf)=@_;
#$xml represents one record of MARCXML as perlhashed 
### $recordtype is needed for mapping the correct field
 ($tag,$subf)=MARCfind_marc_from_kohafield($kohafield,$recordtype) if $kohafield;

if ($tag){
my $biblio=$xml->{'datafield'};
my $controlfields=$xml->{'controlfield'};
my $leader=$xml->{'leader'};
 if ($tag>9){
	foreach my $data (@$biblio){
   	    if ($data->{'tag'} eq $tag){
		foreach my $subfield ( $data->{'subfield'}){
		    foreach my $code ( @$subfield){
			if ($code->{'code'} eq $subf){
			return $code->{'content'};
			}
		   }
		}
  	   }
	}
  }else{
	if ($tag eq "000" || $tag eq "LDR"){
		return  $leader->[0] if $leader->[0];
	}else{
	     foreach my $control (@$controlfields){
		if ($control->{'tag'} eq $tag){
		return	$control->{'content'} if $control->{'content'};
		}
	    }
	}
   }##tag
}## if tag is mapped
return "";
}
sub XML_readline_asarray{
my ($xml,$kohafield,$recordtype,$tag,$subf)=@_;
#$xml represents one record of MARCXML as perlhashed 
## returns an array of read fields--useful for readind repeated fields
### $recordtype is needed for mapping the correct field if supplied
### If only $tag is give reads the whole tag
my @value;
 ($tag,$subf)=MARCfind_marc_from_kohafield($kohafield,$recordtype) if $kohafield;
if ($tag){
my $biblio=$xml->{'datafield'};
my $controlfields=$xml->{'controlfield'};
my $leader=$xml->{'leader'};
 if ($tag>9){
	foreach my $data (@$biblio){
   	    if ($data->{'tag'} eq $tag){
		foreach my $subfield ( $data->{'subfield'}){
		    foreach my $code ( @$subfield){
			if ($code->{'code'} eq $subf || !$subf){
			push @value, $code->{'content'};
			}
		   }
		}
  	   }
	}
  }else{
	if ($tag eq "000" || $tag eq "LDR"){
		push @value,  $leader->[0] if $leader->[0];
	}else{
	     foreach my $control (@$controlfields){
		if ($control->{'tag'} eq $tag){
		push @value,	$control->{'content'} if $control->{'content'};

		}
	    }
	}
   }##tag
}## if tag is mapped
return @value;
}

sub XML_readline{
my ($xml,$kohafield,$recordtype,$tag,$subf)=@_;
#$xml represents one record node hashed of holdings or a complete xml koharecord
### $recordtype is needed for reading the child records( like holdings records) .Otherwise main  record is assumed ( like biblio)
## holding records are parsed and sent here one by one
# If kohafieldname given find tag

($tag,$subf)=MARCfind_marc_from_kohafield($kohafield,$recordtype) if $kohafield;
my @itemresults;
if ($tag){
if ($recordtype eq "holdings"){
	my $item=$xml->{'datafield'};
	my $hcontrolfield=$xml->{'controlfield'};
     if ($tag>9){
	foreach my $data (@$item){
   	    if ($data->{'tag'} eq $tag){
		foreach my $subfield ( $data->{'subfield'}){
		    foreach my $code ( @$subfield){
			if ($code->{'code'} eq $subf){
			return $code->{content};
			}
		   }
		}
  	   }
	}
      }else{
	foreach my $control (@$hcontrolfield){
		if ($control->{'tag'} eq $tag){
		return  $control->{'content'};
		}
	}
      }##tag

}else{ ##Not a holding read biblio
my $biblio=$xml->{'record'}->[0]->{'datafield'};
my $controlfields=$xml->{'record'}->[0]->{'controlfield'};
 if ($tag>9){
	foreach my $data (@$biblio){
   	    if ($data->{'tag'} eq $tag){
		foreach my $subfield ( $data->{'subfield'}){
		    foreach my $code ( @$subfield){
			if ($code->{'code'} eq $subf){
			return $code->{'content'};
			}
		   }
		}
  	   }
	}
  }else{
	
	foreach my $control (@$controlfields){
		if ($control->{'tag'} eq $tag){
		return	$control->{'content'}if $control->{'content'};
		}
	}
   }##tag
}## Holding or not
}## if tag is mapped
return "";
}

sub XML_writeline{
## This routine modifies one line of marcxml record hash
my ($xml,$kohafield,$newvalue,$recordtype,$tag,$subf)=@_;
$newvalue= Encode::decode('utf8',$newvalue) if $newvalue;
my $biblio=$xml->{'datafield'};
my $controlfield=$xml->{'controlfield'};
 ($tag,$subf)=MARCfind_marc_from_kohafield($kohafield,$recordtype) if $kohafield;
my $updated;
    if ($tag>9){
	foreach my $data (@$biblio){
        		if ($data->{'tag'} eq $tag){
			my @subfields=$data->{'subfield'};
			my @newsubs;
			foreach my $subfield ( @subfields){
	 		      foreach my $code ( @$subfield){
				if ($code->{'code'} eq $subf){	
				$code->{'content'}=$newvalue;
				$updated=1;
				}
			      push @newsubs,$code;
	  		      }
			}
		     if (!$updated){	
			 push @newsubs,{code=>$subf,content=>$newvalue};
			$data->{subfield}= \@newsubs;
			$updated=1;
		     }	
		}
       	 }
	## Tag did not exist
	     if (!$updated){
		if ($subf){	
	                push @$biblio,
                                           {
                                             'ind1' => ' ',
                                             'ind2' => ' ',
                                             'subfield' => [
                                                             {
                                                               'content' =>$newvalue,
                                                               'code' => $subf
                                                             }
                                                           ],
                                             'tag' =>$tag
                                           } ;
		   }else{
	                push @$biblio,
                                           {
                                             'ind1' => ' ',
                                             'ind2' => ' ',
                                             'tag' =>$tag
                                           } ;
		   }								
	   }## created now
    }elsif ($tag>0){
	foreach my $control (@$controlfield){
		if ($control->{'tag'} eq $tag){
			$control->{'content'}=$newvalue;
			$updated=1;
		}
	     }
	 if (!$updated){
	   push @$controlfield,{tag=>$tag,content=>$newvalue};     
	}
   }
return $xml;
}

sub XML_writeline_id {
### This routine is similar to XML_writeline but replaces a given value and do not create a new field
## Useful for repeating fields
## Currently  usedin authorities
my ($xml,$oldvalue,$newvalue,$tag,$subf)=@_;
$newvalue= Encode::decode('utf8',$newvalue) if $newvalue;
my $biblio=$xml->{'datafield'};
my $controlfield=$xml->{'controlfield'};
    if ($tag>9){
	foreach my $data (@$biblio){
        		if ($data->{'tag'} eq $tag){
			my @subfields=$data->{'subfield'};
			foreach my $subfield ( @subfields){
	 		      foreach my $code ( @$subfield){
				if ($code->{'code'} eq $subf && $code->{'content'} eq $oldvalue){	
				$code->{'content'}=$newvalue;
				}
	  		      }
			}	
		}
       	 }
    }else{
	foreach my $control(@$controlfield){
		if ($control->{'tag'} eq $tag  && $control->{'content'} eq $oldvalue ){
			$control->{'content'}=$newvalue;
		}
	     }
   }
return $xml;
}

sub XML_xml2hash{
##make a perl hash from xml file
my ($xml)=@_;
  my $hashed = XMLin( $xml ,KeyAttr =>['leader','controlfield','datafield'],ForceArray => ['leader','controlfield','datafield','subfield','holdings','record'],KeepRoot=>0);
return $hashed;
}

sub XML_separate{
##Separates items from biblio
my $hashed=shift;
my $biblio=$hashed->{record}->[0];
my @items;
my $items=$hashed->{holdings}->[0]->{record};
foreach my $item (@$items){
 push @items,$item;
}
return ($biblio,@items);
}

sub XML_xml2hash_onerecord{
##make a perl hash from xml file
my ($xml)=@_;
return undef unless $xml;
  my $hashed = XMLin( $xml ,KeyAttr =>['leader','controlfield','datafield'],ForceArray => ['leader','controlfield','datafield','subfield'],KeepRoot=>0);
return $hashed;
}
sub XML_hash2xml{
## turn a hash back to xml
my ($hashed,$root)=@_;
$root="record" unless $root;
my $xml= XMLout($hashed,KeyAttr=>['leader','controlfıeld','datafield'],NoSort => 1,AttrIndent => 0,KeepRoot=>0,SuppressEmpty => 1,RootName=>$root );
return $xml;
}



sub XMLgetbiblio {
    # Returns MARC::XML of the biblionumber passed in parameter.
    my ( $dbh, $biblionumber ) = @_;
    my $sth =      $dbh->prepare("select marcxml from biblio where biblionumber=? "  );
    $sth->execute( $biblionumber);
   my ($marcxml)=$sth->fetchrow;
	$marcxml=Encode::decode('utf8',$marcxml);
 return ($marcxml);
}

sub XMLgetbibliohash{
## Utility to return s hashed MARCXML
my ($dbh,$biblionumber)=@_;
my $xml=XMLgetbiblio($dbh,$biblionumber);
my $xmlhash=XML_xml2hash_onerecord($xml);
return $xmlhash;
}

sub XMLgetitem {
   # Returns MARC::XML   of the item passed in parameter uses either itemnumber or barcode
    my ( $dbh, $itemnumber,$barcode ) = @_;
my $sth;
if ($itemnumber){
   $sth = $dbh->prepare("select marcxml from items  where itemnumber=?"  ); 
    $sth->execute($itemnumber);
}else{
 $sth = $dbh->prepare("select marcxml from items where barcode=?"  ); 
    $sth->execute($barcode);
}
 my ($marcxml)=$sth->fetchrow;
$marcxml=Encode::decode('utf8',$marcxml);
    return ($marcxml);
}
sub XMLgetitemhash{
## Utility to return s hashed MARCXML
 my ( $dbh, $itemnumber,$barcode ) = @_;
my $xml=XMLgetitem( $dbh, $itemnumber,$barcode);
my $xmlhash=XML_xml2hash_onerecord($xml);
return $xmlhash;
}


sub XMLgetallitems {
# warn "XMLgetallitems";
    # Returns an array of MARC:XML   of the items passed in parameter as biblionumber
    my ( $dbh, $biblionumber ) = @_;
my @results;
my   $sth = $dbh->prepare("select marcxml from items where biblionumber =?"  ); 
    $sth->execute($biblionumber);

 while(my ($marcxml)=$sth->fetchrow_array){
$marcxml=Encode::decode('utf8',$marcxml);
    push @results,$marcxml;
}
return @results;
}

sub XMLmarc2koha {
# warn "XMLmarc2koha";
##Returns two hashes from KOHA_XML record hashed
## A biblio hash and and array of item hashes
	my ($dbh,$xml,$related_record,@fields) = @_;
	my ($result,@items);
	
## if @fields is given do not bother about the rest of fields just parse those

if ($related_record eq "biblios" || $related_record eq "" || !$related_record){
	if (@fields){
		foreach my $field(@fields){
		my $val=&XML_readline($xml,$field,'biblios');
			$result->{$field}=$val if $val;
			
		}
	}else{
	my $sth2=$dbh->prepare("SELECT  kohafield from koha_attr where  recordtype like 'biblios' and tagfield is not null" );
	$sth2->execute();
	my $field;
		while ($field=$sth2->fetchrow) {
		$result->{$field}=&XML_readline($xml,$field,'biblios');
		}
	}

## we only need the following for biblio data
	
# modify copyrightdate to keep only the 1st year found
	my $temp = $result->{'copyrightdate'};
	$temp =~ m/c(\d\d\d\d)/; # search cYYYY first
	if ($1>0) {
		$result->{'copyrightdate'} = $1;
	} else { # if no cYYYY, get the 1st date.
		$temp =~ m/(\d\d\d\d)/;
		$result->{'copyrightdate'} = $1;
	}
# modify publicationyear to keep only the 1st year found
	$temp = $result->{'publicationyear'};
	$temp =~ m/c(\d\d\d\d)/; # search cYYYY first
	if ($1>0) {
		$result->{'publicationyear'} = $1;
	} else { # if no cYYYY, get the 1st date.
		$temp =~ m/(\d\d\d\d)/;
		$result->{'publicationyear'} = $1;
	}
}
if ($related_record eq "holdings" || $related_record eq ""  || !$related_record){
my $holdings=$xml->{holdings}->[0]->{record};


	if (@fields){
	    foreach my $holding (@$holdings){	
my $itemresult;
		foreach my $field(@fields){
		my $val=&XML_readline($holding,$field,'holdings');
		$itemresult->{$field}=$val if $val;	
		}
	    push @items, $itemresult;
	   }
	}else{
	my $sth2=$dbh->prepare("SELECT  kohafield from koha_attr where recordtype like 'holdings' and tagfield is not null" );
	   foreach my $holding (@$holdings){	
	   $sth2->execute();
	    my $field;
my $itemresult;
		while ($field=$sth2->fetchrow) {
		$itemresult->{$field}=&XML_readline($xml,$field,'holdings');
		}
	 push @items, $itemresult;
	   }
	}

}

	return ($result,@items);
}
sub XMLmarc2koha_onerecord {
# warn "XMLmarc2koha_onerecord";
##Returns a koha hash from MARCXML hash

	my ($dbh,$xml,$related_record,@fields) = @_;
	my ($result);
	
## if @fields is given do not bother about the rest of fields just parse those

	if (@fields){
		foreach my $field(@fields){
		my $val=&XML_readline_onerecord($xml,$field,$related_record);
			$result->{$field}=$val if $val;			
		}
	}else{
	my $sth2=$dbh->prepare("SELECT  kohafield from koha_attr where  recordtype like ? and tagfield is not null" );
	$sth2->execute($related_record);
	my $field;
		while ($field=$sth2->fetchrow) {
		$result->{$field}=&XML_readline_onerecord($xml,$field,$related_record);
		}
	}
	return ($result);
}

sub XMLmodLCindex{
# warn "XMLmodLCindex";
my ($dbh,$xmlhash)=@_;
my ($lc)=XML_readline_onerecord($xmlhash,"classification","biblios");
my ($cutter)=XML_readline_onerecord($xmlhash,"subclass","biblios");

	if ($lc){
	$lc.=$cutter;
	my ($lcsort)=calculatelc($lc);
	$xmlhash=XML_writeline($xmlhash,"lcsort",$lcsort,"biblios");
	}
return $xmlhash;
}

sub XMLmoditemonefield{
# This routine takes itemnumber and biblionumber and updates XMLmarc;
### the ZEBR DB update can wait depending on $donotupdate flag
my ($dbh,$biblionumber,$itemnumber,$itemfield,$newvalue,$donotupdate)=@_;
my ($record) = XMLgetitem($dbh,$itemnumber);
	my $recordhash=XML_xml2hash_onerecord($record);
   	XML_writeline( $recordhash, $itemfield, $newvalue,"holdings" );	
 if($donotupdate){
	## Prevent various update calls to zebra wait until all changes finish
		$record=XML_hash2xml($recordhash);
		my $sth=$dbh->prepare("update items set marcxml=? where itemnumber=?");
		$sth->execute($record,$itemnumber);
		$sth->finish;
	}else{
		NEWmoditem($dbh,$recordhash,$biblionumber,$itemnumber);
  }

}

sub XMLkoha2marc {
# warn "MARCkoha2marc";
## This routine  is still used for acqui management
##Returns a  XML recordhash from a kohahash
	my ($dbh,$result,$recordtype) = @_;
###create a basic MARCXML
# find today's date
my ($sec,$min,$hour,$mday,$mon,$year) = localtime();
	$year += 1900;
	$mon += 1;
	my $timestamp = sprintf("%4d%02d%02d%02d%02d%02d.0",
		$year,$mon,$mday,$hour,$min,$sec);
$year=substr($year,2,2);
	my $accdate=sprintf("%2d%02d%02d",$year,$mon,$mday);
my ($titletag,$titlesubf)=MARCfind_marc_from_kohafield("title","biblios");
##create a dummy record
my $xml="<record><leader>     naa a22     7ar4500</leader><controlfield tag='xxx'></controlfield><datafield ind1='' ind2='' tag='$titletag'></datafield></record>";
## Now build XML
	my $record = XML_xml2hash($xml);
	my $sth2=$dbh->prepare("SELECT  kohafield from koha_attr where tagfield is not null and recordtype=?");
	$sth2->execute($recordtype);
	my $field;
	while (($field)=$sth2->fetchrow) {
		$record=XML_writeline($record,$field,$result->{$field},$recordtype) if $result->{$field};
	}
return $record;
}

#
#
# MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC
#
## Script to deal with MARCXML related tables


##Sub to match kohafield to Z3950 -attributes

sub MARCfind_attr_from_kohafield {
# warn "MARCfind_attr_from_kohafield";
## returns attribute
    my (  $kohafield ) = @_;
    return 0, 0 unless $kohafield;

	my $relations = C4::Context->attrfromkohafield;
	return ($relations->{$kohafield});
}


sub MARCgettagslib {
# warn "MARCgettagslib";
    my ( $dbh, $forlibrarian, $frameworkcode ) = @_;
    $frameworkcode = "" unless $frameworkcode;
    my $sth;
    my $libfield = ( $forlibrarian eq 1 ) ? 'liblibrarian' : 'libopac';

    # check that framework exists
    $sth =
      $dbh->prepare(
        "select count(*) from biblios_tag_structure where frameworkcode=?");
    $sth->execute($frameworkcode);
    my ($total) = $sth->fetchrow;
    $frameworkcode = "" unless ( $total > 0 );
    $sth =
      $dbh->prepare(
"select tagfield,liblibrarian,libopac,mandatory,repeatable from biblios_tag_structure where frameworkcode=? order by tagfield"
    );
    $sth->execute($frameworkcode);
    my ( $liblibrarian, $libopac, $tag, $res, $tab, $mandatory, $repeatable );

    while ( ( $tag, $liblibrarian, $libopac, $mandatory, $repeatable ) = $sth->fetchrow ) {
        $res->{$tag}->{lib}        = ($forlibrarian or !$libopac)?$liblibrarian:$libopac;
        $res->{$tab}->{tab}        = "";            # XXX
        $res->{$tag}->{mandatory}  = $mandatory;
        $res->{$tag}->{repeatable} = $repeatable;
    }

    $sth =
      $dbh->prepare(
"select tagfield,tagsubfield,liblibrarian,libopac,tab, mandatory, repeatable,authorised_value,authtypecode,value_builder,seealso,hidden,isurl,link from biblios_subfield_structure where frameworkcode=? order by tagfield,tagsubfield"
    );
    $sth->execute($frameworkcode);

    my $subfield;
    my $authorised_value;
    my $authtypecode;
    my $value_builder;
   
    my $seealso;
    my $hidden;
    my $isurl;
	my $link;

    while (
        ( $tag,         $subfield,   $liblibrarian,   , $libopac,      $tab,
        $mandatory,     $repeatable, $authorised_value, $authtypecode,
        $value_builder,   $seealso,          $hidden,
        $isurl,			$link )
        = $sth->fetchrow
      )
    {
        $res->{$tag}->{$subfield}->{lib}              = ($forlibrarian or !$libopac)?$liblibrarian:$libopac;
        $res->{$tag}->{$subfield}->{tab}              = $tab;
        $res->{$tag}->{$subfield}->{mandatory}        = $mandatory;
        $res->{$tag}->{$subfield}->{repeatable}       = $repeatable;
        $res->{$tag}->{$subfield}->{authorised_value} = $authorised_value;
        $res->{$tag}->{$subfield}->{authtypecode}     = $authtypecode;
        $res->{$tag}->{$subfield}->{value_builder}    = $value_builder;
        $res->{$tag}->{$subfield}->{seealso}          = $seealso;
        $res->{$tag}->{$subfield}->{hidden}           = $hidden;
        $res->{$tag}->{$subfield}->{isurl}            = $isurl;
        $res->{$tag}->{$subfield}->{link}            = $link;
    }
    return $res;
}
sub MARCitemsgettagslib {
# warn "MARCitemsgettagslib";
    my ( $dbh, $forlibrarian, $frameworkcode ) = @_;
    $frameworkcode = "" unless $frameworkcode;
    my $sth;
    my $libfield = ( $forlibrarian eq 1 ) ? 'liblibrarian' : 'libopac';

    # check that framework exists
    $sth =
      $dbh->prepare(
        "select count(*) from holdings_tag_structure where frameworkcode=?");
    $sth->execute($frameworkcode);
    my ($total) = $sth->fetchrow;
    $frameworkcode = "" unless ( $total > 0 );
    $sth =
      $dbh->prepare(
"select tagfield,liblibrarian,libopac,mandatory,repeatable from holdings_tag_structure where frameworkcode=? order by tagfield"
    );
    $sth->execute($frameworkcode);
    my ( $liblibrarian, $libopac, $tag, $res, $tab, $mandatory, $repeatable );

    while ( ( $tag, $liblibrarian, $libopac, $mandatory, $repeatable ) = $sth->fetchrow ) {
        $res->{$tag}->{lib}        = ($forlibrarian or !$libopac)?$liblibrarian:$libopac;
        $res->{$tab}->{tab}        = "";            # XXX
        $res->{$tag}->{mandatory}  = $mandatory;
        $res->{$tag}->{repeatable} = $repeatable;
    }

    $sth =
      $dbh->prepare(
"select tagfield,tagsubfield,liblibrarian,libopac,tab, mandatory, repeatable,authorised_value,authtypecode,value_builder,seealso,hidden,isurl,link from holdings_subfield_structure where frameworkcode=? order by tagfield,tagsubfield"
    );
    $sth->execute($frameworkcode);

    my $subfield;
    my $authorised_value;
    my $authtypecode;
    my $value_builder;
   
    my $seealso;
    my $hidden;
    my $isurl;
	my $link;

    while (
        ( $tag,         $subfield,   $liblibrarian,   , $libopac,      $tab,
        $mandatory,     $repeatable, $authorised_value, $authtypecode,
        $value_builder, $seealso,          $hidden,
        $isurl,			$link )
        = $sth->fetchrow
      )
    {
        $res->{$tag}->{$subfield}->{lib}              = ($forlibrarian or !$libopac)?$liblibrarian:$libopac;
        $res->{$tag}->{$subfield}->{tab}              = $tab;
        $res->{$tag}->{$subfield}->{mandatory}        = $mandatory;
        $res->{$tag}->{$subfield}->{repeatable}       = $repeatable;
        $res->{$tag}->{$subfield}->{authorised_value} = $authorised_value;
        $res->{$tag}->{$subfield}->{authtypecode}     = $authtypecode;
        $res->{$tag}->{$subfield}->{value_builder}    = $value_builder;
        $res->{$tag}->{$subfield}->{seealso}          = $seealso;
        $res->{$tag}->{$subfield}->{hidden}           = $hidden;
        $res->{$tag}->{$subfield}->{isurl}            = $isurl;
        $res->{$tag}->{$subfield}->{link}            = $link;
    }
    return $res;
}
sub MARCfind_marc_from_kohafield {
# warn "MARCfind_marc_from_kohafield";
    my (  $kohafield,$recordtype) = @_;
    return 0, 0 unless $kohafield;
$recordtype="biblios" unless $recordtype;
	my $relations = C4::Context->marcfromkohafield;
	return ($relations->{$recordtype}->{$kohafield}->[0],$relations->{$recordtype}->{$kohafield}->[1]);
}




sub MARCfind_frameworkcode {
# warn "MARCfind_frameworkcode";
    my ( $dbh, $biblionumber ) = @_;
    my $sth =
      $dbh->prepare("select frameworkcode from biblio where biblionumber=?");
    $sth->execute($biblionumber);
    my ($frameworkcode) = $sth->fetchrow;
    return $frameworkcode;
}
sub MARCfind_itemtype {
# warn "MARCfind_itemtype";
    my ( $dbh, $biblionumber ) = @_;
    my $sth =
      $dbh->prepare("select itemtype from biblio where biblionumber=?");
    $sth->execute($biblionumber);
    my ($itemtype) = $sth->fetchrow;
    return $itemtype;
}



sub MARChtml2xml {
# warn "MARChtml2xml ";
	my ($tags,$subfields,$values,$indicator,$ind_tag,$tagindex) = @_;        
	my $xml= "<record>";

    my $prevvalue;
    my $prevtag=-1;
    my $first=1;
	my $j = -1;
    for (my $i=0;$i<=@$tags;$i++){
		@$values[$i] =~ s/&/&amp;/g;
		@$values[$i] =~ s/</&lt;/g;
		@$values[$i] =~ s/>/&gt;/g;
		@$values[$i] =~ s/"/&quot;/g;
		@$values[$i] =~ s/'/&apos;/g;

		if ((@$tags[$i].@$tagindex[$i] ne $prevtag)){
			my $tag=@$tags[$i];
			$j++ unless ($tag eq "");
			## warn "IND:".substr(@$indicator[$j],0,1).substr(@$indicator[$j],1,1)." ".@$tags[$i];
			if (!$first){
		    	$xml.="</datafield>\n";
				if (($tag> 10) && (@$values[$i] ne "")){
						my $ind1 = substr(@$indicator[$j],0,1);
                        my $ind2 = substr(@$indicator[$j],1,1);
                        $xml.="<datafield tag=\"$tag\" ind1=\"$ind1\" ind2=\"$ind2\">\n";
                        $xml.="<subfield code=\"@$subfields[$i]\">@$values[$i]</subfield>\n";
                        $first=0;
				} else {
		    	$first=1;
				}
            			} else {
		    	if (@$values[$i] ne "") {
		    		# leader
		    		if ($tag eq "000") {
				##Force the leader to UTF8
				substr(@$values[$i],9,1)="a";
						$xml.="<leader>@$values[$i]</leader>\n";
						$first=1;
					# rest of the fixed fields
		    		} elsif ($tag < 10) {
						$xml.="<controlfield tag=\"$tag\">@$values[$i]</controlfield>\n";
						$first=1;
		    		} else {
						my $ind1 = substr(@$indicator[$j],0,1);
						my $ind2 = substr(@$indicator[$j],1,1);
						$xml.="<datafield tag=\"$tag\" ind1=\"$ind1\" ind2=\"$ind2\">\n";
						$xml.="<subfield code=\"@$subfields[$i]\">@$values[$i]</subfield>\n";
						$first=0;			
		    		}
		    	}
			}
		} else { # @$tags[$i] eq $prevtag
                                 unless (@$values[$i] eq "") {
              		my $tag=@$tags[$i];
					if ($first){
						my $ind1 = substr(@$indicator[$j],0,1);                        
						my $ind2 = substr(@$indicator[$j],1,1);
						$xml.="<datafield tag=\"$tag\" ind1=\"$ind1\" ind2=\"$ind2\">\n";
						$first=0;
					}
		    	$xml.="<subfield code=\"@$subfields[$i]\">@$values[$i]</subfield>\n";
				}
		}
		$prevtag = @$tags[$i].@$tagindex[$i];
	}
	$xml.="</record>";
	# warn $xml;
	$xml=Encode::decode('utf8',$xml);
	return $xml;
}
sub XML_record_header {
####  this one is for <record>
    my $format = shift;
    my $enc = shift || 'UTF-8';
##
    return( <<MARC_XML_HEADER );
<?xml version="1.0" encoding="$enc"?>
<record  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd"
  xmlns="http://www.loc.gov/MARC21/slim">
MARC_XML_HEADER
}


sub collection_header {
####  this one is for koha collection 
    my $format = shift;
    my $enc = shift || 'UTF-8';
    return( <<KOHA_XML_HEADER );
<?xml version="1.0" encoding="$enc"?>
<kohacollection xmlns:marc="http://loc.gov/MARC21/slim" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://library.neu.edu.tr/kohanamespace/koharecord.xsd">
KOHA_XML_HEADER
}








##########################NEW NEW NEW#############################
sub NEWnewbiblio {
    my ( $dbh, $xml, $frameworkcode) = @_;
$frameworkcode="" unless $frameworkcode;
my $biblionumber=XML_readline_onerecord($xml,"biblionumber","biblios");
## In case reimporting records with biblionumbers keep them
if ($biblionumber){
$biblionumber=NEWmodbiblio( $dbh, $biblionumber,$xml,$frameworkcode );
}else{
    $biblionumber = NEWaddbiblio( $dbh, $xml,$frameworkcode );
}

   return ( $biblionumber );
}





sub NEWmodbiblioframework {
	my ($dbh,$biblionumber,$frameworkcode) =@_;
	my $sth = $dbh->prepare("Update biblio SET frameworkcode=? WHERE biblionumber=$biblionumber");
	$sth->execute($frameworkcode);
	return 1;
}


sub NEWdelbiblio {
    my ( $dbh, $biblionumber ) = @_;
ZEBRAop($dbh,$biblionumber,"recordDelete","biblioserver");
}


sub NEWnewitem {
    my ( $dbh, $xmlhash, $biblionumber ) = @_;
	my $itemtype= MARCfind_itemtype($dbh,$biblionumber);

## In case we are re-importing marc records from bulk import do not change itemnumbers
my $itemnumber=XML_readline_onerecord($xmlhash,"itemnumber","holdings");
if ($itemnumber){
NEWmoditem ( $dbh, $xmlhash, $biblionumber, $itemnumber);
}else{
   
##Add biblionumber to $record
$xmlhash=XML_writeline($xmlhash,"biblionumber",$biblionumber,"holdings");
 my $sth=$dbh->prepare("select notforloan from itemtypes where itemtype='$itemtype'");
$sth->execute();
my $notforloan=$sth->fetchrow;
##Change the notforloan field if $notforloan found
	if ($notforloan >0){
	$xmlhash=XML_writeline($xmlhash,"notforloan",$notforloan,"holdings");
	}
my $dateaccessioned=XML_readline_onerecord($xmlhash,"dateaccessioned","holdings");
unless($dateaccessioned){
# find today's date
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =                                                           
localtime(time); $year +=1900; $mon +=1;
my $date = "$year-".sprintf ("%0.2d", $mon)."-".sprintf("%0.2d",$mday);

$xmlhash=XML_writeline($xmlhash,"dateaccessioned",$date,"holdings");
}
  
## Now calculate itempart of cutter-- This is NEU specific
my $itemcallnumber=XML_readline_onerecord($xmlhash,"itemcallnumber","holdings");
if ($itemcallnumber){
my ($cutterextra)=itemcalculator($dbh,$biblionumber,$itemcallnumber);
$xmlhash=XML_writeline($xmlhash,"cutterextra",$cutterextra,"holdings");
}

##NEU specific add cataloguers cardnumber as well
my $me= C4::Context->userenv;
my $cataloger=$me->{'cardnumber'} if ($me);
$xmlhash=XML_writeline($xmlhash,"circid",$cataloger,"holdings") if $cataloger;

##Add item to SQL
my  $itemnumber = &OLDnewitems( $dbh, $xmlhash );

# add the item to zebra it will add the biblio as well!!!
    ZEBRAop( $dbh, $biblionumber,"specialUpdate","biblioserver" );
return $itemnumber;
}## added new item

}



sub NEWmoditem{
    my ( $dbh, $xmlhash, $biblionumber, $itemnumber ) = @_;

##Add itemnumber incase lost (old bug 090c was lost sometimes) --just incase
$xmlhash=XML_writeline($xmlhash,"itemnumber",$itemnumber,"holdings");
##Add biblionumber incase lost on html
$xmlhash=XML_writeline($xmlhash,"biblionumber",$biblionumber,"holdings");
##Read barcode
my $barcode=XML_readline_onerecord($xmlhash,"barcode","holdings");		
## Now calculate itempart of cutter-- This is NEU specific
my $itemcallnumber=XML_readline_onerecord($xmlhash,"itemcallnumber","holdings");
if ($itemcallnumber){
my ($cutterextra)=itemcalculator($dbh,$biblionumber,$itemcallnumber);
$xmlhash=XML_writeline($xmlhash,"cutterextra",$cutterextra,"holdings");
}

##NEU specific add cataloguers cardnumber as well
my $me= C4::Context->userenv;
my $cataloger=$me->{'cardnumber'} if ($me);
$xmlhash=XML_writeline($xmlhash,"circid",$cataloger,"holdings") if $cataloger;
my $xml=XML_hash2xml($xmlhash);
    OLDmoditem( $dbh, $xml,$biblionumber,$itemnumber,$barcode );
    ZEBRAop($dbh,$biblionumber,"specialUpdate","biblioserver");
}

sub NEWdelitem {
    my ( $dbh, $itemnumber ) = @_;	
my $sth=$dbh->prepare("SELECT biblionumber from items where itemnumber=?");
$sth->execute($itemnumber);
my $biblionumber=$sth->fetchrow;
OLDdelitem( $dbh, $itemnumber ) ;
ZEBRAop($dbh,$biblionumber,"specialUpdate","biblioserver");

}




sub NEWaddbiblio {
    my ( $dbh, $xmlhash,$frameworkcode ) = @_;
     my $sth = $dbh->prepare("Select max(biblionumber) from biblio");
    $sth->execute;
    my $data   = $sth->fetchrow;
    my $biblionumber = $data + 1;
    $sth->finish;
    # we must add biblionumber 
my $record;
$xmlhash=XML_writeline($xmlhash,"biblionumber",$biblionumber,"biblios");

###NEU specific add cataloguers cardnumber as well

my $me= C4::Context->userenv;
my $cataloger=$me->{'cardnumber'} if ($me);
$xmlhash=XML_writeline($xmlhash,"indexedby",$cataloger,"biblios") if $cataloger;

## We must add the indexing fields for LC in MARC record--TG
&XMLmodLCindex($dbh,$xmlhash);

##Find itemtype
my $itemtype=XML_readline_onerecord($xmlhash,"itemtype","biblios");
##Find ISBN
my $isbn=XML_readline_onerecord($xmlhash,"isbn","biblios");
##Find ISSN
my $issn=XML_readline_onerecord($xmlhash,"issn","biblios");
##Find Title
my $title=XML_readline_onerecord($xmlhash,"title","biblios");
##Find Author
my $author=XML_readline_onerecord($xmlhash,"title","biblios");
my $xml=XML_hash2xml($xmlhash);

    $sth = $dbh->prepare("insert into biblio set biblionumber  = ?,frameworkcode=?, itemtype=?,marcxml=?,title=?,author=?,isbn=?,issn=?" );
    $sth->execute( $biblionumber,$frameworkcode, $itemtype,$xml ,$title,$author,$isbn,$issn  );

    $sth->finish;
### Do not add biblio to ZEBRA unless there is an item with it -- depends on system preference defaults to NO
if (C4::Context->preference('AddaloneBiblios')){
 ZEBRAop($dbh,$biblionumber,"specialUpdate","biblioserver");
}
    return ($biblionumber);
}

sub NEWmodbiblio {
    my ( $dbh, $biblionumber,$xmlhash,$frameworkcode ) = @_;
##Add biblionumber incase lost on html

$xmlhash=XML_writeline($xmlhash,"biblionumber",$biblionumber,"biblios");

###NEU specific add cataloguers cardnumber as well
my $me= C4::Context->userenv;
my $cataloger=$me->{'cardnumber'} if ($me);

$xmlhash=XML_writeline($xmlhash,"indexedby",$cataloger,"biblios") if $cataloger;

## We must add the indexing fields for LC in MARC record--TG

  XMLmodLCindex($dbh,$xmlhash);
    OLDmodbiblio ($dbh,$xmlhash,$biblionumber,$frameworkcode);
    my $ok=ZEBRAop($dbh,$biblionumber,"specialUpdate","biblioserver");
    return ($biblionumber);
}

#
#
# OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD
#
#

sub OLDnewitems {

    my ( $dbh, $xmlhash) = @_;
    my $sth = $dbh->prepare("SELECT max(itemnumber) from items");
    my $data;
    my $itemnumber;
    $sth->execute;
    $data       = $sth->fetchrow_hashref;
    $itemnumber = $data->{'max(itemnumber)'} + 1;
    $sth->finish;
      $xmlhash=XML_writeline(  $xmlhash, "itemnumber", $itemnumber,"holdings" );
my $biblionumber=XML_readline_onerecord($xmlhash,"biblionumber","holdings");
 my $barcode=XML_readline_onerecord($xmlhash,"barcode","holdings");
my $xml=XML_hash2xml($xmlhash);
        $sth = $dbh->prepare( "Insert into items set itemnumber = ?,	biblionumber  = ?,barcode = ?,marcxml=?"   );
        $sth->execute($itemnumber,$biblionumber,$barcode,$xml);
    return $itemnumber;
}

sub OLDmoditem {
    my ( $dbh, $xml,$biblionumber,$itemnumber,$barcode  ) = @_;
    my $sth =$dbh->prepare("replace items set  biblionumber=?,marcxml=?,barcode=? , itemnumber=?");
    $sth->execute($biblionumber,$xml,$barcode,$itemnumber);
    $sth->finish;
}

sub OLDdelitem {
    my ( $dbh, $itemnumber ) = @_;
my $sth = $dbh->prepare("select * from items where itemnumber=?");
    $sth->execute($itemnumber);
    if ( my $data = $sth->fetchrow_hashref ) {
        $sth->finish;
        my $query = "replace deleteditems set ";
        my @bind  = ();
        foreach my $temp ( keys %$data ) {
            $query .= "$temp = ?,";
            push ( @bind, $data->{$temp} );
        }

        #replacing the last , by ",?)"
        $query =~ s/\,$//;
        $sth = $dbh->prepare($query);
        $sth->execute(@bind);
        $sth->finish;
   $sth = $dbh->prepare("Delete from items where itemnumber=?");
    $sth->execute($itemnumber);
    $sth->finish;
  }
 $sth->finish;
}

sub OLDmodbiblio {
# modifies the biblio table
my ($dbh,$xmlhash,$biblionumber,$frameworkcode) = @_;
	if (!$frameworkcode){
	$frameworkcode="";
	}
##Find itemtype
my $itemtype=XML_readline_onerecord($xmlhash,"itemtype","biblios");
##Find ISBN
my $isbn=XML_readline_onerecord($xmlhash,"isbn","biblios");
##Find ISSN
my $issn=XML_readline_onerecord($xmlhash,"issn","biblios");
##Find Title
my $title=XML_readline_onerecord($xmlhash,"title","biblios");
##Find Author
my $author=XML_readline_onerecord($xmlhash,"author","biblios");
my $xml=XML_hash2xml($xmlhash);

$isbn=~ s/(\.|\?|\;|\=|\-|\/|\\|\||\:|\*|\!|\,|\(|\)|\[|\]|\{|\}|\/)//g;
$issn=~ s/(\.|\?|\;|\=|\-|\/|\\|\||\:|\*|\!|\,|\(|\)|\[|\]|\{|\}|\/)//g;
$isbn=~s/^\s+|\s+$//g;
$isbn=substr($isbn,0,13);
        my $sth = $dbh->prepare("REPLACE  biblio set biblionumber=?,marcxml=?,frameworkcode=? ,itemtype=? , title=?,author=?,isbn=?,issn=?" );
        $sth->execute( $biblionumber ,$xml, $frameworkcode,$itemtype, $title,$author,$isbn,$issn);  
        $sth->finish;
    return $biblionumber;
}

sub OLDdelbiblio {
    my ( $dbh, $biblionumber ) = @_;
    my $sth = $dbh->prepare("select * from biblio where biblionumber=?");
    $sth->execute($biblionumber);
    if ( my $data = $sth->fetchrow_hashref ) {
        $sth->finish;
        my $query = "replace deletedbiblio set ";
        my @bind  = ();
           foreach my $temp ( keys %$data ) {
            $query .= "$temp = ?,";
            push ( @bind, $data->{$temp} );
           }

        #replacing the last , by ",?)"
        $query =~ s/\,$//;
        $sth = $dbh->prepare($query);
        $sth->execute(@bind);
        $sth->finish;
        $sth = $dbh->prepare("Delete from biblio where biblionumber=?");
        $sth->execute($biblionumber);
        $sth->finish;
    }
    $sth->finish;
}


#
#
#
#ZEBRA ZEBRA ZEBRA
#
#

sub ZEBRAdelbiblio {
## Zebra calls this routine to delete after it deletes biblio from ZEBRAddb
 my ( $dbh, $biblionumber ) = @_;
my $sth=$dbh->prepare("SELECT itemnumber FROM items where biblionumber=?");

$sth->execute($biblionumber);
	while (my $itemnumber =$sth->fetchrow){
	OLDdelitem($dbh,$itemnumber) ;
	}	
OLDdelbiblio($dbh,$biblionumber) ;
}

sub ZEBRAgetrecord{
my $biblionumber=shift;
my @kohafield="biblionumber";
my @value=$biblionumber;
my ($count,@result)=C4::Search::ZEBRAsearch_kohafields(\@kohafield,\@value);

   if ($count>0){
   my ( $xmlrecord, @itemsrecord) = XML_separate($result[0]);
   return ($xmlrecord, @itemsrecord);
   }else{
   return (undef,undef);
   }
}

sub ZEBRAop {
### Puts the zebra update in queue writes in zebraserver table
my ($dbh,$biblionumber,$op,$server)=@_;
my ($record);
my $sth=$dbh->prepare("insert into zebraqueue  (biblio_auth_number ,server,operation) values(?,?,?)");
$sth->execute($biblionumber,$server,$op);
}


sub ZEBRAopserver{

###Accepts a $server variable thus we can use it to update  biblios, authorities or other zebra dbs
my ($record,$op,$server,$biblionumber)=@_;
my @Zconnbiblio;
my @port;
my $Zpackage;
my $tried=0;
my $recon=0;
my $reconnect=0;
$record=Encode::encode("UTF-8",$record);
my $shadow=$server."shadow";
reconnect:

$Zconnbiblio[0]=C4::Context->Zconnauth($server);
if ($record){
my $Zpackage = $Zconnbiblio[0]->package();
$Zpackage->option(action => $op);
	$Zpackage->option(record => $record);
	$Zpackage->option(recordIdOpaque => $biblionumber);
retry:
		$Zpackage->send("update");
my $i;
my $event;

while (($i = ZOOM::event(\@Zconnbiblio)) != 0) {
    $event = $Zconnbiblio[0]->last_event();
    last if $event == ZOOM::Event::ZEND;
}
 my($error, $errmsg, $addinfo, $diagset) = $Zconnbiblio[0]->error_x();
	if ($error==10007 && $tried<3) {## timeout --another 30 looonng seconds for this update
		sleep 1;	##  wait a sec!
		$tried=$tried+1;
		goto "retry";
	}elsif ($error==2 && $tried<2) {## timeout --temporary zebra error !whatever that means
		sleep 2;	##  wait two seconds!
		$tried=$tried+1;
		goto "retry";
	}elsif($error==10004 && $recon==0){##Lost connection -reconnect
		sleep 1;	##  wait a sec!
		$recon=1;
		$Zpackage->destroy();
		$Zconnbiblio[0]->destroy();
		goto "reconnect";
	}elsif ($error){
	#	warn "Error-$server   $op  /errcode:, $error, /MSG:,$errmsg,$addinfo \n";	
		$Zpackage->destroy();
		$Zconnbiblio[0]->destroy();
	#	ZEBRAopfiles($dbh,$biblionumber,$record,$op,$server);
		return 0;
	}
	## System preference batchMode=1 means wea are bulk importing
	## DO NOT COMMIT while in batchMode for faster operation
	my $batchmode=C4::Context->preference('batchMode');
	 if (C4::Context->$shadow >0 && !$batchmode){
	 $Zpackage->send('commit');
		while (($i = ZOOM::event(\@Zconnbiblio)) != 0) {
		 $event = $Zconnbiblio[0]->last_event();
    		last if $event == ZOOM::Event::ZEND;
		}
	     my($error, $errmsg, $addinfo, $diagset) = $Zconnbiblio[0]->error_x();
	     if ($error) { ## This is serious ZEBRA server is not updating	
	     $Zpackage->destroy();
	     $Zconnbiblio[0]->destroy();
	     return 0;
	    }
	 }##commit
#
$Zpackage->destroy();
$Zconnbiblio[0]->destroy();
return 1;
}
return 0;
}

sub ZEBRA_readyXML{
my ($dbh,$biblionumber)=@_;
my $biblioxml=XMLgetbiblio($dbh,$biblionumber);
my @itemxml=XMLgetallitems($dbh,$biblionumber);
my $zebraxml=collection_header();
$zebraxml.="<koharecord>";
$zebraxml.=$biblioxml;
$zebraxml.="<holdings>";
      foreach my $item(@itemxml){
	$zebraxml.=$item if $item;
     }
$zebraxml.="</holdings>";
$zebraxml.="</koharecord>";
$zebraxml.="</kohacollection>";
return $zebraxml;
}

sub ZEBRA_readyXML_noheader{
my ($dbh,$biblionumber)=@_;
my $biblioxml=XMLgetbiblio($dbh,$biblionumber);
my @itemxml=XMLgetallitems($dbh,$biblionumber);
my $zebraxml="<koharecord>";
$zebraxml.=$biblioxml;
$zebraxml.="<holdings>";
      foreach my $item(@itemxml){
	$zebraxml.=$item if $item;
     }
$zebraxml.="</holdings>";
$zebraxml.="</koharecord>";
return $zebraxml;
}

#
#
# various utility subs and those not complying to new rules
#
#

sub newbiblio {
## Used in acqui management -- creates the biblio from koha hash 
    my ($biblio) = @_;
    my $dbh    = C4::Context->dbh;
my $record=XMLkoha2marc($dbh,$biblio,"biblios");
   my $biblionumber=NEWnewbiblio($dbh,$record);
    return ($biblionumber);
}
sub modbiblio {
## Used in acqui management -- modifies the biblio from koha hash rather than xml-hash
    my ($biblio) = @_;
    my $dbh    = C4::Context->dbh;
my $record=XMLkoha2marc($dbh,$biblio,"biblios");
   my $biblionumber=NEWmodbiblio($dbh,$record,$biblio->{biblionumber});
    return ($biblionumber);
}

sub newitems {
## Used in acqui management -- creates the item from hash rather than marc-record
    my ( $item, @barcodes ) = @_;
    my $dbh = C4::Context->dbh;
    my $errors;
    my $itemnumber;
    my $error;
    foreach my $barcode (@barcodes) {
	$item->{barcode}=$barcode;
my $record=MARCkoha2marc($dbh,$item,"holdings");	
  my $itemnumber=     NEWnewitem($dbh,$record,$item->{biblionumber});
    
    }
    return $itemnumber ;
}




sub getitemtypes {
    my $dbh   = C4::Context->dbh;
    my $query = "select * from itemtypes order by description";
    my $sth   = $dbh->prepare($query);

    # || die "Cannot prepare $query" . $dbh->errstr;      
    my $count = 0;
    my @results;
    $sth->execute;
    # || die "Cannot execute $query\n" . $sth->errstr;
    while ( my $data = $sth->fetchrow_hashref ) {
        $results[$count] = $data;
        $count++;
    }    # while

    $sth->finish;
    return ( $count, @results );
}    # sub getitemtypes



sub getkohafields{
#returns MySQL like fieldnames to emulate searches on sql like fieldnames
my $type=shift;
## Either opac or intranet to select appropriate fields
## Assumes intranet
$type="intra" unless $type;
if ($type eq "intranet"){ $type="intra";}
my $dbh   = C4::Context->dbh;
  my $i=0;
my @results;
$type=$type."show";
my $sth=$dbh->prepare("SELECT  * FROM koha_attr  where $type=1 order by label");
$sth->execute();
while (my $data=$sth->fetchrow_hashref){
	$results[$i]=$data;
	$i++;
	}
$sth->finish;
return ($i,@results);
}





sub DisplayISBN {
## Old style ISBN handling should be modified to accept 13 digits

	my ($isbn)=@_;
	my $seg1;
	if(substr($isbn, 0, 1) <=7) {
		$seg1 = substr($isbn, 0, 1);
	} elsif(substr($isbn, 0, 2) <= 94) {
		$seg1 = substr($isbn, 0, 2);
	} elsif(substr($isbn, 0, 3) <= 995) {
		$seg1 = substr($isbn, 0, 3);
	} elsif(substr($isbn, 0, 4) <= 9989) {
		$seg1 = substr($isbn, 0, 4);
	} else {
		$seg1 = substr($isbn, 0, 5);
	}
	my $x = substr($isbn, length($seg1));
	my $seg2;
	if(substr($x, 0, 2) <= 19) {
# 		if(sTmp2 < 10) sTmp2 = "0" sTmp2;
		$seg2 = substr($x, 0, 2);
	} elsif(substr($x, 0, 3) <= 699) {
		$seg2 = substr($x, 0, 3);
	} elsif(substr($x, 0, 4) <= 8399) {
		$seg2 = substr($x, 0, 4);
	} elsif(substr($x, 0, 5) <= 89999) {
		$seg2 = substr($x, 0, 5);
	} elsif(substr($x, 0, 6) <= 9499999) {
		$seg2 = substr($x, 0, 6);
	} else {
		$seg2 = substr($x, 0, 7);
	}
	my $seg3=substr($x,length($seg2));
	$seg3=substr($seg3,0,length($seg3)-1) ;
	my $seg4 = substr($x, -1, 1);
	return "$seg1-$seg2-$seg3-$seg4";
}
sub calculatelc{
## Function to create padded LC call number for sorting items with their LC code. Not exported
my  ($classification)=@_;
$classification=~s/^\s+|\s+$//g;
my $i=0;
my $lc2;
my $lc1;
for  ($i=0; $i<length($classification);$i++){
my $c=(substr($classification,$i,1));
	if ($c ge '0' && $c le '9'){
	
	$lc2=substr($classification,$i);
	last;
	}else{
	$lc1.=substr($classification,$i,1);
	
	}
}#while

my $other=length($lc1);
if(!$lc1){$other=0;}
my $extras;
if ($other<4){
	for (1..(4-$other)){
	$extras.="0";
	}
}
 $lc1.=$extras;
$lc2=~ s/^ //g;

$lc2=~ s/ //g;
$extras="";
##Find the decimal part of $lc2
my $pos=index($lc2,".");
if ($pos<0){$pos=length($lc2);}
if ($pos>=0 && $pos<5){
##Pad lc2 with zeros to create a 5digit decimal needed in marc record to sort as numeric

	for (1..(5-$pos)){
	$extras.="0";
	}
}
$lc2=$extras.$lc2;
return($lc1.$lc2);
}

sub itemcalculator{
## Sublimentary function to obtain sorted LC for items. Not exported
my ($dbh,$biblionumber,$callnumber)=@_;
my $xmlhash=XMLgetbibliohash($dbh,$biblionumber);
my $lc=XML_readline_onerecord($xmlhash,"classification","biblios");
my $cutter=XML_readline_onerecord($xmlhash,"subclass","biblios");
my $all=$lc." ".$cutter;
my $total=length($all);
my $cutterextra=substr($callnumber,$total);
return $cutterextra;

}


#### This function allows decoding of only title and author out of a MARC record
  sub func_title_author {
        my ($tagno,$tagdata) = @_;
  my ($titlef,$subf)=&MARCfind_marc_from_kohafield("title","biblios");
  my ($authf,$subf)=&MARCfind_marc_from_kohafield("author","biblios");
	return ($tagno == $titlef || $tagno == $authf);
    }



END { }    # module clean-up code here (global destructor)

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>



