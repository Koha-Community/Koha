package C4::Record;
#
# Copyright 2006 (C) LibLime
# Joshua Ferraro <jmf@liblime.com>
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
#
# $Id$
#
use strict; use warnings; #FIXME: turn off warnings before release

# please specify in which methods a given module is used
use MARC::Record; #marc2marcxml, marcxml2marc, html2marc, changeEncoding
use MARC::File::XML; #marc2marcxml, marcxml2marc, html2marcxml, changeEncoding

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = do { my @v = '$Revision$' =~ /\d+/g;
                shift(@v) . "." . join("_", map {sprintf "%03d", $_ } @v); };

@ISA = qw(Exporter);

# only export API methods

@EXPORT = qw(
  &marc2marcxml
  &marcxml2marc
  &html2marcxml
  &html2marc
  &changeEncoding
);

=head1 NAME

C4::Record - MARC, MARCXML, XML, etc. Record Management Functions and API

=head1 SYNOPSIS

New in Koha 3.x. This module handles all record-related management functions.

=head1 API

=head2 marc2marcxml

my $marcxml = marc2marcxml($marc,$encoding,$flavour);

returns a MARCXML scalar variable

C<$marc> a MARC::Record object or binary MARC record

C<$encoding> UTF-8 or MARC-8 [UTF-8]

C<$flavour> MARC21 or UNIMARC

=cut

sub marc2marcxml {
	my ($marc,$encoding,$flavour) = @_;
	unless($encoding) {$encoding = "UTF-8"};
	unless($flavour) {$flavour = C4::Context->preference("TemplateEncoding")};
	#FIXME: add error handling
	my $marcxml = $record->as_xml_record($marc,$encoding,$flavour);
	return $marcxml;
}

=head2 marcxml2marc 

my $marc = marcxml2marc($marcxml,$encoding,$flavour);

returns a binary MARC scalar variable

C<$marcxml> a MARCXML record

C<$encoding> UTF-8 or MARC-8 [UTF-8]

C<$flavour> MARC21 or UNIMARC

=cut

sub marcxml2marc {
    my ($marcxml,$encoding,$flavour) = @_;
	unless($encoding) {$encoding = "UTF-8"};
	unless($flavour) {$flavour = C4::Context->preference("TemplateEncoding")};
	#FIXME: add error handling
	my $marc = $marcxml->new_from_xml($marcxml,$encoding,$flavour);
	return $marc;
}

=head2 html2marcxml

my $marcxml = html2marcxml($tags,$subfields,$values,$indicator,$ind_tag);

returns a MARCXML scalar variable

this is used in addbiblio.pl and additem.pl to build the MARCXML record from 
the form submission.

FIXME: this could use some better code documentation

=cut

sub html2marcxml {
    my ($tags,$subfields,$values,$indicator,$ind_tag) = @_;
	# add the header info
    my $marcxml= MARC::File::XML::header(C4::Context->preference('TemplateEncoding'),C4::Context->preference('marcflavour'));

	# some flags used to figure out where in the record we are
    my $prevvalue;
    my $prevtag=-1;
    my $first=1;
    my $j = -1;

	# handle characters that would cause the parser to choke FIXME: is there a more elegant solution?
    for (my $i=0;$i<=@$tags;$i++){
		@$values[$i] =~ s/&/&amp;/g;
		@$values[$i] =~ s/</&lt;/g;
		@$values[$i] =~ s/>/&gt;/g;
		@$values[$i] =~ s/"/&quot;/g;
		@$values[$i] =~ s/'/&apos;/g;
        
		if ((@$tags[$i] ne $prevtag)){
			$j++ unless (@$tags[$i] eq "");
			#warn "IND:".substr(@$indicator[$j],0,1).substr(@$indicator[$j],1,1)." ".@$tags[$i];
			if (!$first){
				$marcxml.="</datafield>\n";
				if ((@$tags[$i] > 10) && (@$values[$i] ne "")){
                	my $ind1 = substr(@$indicator[$j],0,1);
					my $ind2 = substr(@$indicator[$j],1,1);
					$marcxml.="<datafield tag=\"@$tags[$i]\" ind1=\"$ind1\" ind2=\"$ind2\">\n";
					$marcxml.="<subfield code=\"@$subfields[$i]\">@$values[$i]</subfield>\n";
					$first=0;
				} else {
					$first=1;
				}
			} else {
				if (@$values[$i] ne "") {
					# handle the leader
					if (@$tags[$i] eq "000") {
						$marcxml.="<leader>@$values[$i]</leader>\n";
						$first=1;
					# rest of the fixed fields
					} elsif (@$tags[$i] < 010) { #FIXME: <10 was the way it was, there might even be a better way
						$marcxml.="<controlfield tag=\"@$tags[$i]\">@$values[$i]</controlfield>\n";
						$first=1;
					} else {
						my $ind1 = substr(@$indicator[$j],0,1);
						my $ind2 = substr(@$indicator[$j],1,1);
						$marcxml.="<datafield tag=\"@$tags[$i]\" ind1=\"$ind1\" ind2=\"$ind2\">\n";
						$marcxml.="<subfield code=\"@$subfields[$i]\">@$values[$i]</subfield>\n";
						$first=0;
					}
				}
			}
		} else { # @$tags[$i] eq $prevtag
			if (@$values[$i] eq "") {
			} else {
				if ($first){
					my $ind1 = substr(@$indicator[$j],0,1);
					my $ind2 = substr(@$indicator[$j],1,1);
					$marcxml.="<datafield tag=\"@$tags[$i]\" ind1=\"$ind1\" ind2=\"$ind2\">\n";
					$first=0;
				}
				$marcxml.="<subfield code=\"@$subfields[$i]\">@$values[$i]</subfield>\n";
			}
		}
		$prevtag = @$tags[$i];
	}
	$marcxml.= MARC::File::XML::footer();
	#warn $marcxml;
	return $marcxml;
}

=head2 html2marc

Probably best to avoid using this ... it has some rather striking problems:

* saves blank subfields
* subfield order is hardcoded to always start  
 with 'a' for repeatable tags (because it is hardcoded in the   
 addfield routine).
* only possible to specify one set of indicators for each set of 
 tags (ie, one for all the 650s). (because they were stored in a 
 hash with the tag as the key).
* the underlying routines didn't support subfield
 reordering or subfield repeatability.

I've left it in here because it could be useful if someone took the time to 
fix it.

=cut

sub html2marc {
    my ($dbh,$rtags,$rsubfields,$rvalues,%indicators) = @_;
    my $prevtag = -1;
    my $record = MARC::Record->new();
#   my %subfieldlist=();
    my $prevvalue; # if tag <10
    my $field; # if tag >=10
    for (my $i=0; $i< @$rtags; $i++) {
        # rebuild MARC::Record
#           warn "0=>".@$rtags[$i].@$rsubfields[$i]." = ".@$rvalues[$i].": ";
        if (@$rtags[$i] ne $prevtag) {
            if ($prevtag < 10) {
                if ($prevvalue) {
                    if (($prevtag ne '000') && ($prevvalue ne "")) {
                        $record->add_fields((sprintf "%03s",$prevtag),$prevvalue);
                    } elsif ($prevvalue ne ""){
                        $record->leader($prevvalue);
                    }
                }
            } else {
                if (($field) && ($field ne "")) {
                    $record->add_fields($field);
                }
            }
            $indicators{@$rtags[$i]}.='  ';
                # skip blank tags, I hope this works
                if (@$rtags[$i] eq ''){
                $prevtag = @$rtags[$i];
                undef $field;
                next;
            }
            if (@$rtags[$i] <10) {
                $prevvalue= @$rvalues[$i];
                undef $field;
            } else {
                undef $prevvalue;
                if (@$rvalues[$i] eq "") {
                undef $field;
                } else {
                $field = MARC::Field->new( (sprintf "%03s",@$rtags[$i]), substr($indicators{@$rtags[$i]},0,1),substr($indicators{@$rtags[$i]},1,1), @$rsubfields[$i] => @$rvalues[$i]);
                }
#           warn "1=>".@$rtags[$i].@$rsubfields[$i]." = ".@$rvalues[$i].": ".$field->as_formatted;
            }
            $prevtag = @$rtags[$i];
        } else {
            if (@$rtags[$i] <10) {
                $prevvalue=@$rvalues[$i];
            } else {
                if (length(@$rvalues[$i])>0) {
                    $field->add_subfields(@$rsubfields[$i] => @$rvalues[$i]);
#           warn "2=>".@$rtags[$i].@$rsubfields[$i]." = ".@$rvalues[$i].": ".$field->as_formatted;
                }
            }
            $prevtag= @$rtags[$i];
        }
    }
    #}
    # the last has not been included inside the loop... do it now !
    #use Data::Dumper;
    #warn Dumper($field->{_subfields});
    $record->add_fields($field) if (($field) && $field ne "");
    #warn "HTML2MARC=".$record->as_formatted;
    return $record;
}

=head2 changeEncoding

$newrecord = changeEncoding($record,$format,$flavour,$toencoding,$fromencoding);

changes the encoding of a record

<C$record the record itself can be in ISO2709, a MARC::Record object, or MARCXML for now (required)

<C$format MARC or MARCXML (required for now, eventually it will attempt to guess)

<C$flavour MARC21 or UNIMARC, if MARC21, it will change the leader (optional) [defaults to system preference]

<C$toencoding the encoding you want the record to end up in (optional) [UTF-8]

<C$fromencoding the encoding the record is currently in (optional, it will probably be able to tell unless there's a problem with the record)

FIXME: the fromencoding doesn't work yet
FIXME: better handling for UNIMARC, it should allow management of 100 field
FIXME: shouldn't have to convert to and from xml/marc just to change encoding,
	someone needs to re-write MARC::Record's 'encoding' method to actually
	alter the encoding rather than just changing the leader

=cut

sub changeEncoding {
	my ($record,$format,$flavour,$toencoding,$fromencoding) = @_;
	my $newrecord;
	unless($flavour) {$flavour = C4::Context->preference("marcflavour")};
	unless($toencoding) {$toencoding = "UTF-8"};
	if (lc($format) =~ /^MARC$/o) { # ISO2790 Record
		my $marcxml = marc2marcxml($record,$encoding,$flavour);
		$newrecord = marcxml2marc($marcxml,$encoding,$flavour);
	} elsif (lc($format) =~ /^MARCXML$/o) { # MARCXML Record
		my $marc = marcxml2marc($record,$encoding,$flavour);
		$newrecord = marc2marcxml($record,$encoding,$flavour);
	} else {
	#FIXME: handle other record formats, and finally, handle errors
	}
	return $newrecord;
}

END { }       # module clean-up code here (global destructor)
1;
__END__

=back

=head1 AUTHOR

Joshua Ferraro <jmf@liblime.com>

=head MODIFICATIONS

# $Id$

=cut
