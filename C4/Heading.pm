package C4::Heading;

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
use C4::Context;
use C4::Heading::MARC21;
use C4::Search;

our $VERSION = 3.00;

=head1 NAME

C4::Heading

=head1 SYNOPSIS

use C4::Heading;
my $heading = C4::Heading->new_from_bib_field($field);
my $thesaurus = $heading->thesaurus();
my $type = $heading->type();
my $display_heading = $heading->display();
my $search_string = $heading->search_string();

=head1 DESCRIPTION

C<C4::Heading> implements a simple class to representing
headings found in bibliographic and authority records.

=head1 METHODS

=head2 new_from_bib_field

=over 4

my $heading = C4::Heading->new_from_bib_field($field[, $marc_flavour]);

=back

Given a C<MARC::Field> object containing a heading from a 
bib record, create a C<C4::Heading> object.

The optional second parameter is the MARC flavour (i.e., MARC21
or UNIMARC); if this parameter is not supplied, it is
taken from the Koha application context.

If the MARC field supplied is not a valid heading, undef
is returned.

=cut

sub new_from_bib_field {
    my $class = shift;
    my $field = shift;
    my $marcflavour = @_ ? shift : C4::Context->preference('marcflavour');

    my $marc_handler = _marc_format_handler($marcflavour);

    my $tag = $field->tag();
    return unless $marc_handler->valid_bib_heading_tag($tag);
    my $self = {};
   
    ($self->{'auth_type'}, $self->{'subject_added_entry'}, $self->{'series_added_entry'}, $self->{'main_entry'},
     $self->{'thesaurus'}, $self->{'search_form'}, $self->{'display_form'}) =
        $marc_handler->parse_heading($field);

    bless $self, $class;
    return $self;
}

=head2 display_form

=over 4

my $display = $heading->display_form();

=back

Return the "canonical" display form of the heading.

=cut

sub display_form {
    my $self = shift;
    return $self->{'display_form'};
}

=head2 authorities

=over 4

my $authorities = $heading->authorities;

=back

Return a list of authority records for this 
heading.

=cut

sub authorities {
    my $self = shift;
    my $query = qq(Match-heading,ext="$self->{'search_form'}");
    $query .= $self->_query_limiters();
    my ($error, $results, $total_hits) = SimpleSearch( $query, undef, undef, [ "authorityserver" ] );
    return $results;
}

=head2 preferred_authorities

=over 4

my $preferred_authorities = $heading->preferred_authorities;

=back

Return a list of authority records for headings
that are a preferred form of the heading.

=cut

sub preferred_authorities {
    my $self = shift;
    my $query = "Match-heading-see-from,ext='$self->{'search_form'}'";
    $query .= $self->_query_limiters();
    my ($error, $results, $total_hits) = SimpleSearch( $query, undef, undef, [ "authorityserver" ] );
    return $results;
}

=head1 INTERNAL METHODS

=head2 _query_limiters

=cut

sub _query_limiters {
    my $self = shift;

    my $limiters = " AND at='$self->{'auth_type'}'";
    if ($self->{'subject_added_entry'}) {
        $limiters .= " AND Heading-use-subject-added-entry=a"; # FIXME -- is this properly in C4::Heading::MARC21?
        $limiters .= " AND Subject-heading-thesaurus=$self->{'thesaurus'}";
    }
    if ($self->{'series_added_entry'}) {
        $limiters .= " AND Heading-use-series-added-entry=a"; # FIXME -- is this properly in C4::Heading::MARC21?
    }
    if (not $self->{'subject_added_entry'} and not $self->{'series_added_entry'}) {
        $limiters .= " AND Heading-use-main-or-added-entry=a" # FIXME -- is this properly in C4::Heading::MARC21?
    }
    return $limiters;
}

=head1 INTERNAL FUNCTIONS

=head2 _marc_format_handler

Returns a C4::Heading::MARC21 or C4::Heading::UNIMARC object
depending on the selected MARC flavour.

=cut

sub _marc_format_handler {
    my $marcflavour = shift;

    if ($marcflavour eq 'UNIMARC') {
        return C4::Heading::UNIMARC->new();
    } else {
        return C4::Heading::MARC21->new();
    }

}

=head1 AUTHOR

Koha Developement team <info@koha.org>

Galen Charlton <galen.charlton@liblime.com>

=cut

1;
