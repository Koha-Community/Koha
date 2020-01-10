#!/usr/bin/perl

# Copyright 2019 Koha Development team
#
# This file is part of Koha
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

use Test::More tests => 5;
use Test::Exception;

use Koha::Database;
use Koha::DateUtils qw(dt_from_string);
use Koha::Patrons;
use Koha::Patron::Relationships;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'add_guarantor() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'borrowerRelationship', 'father1|father2' );

    my $patron_1 = $builder->build_object({ class => 'Koha::Patrons' });
    my $patron_2 = $builder->build_object({ class => 'Koha::Patrons' });

    throws_ok
        { $patron_1->add_guarantor({ guarantor_id => $patron_2->borrowernumber }); }
        'Koha::Exceptions::Patron::Relationship::InvalidRelationship',
        'Exception is thrown as no relationship passed';

    is( $patron_1->guarantee_relationships->count, 0, 'No guarantors added' );

    throws_ok
        { $patron_1->add_guarantor({ guarantor_id => $patron_2->borrowernumber, relationship => 'father' }); }
        'Koha::Exceptions::Patron::Relationship::InvalidRelationship',
        'Exception is thrown as a wrong relationship was passed';

    is( $patron_1->guarantee_relationships->count, 0, 'No guarantors added' );

    $patron_1->add_guarantor({ guarantor_id => $patron_2->borrowernumber, relationship => 'father1' });

    my $guarantors = $patron_1->guarantor_relationships;

    is( $guarantors->count, 1, 'No guarantors added' );

    {
        local *STDERR;
        open STDERR, '>', '/dev/null';
        throws_ok
            { $patron_1->add_guarantor({ guarantor_id => $patron_2->borrowernumber, relationship => 'father2' }); }
            'Koha::Exceptions::Patron::Relationship::DuplicateRelationship',
            'Exception is thrown for duplicated relationship';
        close STDERR;
    }

    $schema->storage->txn_rollback;
};

subtest 'relationships_debt() tests' => sub {

    plan tests => 168;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'borrowerRelationship', 'parent' );

    my $parent_1 = $builder->build_object({ class => 'Koha::Patrons' });
    my $parent_2 = $builder->build_object({ class => 'Koha::Patrons' });
    my $child_1 = $builder->build_object({ class => 'Koha::Patrons' });
    my $child_2 = $builder->build_object({ class => 'Koha::Patrons' });

    $child_1->add_guarantor({ guarantor_id => $parent_1->borrowernumber, relationship => 'parent' });
    $child_1->add_guarantor({ guarantor_id => $parent_2->borrowernumber, relationship => 'parent' });
    $child_2->add_guarantor({ guarantor_id => $parent_1->borrowernumber, relationship => 'parent' });
    $child_2->add_guarantor({ guarantor_id => $parent_2->borrowernumber, relationship => 'parent' });

    is( $child_1->guarantor_relationships->guarantors->count, 2, 'Child 1 has correct number of guarantors' );
    is( $child_2->guarantor_relationships->guarantors->count, 2, 'Child 2 has correct number of guarantors' );
    is( $parent_1->guarantee_relationships->guarantees->count, 2, 'Parent 1 has correct number of guarantors' );
    is( $parent_2->guarantee_relationships->guarantees->count, 2, 'Parent 2 has correct number of guarantors' );

    # 3 params, count from 0 to 6 in binary ( 3 places ) to get the set of switches, then do that 4 times, one for each parent and child
    is( $parent_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 1 }), 0, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 1 }), 0, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 1 }), 0, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 1 }), 0, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 1 }), 0, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 1 }), 0, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 1 }), 0, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 1 }), 0, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 1 }), 0, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 1 }), 0, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 1 }), 0, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 1 }), 0, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 1 }), 0, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 1 }), 0, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 1 }), 0, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 1 }), 0, 'Family debt is correct' );

    $child_2->account->add_debit({ type => 'ACCOUNT', amount => 10, interface => 'commandline' });
    is( $child_2->account->non_issues_charges, 10, 'Child 2 owes correct amount' );

    is( $parent_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 1 }), 10, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 1 }), 10, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 1 }), 10, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 1 }), 10, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 1 }), 10, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 1 }), 10, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 1 }), 10, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 1 }), 10, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 1 }), 10, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 1 }), 10, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 1 }), 0, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 1 }), 0, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 1 }), 10, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 1 }), 10, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 1 }), 0, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 1 }), 10, 'Family debt is correct' );

    $parent_1->account->add_debit({ type => 'ACCOUNT', amount => 10, interface => 'commandline' });
    is( $parent_1->account->non_issues_charges, 10, 'Parent 1 owes correct amount' );

    is( $parent_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 1 }), 10, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 1 }), 20, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 1 }), 10, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 1 }), 20, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 1 }), 10, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 0 }), 20, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 1 }), 20, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 1 }), 10, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 1 }), 10, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 1 }), 10, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 0 }), 20, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 1 }), 20, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 1 }), 0, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 1 }), 0, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 1 }), 10, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 1 }), 20, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 1 }), 0, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 1 }), 10, 'Family debt is correct' );

    $parent_2->account->add_debit({ type => 'ACCOUNT', amount => 10, interface => 'commandline' });
    is( $parent_2->account->non_issues_charges, 10, 'Parent 2 owes correct amount' );

    is( $parent_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 1 }), 10, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 0 }), 20, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 1 }), 30, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 1 }), 10, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 1 }), 20, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 1 }), 10, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 0 }), 20, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 1 }), 30, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 1 }), 10, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 1 }), 20, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 1 }), 10, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 0 }), 30, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 1 }), 30, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 1 }), 0, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 1 }), 0, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 1 }), 10, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 0 }), 20, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 1 }), 30, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 1 }), 0, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 1 }), 10, 'Family debt is correct' );

    $child_1->account->add_debit({ type => 'ACCOUNT', amount => 10, interface => 'commandline' });
    is( $child_1->account->non_issues_charges, 10, 'Child 1 owes correct amount' );

    is( $parent_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 0 }), 20, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 1 }), 20, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 0 }), 30, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 1 }), 40, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 0 }), 20, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 1 }), 20, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 0 }), 20, 'Family debt is correct' );
    is( $parent_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 1 }), 30, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 0 }), 20, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 1 }), 20, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 0 }), 30, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 1 }), 40, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 0 }), 20, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 1 }), 20, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 0 }), 20, 'Family debt is correct' );
    is( $parent_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 1 }), 30, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 1 }), 20, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 0 }), 30, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 1 }), 40, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 1 }), 0, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_1->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 1 }), 10, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 0 }), 10, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 0, include_this_patron => 1 }), 20, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 0 }), 30, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 0, include_guarantors => 1, include_this_patron => 1 }), 40, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 0, include_this_patron => 1 }), 0, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 0 }), 0, 'Family debt is correct' );
    is( $child_2->relationships_debt({ only_this_guarantor => 1, include_guarantors => 1, include_this_patron => 1 }), 10, 'Family debt is correct' );

    $schema->storage->txn_rollback;
};

subtest 'add_enrolment_fee_if_needed() tests' => sub {

    plan tests => 2;

    subtest 'category has enrolment fee' => sub {
        plan tests => 7;

        $schema->storage->txn_begin;

        my $category = $builder->build_object(
            {
                class => 'Koha::Patron::Categories',
                value => {
                    enrolmentfee => 20
                }
            }
        );

        my $patron = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => {
                    categorycode => $category->categorycode
                }
            }
        );

        my $enrollment_fee = $patron->add_enrolment_fee_if_needed();
        is( $enrollment_fee * 1, 20, 'Enrolment fee amount is correct' );
        my $account = $patron->account;
        is( $patron->account->balance * 1, 20, 'Patron charged the enrolment fee' );
        # second enrolment fee, new
        $enrollment_fee = $patron->add_enrolment_fee_if_needed(0);
        # third enrolment fee, renewal
        $enrollment_fee = $patron->add_enrolment_fee_if_needed(1);
        is( $patron->account->balance * 1, 60, 'Patron charged the enrolment fees' );

        my @debits = $account->outstanding_debits;
        is( scalar @debits, 3, '3 enrolment fees' );
        is( $debits[0]->debit_type_code, 'ACCOUNT', 'Account type set correctly' );
        is( $debits[1]->debit_type_code, 'ACCOUNT', 'Account type set correctly' );
        is( $debits[2]->debit_type_code, 'ACCOUNT_RENEW', 'Account type set correctly' );

        $schema->storage->txn_rollback;
    };

    subtest 'no enrolment fee' => sub {

        plan tests => 3;

        $schema->storage->txn_begin;

        my $category = $builder->build_object(
            {
                class => 'Koha::Patron::Categories',
                value => {
                    enrolmentfee => 0
                }
            }
        );

        my $patron = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => {
                    categorycode => $category->categorycode
                }
            }
        );

        my $enrollment_fee = $patron->add_enrolment_fee_if_needed();
        is( $enrollment_fee * 1, 0, 'No enrolment fee' );
        my $account = $patron->account;
        is( $patron->account->balance, 0, 'Patron not charged anything' );

        my @debits = $account->outstanding_debits;
        is( scalar @debits, 0, 'no debits' );

        $schema->storage->txn_rollback;
    };
};

subtest 'to_api() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $patron_class = Test::MockModule->new('Koha::Patron');
    $patron_class->mock(
        'algo',
        sub { return 'algo' }
    );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                debarred => undef
            }
        }
    );

    my $restricted = $patron->to_api->{restricted};
    ok( defined $restricted, 'restricted is defined' );
    ok( !$restricted, 'debarred is undef, restricted evaluates to false' );

    $patron->debarred( dt_from_string->add( days => 1 ) )->store->discard_changes;
    $restricted = $patron->to_api->{restricted};
    ok( defined $restricted, 'restricted is defined' );
    ok( $restricted, 'debarred is defined, restricted evaluates to true' );

    my $patron_json = $patron->to_api({ embed => { algo => {} } });
    ok( exists $patron_json->{algo} );
    is( $patron_json->{algo}, 'algo' );

    $schema->storage->txn_rollback;
};

subtest 'login_attempts tests' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
        }
    );
    my $patron_info = $patron->unblessed;
    $patron->delete;
    delete $patron_info->{login_attempts};
    my $new_patron = Koha::Patron->new($patron_info)->store;
    is( $new_patron->discard_changes->login_attempts, 0, "login_attempts defaults to 0 as expected");

    $schema->storage->txn_rollback;
};

subtest 'is_superlibrarian() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',

            value => {
                flags => 16
            }
        }
    );

    is( $patron->is_superlibrarian, 0, 'Patron is not a superlibrarian and the method returns the correct value' );

    $patron->flags(1)->store->discard_changes;
    is( $patron->is_superlibrarian, 1, 'Patron is a superlibrarian and the method returns the correct value' );

    $patron->flags(0)->store->discard_changes;
    is( $patron->is_superlibrarian, 0, 'Patron is not a superlibrarian and the method returns the correct value' );

    $schema->storage->txn_rollback;
};
