package C4::Heading::UNIMARC;

# Copyright (C) 2011 C & P Bibliography Services
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

use 5.010;
use strict;
use warnings;
use MARC::Record;
use MARC::Field;
use C4::Context;

our $VERSION = 3.07.00.049;

=head1 NAME

C4::Heading::UNIMARC

=head1 SYNOPSIS

use C4::Heading::UNIMARC;

=head1 DESCRIPTION

This is an internal helper class used by
C<C4::Heading> to parse headings data from
UNIMARC records.  Object of this type
do not carry data, instead, they only
dispatch functions.

=head1 DATA STRUCTURES

FIXME - this should be moved to a configuration file.

=head2 subdivisions

=cut

my %subdivisions = (
    'j' => 'formsubdiv',
    'x' => 'generalsubdiv',
    'y' => 'chronologicalsubdiv',
    'z' => 'geographicsubdiv',
);

my $bib_heading_fields;

=head1 METHODS

=head2 new

  my $marc_handler = C4::Heading::UNIMARC->new();

=cut

sub new {
    my $class = shift;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(
        "SELECT tagfield, authtypecode
         FROM marc_subfield_structure
         WHERE frameworkcode = '' AND authtypecode <> ''"
    );
    $sth->execute();
    $bib_heading_fields = {};
    while ( my ( $tag, $auth_type ) = $sth->fetchrow ) {
        $bib_heading_fields->{$tag} = {
            auth_type => $auth_type,
            subfields => 'abcdefghjklmnopqrstvxyz',
        };
    }

    return bless {}, $class;
}

=head2 valid_bib_heading_tag

=cut

sub valid_bib_heading_tag {
    my ( $self, $tag ) = @_;
    return $bib_heading_fields->{$tag};
}

=head2 parse_heading

=cut

sub parse_heading {
    my ( $self, $field ) = @_;

    my $tag        = $field->tag;
    my $field_info = $bib_heading_fields->{$tag};
    my $auth_type  = $field_info->{'auth_type'};
    my $search_heading =
      _get_search_heading( $field, $field_info->{'subfields'} );
    my $display_heading =
      _get_display_heading( $field, $field_info->{'subfields'} );

    return ( $auth_type, undef, $search_heading, $display_heading, 'exact' );
}

=head1 INTERNAL FUNCTIONS

=head2 _get_subject_thesaurus

=cut

sub _get_subject_thesaurus {
    my $field = shift;

    my $thesaurus = "notdefined";
    my $sf2       = $field->subfield('2');
    $thesaurus = $sf2 if defined($sf2);

    return $thesaurus;
}

=head2 _get_search_heading

=cut

sub _get_search_heading {
    my $field     = shift;
    my $subfields = shift;

    my $heading   = "";
    my @subfields = $field->subfields();
    my $first     = 1;
    for ( my $i = 0 ; $i <= $#subfields ; $i++ ) {
        my $code    = $subfields[$i]->[0];
        my $code_re = quotemeta $code;
        my $value   = $subfields[$i]->[1];
        $value =~ s/[-,.:=;!%\/]*$//;
        next unless $subfields =~ qr/$code_re/;
        if ($first) {
            $first   = 0;
            $heading = $value;
        }
        else {
            $heading .= " $value";
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

    my $heading   = "";
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

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

Jared Camins-Esakov <jcamins@cpbibliography.com>

=cut

1;
