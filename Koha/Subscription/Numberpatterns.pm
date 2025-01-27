package Koha::Subscription::Numberpatterns;

# Copyright 2016 BibLibre Morgane Alonso
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

use Modern::Perl;
use Koha::Database;
use Koha::Subscription::Numberpattern;
use base qw(Koha::Objects);

=head1 NAME

Koha::SubscriptionNumberpatterns - Koha SubscriptionNumberpattern object set class

=head1 API

=head2 Class Methods

=cut

=head3 uniqueLabel

=cut

sub uniqueLabel {
    my ( $self, $label ) = @_;

    my $samelabel = Koha::Subscription::Numberpatterns->search( { label => $label } )->next();
    if ($samelabel) {
        my $i        = 2;
        my $newlabel = $samelabel->label . " ($i)";
        while ( my $othersamelabel = $self->search( { label => $newlabel } )->next() ) {
            $i++;
            $newlabel = $samelabel->label . " ($i)";
        }
        $label = $newlabel;
    }
    return $label;
}

=head3 new_or_existing

=cut

sub new_or_existing {
    my ( $self, $params ) = @_;

    my $params_np;
    if ( $params->{'numbering_pattern'} eq 'mana' ) {
        foreach (
            qw/numberingmethod label1 add1 every1 whenmorethan1 setto1
            numbering1 label2 add2 every2 whenmorethan2 setto2 numbering2
            label3 add3 every3 whenmorethan3 setto3 numbering3/
            )
        {
            $params_np->{$_} = $params->{$_} if $params->{$_};
        }

        my $existing = Koha::Subscription::Numberpatterns->search($params_np)->next();

        if ($existing) {
            return $existing->id;
        }

        $params_np->{label}       = Koha::Subscription::Numberpatterns->uniqueLabel( $params->{'patternname'} );
        $params_np->{description} = $params->{'sndescription'};

        my $subscription_np = Koha::Subscription::Numberpattern->new()->set($params_np)->store();
        return $subscription_np->id;
    }

    return $params->{'numbering_pattern'};
}

=head3 type

=cut

sub _type {
    return 'SubscriptionNumberpattern';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Subscription::Numberpattern';
}

=head1 AUTHOR

Morgane Alonso <morgane.alonso@biblibre.com>

=cut

1;
