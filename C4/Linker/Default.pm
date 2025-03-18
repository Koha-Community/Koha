package C4::Linker::Default;

# Copyright 2011 C & P Bibliography Services
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
use C4::Heading;

use base qw(C4::Linker);

=head1 Functions

=cut

=head2 get_link

Missing POD for get_link.

=cut

sub get_link {
    my $self        = shift;
    my $heading     = shift;
    my $behavior    = shift || 'default';
    my $search_form = $heading->search_form();
    my $auth_type   = $heading->auth_type();
    my $thesaurus   = $heading->{thesaurus} || 'notdefined';
    $thesaurus = 'notconsidered' unless C4::Context->preference('LinkerConsiderThesaurus');
    my $authid;
    my $fuzzy = 0;
    my $match_count;

    if ( $self->{'cache'}->{ $search_form . $auth_type . $thesaurus }->{'cached'} ) {
        $authid      = $self->{'cache'}->{ $search_form . $auth_type . $thesaurus }->{'authid'};
        $fuzzy       = $self->{'cache'}->{ $search_form . $auth_type . $thesaurus }->{'fuzzy'};
        $match_count = $self->{'cache'}->{ $search_form . $auth_type . $thesaurus }->{'match_count'};
    } else {

        # look for matching authorities
        my $authorities = $heading->authorities(1);    # $skipmetadata = true
        $match_count = scalar @$authorities;

        if ( $behavior eq 'default' && $#{$authorities} == 0 ) {
            $authid = $authorities->[0]->{'authid'};
        } elsif ( $behavior eq 'first' && $#{$authorities} >= 0 ) {
            $authid = $authorities->[0]->{'authid'};
            $fuzzy  = $#{$authorities} > 0;
        } elsif ( $behavior eq 'last' && $#{$authorities} >= 0 ) {
            $authid = $authorities->[ $#{$authorities} ]->{'authid'};
            $fuzzy  = $#{$authorities} > 0;
        }

        if ( !defined $authid && $self->{'broader_headings'} ) {
            my $field     = $heading->field();
            my @subfields = grep { $_->[0] ne '9' } $field->subfields();
            if ( scalar @subfields > 1 ) {
                pop @subfields;
                $field = MARC::Field->new(
                    $field->tag,
                    $field->indicator(1),
                    $field->indicator(2),
                    map { $_->[0] => $_->[1] } @subfields
                );
                ( $authid, $fuzzy ) = $self->get_link(
                    C4::Heading->new_from_field($field),
                    $behavior
                );
            }
        }

        $self->{'cache'}->{ $search_form . $auth_type . $thesaurus }->{'cached'}      = 1;
        $self->{'cache'}->{ $search_form . $auth_type . $thesaurus }->{'authid'}      = $authid;
        $self->{'cache'}->{ $search_form . $auth_type . $thesaurus }->{'fuzzy'}       = $fuzzy;
        $self->{'cache'}->{ $search_form . $auth_type . $thesaurus }->{'match_count'} = $match_count;
    }
    return $self->SUPER::_handle_auth_limit($authid), $fuzzy, $match_count;
}

=head2 update_cache

Missing POD for update_cache.

=cut

sub update_cache {
    my $self        = shift;
    my $heading     = shift;
    my $authid      = shift;
    my $search_form = $heading->search_form();
    my $auth_type   = $heading->auth_type();
    my $thesaurus   = $heading->{thesaurus} || 'notdefined';
    $thesaurus = 'notconsidered' unless C4::Context->preference('LinkerConsiderThesaurus');
    my $fuzzy = 0;

    $self->{'cache'}->{ $search_form . $auth_type . $thesaurus }->{'cached'} = 1;
    $self->{'cache'}->{ $search_form . $auth_type . $thesaurus }->{'authid'} = $authid;
    $self->{'cache'}->{ $search_form . $auth_type . $thesaurus }->{'fuzzy'}  = $fuzzy;
}

=head2 flip_heading

Missing POD for flip_heading.

=cut

sub flip_heading {
    my $self    = shift;
    my $heading = shift;

    # TODO: implement
}

1;
__END__

=head1 NAME

C4::Linker::Default - match only if there is a single matching auth

=cut
