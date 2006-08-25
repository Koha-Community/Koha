package C4::Biblio;
# New subs added by tgarip@neu.edu.tr 05/11/05
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
use MARC::Record;
use MARC::File::USMARC;
use MARC::File::XML;
use XML::Simple;
use Encode;

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

&MARCgetallitems 
&MARCfind_marc_from_kohafield
&MARCfind_frameworkcode
&MARCfind_itemtype
&MARCgettagslib
&MARCitemsgettagslib
&MARCmoditemonefield
&MARCkoha2marc
&MARCmarc2koha 
&MARCkoha2marcOnefield 
&MARCfind_attr_from_kohafield
&MARChtml2marc 
&MARChtml2xml 
&MARChtml2marcxml
&MARCgetbiblio 
&MARCgetitem 

&XMLgetbiblio 
&XMLgetitem 
&XMLgetallitems 
&XML_xml2hash 
&XML_hash2xml 
&XMLmarc2koha
&XML_readline
&XML_writeline

&ZEBRAgetrecord   
&ZEBRAgetallitems 
&ZEBRAop &ZEBRAopserver 
&ZEBRA_readyXML 
&ZEBRA_readyXML_noheader

&newbiblio
&modbiblio
&DisplayISBN

);

#################### XML XML  XML  XML ###################
### XML Read- Write functions


sub XML_readline{
my ($xml,$kohafield,$recordtype)=@_;
#$xml represents one record node hashed of holdings or a complete xml koharecord
### $recordtype is needed for reading the child records( like holdings records) .Otherwise main  record is assumed ( like biblio)
## holding records are parsed and sent here one by one
my ($tag,$subf)=MARCfind_marc_from_kohafield($kohafield,$recordtype);
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
			return Encode::decode("UTF-8",$code->{content});
			}
		   }
		}
  	   }
	}
      }else{
	foreach my $control (@$hcontrolfield){
		if ($control->{'tag'} eq $tag){
		return  Encode::decode("UTF-8",$control->{'content'});
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
			return Encode::decode("UTF-8",$code->{'content'});
			}
		   }
		}
  	   }
	}
  }else{
	
	foreach my $control (@$controlfields){
		if ($control->{'tag'} eq $tag){
		return	Encode::decode("UTF-8",$control->{'content'}) if $control->{'content'};
		}
	}
   }##tag
}## Holding or not
}## if tag is mapped
return "";
}

sub XML_writeline{
## This routine modifies one line of marcxml record mainly useful for updating circulation data
my ($xml,$kohafield,$newvalue,$recordtype)=@_;
my $biblio=$xml->{'record'}->[0]->{'datafield'};
my $controlfield=$xml->{'record'}->[0]->{'controlfield'};
my ($tag,$subf)=MARCfind_kohafield($kohafield,$recordtype);
my $updated=0;
    if ($tag>9){
	foreach my $data (@$biblio){
        		if ($data->{'tag'} eq $tag){
			my @subfields=$data->{'subfield'};
			foreach my $subfield ( @subfields){
	 		      foreach my $code ( @$subfield){
				if ($code->{'code'} eq $subf){	
				$code->{content}=$newvalue;
				$updated=1;
				}
	  		      }
			}
		     if (!$updated){	
			 push @subfields,{code=>$subf,content=>$newvalue};
			$data->{subfield}= \@subfields;
			
		     }	
		}
       	 }
		## Tag did not exist
		  if (!$updated){
	                push @$biblio,{datafield=>[{
                                                                               'ind1' => ' ',
                                                                               'ind2' => ' ',
                                                                               'subfield' => [
                                                                                               {
                                                                                                 'content' => $newvalue,
                                                                                                 'code' => $subf
                                                                                               }
                                                                                             ],
                                                                               'tag' => $tag
                                                                             }]
				};
		  }## created now
    }else{
	foreach my $control(@$controlfield){
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

sub XML_xml2hash{
##make a perl hash from xml file
my ($xml)=@_;
  my $hashed = XMLin( $xml ,KeyAttr =>['leader','controlfield','datafield'],ForceArray => ['leader','controlfield','datafield','subfield','holdings','record'],KeepRoot=>0);
return $hashed;
}

sub XML_hash2xml{
## turn a hash back to xml
my ($hashed,$root)=@_;
$root="record" unless $root;
my $xml= XMLout($hashed,KeyAttr=>['collection','record','leader','controlfıeld','datafield'],NoSort => 1,AttrIndent => 0,KeepRoot=>0,SuppressEmpty => 1,RootName=>$root);
return $xml;
}


sub XMLgetbiblio {
    # Returns MARC::XML of the biblionumber passed in parameter.
    my ( $dbh, $biblionumber ) = @_;
    my $sth =      $dbh->prepare("select marcxml from biblio where biblionumber=? "  );
    $sth->execute( $biblionumber);
   my ($marcxml)=$sth->fetchrow;
 return ($marcxml);
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
    return ($marcxml);
}

sub XMLgetallitems {
# warn "XMLgetallitems";
    # Returns an array of MARC:XML   of the items passed in parameter as biblionumber
    my ( $dbh, $biblionumber ) = @_;
my @results;
my   $sth = $dbh->prepare("select marcxml from items where biblionumber =?"  ); 
    $sth->execute($biblionumber);

 while(my ($marcxml)=$sth->fetchrow_array){
    push @results,$marcxml;
}
return @results;
}

sub XMLmarc2koha {
# warn "XMLmarc2koha";
##Returns two hashes from KOHA_XML record
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
	my $sth2=$dbh->prepare("SELECT  marctokoha from koha_attr where  recordtype like 'biblios' and tagfield is not null" );
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
	my $sth2=$dbh->prepare("SELECT  marctokoha from koha_attr where recordtype like 'holdings' and tagfield is not null" );
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

#
#
# MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC MARC
#
## Script to deal with MARC read write operations


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



sub MARCgetbiblio {
    # Returns MARC::Record of the biblio passed in parameter.
    ### Takes a new parameter of $title_author =1 which parses the record obly on those fields and nothing else
    ### Its useful when Koha requires only title&author for performance issues
    my ( $dbh, $biblionumber, $title_author ) = @_;
    my $sth =
      $dbh->prepare("select marc from biblio where biblionumber=? "  );
    $sth->execute( $biblionumber);
   my ($marc)=$sth->fetchrow;
my $record;
	if ($title_author){
	$record = MARC::File::USMARC::decode($marc,\&func_title_author);
	}else{
	 $record = MARC::File::USMARC::decode($marc);
	}
$sth->finish;
 return $record;
}





sub MARCgetitem {
# warn "MARCgetitem";
    # Returns MARC::Record   of the item passed in parameter uses either itemnumber or barcode
    my ( $dbh, $itemnumber,$barcode ) = @_;
my $sth;
if ($itemnumber){
   $sth = $dbh->prepare("select i.marc from items i where i.itemnumber=?"  ); 
    $sth->execute($itemnumber);
}else{
 $sth = $dbh->prepare("select i.marc from  items i where i.barcode=?"  ); 
    $sth->execute($barcode);
}
 my ($marc)=$sth->fetchrow;
 my $record = MARC::File::USMARC::decode($marc);
	
    return ($record);
}

sub MARCgetallitems {
# warn "MARCgetallitems";
    # Returns an array of MARC::Record   of the items passed in parameter as biblionumber
    my ( $dbh, $biblionumber ) = @_;
my @results;
my   $sth = $dbh->prepare("select marc from items where biblionumber =?"  ); 
    $sth->execute($biblionumber);

 while(my ($marc)=$sth->fetchrow_array){
 my $record = MARC::File::USMARC::decode($marc);
    push @results,$record;
}
return @results;
}

sub MARCmoditemonefield{
# This routine will be depraeciated as soon as mysql dependency on items is removed;
## this function is different to MARCkoha2marcOnefield this one does not need the record but the itemnumber
my ($dbh,$biblionumber,$itemnumber,$itemfield,$newvalue,$donotupdate)=@_;
my ($record) = MARCgetitem($dbh,$itemnumber);
   MARCkoha2marcOnefield( $record, $itemfield, $newvalue,"holdings" );
 if($donotupdate){
	## Prevent various update calls to zebra wait until all changes finish
	## Fix  to pass this record around to prevent Mysql update as well
		my $sth=$dbh->prepare("update items set marc=? where itemnumber=?");
		$sth->execute($record->as_usmarc,$itemnumber);
		$sth->finish;
	}else{
		NEWmoditem($dbh,$record,$biblionumber,$itemnumber);
}

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
	my ($tags,$subfields,$values,$indicator,$ind_tag) = @_;        
#	use MARC::File::XML;
	my $xml= marc_record_header('UTF-8'); #### we do not need a collection wrapper

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

		if ((@$tags[$i] ne $prevtag)){
			$j++ unless (@$tags[$i] eq "");
			## warn "IND:".substr(@$indicator[$j],0,1).substr(@$indicator[$j],1,1)." ".@$tags[$i];
			if (!$first){
		    	$xml.="</datafield>\n";
				if ((@$tags[$i] > 10) && (@$values[$i] ne "")){
						my $ind1 = substr(@$indicator[$j],0,1);
                        my $ind2 = substr(@$indicator[$j],1,1);
                        $xml.="<datafield tag=\"@$tags[$i]\" ind1=\"$ind1\" ind2=\"$ind2\">\n";
                        $xml.="<subfield code=\"@$subfields[$i]\">@$values[$i]</subfield>\n";
                        $first=0;
				} else {
		    	$first=1;
				}
            } else {
		    	if (@$values[$i] ne "") {
		    		# leader
		    		if (@$tags[$i] eq "000") {
						$xml.="<leader>@$values[$i]</leader>\n";
						$first=1;
					# rest of the fixed fields
		    		} elsif (@$tags[$i] < 10) {
						$xml.="<controlfield tag=\"@$tags[$i]\">@$values[$i]</controlfield>\n";
						$first=1;
		    		} else {
						my $ind1 = substr(@$indicator[$j],0,1);
						my $ind2 = substr(@$indicator[$j],1,1);
						$xml.="<datafield tag=\"@$tags[$i]\" ind1=\"$ind1\" ind2=\"$ind2\">\n";
						$xml.="<subfield code=\"@$subfields[$i]\">@$values[$i]</subfield>\n";
						$first=0;			
		    		}
		    	}
			}
		} else { # @$tags[$i] eq $prevtag
                if (@$values[$i] eq "") {
                }
                else {
					if ($first){
						my $ind1 = substr(@$indicator[$j],0,1);                        
						my $ind2 = substr(@$indicator[$j],1,1);
						$xml.="<datafield tag=\"@$tags[$i]\" ind1=\"$ind1\" ind2=\"$ind2\">\n";
						$first=0;
					}
		    	$xml.="<subfield code=\"@$subfields[$i]\">@$values[$i]</subfield>\n";
				}
		}
		$prevtag = @$tags[$i];
	}
	$xml.="</record>";
	# warn $xml;
	return $xml;
}
sub marc_record_header {
####  this one is for <record>
    my $format = shift;
    my $enc = shift || 'UTF-8';
    return( <<MARC_XML_HEADER );
<?xml version="1.0" encoding="$enc"?>
<record
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
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

sub MARChtml2marc {
# warn "MARChtml2marc";
	my ($dbh,$rtags,$rsubfields,$rvalues,%indicators) = @_;
	my $prevtag = -1;
	my $record = MARC::Record->new();
# 	my %subfieldlist=();
	my $prevvalue; # if tag <10
	my $field; # if tag >=10
	for (my $i=0; $i< @$rtags; $i++) {
		next unless @$rvalues[$i];
		# rebuild MARC::Record
# 			# warn "0=>".@$rtags[$i].@$rsubfields[$i]." = ".@$rvalues[$i].": ";
		if (@$rtags[$i] ne $prevtag) {
			if ($prevtag < 10) {
				if ($prevvalue) {

					if ($prevtag ne '000') {
						$record->insert_fields_ordered((sprintf "%03s",$prevtag),$prevvalue);
					} else {

						$record->leader($prevvalue);

					}
				}
			} else {
				if ($field) {
					$record->insert_fields_ordered($field);
				}
			}
			$indicators{@$rtags[$i]}.='  ';
			if (@$rtags[$i] <10) {
				$prevvalue= @$rvalues[$i];
				undef $field;
			} else {
				undef $prevvalue;
				$field = MARC::Field->new( (sprintf "%03s",@$rtags[$i]), substr($indicators{@$rtags[$i]},0,1),substr($indicators{@$rtags[$i]},1,1), @$rsubfields[$i] => @$rvalues[$i]);
# 			# warn "1=>".@$rtags[$i].@$rsubfields[$i]." = ".@$rvalues[$i].": ".$field->as_formatted;
			}
			$prevtag = @$rtags[$i];
		} else {
			if (@$rtags[$i] <10) {
				$prevvalue=@$rvalues[$i];
			} else {
				if (length(@$rvalues[$i])>0) {
					$field->add_subfields(@$rsubfields[$i] => @$rvalues[$i]);
# 			# warn "2=>".@$rtags[$i].@$rsubfields[$i]." = ".@$rvalues[$i].": ".$field->as_formatted;
				}
			}
			$prevtag= @$rtags[$i];
		}
	}
	# the last has not been included inside the loop... do it now !
	$record->insert_fields_ordered($field) if $field;
# 	# warn "HTML2MARC=".$record->as_formatted;
	$record->encoding( 'UTF-8' );
#	$record->MARC::File::USMARC::update_leader();
	return $record;
}

sub MARCkoha2marc {
# warn "MARCkoha2marc";
## This routine most probably will be depreaceated -- it is still used for acqui management
##Returns a  MARC record from a hash
	my ($dbh,$result,$recordtype) = @_;

	my $record = MARC::Record->new();
	my $sth2=$dbh->prepare("SELECT  marctokoha from koha_attr where tagfield is not null and recordtype=?");
	$sth2->execute($recordtype);
	my $field;
	while (($field)=$sth2->fetchrow) {
		$record=&MARCkoha2marcOnefield($record,$field,$result->{$field},$recordtype) if $result->{$field};
	}
return $record;
}
sub MARCmarc2koha {
# warn "MARCmarc2koha";
##Returns a hash from MARC record
	my ($dbh,$record,$related_record) = @_;
	my $result;
if (!$related_record){$related_record="biblios";}
	my $sth2=$dbh->prepare("SELECT  marctokoha from koha_attr where  recordtype like ? and tagfield is not null" );
	$sth2->execute($related_record);
	my $field;
	while ($field=$sth2->fetchrow) {
		$result=&MARCmarc2kohaOneField($field,$record,$result,$related_record);
	}

## we only need the following for biblio data
if ($related_record eq "biblios"){	
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
	return $result;
}

sub MARCkoha2marcOnefield {
##Updates or creates one field in MARC record
    my ( $record, $kohafieldname, $value,$recordtype ) = @_;
my ( $tagfield, $tagsubfield ) = MARCfind_marc_from_kohafield($kohafieldname,$recordtype);
if ($tagfield){
my $tag = $record->field($tagfield);
    if  (  $tagfield>9) { 
        if ($tag) {
	  	if ($value){## We may be trying to delete a subfield value
               	 $tag->update( $tagsubfield=> $value );
	  	}else{	
		$tag->delete_subfield(code=>$tagsubfield);
	  	}
                $record->delete_field($tag);
                $record->insert_fields_ordered($tag);         
        }else {
	my $newtag=MARC::Field->new( $tagfield, " ", " ", $tagsubfield => $value);
            $record->insert_fields_ordered($newtag);   
        }
    }else {
        if ($tag) {
	  if ($value){	
                $tag->update( $value );
                $record->delete_field($tag);
                $record->insert_fields_ordered($tag);    
	  }else{
	  $record->delete_field($tag);  
	  }
        }else {
	my $newtag=MARC::Field->new( $tagfield => $value);
            $record->insert_fields_ordered($newtag);   
        }
    }
}## $tagfield defined
    return $record;
}

sub MARCmarc2kohaOneField {
    my (  $kohafield, $record, $result,$recordtype ) = @_;
    #    # warn "kohatable / $kohafield / $result / ";
    my $res = "";

  my  ( $tagfield, $subfield ) = MARCfind_marc_from_kohafield($kohafield,$recordtype);
if ($tagfield){
    foreach my $field ( $record->field($tagfield) ) {
		if ($field->tag()<10) {
			if ($result->{$kohafield}) {
				$result->{$kohafield} .= " | ".$field->data();
			} else {
				$result->{$kohafield} = $field->data();
			}
		} else {
			if ( $field->subfields ) {
				my @subfields = $field->subfields();
				foreach my $subfieldcount ( 0 .. $#subfields ) {
					if ($subfields[$subfieldcount][0] eq $subfield) {
						if ( $result->{$kohafield} ) {
							$result->{$kohafield} .= " | " . $subfields[$subfieldcount][1];
						}
						else {
							$result->{$kohafield} = $subfields[$subfieldcount][1];
						}
					}
				}
			}
		}
    }
}
    return $result;
}

sub MARCmodLCindex{
# warn "MARCmodLCindex";
my ($dbh,$record)=@_;

my ($tagfield,$tagsubfield) = MARCfind_marc_from_kohafield("classification","biblios");
my ($tagfield2,$tagsubfieldsub) = MARCfind_marc_from_kohafield("subclass","biblios");
my $tag=$record->field($tagfield);
if ($tag){
my ($lcsort)=calculatelc($tag->subfield($tagsubfield)).$tag->subfield($tagsubfieldsub);

 &MARCkoha2marcOnefield( $record, "lcsort", $lcsort,"biblios");
}
return $record;
}

##########################NEW NEW NEW#############################
sub NEWnewbiblio {
    my ( $dbh, $record, $frameworkcode) = @_;
    my $biblionumber;
$frameworkcode="" unless $frameworkcode;
    my $olddata = MARCmarc2koha( $dbh, $record,"biblios" );
## In case reimporting records with biblionumbers keep them
if ($olddata->{'biblionumber'}){
$biblionumber=NEWmodbiblio( $dbh, $olddata->{'biblionumber'},$record,$frameworkcode );
}else{
    $biblionumber = NEWaddbiblio( $dbh, $record,$frameworkcode );
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
my $sth=$dbh->prepare("SELECT itemnumber FROM items where biblionumber=?");

$sth->execute($biblionumber);
	while (my $itemnumber =$sth->fetchrow){
	OLDdelitem($dbh,$itemnumber) ;
	}

	ZEBRAop($dbh,$biblionumber,"recordDelete","biblioserver");
OLDdelbiblio($dbh,$biblionumber) ;

}

sub NEWnewitem {
    my ( $dbh, $record, $biblionumber ) = @_;
	my $itemtype= MARCfind_itemtype($dbh,$biblionumber);
    my $item = &MARCmarc2koha( $dbh, $record,"holdings" );
## In case we are re-importing marc records from bulk import do not change itemnumbers
if ($item->{itemnumber}){
NEWmoditem ( $dbh, $record, $biblionumber, $item->{itemnumber});
}else{
    $item->{'biblionumber'} =$biblionumber;
##Add biblionumber to $record
    MARCkoha2marcOnefield($record,"biblionumber",$biblionumber,"holdings");
 my $sth=$dbh->prepare("select notforloan from itemtypes where itemtype='$itemtype'");
$sth->execute();
my $notforloan=$sth->fetchrow;
##Change the notforloan field if $notforloan found
	if ($notforloan >0){
	$item->{'notforloan'}=$notforloan;
	&MARCkoha2marcOnefield($record,"notforloan",$notforloan,"holdings");
	}
if(!$item->{'dateaccessioned'}||$item->{'dateaccessioned'} eq ''){
# find today's date
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =                                                           
localtime(time); $year +=1900; $mon +=1;
my $date = "$year-".sprintf ("%0.2d", $mon)."-".sprintf("%0.2d",$mday);
$item->{'dateaccessioned'}=$date;
&MARCkoha2marcOnefield($record,"dateaccessioned",$date,"holdings");
}
  
## Now calculate itempart of cutter
my ($cutterextra)=itemcalculator($dbh,$item->{'biblionumber'},$item->{'itemcallnumber'});
&MARCkoha2marcOnefield($record,"cutterextra",$cutterextra,"holdings");

##NEU specific add cataloguers cardnumber as well
my ($tag,$cardtag)=MARCfind_marc_from_kohafield("circid","holdings");
	if ($tag && $cardtag){	
	my $me= C4::Context->userenv;
	my $cataloguer=$me->{'cardnumber'} if ($me);
	my $newtag= $record->field($tag);
	$newtag->update($cardtag=>$cataloguer) if ($me);
	$record->delete_field($newtag);
	$record->insert_fields_ordered($newtag);	
	}
##Add item to SQL
my  $itemnumber = &OLDnewitems( $dbh, $item->{barcode},$record );

# add the item to zebra it will add the biblio as well!!!
    ZEBRAop( $dbh, $biblionumber,"specialUpdate","biblioserver" );
return $itemnumber;
}## added new item

}



sub NEWmoditem{
    my ( $dbh, $record, $biblionumber, $itemnumber ) = @_;
##Get a hash of this record as well
my $item=MARCmarc2koha($dbh,$record,"holdings");
##Add itemnumber incase lost (old bug 090c was lost) --just incase
my  (  $tagfield,  $tagsubfield )  =MARCfind_marc_from_kohafield("itemnumber","holdings");
	my $newfield;
my $old_field = $record->field($tagfield);
if ($tagfield<10){
	 $newfield = MARC::Field->new($tagfield,  $itemnumber);
}else{
	if ($old_field){
	$old_field->update($tagsubfield=>$biblionumber);
	$newfield=$old_field->clone();
	}else{	
	 $newfield = MARC::Field->new($tagfield, '', '', "$tagsubfield" => $itemnumber);
	}
}	
		# drop old field and create new one...
		
		$record->delete_field($old_field);
		$record->insert_fields_ordered($newfield);
##Add biblionumber incase lost on html
my  (  $tagfield,  $tagsubfield )  =MARCfind_marc_from_kohafield("biblionumber","holdings");
	my $newfield;
my $old_field = $record->field($tagfield);
if ($tagfield<10){
	 $newfield = MARC::Field->new($tagfield,  $biblionumber);
}else{
	if ($old_field){
	$old_field->update($tagsubfield=>$biblionumber);
	$newfield=$old_field->clone();
	}else{	
	 $newfield = MARC::Field->new($tagfield, '', '', "$tagsubfield" => $biblionumber);
	}
}	
		# drop old field and create new one...
		$record->delete_field($old_field);
		$record->insert_fields_ordered($newfield);
		
###NEU specific add cataloguers cardnumber as well
my ($tag,$cardtag)=MARCfind_marc_from_kohafield("circid","holdings");
if ($tag && $cardtag){	
my $me= C4::Context->userenv;
my $cataloger=$me->{'cardnumber'} if ($me);
my $oldtag=$record->field($tag);
	if (!$oldtag){
	my $newtag=  MARC::Field->new($tag, '', '', $cardtag => $cataloger) if ($me);
	$record->insert_fields_ordered($newtag);	
	}else{
	$oldtag->update($cardtag=>$cataloger) if ($me);
	$record->delete_field($oldtag);
	$record->insert_fields_ordered($oldtag);
	}
}
## We must add the indexing fields for LC Cutter in MARC record in case it changed
my ($cutterextra)=itemcalculator($dbh,$biblionumber,$item->{'itemcallnumber'});
MARCkoha2marcOnefield($record,"cutterextra",$cutterextra,"holdings");
    OLDmoditem( $dbh, $record,$biblionumber,$itemnumber,$item->{barcode} );
    ZEBRAop($dbh,$biblionumber,"specialUpdate","biblioserver");
}

sub NEWdelitem {
    my ( $dbh, $itemnumber ) = @_;
	
my $sth=$dbh->prepare("SELECT biblionumber from items where itemnumber=?");
$sth->execute($itemnumber);
my $biblionumber=$sth->fetchrow;
OLDdelitem( $dbh, $itemnumber ) ;
ZEBRAop($dbh,$biblionumber,"recordDelete","biblioserver");

}




sub NEWaddbiblio {
    my ( $dbh, $record,$frameworkcode ) = @_;
     my $sth = $dbh->prepare("Select max(biblionumber) from biblio");
    $sth->execute;
    my $data   = $sth->fetchrow;
    my $biblionumber = $data + 1;
    $sth->finish;
    # we must add biblionumber MARC::Record...
  my  (  $tagfield,  $tagsubfield ) =MARCfind_marc_from_kohafield("biblionumber","biblios");
	my $newfield;
if ($tagfield<10){
	 $newfield = MARC::Field->new($tagfield,  $biblionumber);
}else{
 $newfield = MARC::Field->new($tagfield, '', '', "$tagsubfield" => "$biblionumber");
}
		# drop old field and create new one..
		$record->delete_field($newfield);
		$record->insert_fields_ordered($newfield);

###NEU specific add cataloguers cardnumber as well
my ($tag,$cardtag)=MARCfind_marc_from_kohafield("indexedby","biblios");
if ($tag && $cardtag){	
my $me= C4::Context->userenv;
my $cataloger=$me->{'cardnumber'} if ($me);
my $oldtag=$record->field($tag);
	if (!$oldtag){
	my $newtag=  MARC::Field->new($tag, '', '', $cardtag => $cataloger) if ($me);
	$record->insert_fields_ordered($newtag);	
	}else{
	$oldtag->update($cardtag=>$cataloger) if ($me);
	$record->delete_field($oldtag);
	$record->insert_fields_ordered($oldtag);
	}
}
## We must add the indexing fields for LC in MARC record--TG
	&MARCmodLCindex($dbh,$record);

##Find itemtype
 ($tagfield,$tagsubfield)=MARCfind_marc_from_kohafield("itemtype","biblios");
my $itemtype=$record->field($tagfield)->subfield($tagsubfield) if ($record->field($tagfield));
##Find ISBN
($tagfield,$tagsubfield)=MARCfind_marc_from_kohafield("isbn","biblios") ;
my $isbn=$record->field($tagfield)->subfield($tagsubfield) if ($record->field($tagfield));
##Find ISSN
($tagfield,$tagsubfield)=MARCfind_marc_from_kohafield("issn","biblios") ;
my $issn=$record->field($tagfield)->subfield($tagsubfield) if ($record->field($tagfield));
    $sth = $dbh->prepare("insert into biblio set biblionumber  = ?, marc = ?, frameworkcode=?, itemtype=?,marcxml=?,title=?,author=?,isbn=?,issn=?" );
    $sth->execute( $biblionumber,  $record->as_usmarc,$frameworkcode, $itemtype,MARC::File::XML::record( $record ) ,$record->title(),$record->author,$isbn,$issn  );

    $sth->finish;
### Do not add biblio to ZEBRA unless there is an item with it -- depends on system preference defaults to NO
if (C4::Context->preference('AddaloneBiblios')){
 ZEBRAop($dbh,$biblionumber,"specialUpdate","biblioserver");
}
    return ($biblionumber);
}

sub NEWmodbiblio {
    my ( $dbh, $biblionumber,$record,$frameworkcode ) = @_;
##Add biblionumber incase lost on html
my  (  $tagfield,  $tagsubfield )  =MARCfind_marc_from_kohafield("biblionumber","biblios");
	my $newfield;
if ($tagfield<10){
	 $newfield = MARC::Field->new($tagfield,  $biblionumber);
}else{
 $newfield = MARC::Field->new($tagfield, '', '', "$tagsubfield" => $biblionumber);
}	
		# drop old field and create new one...
		my $old_field = $record->field($tagfield);
		$record->delete_field($old_field);
		$record->insert_fields_ordered($newfield);

###NEU specific add cataloguers cardnumber as well
my ($tag,$cardtag)=MARCfind_marc_from_kohafield("indexedby","biblios");
if ($tag && $cardtag){	
my $me= C4::Context->userenv;
my $cataloger=$me->{'cardnumber'} if ($me);
my $oldtag=$record->field($tag);
	if (!$oldtag){
	my $newtag=  MARC::Field->new($tag, '', '', $cardtag => $cataloger) if ($me);
	$record->insert_fields_ordered($newtag);	
	}else{
	$oldtag->update($cardtag=>$cataloger) if ($me);
	$record->delete_field($oldtag);
	$record->insert_fields_ordered($oldtag);
	}
}
## We must add the indexing fields for LC in MARC record--TG
   MARCmodLCindex($dbh,$record);
    OLDmodbiblio ($dbh,$record,$biblionumber,$frameworkcode);
    my $ok=ZEBRAop($dbh,$biblionumber,"specialUpdate","biblioserver");
    return ($biblionumber);
}

#
#
# OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD OLD
#
#

sub OLDnewitems {

    my ( $dbh, $barcode,$record) = @_;
    my $sth = $dbh->prepare("SELECT max(itemnumber) from items");
    my $data;
    my $itemnumber;
    $sth->execute;
    $data       = $sth->fetchrow_hashref;
    $itemnumber = $data->{'max(itemnumber)'} + 1;
    $sth->finish;
      &MARCkoha2marcOnefield(  $record, "itemnumber", $itemnumber,"holdings" );
    my ($biblionumbertag,$subf)=MARCfind_marc_from_kohafield( "biblionumber","holdings");

my $biblionumber;
  if ($biblionumbertag <10){
  $biblionumber=$record->field($biblionumbertag)->data();
  }else{
   $biblionumber=$record->field($biblionumbertag)->subfield($subf);
  }
        $sth = $dbh->prepare( "Insert into items set itemnumber = ?,	biblionumber  = ?,barcode = ?,marc=?	,marcxml=?"   );
        $sth->execute($itemnumber,$biblionumber,$barcode,$record->as_usmarc(),MARC::File::XML::record( $record));
    return $itemnumber;
}

sub OLDmoditem {
    my ( $dbh, $record,$biblionumber,$itemnumber,$barcode  ) = @_;
    my $sth =$dbh->prepare("replace items set  biblionumber=?,marc=?,marcxml=?,barcode=? , itemnumber=?");
    $sth->execute($biblionumber,$record->as_usmarc(),MARC::File::XML::record( $record),$barcode,$itemnumber);
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
my ($dbh,$record,$biblionumber,$frameworkcode) = @_;
	if (!$frameworkcode){
	$frameworkcode="";
	}
my ($tagfield,$tagsubfield)=MARCfind_marc_from_kohafield("itemtype","biblios");
my $itemtype=$record->field($tagfield)->subfield($tagsubfield) if ($record->field($tagfield));
my ($tagfield,$tagsubfield)=MARCfind_marc_from_kohafield("isbn","biblios");
my $isbn=$record->field($tagfield)->subfield($tagsubfield) if ($record->field($tagfield));
my ($tagfield,$tagsubfield)=MARCfind_marc_from_kohafield("issn","biblios");
my $issn=$record->field($tagfield)->subfield($tagsubfield) if ($record->field($tagfield));
$isbn=~ s/(\.|\?|\;|\=|\-|\/|\\|\||\:|\*|\!|\,|\(|\)|\[|\]|\{|\}|\/)//g;
$issn=~ s/(\.|\?|\;|\=|\-|\/|\\|\||\:|\*|\!|\,|\(|\)|\[|\]|\{|\}|\/)//g;
$isbn=~s/^\s+|\s+$//g;
$isbn=substr($isbn,0,13);
        my $sth = $dbh->prepare("REPLACE  biblio set biblionumber=?,marc=?,marcxml=?,frameworkcode=? ,itemtype=? , title=?,author=?,isbn=?,issn=?" );
        $sth->execute( $biblionumber,$record->as_usmarc() ,MARC::File::XML::record( $record), $frameworkcode,$itemtype, $record->title(),$record->author(),$isbn,$issn);  
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

sub ZEBRAopfiles{
##Utility function to write an xml file to disk when the zebra server goes down
my ($dbh,$biblionumber,$record,$folder,$server)=@_;
#my $record = XMLgetbiblio($dbh,$biblionumber);
my $op;
my $zebradir = C4::Context->zebraconfig($server)->{directory}."/".$folder."/";
my $zebraroot=C4::Context->zebraconfig($server)->{directory};
my $serverbase=C4::Context->config($server);
	unless (opendir(DIR, "$zebradir")) {
# warn "$zebradir not found";
			return;
	} 
	closedir DIR;
	my $filename = $zebradir.$biblionumber;
if ($record){
	open (OUTPUT,">", $filename.".xml");
	print OUTPUT $record;
	close OUTPUT;
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
my ($record,$op,$server)=@_;
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
## Used in acqui management -- creates the biblio from hash rather than marc-record
    my ($biblio) = @_;
    my $dbh    = C4::Context->dbh;
my $record=MARCkoha2marc($dbh,$biblio,"biblios");
$record->encoding('UTF-8');
   my $biblionumber=NEWnewbiblio($dbh,$record);
    return ($biblionumber);
}
sub modbiblio {
## Used in acqui management -- modifies the biblio from hash rather than marc-record
    my ($biblio) = @_;
    my $dbh    = C4::Context->dbh;
my $record=MARCkoha2marc($dbh,$biblio,"biblios");
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
my $type=@_;
## Either opac or intranet to select appropriate fields
## Assumes intranet
$type="intra" unless $type;
if ($type eq "intranet"){ $type="intra";}
my $dbh   = C4::Context->dbh;
  my $i=0;
my @results;
$type=$type."show";
my $sth=$dbh->prepare("SELECT  * FROM koha_attr  where $type=1 order by liblibrarian");
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
my ($record,$frameworkcode)=MARCgetbiblio($dbh,$biblionumber);
my $biblio=MARCmarc2koha($dbh,$record,$frameworkcode,"biblios");

my $all=$biblio->{classification}." ".$biblio->{subclass};
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



