package C4::Heading;

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
use MARC::Record;
use MARC::Field;
use C4::Context;
use Module::Load;
use Carp;

our $VERSION = 3.07.00.049;

=head1 NAME

C4::Heading

=head1 SYNOPSIS

 use C4::Heading;
 my $heading = C4::Heading->new_from_bib_field($field, $frameworkcode);
 my $thesaurus = $heading->thesaurus();
 my $type = $heading->type();
 my $display_heading = $heading->display_form();
 my $search_form = $heading->search_form();

=head1 DESCRIPTION

C<C4::Heading> implements a simple class to representing
headings found in bibliographic and authority records.

=head1 METHODS

=head2 new_from_bib_field

  my $heading = C4::Heading->new_from_bib_field($field, $frameworkcode, [, $marc_flavour]);

Given a C<MARC::Field> object containing a heading from a 
bib record, create a C<C4::Heading> object.

The optional second parameter is the MARC flavour (i.e., MARC21
or UNIMARC); if this parameter is not supplied, it is
taken from the Koha application context.

If the MARC field supplied is not a valid heading, undef
is returned.

=cut

sub new_from_bib_field {
    my $class         = shift;
    my $field         = shift;
    my $frameworkcode = shift;
    my $marcflavour   = @_ ? shift : C4::Context->preference('marcflavour');

    my $marc_handler = _marc_format_handler($marcflavour);

    my $tag = $field->tag();
    return unless $marc_handler->valid_bib_heading_tag( $tag, $frameworkcode );
    my $self = {};

    $self->{'field'} = $field;
    (
        $self->{'auth_type'},   $self->{'thesaurus'},
        $self->{'search_form'}, $self->{'display_form'},
        $self->{'match_type'}
    ) = $marc_handler->parse_heading($field);

    bless $self, $class;
    return $self;
}

=head2 auth_type

  my $auth_type = $heading->auth_type();

Return the auth_type of the heading.

=cut

sub auth_type {
    my $self = shift;
    return $self->{'auth_type'};
}

=head2 field

  my $field = $heading->field();

Return the MARC::Field the heading is based on.

=cut

sub field {
    my $self = shift;
    return $self->{'field'};
}

=head2 display_form

  my $display = $heading->display_form();

Return the "canonical" display form of the heading.

=cut

sub display_form {
    my $self = shift;
    return $self->{'display_form'};
}

=head2 search_form

  my $search_form = $heading->search_form();

Return the "canonical" search form of the heading.

=cut

sub search_form {
    my $self = shift;
    return $self->{'search_form'};
}

=head2 authorities

  my $authorities = $heading->authorities([$skipmetadata]);

Return a list of authority records for this 
heading. If passed a true value for $skipmetadata,
SearchAuthorities will return only authids.

=cut

sub authorities {
    my $self         = shift;
    my $skipmetadata = shift;
    my ( $results, $total ) = _search( $self, 'match-heading', $skipmetadata );
    return $results;
}

=head2 preferred_authorities

  my $preferred_authorities = $heading->preferred_authorities;

Return a list of authority records for headings
that are a preferred form of the heading.

=cut

sub preferred_authorities {
    my $self = shift;
    my $skipmetadata = shift || undef;
    my ( $results, $total ) = _search( 'see-from', $skipmetadata );
    return $results;
}

=head1 INTERNAL METHODS

=head2 _search

=cut

sub _search {
    my $self         = shift;
    my $index        = shift || undef;
    my $skipmetadata = shift || undef;
    my @marclist;
    my @and_or;
    my @excluding = [];
    my @operator;
    my @value;

    if ($index) {
        push @marclist, $index;
        push @and_or,   'and';
        push @operator, $self->{'match_type'};
        push @value,    $self->{'search_form'};
    }

    #    if ($self->{'thesaurus'}) {
    #        push @marclist, 'thesaurus';
    #        push @and_or, 'and';
    #        push @excluding, '';
    #        push @operator, 'is';
    #        push @value, $self->{'thesaurus'};
    #    }
    require C4::AuthoritiesMarc;
    return C4::AuthoritiesMarc::SearchAuthorities(
        \@marclist, \@and_or, \@excluding, \@operator,
        \@value,    0,        20,          $self->{'auth_type'},
        'AuthidAsc',         $skipmetadata
    );
}

=head1 INTERNAL FUNCTIONS

=head2 _marc_format_handler

Returns a C4::Heading::MARC21 or C4::Heading::UNIMARC object
depending on the selected MARC flavour.

=cut

sub _marc_format_handler {
    my $marcflavour = uc shift;
    $marcflavour = 'MARC21' if ( $marcflavour eq 'NORMARC' );
    my $pname = "C4::Heading::$marcflavour";
    load $pname;
    return $pname->new();
}

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

Galen Charlton <galen.charlton@liblime.com>

=cut

1;
