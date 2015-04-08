package C4::Record;
#
# Copyright 2006 (C) LibLime
# Parts copyright 2010 BibLibre
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.
#
#
use strict;
#use warnings; FIXME - Bug 2505

# please specify in which methods a given module is used
use MARC::Record; # marc2marcxml, marcxml2marc, changeEncoding
use MARC::File::XML; # marc2marcxml, marcxml2marc, changeEncoding
use MARC::Crosswalk::DublinCore; # marc2dcxml
use Biblio::EndnoteStyle;
use Unicode::Normalize; # _entity_encode
use C4::Biblio; #marc2bibtex
use C4::Csv; #marc2csv
use C4::Koha; #marc2csv
use C4::XSLT ();
use YAML; #marcrecords2csv
use Text::CSV::Encoded; #marc2csv

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 3.07.00.049;

@ISA = qw(Exporter);

# only export API methods

@EXPORT = qw(
  &marc2endnote
  &marc2marc
  &marc2marcxml
  &marcxml2marc
  &marc2dcxml
  &marc2modsxml
  &marc2madsxml
  &marc2bibtex
  &marc2csv
  &changeEncoding
);

=head1 NAME

C4::Record - MARC, MARCXML, DC, MODS, XML, etc. Record Management Functions and API

=head1 SYNOPSIS

New in Koha 3.x. This module handles all record-related management functions.

=head1 API (EXPORTED FUNCTIONS)

=head2 marc2marc - Convert from one flavour of ISO-2709 to another

  my ($error,$newmarc) = marc2marc($marc,$to_flavour,$from_flavour,$encoding);

Returns an ISO-2709 scalar

=cut

sub marc2marc {
	my ($marc,$to_flavour,$from_flavour,$encoding) = @_;
	my $error;
    if ($to_flavour =~ m/marcstd/) {
        my $marc_record_obj;
        if ($marc =~ /^MARC::Record/) { # it's already a MARC::Record object
            $marc_record_obj = $marc;
        } else { # it's not a MARC::Record object, make it one
            eval { $marc_record_obj = MARC::Record->new_from_usmarc($marc) }; # handle exceptions

# conversion to MARC::Record object failed, populate $error
                if ($@) { $error .="\nCreation of MARC::Record object failed: ".$MARC::File::ERROR };
        }
        unless ($error) {
            my @privatefields;
            foreach my $field ($marc_record_obj->fields()) {
                if ($field->tag() =~ m/9/ && ($field->tag() != '490' || C4::Context->preference("marcflavour") eq 'UNIMARC')) {
                    push @privatefields, $field;
                } elsif (! ($field->is_control_field())) {
                    $field->delete_subfield(code => '9') if ($field->subfield('9'));
                }
            }
            $marc_record_obj->delete_field($_) for @privatefields;
            $marc = $marc_record_obj->as_usmarc();
        }
    } else {
        $error = "Feature not yet implemented\n";
    }
	return ($error,$marc);
}

=head2 marc2marcxml - Convert from ISO-2709 to MARCXML

  my ($error,$marcxml) = marc2marcxml($marc,$encoding,$flavour);

Returns a MARCXML scalar

C<$marc> - an ISO-2709 scalar or MARC::Record object

C<$encoding> - UTF-8 or MARC-8 [UTF-8]

C<$flavour> - MARC21 or UNIMARC

C<$dont_entity_encode> - a flag that instructs marc2marcxml not to entity encode the xml before returning (optional)

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

  my ($error,$marc) = marcxml2marc($marcxml,$encoding,$flavour);

Returns an ISO-2709 scalar

C<$marcxml> - a MARCXML record

C<$encoding> - UTF-8 or MARC-8 [UTF-8]

C<$flavour> - MARC21 or UNIMARC

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

  my ($error,$dcxml) = marc2dcxml($marc,$qualified);

Returns a DublinCore::Record object, will eventually return a Dublin Core scalar

FIXME: should return actual XML, not just an object

C<$marc> - an ISO-2709 scalar or MARC::Record object

C<$qualified> - specify whether qualified Dublin Core should be used in the input or output [0]

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

  my $modsxml = marc2modsxml($marc);

Returns a MODS scalar

=cut

sub marc2modsxml {
    my ($marc) = @_;
    return _transformWithStylesheet($marc, "/prog/en/xslt/MARC21slim2MODS3-1.xsl");
}

=head2 marc2madsxml - Convert from ISO-2709 to MADS

  my $madsxml = marc2madsxml($marc);

Returns a MADS scalar

=cut

sub marc2madsxml {
    my ($marc) = @_;
    return _transformWithStylesheet($marc, "/prog/en/xslt/MARC21slim2MADS.xsl");
}

=head2 _transformWithStylesheet - Transform a MARC record with a stylesheet

    my $xml = _transformWithStylesheet($marc, $stylesheet)

Returns the XML scalar result of the transformation. $stylesheet should
contain the path to a stylesheet under intrahtdocs.

=cut

sub _transformWithStylesheet {
    my ($marc, $stylesheet) = @_;
    # grab the XML, run it through our stylesheet, push it out to the browser
    my $xmlrecord = marc2marcxml($marc);
    my $xslfile = C4::Context->config('intrahtdocs') . $stylesheet;
    return C4::XSLT::engine->transform($xmlrecord, $xslfile);
}

sub marc2endnote {
    my ($marc) = @_;
	my $marc_rec_obj =  MARC::Record->new_from_usmarc($marc);
    my ( $abstract, $f260a, $f710a );
    my $f260 = $marc_rec_obj->field('260');
    if ($f260) {
        $f260a = $f260->subfield('a') if $f260;
    }
    my $f710 = $marc_rec_obj->field('710');
    if ($f710) {
        $f710a = $f710->subfield('a');
    }
    my $f500 = $marc_rec_obj->field('500');
    if ($f500) {
        $abstract = $f500->subfield('a');
    }
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

=head2 marc2csv - Convert several records from UNIMARC to CSV

  my ($csv) = marc2csv($biblios, $csvprofileid, $itemnumbers);

Pre and postprocessing can be done through a YAML file

Returns a CSV scalar

C<$biblio> - a list of biblionumbers

C<$csvprofileid> - the id of the CSV profile to use for the export (see export_format.export_format_id and the GetCsvProfiles function in C4::Csv)

C<$itemnumbers> - a list of itemnumbers to export

=cut

sub marc2csv {
    my ($biblios, $id, $itemnumbers) = @_;
    $itemnumbers ||= [];
    my $output;
    my $csv = Text::CSV::Encoded->new();

    # Getting yaml file
    my $configfile = "../tools/csv-profiles/$id.yaml";
    my ($preprocess, $postprocess, $fieldprocessing);
    if (-e $configfile){
        ($preprocess,$postprocess, $fieldprocessing) = YAML::LoadFile($configfile);
    }

    # Preprocessing
    eval $preprocess if ($preprocess);

    my $firstpass = 1;
    if ( @$itemnumbers ) {
        for my $itemnumber ( @$itemnumbers) {
            my $biblionumber = GetBiblionumberFromItemnumber $itemnumber;
            $output .= marcrecord2csv( $biblionumber, $id, $firstpass, $csv, $fieldprocessing, [$itemnumber] );
            $firstpass = 0;
        }
    } else {
        foreach my $biblio (@$biblios) {
            $output .= marcrecord2csv( $biblio, $id, $firstpass, $csv, $fieldprocessing );
            $firstpass = 0;
        }
    }

    # Postprocessing
    eval $postprocess if ($postprocess);

    return $output;
}

=head2 marcrecord2csv - Convert a single record from UNIMARC to CSV

  my ($csv) = marcrecord2csv($biblio, $csvprofileid, $header);

Returns a CSV scalar

C<$biblio> - a biblionumber

C<$csvprofileid> - the id of the CSV profile to use for the export (see export_format.export_format_id and the GetCsvProfiles function in C4::Csv)

C<$header> - true if the headers are to be printed (typically at first pass)

C<$csv> - an already initialised Text::CSV object

C<$fieldprocessing>

C<$itemnumbers> a list of itemnumbers to export

=cut


sub marcrecord2csv {
    my ($biblio, $id, $header, $csv, $fieldprocessing, $itemnumbers) = @_;
    my $output;

    # Getting the record
    my $record = GetMarcBiblio($biblio);
    next unless $record;
    C4::Biblio::EmbedItemsInMarcBiblio( $record, $biblio, $itemnumbers );
    # Getting the framework
    my $frameworkcode = GetFrameworkCode($biblio);

    # Getting information about the csv profile
    my $profile = GetCsvProfile($id);

    # Getting output encoding
    my $encoding          = $profile->{encoding} || 'utf8';
    # Getting separators
    my $csvseparator      = $profile->{csv_separator}      || ',';
    my $fieldseparator    = $profile->{field_separator}    || '#';
    my $subfieldseparator = $profile->{subfield_separator} || '|';

    # TODO: Be more generic (in case we have to handle other protected chars or more separators)
    if ($csvseparator eq '\t') { $csvseparator = "\t" }
    if ($fieldseparator eq '\t') { $fieldseparator = "\t" }
    if ($subfieldseparator eq '\t') { $subfieldseparator = "\t" }
    if ($csvseparator eq '\n') { $csvseparator = "\n" }
    if ($fieldseparator eq '\n') { $fieldseparator = "\n" }
    if ($subfieldseparator eq '\n') { $subfieldseparator = "\n" }

    $csv = $csv->encoding_out($encoding) ;
    $csv->sep_char($csvseparator);

    # Getting the marcfields
    my $marcfieldslist = $profile->{content};

    # Getting the marcfields as an array
    my @marcfieldsarray = split('\|', $marcfieldslist);

   # Separating the marcfields from the user-supplied headers
    my @marcfields;
    foreach (@marcfieldsarray) {
        my @result = split('=', $_);
        if (scalar(@result) == 2) {
           push @marcfields, { header => $result[0], field => $result[1] }; 
        } else {
           push @marcfields, { field => $result[0] }
        }
    }

    # If we have to insert the headers
    if ($header) {
	my @marcfieldsheaders;
	my $dbh   = C4::Context->dbh;

	# For each field or subfield
	foreach (@marcfields) {

	    my $field = $_->{field};
        # Remove any blank char that might have unintentionally insered into the tag name
        $field =~ s/\s+//g; 

	    # If we have a user-supplied header, we use it
	    if (exists $_->{header}) {
		    push @marcfieldsheaders, $_->{header};
	    } else {
		# If not, we get the matching tag name from koha
		if (index($field, '$') > 0) {
		    my ($fieldtag, $subfieldtag) = split('\$', $field);
		    my $query = "SELECT liblibrarian FROM marc_subfield_structure WHERE tagfield=? AND tagsubfield=?";
		    my $sth = $dbh->prepare($query);
		    $sth->execute($fieldtag, $subfieldtag);
		    my @results = $sth->fetchrow_array();
		    push @marcfieldsheaders, $results[0];
		} else {
		    my $query = "SELECT liblibrarian FROM marc_tag_structure WHERE tagfield=?";
		    my $sth = $dbh->prepare($query);
		    $sth->execute($field);
		    my @results = $sth->fetchrow_array();
		    push @marcfieldsheaders, $results[0];
		}
	    }
	}
	$csv->combine(@marcfieldsheaders);
	$output = $csv->string() . "\n";	
    }

    # For each marcfield to export
    my @fieldstab;
    foreach (@marcfields) {
	my $marcfield = $_->{field};
	# If it is a subfield
	if (index($marcfield, '$') > 0) {
	    my ($fieldtag, $subfieldtag) = split('\$', $marcfield);
	    my @fields = $record->field($fieldtag);
	    my @tmpfields;

	    # For each field
	    foreach my $field (@fields) {

		# We take every matching subfield
		my @subfields = $field->subfield($subfieldtag);
		foreach my $subfield (@subfields) {

		    # Getting authorised value
		    my $authvalues = GetKohaAuthorisedValuesFromField($fieldtag, $subfieldtag, $frameworkcode, undef);
		    push @tmpfields, (defined $authvalues->{$subfield}) ? $authvalues->{$subfield} : $subfield;
		}
	    }
	    push (@fieldstab, join($subfieldseparator, @tmpfields));  		
	# Or a field
	} else {
	    my @fields = ($record->field($marcfield));
	    my $authvalues = GetKohaAuthorisedValuesFromField($marcfield, undef, $frameworkcode, undef);

        my @valuesarray;
        foreach (@fields) {
            my $value;

            # If it is a control field
            if ($_->is_control_field) {
                $value = defined $authvalues->{$_->as_string} ? $authvalues->{$_->as_string} : $_->as_string;
            } else {
                # If it is a field, we gather all subfields, joined by the subfield separator
                my @subvaluesarray;
                my @subfields = $_->subfields;
                foreach my $subfield (@subfields) {
                    push (@subvaluesarray, defined $authvalues->{$subfield->[1]} ? $authvalues->{$subfield->[1]} : $subfield->[1]);
                }
                $value = join ($subfieldseparator, @subvaluesarray);
            }

            # Field processing
            eval $fieldprocessing if ($fieldprocessing);

            push @valuesarray, $value;
        }
	    push (@fieldstab, join($fieldseparator, @valuesarray)); 
	 }
    };

    $csv->combine(@fieldstab);
    $output .= $csv->string() . "\n";

    return $output;

}


=head2 changeEncoding - Change the encoding of a record

  my ($error, $newrecord) = changeEncoding($record,$format,$flavour,$to_encoding,$from_encoding);

Changes the encoding of a record

C<$record> - the record itself can be in ISO-2709, a MARC::Record object, or MARCXML for now (required)

C<$format> - MARC or MARCXML (required)

C<$flavour> - MARC21 or UNIMARC, if MARC21, it will change the leader (optional) [defaults to Koha system preference]

C<$to_encoding> - the encoding you want the record to end up in (optional) [UTF-8]

C<$from_encoding> - the encoding the record is currently in (optional, it will probably be able to tell unless there's a problem with the record)

FIXME: the from_encoding doesn't work yet

FIXME: better handling for UNIMARC, it should allow management of 100 field

FIXME: shouldn't have to convert to and from xml/marc just to change encoding someone needs to re-write MARC::Record's 'encoding' method to actually alter the encoding rather than just changing the leader

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

=head2 marc2bibtex - Convert from MARC21 and UNIMARC to BibTex

  my ($bibtex) = marc2bibtex($record, $id);

Returns a BibTex scalar

C<$record> - a MARC::Record object

C<$id> - an id for the BibTex record (might be the biblionumber)

=cut


sub marc2bibtex {
    my ($record, $id) = @_;
    my $tex;
    my $marcflavour = C4::Context->preference("marcflavour");

    # Authors
    my $author;
    my @texauthors;
    my @authorFields = ('100','110','111','700','710','711');
    @authorFields = ('700','701','702','710','711','721') if ( $marcflavour eq "UNIMARC" );

    foreach my $field ( @authorFields ) {
        # author formatted surname, firstname
        my $texauthor = '';
        if ( $marcflavour eq "UNIMARC" ) {
           $texauthor = join ', ',
           ( $record->subfield($field,"a"), $record->subfield($field,"b") );
       } else {
           $texauthor = $record->subfield($field,"a");
       }
       push @texauthors, $texauthor if $texauthor;
    }
    $author = join ' and ', @texauthors;

    # Defining the conversion array according to the marcflavour
    my @bh;
    if ( $marcflavour eq "UNIMARC" ) {

        # FIXME, TODO : handle repeatable fields
        # TODO : handle more types of documents

        # Unimarc to bibtex array
        @bh = (

            # Mandatory
            author    => $author,
            title     => $record->subfield("200", "a") || "",
            editor    => $record->subfield("210", "g") || "",
            publisher => $record->subfield("210", "c") || "",
            year      => $record->subfield("210", "d") || $record->subfield("210", "h") || "",

            # Optional
            volume  =>  $record->subfield("200", "v") || "",
            series  =>  $record->subfield("225", "a") || "",
            address =>  $record->subfield("210", "a") || "",
            edition =>  $record->subfield("205", "a") || "",
            note    =>  $record->subfield("300", "a") || "",
            url     =>  $record->subfield("856", "u") || ""
        );
    } else {

        # Marc21 to bibtex array
        @bh = (

            # Mandatory
            author    => $author,
            title     => $record->subfield("245", "a") || "",
            editor    => $record->subfield("260", "f") || "",
            publisher => $record->subfield("264", "b") || $record->subfield("260", "b") || "",
            year      => $record->subfield("264", "c") || $record->subfield("260", "c") || $record->subfield("260", "g") || "",

            # Optional
            # unimarc to marc21 specification says not to convert 200$v to marc21
            series  =>  $record->subfield("490", "a") || "",
            address =>  $record->subfield("264", "a") || $record->subfield("260", "a") || "",
            edition =>  $record->subfield("250", "a") || "",
            note    =>  $record->subfield("500", "a") || "",
            url     =>  $record->subfield("856", "u") || ""
        );
    }

    $tex .= "\@book{";
    my @elt;
    for ( my $i = 0 ; $i < scalar( @bh ) ; $i = $i + 2 ) {
        next unless $bh[$i+1];
        push @elt, qq|\t$bh[$i] = {$bh[$i+1]}|;
    }
    $tex .= join(",\n", $id, @elt);
    $tex .= "\n}\n";

    return $tex;
}


=head1 INTERNAL FUNCTIONS

=head2 _entity_encode - Entity-encode an array of strings

  my ($entity_encoded_string) = _entity_encode($string);

or

  my (@entity_encoded_strings) = _entity_encode(@strings);

Entity-encode an array of strings

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
