package Koha::Patron::HouseboundVisits;

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

use Koha::Database;
use Koha::Patron::HouseboundVisit;

use base qw(Koha::Objects);

=head1 NAME

Koha::Patron::HouseboundVisits - Koha Patron HouseboundVisits Object class

=head1 SYNOPSIS

HouseboundVisits class used primarily by members/housebound.pl.

=head1 DESCRIPTION

Standard Koha::Objects definitions, and additional methods.

=head1 API

=head2 Class Methods

=cut

=head3 special_search;

   my @houseboundVisits = Koha::HouseboundVisits->special_search($params, $attributes);

Perform a search for housebound visits.  This method overrides standard search
to prefetch deliverers and choosers as we always need them anyway.

If $attributes contains a prefetch entry, we defer to it, otherwise we add the
prefetch attribute and also augment $params with explicit 'me.' prefixes.

This is intended to make search behave as most people would expect it to
behave.

Should the user want to do complicated searches involving joins, without
specifying their own prefetch, the naive 'me.' augmentation will break in
hilarious ways.  In this case the user should supply their own prefetch
clause.

=cut

sub special_search {
    my ( $self, $params, $attributes ) = @_;
    unless (exists $attributes->{prefetch}) {
        # No explicit prefetch has been passed in -> automatic optimisation.
        $attributes->{prefetch} = [
            'chooser_brwnumber', 'deliverer_brwnumber'
        ];
        # So we must ensure our $params use the 'me.' prefix.
        my $oldparams = $params;
        $params = {};
        while (my ($k, $v) = each %{$oldparams}) {
            if ($k =~ /^me\..*/) {
                $params->{$k} = $v;
            } else {
                $params->{"me." . $k} = $v;
            }
        }
    }
    $self->SUPER::search($params, $attributes);
}

=head3 _type

=cut

sub _type {
    return 'HouseboundVisit';
}

sub object_class {
    return 'Koha::Patron::HouseboundVisit';
}

1;

=head1 AUTHOR

Alex Sassmannshausen <alex.sassmannshausen@ptfs-europe.com>

=cut
