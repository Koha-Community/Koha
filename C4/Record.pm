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
#
use strict;# use warnings; #FIXME: turn off warnings before release

# please specify in which methods a given module is used
use MARC::Record; # marc2marcxml, marcxml2marc, html2marc, changeEncoding
use MARC::File::XML; # marc2marcxml, marcxml2marc, html2marcxml, changeEncoding
use MARC::Crosswalk::DublinCore; # marc2dcxml
use Biblio::EndnoteStyle;
use Unicode::Normalize; # _entity_encode
use XML::LibXSLT;
use XML::LibXML;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 3.00;

@ISA = qw(Exporter);

# only export API methods

@EXPORT = qw(
  &marc2endnote
  &marc2marc
  &marc2marcxml
  &marcxml2marc
  &marc2dcxml
  &marc2modsxml

  &html2marcxml
  &html2marc
  &changeEncoding
);

=head1 NAME

C4::Record - MARC, MARCXML, DC, MODS, XML, etc. Record Management Functions and API

=head1 SYNOPSIS

New in Koha 3.x. This module handles all record-related management functions.

=head1 API (EXPORTED FUNCTIONS)

=head2 marc2marc - Convert from one flavour of ISO-2709 to another

=over 4

my ($error,$newmarc) = marc2marc($marc,$to_flavour,$from_flavour,$encoding);

Returns an ISO-2709 scalar

=back

=cut

sub marc2marc {
	my ($marc,$to_flavour,$from_flavour,$encoding) = @_;
	my $error = "Feature not yet implemented\n";
	return ($error,$marc);
}

=head2 marc2marcxml - Convert from ISO-2709 to MARCXML

=over 4

my ($error,$marcxml) = marc2marcxml($marc,$encoding,$flavour);

Returns a MARCXML scalar

=over 2

C<$marc> - an ISO-2709 scalar or MARC::Record object

C<$encoding> - UTF-8 or MARC-8 [UTF-8]

C<$flavour> - MARC21 or UNIMARC

C<$dont_entity_encode> - a flag that instructs marc2marcxml not to entity encode the xml before returning (optional)

=back

=back

=cut

sub marc2marcxml {
	my ($marc,$encoding,$flavour,$dont_entity_encode) = @_;
	my $error; # the error string
	my $marcxml; # the final MARCXML scalar

	# test if it's already a MARC::Record object, if not, make it one
	my $marc_record_obj;
	if ($marc =~ /^MARC::Record/) { # it's already a MARC::Record object
		$marc_record_obj = $marc;
	} else { # it's not a MARC::Record object, make it one
		eval { $marc_record_obj = MARC::Record->new_from_usmarc($marc) }; # handle exceptions

		# conversion to MARC::Record object failed, populate $error
		if ($@) { $error .="\nCreation of MARC::Record object failed: ".$MARC::File::ERROR };
	}
	# only proceed if no errors so far
	unless ($error) {

		# check the record for warnings
		my @warnings = $marc_record_obj->warnings();
		if (@warnings) {
			warn "\nWarnings encountered while processing ISO-2709 record with title \"".$marc_record_obj->title()."\":\n";
			foreach my $warn (@warnings) { warn "\t".$warn };
		}
		unless($encoding) {$encoding = "UTF-8"}; # set default encoding
		unless($flavour) {$flavour = C4::Context->preference("marcflavour")}; # set default MARC flavour

		# attempt to convert the record to MARCXML
		eval { $marcxml = $marc_record_obj->as_xml_record($flavour) }; #handle exceptions

		# record creation failed, populate $error
		if ($@) {
			$error .= "Creation of MARCXML failed:".$MARC::File::ERROR;
			$error .= "Additional information:\n";
			my @warnings = $@->warnings();
			foreach my $warn (@warnings) { $error.=$warn."\n" };

		# record creation was successful
    	} else {

			# check the record for warning flags again (warnings() will be cleared already if there was an error, see above block
			@warnings = $marc_record_obj->warnings();
			if (@warnings) {
				warn "\nWarnings encountered while processing ISO-2709 record with title \"".$marc_record_obj->title()."\":\n";
				foreach my $warn (@warnings) { warn "\t".$warn };
			}
		}

		# only proceed if no errors so far
		unless ($error) {

			# entity encode the XML unless instructed not to
    		unless ($dont_entity_encode) {
        		my ($marcxml_entity_encoded) = _entity_encode($marcxml);
        		$marcxml = $marcxml_entity_encoded;
    		}
		}
	}
	# return result to calling program
	return ($error,$marcxml);
}

=head2 marcxml2marc - Convert from MARCXML to ISO-2709

=over 4

my ($error,$marc) = marcxml2marc($marcxml,$encoding,$flavour);

Returns an ISO-2709 scalar

=over 2

C<$marcxml> - a MARCXML record

C<$encoding> - UTF-8 or MARC-8 [UTF-8]

C<$flavour> - MARC21 or UNIMARC

=back

=back

=cut

sub marcxml2marc {
    my ($marcxml,$encoding,$flavour) = @_;
	my $error; # the error string
	my $marc; # the final ISO-2709 scalar
	unless($encoding) {$encoding = "UTF-8"}; # set the default encoding
	unless($flavour) {$flavour = C4::Context->preference("marcflavour")}; # set the default MARC flavour

	# attempt to do the conversion
	eval { $marc = MARC::Record->new_from_xml($marcxml,$encoding,$flavour) }; # handle exceptions

	# record creation failed, populate $error
	if ($@) {$error .="\nCreation of MARCXML Record failed: ".$@;
		$error.=$MARC::File::ERROR if ($MARC::File::ERROR);
		};
	# return result to calling program
	return ($error,$marc);
}

=head2 marc2dcxml - Convert from ISO-2709 to Dublin Core

=over 4

my ($error,$dcxml) = marc2dcxml($marc,$qualified);

Returns a DublinCore::Record object, will eventually return a Dublin Core scalar

FIXME: should return actual XML, not just an object

=over 2

C<$marc> - an ISO-2709 scalar or MARC::Record object

C<$qualified> - specify whether qualified Dublin Core should be used in the input or output [0]

=back

=back

=cut

sub marc2dcxml {
	my ($marc,$qualified) = @_;
	my $error;
    # test if it's already a MARC::Record object, if not, make it one
    my $marc_record_obj;
    if ($marc =~ /^MARC::Record/) { # it's already a MARC::Record object
        $marc_record_obj = $marc;
    } else { # it's not a MARC::Record object, make it one
		eval { $marc_record_obj = MARC::Record->new_from_usmarc($marc) }; # handle exceptions

		# conversion to MARC::Record object failed, populate $error
		if ($@) {
			$error .="\nCreation of MARC::Record object failed: ".$MARC::File::ERROR;
		}
	}
	my $crosswalk = MARC::Crosswalk::DublinCore->new;
	if ($qualified) {
		$crosswalk = MARC::Crosswalk::DublinCore->new( qualified => 1 );
	}
	my $dcxml = $crosswalk->as_dublincore($marc_record_obj);
	my $dcxmlfinal = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
	$dcxmlfinal .= "<metadata
  xmlns=\"http://example.org/myapp/\"
  xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
  xsi:schemaLocation=\"http://example.org/myapp/ http://example.org/myapp/schema.xsd\"
  xmlns:dc=\"http://purl.org/dc/elements/1.1/\"
  xmlns:dcterms=\"http://purl.org/dc/terms/\">";

	foreach my $element ( $dcxml->elements() ) {
                $dcxmlfinal.="<"."dc:".$element->name().">".$element->content()."</"."dc:".$element->name().">\n";
    }
	$dcxmlfinal .= "\n</metadata>";
	return ($error,$dcxmlfinal);
}
=head2 marc2modsxml - Convert from ISO-2709 to MODS

=over 4

my ($error,$modsxml) = marc2modsxml($marc);

Returns a MODS scalar

=back

=cut

sub marc2modsxml {
	my ($marc) = @_;
	# grab the XML, run it through our stylesheet, push it out to the browser
	my $xmlrecord = marc2marcxml($marc);
	my $xslfile = C4::Context->config('intrahtdocs')."/prog/en/xslt/MARC21slim2MODS3-1.xsl";
	my $parser = XML::LibXML->new();
	my $xslt = XML::LibXSLT->new();
	my $source = $parser->parse_string($xmlrecord);
	my $style_doc = $parser->parse_file($xslfile);
	my $stylesheet = $xslt->parse_stylesheet($style_doc);
	my $results = $stylesheet->transform($source);
	my $newxmlrecord = $stylesheet->output_string($results);
	return ($newxmlrecord);
}

sub marc2endnote {
    my ($marc) = @_;
	my $marc_rec_obj =  MARC::Record->new_from_usmarc($marc);
	my $f260 = $marc_rec_obj->field('260');
	my $f260a = $f260->subfield('a') if $f260;
    my $f710 = $marc_rec_obj->field('710');
    my $f710a = $f710->subfield('a') if $f710;
	my $f500 = $marc_rec_obj->field('500');
	my $abstract = $f500->subfield('a') if $f500;
	my $fields = {
		DB => C4::Context->preference("LibraryName"),
		Title => $marc_rec_obj->title(),	
		Author => $marc_rec_obj->author(),	
		Publisher => $f710a,
		City => $f260a,
		Year => $marc_rec_obj->publication_date,
		Abstract => $abstract,
	};
	my $endnote;
	my $style = new Biblio::EndnoteStyle();
	my $template;
	$template.= "DB - DB\n" if C4::Context->preference("LibraryName");
	$template.="T1 - Title\n" if $marc_rec_obj->title();
	$template.="A1 - Author\n" if $marc_rec_obj->author();
	$template.="PB - Publisher\n" if  $f710a;
	$template.="CY - City\n" if $f260a;
	$template.="Y1 - Year\n" if $marc_rec_obj->publication_date;
	$template.="AB - Abstract\n" if $abstract;
	my ($text, $errmsg) = $style->format($template, $fields);
	return ($text);
	
}


=head2 html2marcxml

=over 4

my ($error,$marcxml) = html2marcxml($tags,$subfields,$values,$indicator,$ind_tag);

Returns a MARCXML scalar

this is used in addbiblio.pl and additem.pl to build the MARCXML record from 
the form submission.

FIXME: this could use some better code documentation

=back

=cut

sub html2marcxml {
    my ($tags,$subfields,$values,$indicator,$ind_tag) = @_;
	my $error;
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
					} elsif (@$tags[$i] lt '010') { # don't compare numerically 010 == 8
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
	return ($error,$marcxml);
}

=head2 html2marc

=over 4

Probably best to avoid using this ... it has some rather striking problems:

=over 2

* saves blank subfields

* subfield order is hardcoded to always start with 'a' for repeatable tags (because it is hardcoded in the addfield routine).

* only possible to specify one set of indicators for each set of tags (ie, one for all the 650s). (because they were stored in a hash with the tag as the key).

* the underlying routines didn't support subfield reordering or subfield repeatability.

=back 

I've left it in here because it could be useful if someone took the time to fix it. -- kados

=back

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

=head2 changeEncoding - Change the encoding of a record

=over 4

my ($error, $newrecord) = changeEncoding($record,$format,$flavour,$to_encoding,$from_encoding);

Changes the encoding of a record

=over 2

C<$record> - the record itself can be in ISO-2709, a MARC::Record object, or MARCXML for now (required)

C<$format> - MARC or MARCXML (required)

C<$flavour> - MARC21 or UNIMARC, if MARC21, it will change the leader (optional) [defaults to Koha system preference]

C<$to_encoding> - the encoding you want the record to end up in (optional) [UTF-8]

C<$from_encoding> - the encoding the record is currently in (optional, it will probably be able to tell unless there's a problem with the record)

=back 

FIXME: the from_encoding doesn't work yet

FIXME: better handling for UNIMARC, it should allow management of 100 field

FIXME: shouldn't have to convert to and from xml/marc just to change encoding someone needs to re-write MARC::Record's 'encoding' method to actually alter the encoding rather than just changing the leader

=back

=cut

sub changeEncoding {
	my ($record,$format,$flavour,$to_encoding,$from_encoding) = @_;
	my $newrecord;
	my $error;
	unless($flavour) {$flavour = C4::Context->preference("marcflavour")};
	unless($to_encoding) {$to_encoding = "UTF-8"};
	
	# ISO-2709 Record (MARC21 or UNIMARC)
	if (lc($format) =~ /^marc$/o) {
		# if we're converting encoding of an ISO2709 file, we need to roundtrip through XML
		# 	because MARC::Record doesn't directly provide us with an encoding method
		# 	It's definitely less than idea and should be fixed eventually - kados
		my $marcxml; # temporary storage of MARCXML scalar
		($error,$marcxml) = marc2marcxml($record,$to_encoding,$flavour);
		unless ($error) {
			($error,$newrecord) = marcxml2marc($marcxml,$to_encoding,$flavour);
		}
	
	# MARCXML Record
	} elsif (lc($format) =~ /^marcxml$/o) { # MARCXML Record
		my $marc;
		($error,$marc) = marcxml2marc($record,$to_encoding,$flavour);
		unless ($error) {
			($error,$newrecord) = marc2marcxml($record,$to_encoding,$flavour);
		}
	} else {
		$error.="Unsupported record format:".$format;
	}
	return ($error,$newrecord);
}

=head1 INTERNAL FUNCTIONS

=head2 _entity_encode - Entity-encode an array of strings

=over 4

my ($entity_encoded_string) = _entity_encode($string);

or

my (@entity_encoded_strings) = _entity_encode(@strings);

Entity-encode an array of strings

=back

=cut

sub _entity_encode {
	my @strings = @_;
	my @strings_entity_encoded;
	foreach my $string (@strings) {
		my $nfc_string = NFC($string);
		$nfc_string =~ s/([\x{0080}-\x{fffd}])/sprintf('&#x%X;',ord($1))/sgoe;
		push @strings_entity_encoded, $nfc_string;
	}
	return @strings_entity_encoded;
}

END { }       # module clean-up code here (global destructor)
1;
__END__

=head1 AUTHOR

Joshua Ferraro <jmf@liblime.com>

=head1 MODIFICATIONS


=cut
