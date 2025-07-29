package C4::Heading::MARC21;

# Copyright (C) 2008 LibLime
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

use strict;
use warnings;
use MARC::Field;


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
    '100' => {
        auth_type  => 'PERSO_NAME',
        subfields  => 'abcdfghjklmnopqrst',
        main_entry => 1
    },
    '110' => {
        auth_type  => 'CORPO_NAME',
        subfields  => 'abcdfghklmnoprst',
        main_entry => 1
    },
    '111' => {
        auth_type  => 'MEETI_NAME',
        subfields  => 'acdefghklnpqst',
        main_entry => 1
    },
    '130' => {
        auth_type  => 'UNIF_TITLE',
        subfields  => 'adfghklmnoprst',
        main_entry => 1
    },
    '147' => {
        auth_type => 'NAME_EVENT',
        subfields => 'acdgvxyz68',
        main_entry => 1
    },
    '148' => {
        auth_type => 'CHRON_TERM',
        subfields => 'abvxyz68',
        main_entry => 1
    },
    '150' => {
        auth_type => 'TOPIC_TERM',
        subfields => 'abgvxyz68',
        main_entry => 1
    },
    '151' => {
        auth_type => 'GEOGR_NAME',
        subfields => 'agvxyz68',
        main_entry => 1
    },
    '155' => {
        auth_type => 'GENRE/FORM',
        subfields => 'abvxyz68',
        main_entry => 1
    },
    '162' => {
        auth_type => 'MED_PERFRM',
        subfields => 'a68',
        main_entry => 1
    },
    '180' => {
        auth_type => 'TOPIC_TERM',
        subfields => 'vxyz68'
    },
    '181' => {
        auth_type => 'GEOGR_NAME',
        subfields => 'vxyz68'
    },
    '182' => {
        auth_type => 'CHRON_TERM',
        subfields => 'vxyz68'
    },
    '185' => {
        auth_type => 'GENRE/FORM',
        subfields => 'vxyz68'
    },
    '240' => {
        auth_type  => 'UNIF_TITLE',
        subfields  => 'adfghklmnoprst',
    },
    '380' => { auth_type => 'GENRE/FORM', subfields => 'a',  subject => 1 },
    '385' => { auth_type => 'TOPIC_TERM', subfields => 'a',  subject => 1 },
    '386' => { auth_type => 'GENRE/FORM', subfields => 'a',  subject => 1 },
    '388' => { auth_type => 'CHRON_TERM', subfields => 'a',  subject => 1 },
    '440' => { auth_type => 'UNIF_TITLE', subfields => 'anp', series => 1 },
    '600' => {
        auth_type => 'PERSO_NAME',
        subfields => 'abcdfghjklmnopqrstvxyz',
        subject   => 1
    },
    '610' => {
        auth_type => 'CORPO_NAME',
        subfields => 'abcdfghklmnoprstvxyz',
        subject   => 1
    },
    '611' => {
        auth_type => 'MEETI_NAME',
        subfields => 'acdefghklnpqstvxyz',
        subject   => 1
    },
    '630' => {
        auth_type => 'UNIF_TITLE',
        subfields => 'adfghklmnoprstvxyz',
        subject   => 1
    },
    '648' => { auth_type => 'CHRON_TERM', subfields => 'avxyz',  subject => 1 },
    '650' => { auth_type => 'TOPIC_TERM', subfields => 'abvxyz', subject => 1 },
    '651' => { auth_type => 'GEOGR_NAME', subfields => 'agvxyz', subject => 1 },
    '655' => { auth_type => 'GENRE/FORM', subfields => 'avxyz',  subject => 1 },
    '658' => { auth_type => 'TOPIC_TERM', subfields => 'a',  subject => 1 },
    '690' => { auth_type => 'TOPIC_TERM', subfields => 'abvxyz', subject => 1 },
    '691' => { auth_type => 'GEOGR_NAME', subfields => 'avxyz',  subject => 1 },
    '696' => { auth_type => 'PERSO_NAME', subfields => 'abcdfghjklmnopqrst' },
    '697' => { auth_type => 'CORPO_NAME', subfields => 'abcdfghklmnoprst' },
    '698' => { auth_type => 'MEETI_NAME', subfields => 'acdfghjklnpqst' },
    '699' => { auth_type => 'UNIF_TITLE', subfields => 'adfghklmnoprst' },
    '700' => { auth_type => 'PERSO_NAME', subfields => 'abcdfghjklmnopqrst' },
    '710' => { auth_type => 'CORPO_NAME', subfields => 'abcdfghklmnoprst' },
    '711' => { auth_type => 'MEETI_NAME', subfields => 'acdefghklnpqst' },
    '730' => { auth_type => 'UNIF_TITLE', subfields => 'adfghklmnoprst' },
    '800' => {
        auth_type => 'PERSO_NAME',
        subfields => 'abcdfghjklmnopqrst',
        series    => 1
    },
    '810' => {
        auth_type => 'CORPO_NAME',
        subfields => 'abcdfghklmnoprst',
        series    => 1
    },
    '811' =>
      { auth_type => 'MEETI_NAME', subfields => 'acdefghklnpqst', series => 1 },
    '830' =>
      { auth_type => 'UNIF_TITLE', subfields => 'adfghklmnoprst', series => 1 },
};

my $auth_heading_fields = {
    '100' => {
        auth_type  => 'PERSO_NAME',
        subfields  => 'abcdfghjklmnopqrstvxyz68',
        main_entry => 1
    },
    '110' => {
        auth_type  => 'CORPO_NAME',
        subfields  => 'abcdfghklmnoprstvxyz68',
        main_entry => 1
    },
    '111' => {
        auth_type  => 'MEETI_NAME',
        subfields  => 'acdefghklnpqstvxyz68',
        main_entry => 1
    },
    '130' => {
        auth_type  => 'UNIF_TITLE',
        subfields  => 'adfghklmnoprstvxyz68',
        main_entry => 1
    },
    '147' => {
        auth_type  => 'NAME_EVENT',
        subfields  => 'acdgvxyz68',
        main_entry => 1
    },
    '148' => {
        auth_type  => 'CHRON_TERM',
        subfields  => 'abvxyz68',
        main_entry => 1
    },
    '150' => {
        auth_type  => 'TOPIC_TERM',
        subfields  => 'abgvxyz68',
        main_entry => 1
    },
    '151' => {
        auth_type  => 'GEOGR_NAME',
        subfields  => 'agvxyz68',
        main_entry => 1
    },
    '155' => {
        auth_type  => 'GENRE/FORM',
        subfields  => 'abvxyz68',
        main_entry => 1
    },
    '162' => {
        auth_type  => 'MED_PERFRM',
        subfields  => 'a68',
        main_entry => 1
    },
    '180' => {
        auth_type => 'TOPIC_TERM',
        subfields => 'vxyz68',
    },
    '181' => {
        auth_type => 'GEOGR_NAME',
        subfields => 'vxyz68',
    },
    '182' => {
        auth_type => 'CHRON_TERM',
        subfields => 'vxyz68',
    },
    '185' => {
        auth_type => 'GENRE/FORM',
        subfields => 'vxyz68',
    },
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

  my $marc_handler = C4::Heading::MARC21->new();

=cut

sub new {
    my $class = shift;
    return bless {}, $class;
}

=head2 valid_heading_tag

=cut

sub valid_heading_tag {
    my $self          = shift;
    my $tag           = shift;
    my $frameworkcode = shift;
    my $auth          = shift;
    my $heading_fields = $auth ? { %$auth_heading_fields } : { %$bib_heading_fields };

    if ( exists $heading_fields->{$tag} ) {
        return 1;
    }
    else {
        return 0;
    }

}

=head2 valid_heading_subfield

=cut

sub valid_heading_subfield {
    my $self          = shift;
    my $tag           = shift;
    my $subfield      = shift;
    my $auth          = shift;

    my $heading_fields = $auth ? { %$auth_heading_fields } : { %$bib_heading_fields };

    if ( exists $heading_fields->{$tag} ) {
        return 1 if ($heading_fields->{$tag}->{subfields} =~ /$subfield/);
    }
    return 0;
}

=head2 get_valid_bib_heading_subfields

=cut

sub get_valid_bib_heading_subfields {
    my $self          = shift;
    my $tag           = shift;

    return $bib_heading_fields->{$tag}->{subfields} // undef;
}

=head2 get_auth_heading_subfields_to_report

=cut

sub get_auth_heading_subfields_to_report {
    my $self          = shift;
    my $tag           = shift;

    my $subfields = $auth_heading_fields->{$tag}->{subfields} // '';
    $subfields =~ s/[68]//;
    return $subfields;
}

=head2 parse_heading

Given a field and an indicator to specify if it is an authority field or biblio field we return
the correct type, thesauarus, search form, and display form of the heading.

=cut

sub parse_heading {
    my $self  = shift;
    my $field = shift;
    my $auth  = shift;

    my $tag        = $field->tag;
    my $heading_fields = $auth ? { %$auth_heading_fields } : { %$bib_heading_fields };

    my $field_info = $heading_fields->{$tag};
    my $auth_type = $field_info->{'auth_type'};
    my $thesaurus =
      $tag =~ m/6../
      ? _get_subject_thesaurus($field)
      : undef;    # We can't know the thesaurus for non-subject fields
    my $search_heading =
      _get_search_heading( $field, $field_info->{'subfields'} );
    my $display_heading =
      _get_display_heading( $field, $field_info->{'subfields'} );
    return ( $auth_type, $thesaurus, $search_heading, $display_heading,
        'exact' );
}

=head1 INTERNAL FUNCTIONS

=head2 _get_subject_thesaurus

=cut

sub _get_subject_thesaurus {
    my $field = shift;
    my $ind2  = $field->indicator(2);

    # NOTE: sears and aat do not appear
    # here as they do not have indicator values
    # though the 008 in the authority records
    # do have values for them

    my $thesaurus = "notdefined";
    if ( $ind2 eq '0' ) {
        $thesaurus = "lcsh";
    }
    elsif ( $ind2 eq '1' ) {
        $thesaurus = "lcac";
    }
    elsif ( $ind2 eq '2' ) {
        $thesaurus = "mesh";
    }
    elsif ( $ind2 eq '3' ) {
        $thesaurus = "nal";
    }
    elsif ( $ind2 eq '4' ) {
        $thesaurus = "notspecified";
    }
    elsif ( $ind2 eq '5' ) {
        $thesaurus = "cash";
    }
    elsif ( $ind2 eq '6' ) {
        $thesaurus = "rvm";
    }
    elsif ( $ind2 eq '7' ) {
        my $sf2 = $field->subfield('2');
        $thesaurus = $sf2 if defined($sf2);
    }

    return $thesaurus;
}

=head2 _get_search_heading

=cut

sub _get_search_heading {
    my $field     = shift;
    my $subfields = shift;

    my $heading = "";
    return $heading unless $subfields;

    my @subfields = $field->subfields();
    my $first     = 1;
    for ( my $i = 0 ; $i <= $#subfields ; $i++ ) {
        my $code    = $subfields[$i]->[0];
        my $code_re = quotemeta $code;
        my $value   = $subfields[$i]->[1];
        $value =~ s/[\s]*[-,.:=;!%\/]*[\s]*$//;
        next unless $subfields =~ qr/$code_re/;
        if ($first) {
            $first   = 0;
            $heading = $value;
        }
        else {
            if ( exists $subdivisions{$code} ) {
                $heading .= " $subdivisions{$code} $value";
            }
            else {
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
    my $field     = shift;
    my $subfields = shift;

    my $heading = "";
    return $heading unless $subfields;

    my @subfields = $field->subfields();
    my $first     = 1;
    for ( my $i = 0 ; $i <= $#subfields ; $i++ ) {
        my $code    = $subfields[$i]->[0];
        my $code_re = quotemeta $code;
        my $value   = $subfields[$i]->[1];
        next unless $subfields =~ qr/$code_re/;
        if ($first) {
            $first   = 0;
            $heading = $value;
        }
        else {
            if ( exists $subdivisions{$code} ) {
                $heading .= "--$value";
            }
            else {
                $heading .= " $value";
            }
        }
    }
    return $heading;
}

# Additional limiters that we aren't using:
#    if ($self->{'subject_added_entry'}) {
#        $limiters .= " AND Heading-use-subject-added-entry=a";
#    }
#    if ($self->{'series_added_entry'}) {
#        $limiters .= " AND Heading-use-series-added-entry=a";
#    }
#    if (not $self->{'subject_added_entry'} and not $self->{'series_added_entry'}) {
#        $limiters .= " AND Heading-use-main-or-added-entry=a"
#    }

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

Galen Charlton <galen.charlton@liblime.com>

=cut

1;
