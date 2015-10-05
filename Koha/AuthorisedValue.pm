package Koha::AuthorisedValue;

# Copyright ByWater Solutions 2014
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Carp;

use Koha::Database;

use base qw(Koha::Object);

=head1 NAME

Koha::AuthorisedValue - Koha Authorised value Object class

=head1 API

=head2 Class Methods

=cut

=head3 branch_limitations

my $limitations = $av->branch_limitations();

$av->branch_limitations( \@branchcodes );

=cut

sub branch_limitations {
    my ( $self, $branchcodes ) = @_;

    if ($branchcodes) {
        return $self->replace_branch_limitations($branchcodes);
    }
    else {
        return $self->get_branch_limitations();
    }

}

=head3 get_branch_limitations

my $limitations = $av->get_branch_limitations();

=cut

sub get_branch_limitations {
    my ($self) = @_;

    my @branchcodes =
      $self->_avb_resultset->search( { av_id => $self->id() } )
      ->get_column('branchcode')->all();

    return \@branchcodes;
}

=head3 add_branch_limitation

$av->add_branch_limitation( $branchcode );

=cut

sub add_branch_limitation {
    my ( $self, $branchcode ) = @_;

    croak("No branchcode passed in!") unless $branchcode;

    my $limitation = $self->_avb_resultset->update_or_create(
        { av_id => $self->id(), branchcode => $branchcode } );

    return $limitation ? 1 : undef;
}

=head3 del_branch_limitation

$av->del_branch_limitation( $branchcode );

=cut

sub del_branch_limitation {
    my ( $self, $branchcode ) = @_;

    croak("No branchcode passed in!") unless $branchcode;

    my $limitation =
      $self->_avb_resultset->find(
        { av_id => $self->id(), branchcode => $branchcode } );

    unless ($limitation) {
        my $id = $self->id();
        carp(
"No branch limit for branch $branchcode found for av_id $id to delete!"
        );
        return;
    }

    return $limitation->delete();
}

=head3 replace_branch_limitations

$av->replace_branch_limitations( \@branchcodes );

=cut

sub replace_branch_limitations {
    my ( $self, $branchcodes ) = @_;

    $self->_avb_resultset->search( { av_id => $self->id() } )->delete();

    my @return_values =
      map { $self->add_branch_limitation($_) } @$branchcodes;

    return \@return_values;
}

=head3 lib_opac

my $description = $av->lib_opac();

$av->lib_opac( $description );

=cut

sub opac_description {
    my ( $self, $value ) = @_;

    return $self->lib_opac() || $self->lib();
}

=head3 Koha::Objects->_avb_resultset

Returns the internal resultset or creates it if undefined

=cut

sub _avb_resultset {
    my ($self) = @_;

    $self->{_avb_resultset} ||=
      Koha::Database->new()->schema()->resultset('AuthorisedValuesBranch');

    $self->{_avb_resultset};
}

=head3 type

=cut

sub _type {
    return 'AuthorisedValue';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
