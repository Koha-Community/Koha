package Koha::REST::V1::IssuingRule;

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

use Mojo::Base 'Mojolicious::Controller';

use C4::Circulation;

use Koha::IssuingRules;
use Koha::Items;
use Koha::ItemTypes;
use Koha::Libraries;
use Koha::Patron::Categories;
use Koha::Patrons;

use Koha::Exceptions;
use Koha::Exceptions::Category;
use Koha::Exceptions::ItemType;
use Koha::Exceptions::Library;
use Koha::Exceptions::Patron;

use Try::Tiny;

sub get_effective {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $params = $c->req->query_params->to_hash;

        my ($categorycode, $itemtype, $branchcode, $ccode, $permanent_location,
            $sub_location, $genre, $circulation_level, $reserve_level);
        my $user      = $c->stash('koha.user');
        my $patron    = _find_patron($params);
        my $item      = _find_item($params);
        $categorycode = _find_categorycode($params, $patron);
        $itemtype     = _find_itemtype($params, $item);
        $branchcode   = _find_branchcode($params, $item, $patron, $user);
        $ccode        = _find_ccode($params, $item);
        $permanent_location = _find_permanent_location($params, $item);
        $sub_location = _find_sub_location($params, $item);
        $genre        = _find_genre($params, $item);
        $circulation_level = _find_circulation_level($params, $item);
        $reserve_level = _find_reserve_level($params, $item);

        my $rule = Koha::IssuingRules->get_effective_issuing_rule({
            categorycode => $categorycode,
            itemtype     => $itemtype,
            branchcode   => $branchcode,
            ccode        => $ccode,
            permanent_location => $permanent_location,
            sub_location => $sub_location,
            genre        => $genre,
            circulation_level => $circulation_level,
            reserve_level => $reserve_level,
        });

        return $c->render(status => 200, openapi => $rule);
    }
    catch {
        if ($_->isa('Koha::Exceptions::BadParameter')) {
            return $c->render(status => 400, openapi => { error => $_->error });
        }
        elsif ($_->isa('Koha::Exceptions::Category::CategorycodeNotFound')) {
            return $c->render(status => 404, openapi => { error => $_->error });
        }
        elsif ($_->isa('Koha::Exceptions::Item::NotFound')) {
            return $c->render(status => 404, openapi => { error => $_->error });
        }
        elsif ($_->isa('Koha::Exceptions::ItemType::NotFound')) {
            return $c->render(status => 404, openapi => { error => $_->error });
        }
        elsif ($_->isa('Koha::Exceptions::Library::BranchcodeNotFound')) {
            return $c->render(status => 404, openapi => { error => $_->error });
        }
        elsif ($_->isa('Koha::Exceptions::Patron::NotFound')) {
            return $c->render(status => 404, openapi => { error => $_->error });
        }
        Koha::Exceptions::rethrow_exception($_);
    };
}

sub _find_branchcode {
    my ($params, $item, $patron, $loggedin_user) = @_;

    my $circcontrol = C4::Context->preference('CircControl');
    my $branchcode;
    if ($circcontrol eq 'PatronLibrary' && defined $patron
        && !length $params->{branchcode}) {
        $branchcode = C4::Circulation::_GetCircControlBranch(
            undef,
            $patron->unblessed
        );
    } elsif ($circcontrol eq 'ItemHomeLibrary' && defined $item
             && !length $params->{branchcode}) {
        $branchcode = C4::Circulation::_GetCircControlBranch(
            $item->unblessed,
            undef
        );
    } elsif ($circcontrol eq 'PickupLibrary' && !exists $params->{branchcode}) {
        # If CircControl == PickupLibrary, expect currently logged in branch
        # to be the homebranch of logged in user ONLY IF parameter branchcode
        # is not provided - if the parameter exists but is not defined, allow
        # the possibility to query with null branchcode
        $branchcode = $loggedin_user->branchcode;
    }

    return $branchcode if $branchcode;

    if (length $params->{branchcode}) {
        my $library = Koha::Libraries->find($params->{branchcode});
        unless ($library) {
            Koha::Exceptions::Library::BranchcodeNotFound->throw(
                error => 'Branchcode not found'
            );
        }
        $branchcode = $library->branchcode;
    }

    return $branchcode;

}

sub _find_categorycode {
    my ($params, $patron) = @_;

    my $categorycode;
    if (defined $patron && length $params->{categorycode}) {
        unless ($patron->categorycode eq $params->{categorycode}) {
            Koha::Exceptions::BadParameter->throw(
                error => "Patron's categorycode does not match given categorycode"
            );
        }
    }

    return $patron->categorycode if $patron;

    if (length $params->{categorycode}) {
        my $category = Koha::Patron::Categories->find($params->{categorycode});
        unless ($category) {
            Koha::Exceptions::Category::CategorycodeNotFound->throw(
                error => 'Categorycode not found'
            );
        }
        $categorycode = $category->categorycode;
    }

    return $categorycode;
}

sub _find_circulation_level {
    my ($params, $item) = @_;

    if (defined $item && length $params->{circulation_level}) {
        unless ($item->circulation_level eq $params->{circulation_level}) {
            Koha::Exceptions::BadParameter->throw(
                error => "Item's circulation level does not match given level"
            );
        }
    }

    return $item->circulation_level if $item;

    return $params->{circulation_level};
}

sub _find_ccode {
    my ($params, $item) = @_;

    my $ccode;
    if (defined $item && length $params->{ccode}) {
        unless ($item->ccode eq $params->{ccode}) {
            Koha::Exceptions::BadParameter->throw(
                error => "Item's ccode does not match given ccode"
            );
        }
    }

    return $item->ccode if $item;

    return $params->{ccode};
}

sub _find_genre {
    my ($params, $item) = @_;

    my $ccode;
    if (defined $item && length $params->{genre}) {
        unless ($item->genre eq $params->{genre}) {
            Koha::Exceptions::BadParameter->throw(
                error => "Item's genre does not match given genre"
            );
        }
    }

    return $item->genre if $item;

    return $params->{genre};
}

sub _find_item {
    my ($params) = @_;

    my $item;
    if (length $params->{itemnumber} && length $params->{barcode}) {
        $item = Koha::Items->find({
            itemnumber  => $params->{itemnumber},
            barcode     => $params->{barcode},
        });
    } elsif (length $params->{itemnumber}) {
        $item = Koha::Items->find($params->{itemnumber});
    } elsif (length $params->{barcode}) {
        $item = Koha::Items->find({
            barcode => $params->{barcode}
        });
    }

    if ((length $params->{itemnumber} || length $params->{barcode})
        && !defined $item) {
        Koha::Exceptions::Item::NotFound->throw(
            error => 'Item not found'
        );
    }

    return $item;
}

sub _find_itemtype {
    my ($params, $item) = @_;

    my $itemtype;
    if (defined $item && length $params->{itemtype}) {
        unless ($item->effective_itemtype eq $params->{itemtype}) {
            Koha::Exceptions::BadParameter->throw(
                error => "Item's item type does not match given item type"
            );
        }
    }

    return $item->effective_itemtype if $item;

    if (length $params->{itemtype}) {
        my $itemtype_o = Koha::ItemTypes->find($params->{itemtype});
        unless ($itemtype_o) {
            Koha::Exceptions::ItemType::NotFound->throw(
                error => 'Item type not found'
            );
        }
        $itemtype = $itemtype_o->itemtype;
    }

    return $itemtype;
}

sub _find_patron {
    my ($params) = @_;

    my $patron;
    if (length $params->{borrowernumber} && length $params->{cardnumber}) {
        $patron = Koha::Patrons->find({
            borrowernumber => $params->{borrowernumber},
            cardnumber     => $params->{cardnumber},
        });
    } elsif (length $params->{borrowernumber}) {
        $patron = Koha::Patrons->find($params->{borrowernumber});
    } elsif (length $params->{cardnumber}) {
        $patron = Koha::Patrons->find({
            cardnumber => $params->{cardnumber}
        });
    }

    if ((length $params->{borrowernumber} || length $params->{cardnumber})
        && !defined $patron) {
        Koha::Exceptions::Patron::NotFound->throw(
            error => 'Patron not found'
        );
    }

    return $patron;
}

sub _find_permanent_location {
    my ($params, $item) = @_;

    my $permanent_location;
    if (defined $item && length $params->{permanent_location}) {
        unless ($item->permanent_location eq $params->{permanent_location}) {
            Koha::Exceptions::BadParameter->throw(
                error => "Item's permanent location does not match given location"
            );
        }
    }

    return $item->permanent_location if $item;

    return $params->{permanent_location};
}

sub _find_reserve_level {
    my ($params, $item) = @_;

    if (defined $item && length $params->{reserve_level}) {
        unless ($item->reserve_level eq $params->{reserve_level}) {
            Koha::Exceptions::BadParameter->throw(
                error => "Item's reserve level does not match given level"
            );
        }
    }

    return $item->reserve_level if $item;

    return $params->{reserve_level};
}

sub _find_sub_location {
    my ($params, $item) = @_;

    my $permanent_location;
    if (defined $item && length $params->{sub_location}) {
        unless ($item->sub_location eq $params->{sub_location}) {
            Koha::Exceptions::BadParameter->throw(
                error => "Item's sub location does not match given location"
            );
        }
    }

    return $item->sub_location if $item;

    return $params->{sub_location};
}

1;
