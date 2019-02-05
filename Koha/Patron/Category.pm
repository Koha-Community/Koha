package Koha::Patron::Category;

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

use C4::Members::Messaging;

use Koha::Database;
use Koha::DateUtils;

use base qw(Koha::Object);

=head1 NAME

Koha::Patron;;Category - Koha Patron;;Category Object class

=head1 API

=head2 Class Methods

=cut

=head3 effective_BlockExpiredPatronOpacActions

my $BlockExpiredPatronOpacActions = $category->effective_BlockExpiredPatronOpacActions

Return the effective BlockExpiredPatronOpacActions value.

=cut

sub effective_BlockExpiredPatronOpacActions {
    my( $self) = @_;
    return C4::Context->preference('BlockExpiredPatronOpacActions') if $self->BlockExpiredPatronOpacActions == -1;
    return $self->BlockExpiredPatronOpacActions
}

=head3 store

=cut

sub store {
    my ($self) = @_;

    $self->dateofbirthrequired(undef)
      if not defined $self->dateofbirthrequired
      or $self->dateofbirthrequired eq '';

    $self->upperagelimit(undef)
      if not defined $self->upperagelimit
      or $self->upperagelimit eq '';

    $self->checkprevcheckout('inherit')
      unless defined $self->checkprevcheckout;

    return $self->SUPER::store;
}

=head3 default_messaging

my $messaging = $category->default_messaging();

=cut

sub default_messaging {
    my ( $self ) = @_;
    my $messaging_options = C4::Members::Messaging::GetMessagingOptions();
    my @messaging;
    foreach my $option (@$messaging_options) {
        my $pref = C4::Members::Messaging::GetMessagingPreferences(
            {
                categorycode => $self->categorycode,
                message_name => $option->{message_name}
            }
        );
        next unless $pref->{transports};
        my $brief_pref = {
            message_attribute_id      => $option->{message_attribute_id},
            message_name              => $option->{message_name},
            $option->{'message_name'} => 1,
        };
        foreach my $transport ( keys %{ $pref->{transports} } ) {
            push @{ $brief_pref->{transports} }, { transport => $transport };
        }
        push @messaging, $brief_pref;
    }
    return \@messaging;
}

=head3 branch_limitations

my $limitations = $category->branch_limitations();

$category->branch_limitations( \@branchcodes );

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

my $limitations = $category->get_branch_limitations();

=cut

sub get_branch_limitations {
    my ($self) = @_;

    my @branchcodes =
      $self->_catb_resultset->search( { categorycode => $self->categorycode } )
      ->get_column('branchcode')->all();

    return \@branchcodes;
}

=head3 add_branch_limitation

$category->add_branch_limitation( $branchcode );

=cut

sub add_branch_limitation {
    my ( $self, $branchcode ) = @_;

    croak("No branchcode passed in!") unless $branchcode;

    my $limitation = $self->_catb_resultset->update_or_create(
        { categorycode => $self->categorycode, branchcode => $branchcode } );

    return $limitation ? 1 : undef;
}

=head3 del_branch_limitation

$category->del_branch_limitation( $branchcode );

=cut

sub del_branch_limitation {
    my ( $self, $branchcode ) = @_;

    croak("No branchcode passed in!") unless $branchcode;

    my $limitation =
      $self->_catb_resultset->find(
        { categorycode => $self->categorycode, branchcode => $branchcode } );

    unless ($limitation) {
        my $categorycode = $self->categorycode;
        carp(
"No branch limit for branch $branchcode found for categorycode $categorycode to delete!"
        );
        return;
    }

    return $limitation->delete();
}

=head3 replace_branch_limitations

$category->replace_branch_limitations( \@branchcodes );

=cut

sub replace_branch_limitations {
    my ( $self, $branchcodes ) = @_;

    $self->_catb_resultset->search( { categorycode => $self->categorycode } )->delete;

    my @return_values =
      map { $self->add_branch_limitation($_) } @$branchcodes;

    return \@return_values;
}

=head3 Koha::Objects->_catb_resultset

Returns the internal resultset or creates it if undefined

=cut

sub _catb_resultset {
    my ($self) = @_;

    $self->{_catb_resultset} ||=
      Koha::Database->new->schema->resultset('CategoriesBranch');

    return $self->{_catb_resultset};
}

sub get_expiry_date {
    my ($self, $date ) = @_;
    if ( $self->enrolmentperiod ) {
        $date ||= dt_from_string;
        $date = dt_from_string( $date ) unless ref $date;
        return $date->add( months => $self->enrolmentperiod, end_of_month => 'limit' );
    } else {
        return $self->enrolmentperioddate;
    }
}

=head3 effective_reset_password

Returns if patrons in this category can reset their password. If set in $self->reset_password
or, if undef, falls back to the OpacResetPassword system preference.

=cut

sub effective_reset_password {
    my ($self) = @_;

    return ( defined $self->reset_password )
        ? $self->reset_password
        : C4::Context->preference('OpacResetPassword');
}

=head2 Internal methods

=head3 type

=cut

sub _type {
    return 'Category';
}

1;
