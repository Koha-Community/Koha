#!/usr/bin/perl

# Copyright 2016 Oslo Public Library
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

use Test::NoWarnings;
use Test::More tests => 5;
use t::lib::TestBuilder;

use C4::Reserves qw( ReserveSlip );
use C4::Context;
use Koha::Database;
use Koha::Holds;
my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $dbh = C4::Context->dbh;
$dbh->do(q|DELETE FROM letter|);
$dbh->do(q|DELETE FROM reserves|);

my $builder = t::lib::TestBuilder->new();
my $library = $builder->build(
    {
        source => 'Branch',
    }
);

my $patron = $builder->build(
    {
        source => 'Borrower',
        value  => {
            branchcode => $library->{branchcode},
        },
    }
);

my $biblio = $builder->build_sample_biblio;
my $item1  = $builder->build_sample_item(
    {
        biblionumber => $biblio->biblionumber,
        library      => $library->{branchcode},
    }
);
my $item2 = $builder->build_sample_item(
    {
        biblionumber => $biblio->biblionumber,
        library      => $library->{branchcode},
    }
);

my $hold1 = Koha::Hold->new(
    {
        biblionumber   => $biblio->biblionumber,
        itemnumber     => $item1->itemnumber,
        waitingdate    => '2000-01-01',
        borrowernumber => $patron->{borrowernumber},
        branchcode     => $library->{branchcode},
    }
)->store;

my $hold2 = Koha::Hold->new(
    {
        biblionumber   => $biblio->biblionumber,
        itemnumber     => $item2->itemnumber,
        waitingdate    => '2000-01-01',
        borrowernumber => $patron->{borrowernumber},
        branchcode     => $library->{branchcode},
    }
)->store;

my $letter = $builder->build(
    {
        source => 'Letter',
        value  => {
            module     => 'circulation',
            code       => 'HOLD_SLIP',
            lang       => 'default',
            branchcode => $library->{branchcode},
            content    =>
                'Hold found for <<borrowers.firstname>>: Please pick up <<biblio.title>> with barcode <<items.barcode>> at <<branches.branchcode>>.',
            message_transport_type => 'email',
        },
    }
);

is( ReserveSlip(), undef, "No hold slip returned if invalid or undef borrowernumber and/or biblionumber" );
is(
    ReserveSlip(
        {
            branchcode => $library->{branchcode},
            reserve_id => $hold1->reserve_id,
        }
    )->{code},
    'HOLD_SLIP',
    "Get a hold slip from library, patron and biblio"
);

is(
    ReserveSlip(
        {
            branchcode => $library->{branchcode},
            reserve_id => $hold1->reserve_id,
        }
    )->{content},
    sprintf(
        "Hold found for %s: Please pick up %s with barcode %s at %s.", $patron->{firstname}, $biblio->title,
        $item1->barcode, $library->{branchcode}
    ),
    "Hold slip contains correctly parsed content"
);

subtest 'title level hold' => sub {
    plan tests => 2;

    my $biblio = $builder->build_sample_biblio;
    my $item   = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            library      => $library->{branchcode},
        }
    );
    my $hold = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                branchcode     => $library->{branchcode},
                borrowernumber => $patron->{borrowernumber},
                biblionumber   => $biblio->id,
                itemnumber     => undef,
            }
        }
    );

    my $slip = ReserveSlip(
        {
            branchcode => $hold->branchcode,
            reserve_id => $hold->id,
            itemnumber => $item->id
        }
    );
    is( $slip->{code}, 'HOLD_SLIP', "We get expected letter" );
    is(
        $slip->{content},
        sprintf(
            "Hold found for %s: Please pick up %s with barcode %s at %s.", $patron->{firstname}, $biblio->title,
            $item->barcode, $library->{branchcode}
        ),
        "Hold slip contents correctly use the passed item"
    );
};

$schema->storage->txn_rollback;

1;
