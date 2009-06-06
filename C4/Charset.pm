package C4::Charset;

# Copyright (C) 2008 LibLime
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
use MARC::Charset qw/marc8_to_utf8/;
use Text::Iconv;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

BEGIN {
    # set the version for version checking
    $VERSION = 3.01;
    require Exporter;
    @ISA    = qw(Exporter);
    @EXPORT = qw(
        IsStringUTF8ish
        MarcToUTF8Record
        SetMarcUnicodeFlag
        StripNonXmlChars
    );
}

=head1 NAME

C4::Charset - utilities for handling character set conversions.

=head1 SYNOPSIS

use C4::Charset;

=head1 DESCRIPTION

This module contains routines for dealing with character set
conversions, particularly for MARC records.

A variety of character encodings are in use by various MARC
standards, and even more character encodings are used by
non-standard MARC records.  The various MARC formats generally
do not do a good job of advertising a given record's character
encoding, and even when a record does advertise its encoding,
e.g., via the Leader/09, experience has shown that one cannot
trust it.

Ultimately, all MARC records are stored in Koha in UTF-8 and
must be converted from whatever the source character encoding is.
The goal of this module is to ensure that these conversions
take place accurately.  When a character conversion cannot take
place, or at least not accurately, the module was provide
enough information to allow user-facing code to inform the user
on how to deal with the situation.

=cut

=head1 FUNCTIONS

=head2 IsStringUTF8ish

=over 4

my $is_utf8 = IsStringUTF8ish($str);

=back

Determines if C<$str> is valid UTF-8.  This can mean
one of two things:

=over 2

=item *

The Perl UTF-8 flag is set and the string contains valid UTF-8.

=item *

The Perl UTF-8 flag is B<not> set, but the octets contain
valid UTF-8.

=back

The function is named C<IsStringUTF8ish> instead of C<IsStringUTF8> 
because in one could be presented with a MARC blob that is
not actually in UTF-8 but whose sequence of octets appears to be
valid UTF-8.  The rest of the MARC character conversion functions 
will assume that this situation occur does not very often.

=cut

sub IsStringUTF8ish {
    my $str = shift;

    return 1 if utf8::is_utf8($str);
    return utf8::decode($str);
}

=head2 MarcToUTF8Record

=over 4

($marc_record, $converted_from, $errors_arrayref) = MarcToUTF8Record($marc_blob, $marc_flavour, [, $source_encoding]);

=back

Given a MARC blob or a C<MARC::Record>, the MARC flavour, and an 
optional source encoding, return a C<MARC::Record> that is 
converted to UTF-8.

The returned C<$marc_record> is guaranteed to be in valid UTF-8, but
is not guaranteed to have been converted correctly.  Specifically,
if C<$converted_from> is 'failed', the MARC record returned failed
character conversion and had each of its non-ASCII octets changed
to the Unicode replacement character.

If the source encoding was not specified, this routine will 
try to guess it; the character encoding used for a successful
conversion is returned in C<$converted_from>.

=cut

sub MarcToUTF8Record {
    my $marc = shift;
    my $marc_flavour = shift;
    my $source_encoding = shift;

    my $marc_record;
    my $marc_blob_is_utf8 = 0;
    if (ref($marc) eq 'MARC::Record') {
        my $marc_blob = $marc->as_usmarc();
        $marc_blob_is_utf8 = IsStringUTF8ish($marc_blob);
        $marc_record = $marc;
    } else {
        # dealing with a MARC blob
       
        # remove any ersatz whitespace from the beginning and
        # end of the MARC blob -- these can creep into MARC
        # files produced by several sources -- caller really
        # should be doing this, however
        $marc =~ s/^\s+//;
        $marc =~ s/\s+$//;
        $marc_blob_is_utf8 = IsStringUTF8ish($marc);
        eval {
            $marc_record = MARC::Record->new_from_usmarc($marc);
        };
        if ($@) {
            # if we fail the first time, one likely problem
            # is that we have a MARC21 record that says that it's
            # UTF-8 (Leader/09 = 'a') but contains non-UTF-8 characters.
            # We'll try parsing it again.
            substr($marc, 9, 1) = ' ';
            eval {
                $marc_record = MARC::Record->new_from_usmarc($marc);
            };
            if ($@) {
                # it's hopeless; return an empty MARC::Record
                return MARC::Record->new(), 'failed', ['could not parse MARC blob'];
            }
        }
    }

    # If we do not know the source encoding, try some guesses
    # as follows:
    #   1. Record is UTF-8 already.
    #   2. If MARC flavor is MARC21, then
    #      a. record is MARC-8
    #      b. record is ISO-8859-1
    #   3. If MARC flavor is UNIMARC, then
    if (not defined $source_encoding) {
        if ($marc_blob_is_utf8) {
            # note that for MARC21 we are not bothering to check
            # if the Leader/09 is set to 'a' or not -- because
            # of problems with various ILSs (including Koha in the
            # past, alas), this just is not trustworthy.
            SetMarcUnicodeFlag($marc_record, $marc_flavour);
            return $marc_record, 'UTF-8', [];
        } else {
            if ($marc_flavour eq 'MARC21') {
                return _default_marc21_charconv_to_utf8($marc_record, $marc_flavour);
            } elsif ($marc_flavour eq 'UNIMARC') {
                return _default_unimarc_charconv_to_utf8($marc_record, $marc_flavour);
            } else {
                return _default_marc21_charconv_to_utf8($marc_record, $marc_flavour);
            }
        }
    } else {
        # caller knows the character encoding
        my $original_marc_record = $marc_record->clone();
        my @errors;
        if ($source_encoding =~ /utf-?8/i) {
            if ($marc_blob_is_utf8) {
                SetMarcUnicodeFlag($marc_record, $marc_flavour);
                return $marc_record, 'UTF-8', [];
            } else {
                push @errors, 'specified UTF-8 => UTF-8 conversion, but record is not in UTF-8';
            }
        } elsif ($source_encoding =~ /marc-?8/i) {
            @errors = _marc_marc8_to_utf8($marc_record, $marc_flavour);
        } elsif ($source_encoding =~ /5426/) {
            @errors = _marc_iso5426_to_utf8($marc_record, $marc_flavour);
        } else {
            # assume any other character encoding is for Text::Iconv
            @errors = _marc_to_utf8_via_text_iconv($marc_record, $marc_flavour, 'iso-8859-1');
        }

        if (@errors) {
            _marc_to_utf8_replacement_char($original_marc_record, $marc_flavour);
            return $original_marc_record, 'failed', \@errors;
        } else {
            return $marc_record, $source_encoding, [];
        }
    }

}

=head2 SetMarcUnicodeFlag

=over 4

SetMarcUnicodeFlag($marc_record, $marc_flavour);

=back

Set both the internal MARC::Record encoding flag
and the appropriate Leader/09 (MARC21) or 
100/26-29 (UNIMARC) to indicate that the record
is in UTF-8.  Note that this does B<not> do
any actual character conversion.

=cut

sub SetMarcUnicodeFlag {
    my $marc_record = shift;
    my $marc_flavour = shift; # || C4::Context->preference("marcflavour");

    $marc_record->encoding('UTF-8');
    if ($marc_flavour eq 'MARC21') {
        my $leader = $marc_record->leader();
        substr($leader, 9, 1) = 'a';
        $marc_record->leader($leader); 
    } elsif ($marc_flavour eq "UNIMARC") {
        if (my $field = $marc_record->field('100')) {
            my $sfa = $field->subfield('a');
            
            my $subflength = 36;
            # fix the length of the field
            $sfa = substr $sfa, 0, $subflength if (length($sfa) > $subflength);
            $sfa = sprintf( "%-*s", 35, $sfa ) if (length($sfa) < $subflength);
            
            substr($sfa, 26, 4) = '50  ';
            $field->update('a' => $sfa);
        }
    } else {
        warn "Unrecognized marcflavour: $marc_flavour";
    }
}

=head2 StripNonXmlChars

=over 4

my $new_str = StripNonXmlChars($old_str);

=back

Given a string, return a copy with the
characters that are illegal in XML 
removed.

This function exists to work around a problem
that can occur with badly-encoded MARC records.
Specifically, if a UTF-8 MARC record also
has excape (\x1b) characters, MARC::File::XML
will let the escape characters pass through
when as_xml() or as_xml_record() is called.  The
problem is that the escape character is not
legal in well-formed XML documents, so when
MARC::File::XML attempts to parse such a record,
the XML parser will fail.

Stripping such characters will allow a 
MARC::Record->new_from_xml()
to work, at the possible risk of some data loss.

=cut

sub StripNonXmlChars {
    my $str = shift;
    $str =~ s/[^\x09\x0A\x0D\x{0020}-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}]//g;
    return $str;
}

=head1 INTERNAL FUNCTIONS

=head2 _default_marc21_charconv_to_utf8

=over 4

my ($new_marc_record, $guessed_charset) = _default_marc21_charconv_to_utf8($marc_record);

=back

Converts a C<MARC::Record> of unknown character set to UTF-8,
first by trying a MARC-8 to UTF-8 conversion, then ISO-8859-1
to UTF-8, then a default conversion that replaces each non-ASCII
character with the replacement character.

The C<$guessed_charset> return value contains the character set
that resulted in a conversion to valid UTF-8; note that
if the MARC-8 and ISO-8859-1 conversions failed, the value of
this is 'failed'. 

=cut

sub _default_marc21_charconv_to_utf8 {
    my $marc_record = shift;
    my $marc_flavour = shift;

    my $trial_marc8 = $marc_record->clone();
    my @all_errors = ();
    my @errors = _marc_marc8_to_utf8($trial_marc8, $marc_flavour);
    unless (@errors) {
        return $trial_marc8, 'MARC-8', [];
    }
    push @all_errors, @errors;
    
    my $trial_8859_1 = $marc_record->clone();
    @errors = _marc_to_utf8_via_text_iconv($trial_8859_1, $marc_flavour, 'iso-8859-1');
    unless (@errors) {
        return $trial_8859_1, 'iso-8859-1', []; # note -- we could return \@all_errors
                                                # instead if we wanted to report details
                                                # of the failed attempt at MARC-8 => UTF-8
    }
    push @all_errors, @errors;
    
    my $default_converted = $marc_record->clone();
    _marc_to_utf8_replacement_char($default_converted, $marc_flavour);
    return $default_converted, 'failed', \@all_errors;
}

=head2 _default_unimarc_charconv_to_utf8

=over 4

my ($new_marc_record, $guessed_charset) = _default_unimarc_charconv_to_utf8($marc_record);

=back

Converts a C<MARC::Record> of unknown character set to UTF-8,
first by trying a ISO-5426 to UTF-8 conversion, then ISO-8859-1
to UTF-8, then a default conversion that replaces each non-ASCII
character with the replacement character.

The C<$guessed_charset> return value contains the character set
that resulted in a conversion to valid UTF-8; note that
if the MARC-8 and ISO-8859-1 conversions failed, the value of
this is 'failed'. 

=cut

sub _default_unimarc_charconv_to_utf8 {
    my $marc_record = shift;
    my $marc_flavour = shift;

    my $trial_marc8 = $marc_record->clone();
    my @all_errors = ();
    my @errors = _marc_iso5426_to_utf8($trial_marc8, $marc_flavour);
    unless (@errors) {
        return $trial_marc8, 'iso-5426';
    }
    push @all_errors, @errors;
    
    my $trial_8859_1 = $marc_record->clone();
    @errors = _marc_to_utf8_via_text_iconv($trial_8859_1, $marc_flavour, 'iso-8859-1');
    unless (@errors) {
        return $trial_8859_1, 'iso-8859-1';
    }
    push @all_errors, @errors;
    
    my $default_converted = $marc_record->clone();
    _marc_to_utf8_replacement_char($default_converted, $marc_flavour);
    return $default_converted, 'failed', \@all_errors;
}

=head2 _marc_marc8_to_utf8

=over 4

my @errors = _marc_marc8_to_utf8($marc_record, $marc_flavour, $source_encoding);

=back

Convert a C<MARC::Record> to UTF-8 in-place from MARC-8.
If the conversion fails for some reason, an
appropriate messages will be placed in the returned
C<@errors> array.

=cut

sub _marc_marc8_to_utf8 {
    my $marc_record = shift;
    my $marc_flavour = shift;

    my $prev_ignore = MARC::Charset->ignore_errors(); 
    MARC::Charset->ignore_errors(1);

    # trap warnings raised by MARC::Charset
    my @errors = ();
    local $SIG{__WARN__} = sub {
        my $msg = $_[0];
        if ($msg =~ /MARC.Charset/) {
            # FIXME - purpose of this regexp is to strip out the
            # line reference to MARC/Charset.pm, but as it
            # exists probably won't work quite on Windows --
            # some sort of minimal-bunch back-tracking RE
            # would be helpful here
            $msg =~ s/at [\/].*?.MARC.Charset\.pm line \d+\.\n$//;
            push @errors, $msg;
        } else {
            # if warning doesn't come from MARC::Charset, just
            # pass it on
            warn $msg;
        }
    };

    foreach my $field ($marc_record->fields()) {
        if ($field->is_control_field()) {
            ; # do nothing -- control fields should not contain non-ASCII characters
        } else {
            my @converted_subfields;
            foreach my $subfield ($field->subfields()) {
                my $utf8sf = MARC::Charset::marc8_to_utf8($subfield->[1]);
                unless (IsStringUTF8ish($utf8sf)) {
                    # Because of a bug in MARC::Charset 0.98, if the string
                    # has (a) one or more diacritics that (b) are only in character positions
                    # 128 to 255 inclusive, the resulting converted string is not in
                    # UTF-8, but the legacy 8-bit encoding (e.g., ISO-8859-1).  If that
                    # occurs, upgrade the string in place.  Moral of the story seems to be
                    # that pack("U", ...) is better than chr(...) if you need to guarantee
                    # that the resulting string is UTF-8.
                    utf8::upgrade($utf8sf);
                }
                push @converted_subfields, $subfield->[0], $utf8sf;
            }

            $field->replace_with(MARC::Field->new(
                $field->tag(), $field->indicator(1), $field->indicator(2),
                @converted_subfields)
            ); 
        }
    }

    MARC::Charset->ignore_errors($prev_ignore);

    SetMarcUnicodeFlag($marc_record, $marc_flavour);

    return @errors;
}

=head2 _marc_iso5426_to_utf8

=over 4

my @errors = _marc_iso5426_to_utf8($marc_record, $marc_flavour, $source_encoding);

=back

Convert a C<MARC::Record> to UTF-8 in-place from ISO-5426.
If the conversion fails for some reason, an
appropriate messages will be placed in the returned
C<@errors> array.

FIXME - is ISO-5426 equivalent enough to MARC-8
that C<MARC::Charset> can be used instead?

=cut

sub _marc_iso5426_to_utf8 {
    my $marc_record = shift;
    my $marc_flavour = shift;

    my @errors = ();

    foreach my $field ($marc_record->fields()) {
        if ($field->is_control_field()) {
            ; # do nothing -- control fields should not contain non-ASCII characters
        } else {
            my @converted_subfields;
            foreach my $subfield ($field->subfields()) {
                my $utf8sf = char_decode5426($subfield->[1]);
                push @converted_subfields, $subfield->[0], $utf8sf;
            }

            $field->replace_with(MARC::Field->new(
                $field->tag(), $field->indicator(1), $field->indicator(2),
                @converted_subfields)
            ); 
        }
    }

    SetMarcUnicodeFlag($marc_record, $marc_flavour);

    return @errors;
}

=head2 _marc_to_utf8_via_text_iconv 

=over 4

my @errors = _marc_to_utf8_via_text_iconv($marc_record, $marc_flavour, $source_encoding);

=back

Convert a C<MARC::Record> to UTF-8 in-place using the
C<Text::Iconv> CPAN module.  Any source encoding accepted
by the user's iconv installation should work.  If
the source encoding is not recognized on the user's 
server or the conversion fails for some reason,
appropriate messages will be placed in the returned
C<@errors> array.

=cut

sub _marc_to_utf8_via_text_iconv {
    my $marc_record = shift;
    my $marc_flavour = shift;
    my $source_encoding = shift;

    my @errors = ();
    my $decoder;
    eval { $decoder = Text::Iconv->new($source_encoding, 'utf8'); };
    if ($@) {
        push @errors, "Could not initialze $source_encoding => utf8 converter: $@";
        return @errors;
    }

    my $prev_raise_error = Text::Iconv->raise_error();
    Text::Iconv->raise_error(1);

    foreach my $field ($marc_record->fields()) {
        if ($field->is_control_field()) {
            ; # do nothing -- control fields should not contain non-ASCII characters
        } else {
            my @converted_subfields;
            foreach my $subfield ($field->subfields()) {
                my $converted_value;
                my $conversion_ok = 1;
                eval { $converted_value = $decoder->convert($subfield->[1]); };
                if ($@) {
                    $conversion_ok = 0;
                    push @errors, $@;
                } elsif (not defined $converted_value) {
                    $conversion_ok = 0;
                    push @errors, "Text::Iconv conversion failed - retval is " . $decoder->retval();
                }

                if ($conversion_ok) {
                    push @converted_subfields, $subfield->[0], $converted_value;
                } else {
                    $converted_value = $subfield->[1];
                    $converted_value =~ s/[\200-\377]/\xef\xbf\xbd/g;
                    push @converted_subfields, $subfield->[0], $converted_value;
                }
            }

            $field->replace_with(MARC::Field->new(
                $field->tag(), $field->indicator(1), $field->indicator(2),
                @converted_subfields)
            ); 
        }
    }

    SetMarcUnicodeFlag($marc_record, $marc_flavour);
    Text::Iconv->raise_error($prev_raise_error);

    return @errors;
}

=head2 _marc_to_utf8_replacement_char 

=over 4

_marc_to_utf8_replacement_char($marc_record, $marc_flavour);

=back

Convert a C<MARC::Record> to UTF-8 in-place, adopting the 
unsatisfactory method of replacing all non-ASCII (e.g.,
where the eight bit is set) octet with the Unicode
replacement character.  This is meant as a last-ditch
method, and would be best used as part of a UI that
lets a cataloguer pick various character conversions
until he or she finds the right one.

=cut

sub _marc_to_utf8_replacement_char {
    my $marc_record = shift;
    my $marc_flavour = shift;

    foreach my $field ($marc_record->fields()) {
        if ($field->is_control_field()) {
            ; # do nothing -- control fields should not contain non-ASCII characters
        } else {
            my @converted_subfields;
            foreach my $subfield ($field->subfields()) {
                my $value = $subfield->[1];
                $value =~ s/[\200-\377]/\xef\xbf\xbd/g;
                push @converted_subfields, $subfield->[0], $value;
            }

            $field->replace_with(MARC::Field->new(
                $field->tag(), $field->indicator(1), $field->indicator(2),
                @converted_subfields)
            ); 
        }
    }

    SetMarcUnicodeFlag($marc_record, $marc_flavour);
}

=head2 char_decode5426

=over 4

my $utf8string = char_decode5426($iso_5426_string);

=back

Converts a string from ISO-5426 to UTF-8.

=cut


my %chars;
$chars{0xb0}=0x0101;#3/0ayn[ain]
$chars{0xb1}=0x0623;#3/1alif/hamzah[alefwithhamzaabove]
#$chars{0xb2}=0x00e0;#'à';
$chars{0xb2}=0x00e0;#3/2leftlowsinglequotationmark
#$chars{0xb3}=0x00e7;#'ç';
$chars{0xb3}=0x00e7;#3/2leftlowsinglequotationmark
# $chars{0xb4}='è';
$chars{0xb4}=0x00e8;
# $chars{0xb5}='é';
$chars{0xb5}=0x00e9;
$chars{0x97}=0x003c;#3/2leftlowsinglequotationmark
$chars{0x98}=0x003e;#3/2leftlowsinglequotationmark
$chars{0xfa}=0x0153;#oe
$chars{0x81d1}=0x00b0;

####
## combined characters iso5426

$chars{0xc041}=0x1ea2; # capital a with hook above
$chars{0xc045}=0x1eba; # capital e with hook above
$chars{0xc049}=0x1ec8; # capital i with hook above
$chars{0xc04f}=0x1ece; # capital o with hook above
$chars{0xc055}=0x1ee6; # capital u with hook above
$chars{0xc059}=0x1ef6; # capital y with hook above
$chars{0xc061}=0x1ea3; # small a with hook above
$chars{0xc065}=0x1ebb; # small e with hook above
$chars{0xc069}=0x1ec9; # small i with hook above
$chars{0xc06f}=0x1ecf; # small o with hook above
$chars{0xc075}=0x1ee7; # small u with hook above
$chars{0xc079}=0x1ef7; # small y with hook above
    
        # 4/1 grave accent
$chars{0xc141}=0x00c0; # capital a with grave accent
$chars{0xc145}=0x00c8; # capital e with grave accent
$chars{0xc149}=0x00cc; # capital i with grave accent
$chars{0xc14f}=0x00d2; # capital o with grave accent
$chars{0xc155}=0x00d9; # capital u with grave accent
$chars{0xc157}=0x1e80; # capital w with grave
$chars{0xc159}=0x1ef2; # capital y with grave
$chars{0xc161}=0x00e0; # small a with grave accent
$chars{0xc165}=0x00e8; # small e with grave accent
$chars{0xc169}=0x00ec; # small i with grave accent
$chars{0xc16f}=0x00f2; # small o with grave accent
$chars{0xc175}=0x00f9; # small u with grave accent
$chars{0xc177}=0x1e81; # small w with grave
$chars{0xc179}=0x1ef3; # small y with grave
        # 4/2 acute accent
$chars{0xc241}=0x00c1; # capital a with acute accent
$chars{0xc243}=0x0106; # capital c with acute accent
$chars{0xc245}=0x00c9; # capital e with acute accent
$chars{0xc247}=0x01f4; # capital g with acute
$chars{0xc249}=0x00cd; # capital i with acute accent
$chars{0xc24b}=0x1e30; # capital k with acute
$chars{0xc24c}=0x0139; # capital l with acute accent
$chars{0xc24d}=0x1e3e; # capital m with acute
$chars{0xc24e}=0x0143; # capital n with acute accent
$chars{0xc24f}=0x00d3; # capital o with acute accent
$chars{0xc250}=0x1e54; # capital p with acute
$chars{0xc252}=0x0154; # capital r with acute accent
$chars{0xc253}=0x015a; # capital s with acute accent
$chars{0xc255}=0x00da; # capital u with acute accent
$chars{0xc257}=0x1e82; # capital w with acute
$chars{0xc259}=0x00dd; # capital y with acute accent
$chars{0xc25a}=0x0179; # capital z with acute accent
$chars{0xc261}=0x00e1; # small a with acute accent
$chars{0xc263}=0x0107; # small c with acute accent
$chars{0xc265}=0x00e9; # small e with acute accent
$chars{0xc267}=0x01f5; # small g with acute
$chars{0xc269}=0x00ed; # small i with acute accent
$chars{0xc26b}=0x1e31; # small k with acute
$chars{0xc26c}=0x013a; # small l with acute accent
$chars{0xc26d}=0x1e3f; # small m with acute
$chars{0xc26e}=0x0144; # small n with acute accent
$chars{0xc26f}=0x00f3; # small o with acute accent
$chars{0xc270}=0x1e55; # small p with acute
$chars{0xc272}=0x0155; # small r with acute accent
$chars{0xc273}=0x015b; # small s with acute accent
$chars{0xc275}=0x00fa; # small u with acute accent
$chars{0xc277}=0x1e83; # small w with acute
$chars{0xc279}=0x00fd; # small y with acute accent
$chars{0xc27a}=0x017a; # small z with acute accent
$chars{0xc2e1}=0x01fc; # capital ae with acute
$chars{0xc2f1}=0x01fd; # small ae with acute
       # 4/3 circumflex accent
$chars{0xc341}=0x00c2; # capital a with circumflex accent
$chars{0xc343}=0x0108; # capital c with circumflex
$chars{0xc345}=0x00ca; # capital e with circumflex accent
$chars{0xc347}=0x011c; # capital g with circumflex
$chars{0xc348}=0x0124; # capital h with circumflex
$chars{0xc349}=0x00ce; # capital i with circumflex accent
$chars{0xc34a}=0x0134; # capital j with circumflex
$chars{0xc34f}=0x00d4; # capital o with circumflex accent
$chars{0xc353}=0x015c; # capital s with circumflex
$chars{0xc355}=0x00db; # capital u with circumflex
$chars{0xc357}=0x0174; # capital w with circumflex
$chars{0xc359}=0x0176; # capital y with circumflex
$chars{0xc35a}=0x1e90; # capital z with circumflex
$chars{0xc361}=0x00e2; # small a with circumflex accent
$chars{0xc363}=0x0109; # small c with circumflex
$chars{0xc365}=0x00ea; # small e with circumflex accent
$chars{0xc367}=0x011d; # small g with circumflex
$chars{0xc368}=0x0125; # small h with circumflex
$chars{0xc369}=0x00ee; # small i with circumflex accent
$chars{0xc36a}=0x0135; # small j with circumflex
$chars{0xc36e}=0x00f1; # small n with tilde
$chars{0xc36f}=0x00f4; # small o with circumflex accent
$chars{0xc373}=0x015d; # small s with circumflex
$chars{0xc375}=0x00fb; # small u with circumflex
$chars{0xc377}=0x0175; # small w with circumflex
$chars{0xc379}=0x0177; # small y with circumflex
$chars{0xc37a}=0x1e91; # small z with circumflex
        # 4/4 tilde
$chars{0xc441}=0x00c3; # capital a with tilde
$chars{0xc445}=0x1ebc; # capital e with tilde
$chars{0xc449}=0x0128; # capital i with tilde
$chars{0xc44e}=0x00d1; # capital n with tilde
$chars{0xc44f}=0x00d5; # capital o with tilde
$chars{0xc455}=0x0168; # capital u with tilde
$chars{0xc456}=0x1e7c; # capital v with tilde
$chars{0xc459}=0x1ef8; # capital y with tilde
$chars{0xc461}=0x00e3; # small a with tilde
$chars{0xc465}=0x1ebd; # small e with tilde
$chars{0xc469}=0x0129; # small i with tilde
$chars{0xc46e}=0x00f1; # small n with tilde
$chars{0xc46f}=0x00f5; # small o with tilde
$chars{0xc475}=0x0169; # small u with tilde
$chars{0xc476}=0x1e7d; # small v with tilde
$chars{0xc479}=0x1ef9; # small y with tilde
    # 4/5 macron
$chars{0xc541}=0x0100; # capital a with macron
$chars{0xc545}=0x0112; # capital e with macron
$chars{0xc547}=0x1e20; # capital g with macron
$chars{0xc549}=0x012a; # capital i with macron
$chars{0xc54f}=0x014c; # capital o with macron
$chars{0xc555}=0x016a; # capital u with macron
$chars{0xc561}=0x0101; # small a with macron
$chars{0xc565}=0x0113; # small e with macron
$chars{0xc567}=0x1e21; # small g with macron
$chars{0xc569}=0x012b; # small i with macron
$chars{0xc56f}=0x014d; # small o with macron
$chars{0xc575}=0x016b; # small u with macron
$chars{0xc572}=0x0159; # small r with macron
$chars{0xc5e1}=0x01e2; # capital ae with macron
$chars{0xc5f1}=0x01e3; # small ae with macron
        # 4/6 breve
$chars{0xc641}=0x0102; # capital a with breve
$chars{0xc645}=0x0114; # capital e with breve
$chars{0xc647}=0x011e; # capital g with breve
$chars{0xc649}=0x012c; # capital i with breve
$chars{0xc64f}=0x014e; # capital o with breve
$chars{0xc655}=0x016c; # capital u with breve
$chars{0xc661}=0x0103; # small a with breve
$chars{0xc665}=0x0115; # small e with breve
$chars{0xc667}=0x011f; # small g with breve
$chars{0xc669}=0x012d; # small i with breve
$chars{0xc66f}=0x014f; # small o with breve
$chars{0xc675}=0x016d; # small u with breve
        # 4/7 dot above
$chars{0xc7b0}=0x01e1; # Ain with dot above
$chars{0xc742}=0x1e02; # capital b with dot above
$chars{0xc743}=0x010a; # capital c with dot above
$chars{0xc744}=0x1e0a; # capital d with dot above
$chars{0xc745}=0x0116; # capital e with dot above
$chars{0xc746}=0x1e1e; # capital f with dot above
$chars{0xc747}=0x0120; # capital g with dot above
$chars{0xc748}=0x1e22; # capital h with dot above
$chars{0xc749}=0x0130; # capital i with dot above
$chars{0xc74d}=0x1e40; # capital m with dot above
$chars{0xc74e}=0x1e44; # capital n with dot above
$chars{0xc750}=0x1e56; # capital p with dot above
$chars{0xc752}=0x1e58; # capital r with dot above
$chars{0xc753}=0x1e60; # capital s with dot above
$chars{0xc754}=0x1e6a; # capital t with dot above
$chars{0xc757}=0x1e86; # capital w with dot above
$chars{0xc758}=0x1e8a; # capital x with dot above
$chars{0xc759}=0x1e8e; # capital y with dot above
$chars{0xc75a}=0x017b; # capital z with dot above
$chars{0xc761}=0x0227; # small b with dot above
$chars{0xc762}=0x1e03; # small b with dot above
$chars{0xc763}=0x010b; # small c with dot above
$chars{0xc764}=0x1e0b; # small d with dot above
$chars{0xc765}=0x0117; # small e with dot above
$chars{0xc766}=0x1e1f; # small f with dot above
$chars{0xc767}=0x0121; # small g with dot above
$chars{0xc768}=0x1e23; # small h with dot above
$chars{0xc76d}=0x1e41; # small m with dot above
$chars{0xc76e}=0x1e45; # small n with dot above
$chars{0xc770}=0x1e57; # small p with dot above
$chars{0xc772}=0x1e59; # small r with dot above
$chars{0xc773}=0x1e61; # small s with dot above
$chars{0xc774}=0x1e6b; # small t with dot above
$chars{0xc777}=0x1e87; # small w with dot above
$chars{0xc778}=0x1e8b; # small x with dot above
$chars{0xc779}=0x1e8f; # small y with dot above
$chars{0xc77a}=0x017c; # small z with dot above
        # 4/8 trema, diaresis
$chars{0xc820}=0x00a8; # diaeresis
$chars{0xc841}=0x00c4; # capital a with diaeresis
$chars{0xc845}=0x00cb; # capital e with diaeresis
$chars{0xc848}=0x1e26; # capital h with diaeresis
$chars{0xc849}=0x00cf; # capital i with diaeresis
$chars{0xc84f}=0x00d6; # capital o with diaeresis
$chars{0xc855}=0x00dc; # capital u with diaeresis
$chars{0xc857}=0x1e84; # capital w with diaeresis
$chars{0xc858}=0x1e8c; # capital x with diaeresis
$chars{0xc859}=0x0178; # capital y with diaeresis
$chars{0xc861}=0x00e4; # small a with diaeresis
$chars{0xc865}=0x00eb; # small e with diaeresis
$chars{0xc868}=0x1e27; # small h with diaeresis
$chars{0xc869}=0x00ef; # small i with diaeresis
$chars{0xc86f}=0x00f6; # small o with diaeresis
$chars{0xc874}=0x1e97; # small t with diaeresis
$chars{0xc875}=0x00fc; # small u with diaeresis
$chars{0xc877}=0x1e85; # small w with diaeresis
$chars{0xc878}=0x1e8d; # small x with diaeresis
$chars{0xc879}=0x00ff; # small y with diaeresis
        # 4/9 umlaut
$chars{0xc920}=0x00a8; # [diaeresis]
$chars{0xc961}=0x00e4; # a with umlaut 
$chars{0xc965}=0x00eb; # e with umlaut
$chars{0xc969}=0x00ef; # i with umlaut
$chars{0xc96f}=0x00f6; # o with umlaut
$chars{0xc975}=0x00fc; # u with umlaut
        # 4/10 circle above 
$chars{0xca41}=0x00c5; # capital a with ring above
$chars{0xcaad}=0x016e; # capital u with ring above
$chars{0xca61}=0x00e5; # small a with ring above
$chars{0xca75}=0x016f; # small u with ring above
$chars{0xca77}=0x1e98; # small w with ring above
$chars{0xca79}=0x1e99; # small y with ring above
        # 4/11 high comma off centre
        # 4/12 inverted high comma centred
        # 4/13 double acute accent
$chars{0xcd4f}=0x0150; # capital o with double acute
$chars{0xcd55}=0x0170; # capital u with double acute
$chars{0xcd6f}=0x0151; # small o with double acute
$chars{0xcd75}=0x0171; # small u with double acute
        # 4/14 horn
$chars{0xce54}=0x01a0; # latin capital letter o with horn
$chars{0xce55}=0x01af; # latin capital letter u with horn
$chars{0xce74}=0x01a1; # latin small letter o with horn
$chars{0xce75}=0x01b0; # latin small letter u with horn
        # 4/15 caron (hacek
$chars{0xcf41}=0x01cd; # capital a with caron
$chars{0xcf43}=0x010c; # capital c with caron
$chars{0xcf44}=0x010e; # capital d with caron
$chars{0xcf45}=0x011a; # capital e with caron
$chars{0xcf47}=0x01e6; # capital g with caron
$chars{0xcf49}=0x01cf; # capital i with caron
$chars{0xcf4b}=0x01e8; # capital k with caron
$chars{0xcf4c}=0x013d; # capital l with caron
$chars{0xcf4e}=0x0147; # capital n with caron
$chars{0xcf4f}=0x01d1; # capital o with caron
$chars{0xcf52}=0x0158; # capital r with caron
$chars{0xcf53}=0x0160; # capital s with caron
$chars{0xcf54}=0x0164; # capital t with caron
$chars{0xcf55}=0x01d3; # capital u with caron
$chars{0xcf5a}=0x017d; # capital z with caron
$chars{0xcf61}=0x01ce; # small a with caron
$chars{0xcf63}=0x010d; # small c with caron
$chars{0xcf64}=0x010f; # small d with caron
$chars{0xcf65}=0x011b; # small e with caron
$chars{0xcf67}=0x01e7; # small g with caron
$chars{0xcf69}=0x01d0; # small i with caron
$chars{0xcf6a}=0x01f0; # small j with caron
$chars{0xcf6b}=0x01e9; # small k with caron
$chars{0xcf6c}=0x013e; # small l with caron
$chars{0xcf6e}=0x0148; # small n with caron
$chars{0xcf6f}=0x01d2; # small o with caron
$chars{0xcf72}=0x0159; # small r with caron
$chars{0xcf73}=0x0161; # small s with caron
$chars{0xcf74}=0x0165; # small t with caron
$chars{0xcf75}=0x01d4; # small u with caron
$chars{0xcf7a}=0x017e; # small z with caron
        # 5/0 cedilla
$chars{0xd020}=0x00b8; # cedilla
$chars{0xd043}=0x00c7; # capital c with cedilla
$chars{0xd044}=0x1e10; # capital d with cedilla
$chars{0xd047}=0x0122; # capital g with cedilla
$chars{0xd048}=0x1e28; # capital h with cedilla
$chars{0xd04b}=0x0136; # capital k with cedilla
$chars{0xd04c}=0x013b; # capital l with cedilla
$chars{0xd04e}=0x0145; # capital n with cedilla
$chars{0xd052}=0x0156; # capital r with cedilla
$chars{0xd053}=0x015e; # capital s with cedilla
$chars{0xd054}=0x0162; # capital t with cedilla
$chars{0xd063}=0x00e7; # small c with cedilla
$chars{0xd064}=0x1e11; # small d with cedilla
$chars{0xd065}=0x0119; # small e with cedilla
$chars{0xd067}=0x0123; # small g with cedilla
$chars{0xd068}=0x1e29; # small h with cedilla
$chars{0xd06b}=0x0137; # small k with cedilla
$chars{0xd06c}=0x013c; # small l with cedilla
$chars{0xd06e}=0x0146; # small n with cedilla
$chars{0xd072}=0x0157; # small r with cedilla
$chars{0xd073}=0x015f; # small s with cedilla
$chars{0xd074}=0x0163; # small t with cedilla
        # 5/1 rude
        # 5/2 hook to left
        # 5/3 ogonek (hook to right
$chars{0xd320}=0x02db; # ogonek
$chars{0xd341}=0x0104; # capital a with ogonek
$chars{0xd345}=0x0118; # capital e with ogonek
$chars{0xd349}=0x012e; # capital i with ogonek
$chars{0xd34f}=0x01ea; # capital o with ogonek
$chars{0xd355}=0x0172; # capital u with ogonek
$chars{0xd361}=0x0105; # small a with ogonek
$chars{0xd365}=0x0119; # small e with ogonek
$chars{0xd369}=0x012f; # small i with ogonek
$chars{0xd36f}=0x01eb; # small o with ogonek
$chars{0xd375}=0x0173; # small u with ogonek
        # 5/4 circle below
$chars{0xd441}=0x1e00; # capital a with ring below
$chars{0xd461}=0x1e01; # small a with ring below
        # 5/5 half circle below
$chars{0xf948}=0x1e2a; # capital h with breve below
$chars{0xf968}=0x1e2b; # small h with breve below
        # 5/6 dot below
$chars{0xd641}=0x1ea0; # capital a with dot below
$chars{0xd642}=0x1e04; # capital b with dot below
$chars{0xd644}=0x1e0c; # capital d with dot below
$chars{0xd645}=0x1eb8; # capital e with dot below
$chars{0xd648}=0x1e24; # capital h with dot below
$chars{0xd649}=0x1eca; # capital i with dot below
$chars{0xd64b}=0x1e32; # capital k with dot below
$chars{0xd64c}=0x1e36; # capital l with dot below
$chars{0xd64d}=0x1e42; # capital m with dot below
$chars{0xd64e}=0x1e46; # capital n with dot below
$chars{0xd64f}=0x1ecc; # capital o with dot below
$chars{0xd652}=0x1e5a; # capital r with dot below
$chars{0xd653}=0x1e62; # capital s with dot below
$chars{0xd654}=0x1e6c; # capital t with dot below
$chars{0xd655}=0x1ee4; # capital u with dot below
$chars{0xd656}=0x1e7e; # capital v with dot below
$chars{0xd657}=0x1e88; # capital w with dot below
$chars{0xd659}=0x1ef4; # capital y with dot below
$chars{0xd65a}=0x1e92; # capital z with dot below
$chars{0xd661}=0x1ea1; # small a with dot below
$chars{0xd662}=0x1e05; # small b with dot below
$chars{0xd664}=0x1e0d; # small d with dot below
$chars{0xd665}=0x1eb9; # small e with dot below
$chars{0xd668}=0x1e25; # small h with dot below
$chars{0xd669}=0x1ecb; # small i with dot below
$chars{0xd66b}=0x1e33; # small k with dot below
$chars{0xd66c}=0x1e37; # small l with dot below
$chars{0xd66d}=0x1e43; # small m with dot below
$chars{0xd66e}=0x1e47; # small n with dot below
$chars{0xd66f}=0x1ecd; # small o with dot below
$chars{0xd672}=0x1e5b; # small r with dot below
$chars{0xd673}=0x1e63; # small s with dot below
$chars{0xd674}=0x1e6d; # small t with dot below
$chars{0xd675}=0x1ee5; # small u with dot below
$chars{0xd676}=0x1e7f; # small v with dot below
$chars{0xd677}=0x1e89; # small w with dot below
$chars{0xd679}=0x1ef5; # small y with dot below
$chars{0xd67a}=0x1e93; # small z with dot below
        # 5/7 double dot below
$chars{0xd755}=0x1e72; # capital u with diaeresis below
$chars{0xd775}=0x1e73; # small u with diaeresis below
        # 5/8 underline
$chars{0xd820}=0x005f; # underline
        # 5/9 double underline
$chars{0xd920}=0x2017; # double underline
        # 5/10 small low vertical bar
$chars{0xda20}=0x02cc; # 
        # 5/11 circumflex below
        # 5/12 (this position shall not be used)
        # 5/13 left half of ligature sign and of double tilde
        # 5/14 right half of ligature sign
        # 5/15 right half of double tilde
#     map {printf "%x :%x\n",$_,$chars{$_};}keys %chars;

sub char_decode5426 {
    my ( $string) = @_;
    my $result;

    my @data = unpack("C*", $string);
    my @characters;
    my $length=scalar(@data);
    for (my $i = 0; $i < scalar(@data); $i++) {
      my $char= $data[$i];
      if ($char >= 0x00 && $char <= 0x7F){
        #IsAscii
              
          push @characters,$char unless ($char<0x02 ||$char== 0x0F);
      }elsif (($char >= 0xC0 && $char <= 0xDF)) {
        #Combined Char
        my $convchar ;
        if ($chars{$char*256+$data[$i+1]}) {
          $convchar= $chars{$char * 256 + $data[$i+1]};
          $i++;     
#           printf "char %x $char, char to convert %x , converted %x\n",$char,$char * 256 + $data[$i - 1],$convchar;       
        } elsif ($chars{$char})  {
          $convchar= $chars{$char};
#           printf "0xC char %x, converted %x\n",$char,$chars{$char};       
        }else {
          $convchar=$char;
        }     
        push @characters,$convchar;
      } else {
        my $convchar;    
        if ($chars{$char})  {
          $convchar= $chars{$char};
#            printf "char %x,  converted %x\n",$char,$chars{$char};   
        }else {
#            printf "char %x $char\n",$char;   
          $convchar=$char;    
        }  
        push @characters,$convchar;    
      }        
    }
    $result=pack "U*",@characters; 
#     $result=~s/\x01//;  
#     $result=~s/\x00//;  
     $result=~s/\x0f//;  
     $result=~s/\x1b.//;  
     $result=~s/\x0e//;  
     $result=~s/\x1b\x5b//;  
#   map{printf "%x",$_} @characters;  
#   printf "\n"; 
  return $result;
}

1;


=head1 AUTHOR

Koha Development Team <info@koha.org>

Galen Charlton <galen.charlton@liblime.com>

=cut
