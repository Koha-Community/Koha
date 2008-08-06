package C4::Heading::MARC21;

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
use MARC::Record;
use MARC::Field;

our $VERSION = 3.00;

=head1 NAME

C4::Heading::MARC21

=head1 SYNOPSIS

use C4::Heading::MARC21;

=head1 DESCRIPTION

This is an internal helper class used by
C<C4::Heading> to parse headings data from
MARC21 records.  Object of this type
do not carry data, instead, they only
dispatch functions.

=head1 DATA STRUCTURES

FIXME - this should be moved to a configuration file.

=head2 bib_heading_fields

=cut

my $bib_heading_fields = {
    '100' => { auth_type => 'PERSO_NAME', subfields => 'abcdefghjklmnopqrst', main_entry => 1 },
    '110' => { auth_type => 'CORPO_NAME', subfields => 'abcdefghklmnoprst', main_entry => 1 },
    '111' => { auth_type => 'MEETI_NAME', subfields => 'acdefghjklnpqst', main_entry => 1 },
    '130' => { auth_type => 'UNIF_TITLE', subfields => 'adfghklmnoprst', main_entry => 1 },
    '440' => { auth_type => 'UNIF_TITLE', subfields => 'anp', series => 1 },
    '600' => { auth_type => 'PERSO_NAME', subfields => 'abcdefghjklmnopqrstvxyz', subject => 1 },
    '610' => { auth_type => 'CORPO_NAME', subfields => 'abcdefghklmnoprstvxyz', subject => 1 },
    '611' => { auth_type => 'MEETI_NAME', subfields => 'acdefghjklnpqstvxyz', subject => 1 },
    '630' => { auth_type => 'UNIF_TITLE', subfields => 'adfghklmnoprstvxyz', subject => 1 },
    '648' => { auth_type => 'CHRON_TERM', subfields => 'avxyz', subject => 1 },
    '650' => { auth_type => 'TOPIC_TERM', subfields => 'abvxyz', subject => 1 },
    '651' => { auth_type => 'GEOGR_NAME', subfields => 'avxyz', subject => 1 },
    '655' => { auth_type => 'GENRE/FORM', subfields => 'avxyz', subject => 1 },
    '700' => { auth_type => 'PERSO_NAME', subfields => 'abcdefghjklmnopqrst' },
    '710' => { auth_type => 'CORPO_NAME', subfields => 'abcdefghklmnoprst' },
    '711' => { auth_type => 'MEETI_NAME', subfields => 'acdefghjklnpqst' },
    '730' => { auth_type => 'UNIF_TITLE', subfields => 'adfghklmnoprst' },
    '800' => { auth_type => 'PERSO_NAME', subfields => 'abcdefghjklmnopqrst', series => 1 },
    '810' => { auth_type => 'CORPO_NAME', subfields => 'abcdefghklmnoprst', series => 1 },
    '811' => { auth_type => 'MEETI_NAME', subfields => 'acdefghjklnpqst', series => 1 },
    '830' => { auth_type => 'UNIF_TITLE', subfields => 'adfghklmnoprst', series => 1 },
};

=head2 subdivisions

=cut

my %subdivisions = (
    'v' => 'formsubdiv',
    'x' => 'generalsubdiv',
    'y' => 'chronologicalsubdiv',
    'z' => 'geographicsubdiv',
);

=head1 METHODS

=head2 new

=over 4

my $marc_handler = C4::Heading::MARC21->new();

=back

=cut

sub new {
    my $class = shift;
    return bless {}, $class;
}

=head2 valid_bib_heading_tag

=cut

sub valid_bib_heading_tag {
    my $self = shift;
    my $tag = shift;

    if (exists $bib_heading_fields->{$tag}) {
        return 1
    } else {
        return 0;
    }

}

=head2 parse_heading

=cut

sub parse_heading {
    my $self = shift;
    my $field = shift;

    my $tag = $field->tag;
    my $field_info = $bib_heading_fields->{$tag};

    my $auth_type = $field_info->{'auth_type'};
    my $subject = $field_info->{'subject'} ? 1 : 0;
    my $series = $field_info->{'series'} ? 1 : 0;
    my $main_entry = $field_info->{'main_entry'} ? 1 : 0;
    my $thesaurus = $subject ? _get_subject_thesaurus($field) : "lcsh"; # use 'lcsh' for names, UT, etc.
    my $search_heading = _get_search_heading($field, $field_info->{'subfields'});
    my $display_heading = _get_display_heading($field, $field_info->{'subfields'});

    return ($auth_type, $subject, $series, $main_entry, $thesaurus, $search_heading, $display_heading);
}

=head1 INTERNAL FUNCTIONS

=head2 _get_subject_thesaurus

=cut

sub _get_subject_thesaurus {
    my $field = shift;
    my $ind2 = $field->indicator(2);

    my $thesaurus = "notdefined";
    if ($ind2 eq '0') {
        $thesaurus = "lcsh";
    } elsif ($ind2 eq '1') {
        $thesaurus = "lcac";
    } elsif ($ind2 eq '2') {
        $thesaurus = "mesh";
    } elsif ($ind2 eq '3') {
        $thesaurus = "nal";
    } elsif ($ind2 eq '4') {
        $thesaurus = "notspecified";
    } elsif ($ind2 eq '5') {
        $thesaurus = "cash";
    } elsif ($ind2 eq '6') {
        $thesaurus = "rvm";
    } elsif ($ind2 eq '7') {
        my $sf2 = $field->subfield('2');
        $thesaurus = $sf2 if defined($sf2);
    }

    return $thesaurus;
}

=head2 _get_search_heading

=cut

sub _get_search_heading {
    my $field = shift;
    my $subfields = shift;

    my $heading = "";
    my @subfields = $field->subfields();
    my $first = 1;
    for (my $i = 0; $i <= $#subfields; $i++) {
        my $code = $subfields[$i]->[0];
        my $code_re = quotemeta $code;
        my $value = $subfields[$i]->[1];
        next unless $subfields =~ qr/$code_re/;
        if ($first) {
            $first = 0;
            $heading = $value;
        } else {
            if (exists $subdivisions{$code}) {
                $heading .= " $subdivisions{$code} $value";
            } else {
                $heading .= " $value";
            }
        }
    }

    # remove characters that are part of CCL syntax
    $heading =~ s/[)(=]//g;

    return $heading;
}

=head2 _get_display_heading

=cut

sub _get_display_heading {
    my $field = shift;
    my $subfields = shift;

    my $heading = "";
    my @subfields = $field->subfields();
    my $first = 1;
    for (my $i = 0; $i <= $#subfields; $i++) {
        my $code = $subfields[$i]->[0];
        my $code_re = quotemeta $code;
        my $value = $subfields[$i]->[1];
        next unless $subfields =~ qr/$code_re/;
        if ($first) {
            $first = 0;
            $heading = $value;
        } else {
            if (exists $subdivisions{$code}) {
                $heading .= "--$value";
            } else {
                $heading .= " $value";
            }
        }
    }
    return $heading;
}

=head1 AUTHOR

Koha Developement team <info@koha.org>

Galen Charlton <galen.charlton@liblime.com>

=cut

1;
