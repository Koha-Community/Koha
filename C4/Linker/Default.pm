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
use Carp;
use MARC::Field;
use C4::Heading;

use base qw(C4::Linker);

sub get_link {
    my $self        = shift;
    my $heading     = shift;
    my $behavior    = shift || 'default';
    my $search_form = $heading->search_form();
    my $authid;
    my $fuzzy = 0;

    if ( $self->{'cache'}->{$search_form}->{'cached'} ) {
        $authid = $self->{'cache'}->{$search_form}->{'authid'};
        $fuzzy  = $self->{'cache'}->{$search_form}->{'fuzzy'};
    }
    else {

        # look for matching authorities
        my $authorities = $heading->authorities(1);    # $skipmetadata = true

        if ( $behavior eq 'default' && $#{$authorities} == 0 ) {
            $authid = $authorities->[0]->{'authid'};
        }
        elsif ( $behavior eq 'first' && $#{$authorities} >= 0 ) {
            $authid = $authorities->[0]->{'authid'};
            $fuzzy  = $#{$authorities} > 0;
        }
        elsif ( $behavior eq 'last' && $#{$authorities} >= 0 ) {
            $authid = $authorities->[ $#{$authorities} ]->{'authid'};
            $fuzzy  = $#{$authorities} > 0;
        }

        if ( !defined $authid && $self->{'broader_headings'} ) {
            my $field     = $heading->field();
            my @subfields = grep { $_->[0] ne '9' } $field->subfields();
            if ( scalar @subfields > 1 ) {
                pop @subfields;
                $field =
                    MARC::Field->new(
                        $field->tag,
                        $field->indicator(1),
                        $field->indicator(2),
                        map { $_->[0] => $_->[1] } @subfields
                    );
                ( $authid, $fuzzy ) =
                  $self->get_link( C4::Heading->new_from_bib_field($field),
                    $behavior );
            }
        }

        $self->{'cache'}->{$search_form}->{'cached'} = 1;
        $self->{'cache'}->{$search_form}->{'authid'} = $authid;
        $self->{'cache'}->{$search_form}->{'fuzzy'}  = $fuzzy;
    }
    return $self->SUPER::_handle_auth_limit($authid), $fuzzy;
}

sub update_cache {
    my $self        = shift;
    my $heading     = shift;
    my $authid      = shift;
    my $search_form = $heading->search_form();
    my $fuzzy = 0;

    $self->{'cache'}->{$search_form}->{'cached'} = 1;
    $self->{'cache'}->{$search_form}->{'authid'} = $authid;
    $self->{'cache'}->{$search_form}->{'fuzzy'}  = $fuzzy;
}

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
