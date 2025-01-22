#!/usr/bin/perl

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
use Test::More tests => 19;
use Test::Warn;

use C4::Context;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

use t::lib::Dates;
use t::lib::TestBuilder;
use t::lib::Mocks;

BEGIN {
    use_ok('Koha::Objects');
    use_ok('Koha::Patrons');
}

# Start transaction
my $database = Koha::Database->new();
my $schema   = $database->schema();
$schema->storage->txn_begin();
my $builder = t::lib::TestBuilder->new;

my $categorycode = $builder->build( { source => 'Category' } )->{categorycode};
my $branchcode   = $builder->build( { source => 'Branch' } )->{branchcode};

my $b1 = Koha::Patron->new(
    {
        surname      => 'Test 1',
        branchcode   => $branchcode,
        categorycode => $categorycode
    }
);
$b1->store();
my $now = dt_from_string;
my $b2  = Koha::Patron->new(
    {
        surname      => 'Test 2',
        branchcode   => $branchcode,
        categorycode => $categorycode
    }
);
$b2->store();
my $three_days_ago = dt_from_string->add( days => -3 );
my $b3             = Koha::Patron->new(
    {
        surname      => 'Test 3',
        branchcode   => $branchcode,
        categorycode => $categorycode,
        updated_on   => $three_days_ago,
    }
);
$b3->store();

my $b1_new = Koha::Patrons->find( $b1->borrowernumber() );
is( $b1->surname(), $b1_new->surname(), "Found matching patron" );
isnt( $b1_new->updated_on, undef, "borrowers.updated_on should be set" );
is(
    t::lib::Dates::compare( $b1_new->updated_on, $now ), 0,
    "borrowers.updated_on should have been set to now on creating"
);

my $b3_new = Koha::Patrons->find( $b3->borrowernumber() );
is(
    t::lib::Dates::compare( $b3_new->updated_on, $three_days_ago ), 0,
    "borrowers.updated_on should have been kept to what we set on creating"
);
$b3_new->set( { firstname => 'Some first name for Test 3' } )->store();
$b3_new = Koha::Patrons->find( $b3->borrowernumber() );
is(
    t::lib::Dates::compare( $b3_new->updated_on, $now ), 0,
    "borrowers.updated_on should have been set to now on updating"
);

my @patrons = Koha::Patrons->search( { branchcode => $branchcode } )->as_list;
is( @patrons, 3, "Found 3 patrons with Search" );

my $unexistent = Koha::Patrons->find('1234567890');
is( $unexistent, undef, 'Koha::Objects->Find should return undef if the record does not exist' );

my $patrons = Koha::Patrons->search( { branchcode => $branchcode } );
is( $patrons->count( { branchcode => $branchcode } ), 3, "Counted 3 patrons with Count" );

my $b = $patrons->next();
is( $b->surname(), 'Test 1', "Next returns first patron" );
$b = $patrons->next();
is( $b->surname(), 'Test 2', "Next returns second patron" );
$b = $patrons->next();
is( $b->surname(), 'Test 3', "Next returns third patron" );
$b = $patrons->next();
is( $b, undef, "Next returns undef" );

# Test Reset and iteration in concert
$patrons->reset();
foreach my $b ( $patrons->as_list() ) {
    is( $b->categorycode(), $categorycode, "Iteration returns a patron object" );
}

subtest "Update patron categories" => sub {
    plan tests => 29;
    t::lib::Mocks::mock_preference( 'borrowerRelationship', 'test' );
    my $c_categorycode = $builder->build(
        {
            source => 'Category',
            value  => {
                category_type       => 'C',
                upperagelimit       => 17,
                dateofbirthrequired => 5,
                can_be_guarantee    => 1,
            }
        }
    )->{categorycode};
    my $c_categorycode_2 = $builder->build(
        {
            source => 'Category',
            value  => {
                category_type       => 'C',
                upperagelimit       => 17,
                dateofbirthrequired => 5,
                can_be_guarantee    => 1,
            }
        }
    )->{categorycode};
    my $a_categorycode =
        $builder->build( { source => 'Category', value => { category_type => 'A', can_be_guarantee => 0 } } )
        ->{categorycode};
    my $a_categorycode_2 =
        $builder->build( { source => 'Category', value => { category_type => 'A', can_be_guarantee => 1 } } )
        ->{categorycode};
    my $p_categorycode = $builder->build( { source => 'Category', value => { category_type => 'P' } } )->{categorycode};
    my $i_categorycode = $builder->build( { source => 'Category', value => { category_type => 'I' } } )->{categorycode};
    my $branchcode1    = $builder->build( { source => 'Branch' } )->{branchcode};
    my $branchcode2    = $builder->build( { source => 'Branch' } )->{branchcode};
    my $adult1         = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                categorycode => $a_categorycode,
                branchcode   => $branchcode1,
                dateenrolled => '2018-01-01',
                sort1        => 'quack',
            }
        }
    );
    my $adult2 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                categorycode => $a_categorycode,
                branchcode   => $branchcode2,
                dateenrolled => '2017-01-01',
            }
        }
    );
    my $inst = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                categorycode => $i_categorycode,
                branchcode   => $branchcode2,
            }
        }
    );
    my $prof = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                categorycode => $p_categorycode,
                branchcode   => $branchcode2,
            }
        }
    );
    $prof->add_guarantor( { guarantor_id => $inst->borrowernumber, relationship => 'test' } );
    my $child1 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                dateofbirth  => dt_from_string->add( years => -4 ),
                categorycode => $c_categorycode,
                branchcode   => $branchcode1,
            }
        }
    );
    $child1->add_guarantor( { guarantor_id => $adult1->borrowernumber, relationship => 'test' } );
    my $child2 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                dateofbirth  => dt_from_string->add( years => -8 ),
                categorycode => $c_categorycode,
                branchcode   => $branchcode1,
            }
        }
    );
    $child2->add_guarantor( { guarantor_id => $adult1->borrowernumber, relationship => 'test' } );
    my $child3 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                dateofbirth  => dt_from_string->add( years => -18 ),
                categorycode => $c_categorycode,
                branchcode   => $branchcode1,
            }
        }
    );
    $child3->add_guarantor( { guarantor_id => $adult1->borrowernumber, relationship => 'test' } );
    $builder->build(
        { source => 'Accountline', value => { amountoutstanding => 4.99, borrowernumber => $adult1->borrowernumber } }
    );
    $builder->build(
        { source => 'Accountline', value => { amountoutstanding => 5.01, borrowernumber => $adult2->borrowernumber } }
    );

    is(
        Koha::Patrons->search_patrons_to_update_category( { from => $c_categorycode } )->count, 3,
        'Three patrons in child category'
    );
    is(
        Koha::Patrons->search_patrons_to_update_category( { from => $c_categorycode, too_young => 1 } )->count, 1,
        'One under age patron in child category'
    );
    is( Koha::Patrons->search_patrons_to_update_category( { from => $c_categorycode, too_young => 1 } )
            ->next->borrowernumber, $child1->borrowernumber, 'Under age patron in child category is expected one' );
    is(
        Koha::Patrons->search_patrons_to_update_category( { from => $c_categorycode, too_old => 1 } )->count, 1,
        'One over age patron in child category'
    );
    is( Koha::Patrons->search_patrons_to_update_category( { from => $c_categorycode, too_old => 1 } )
            ->next->borrowernumber, $child3->borrowernumber, 'Over age patron in child category is expected one' );
    is( Koha::Patrons->search( { branchcode => $branchcode2 } )
            ->search_patrons_to_update_category( { from => $a_categorycode } )->count, 1, 'One patron in branch 2' );
    is(
        Koha::Patrons->search( { branchcode => $branchcode2 } )
            ->search_patrons_to_update_category( { from => $a_categorycode } )->next->borrowernumber,
        $adult2->borrowernumber, 'Adult patron in branch 2 is expected one'
    );
    is(
        Koha::Patrons->search_patrons_to_update_category( { from => $a_categorycode, fine_min => 5 } )->count, 1,
        'One patron with fines over $5'
    );
    is( Koha::Patrons->search_patrons_to_update_category( { from => $a_categorycode, fine_min => 5 } )
            ->next->borrowernumber, $adult2->borrowernumber, 'One patron with fines over $5 is expected one' );
    is(
        Koha::Patrons->search_patrons_to_update_category( { from => $a_categorycode, fine_max => 5 } )->count, 1,
        'One patron with fines under $5'
    );
    is( Koha::Patrons->search_patrons_to_update_category( { from => $a_categorycode, fine_max => 5 } )
            ->next->borrowernumber, $adult1->borrowernumber, 'One patron with fines under $5 is expected one' );

    my $adult3 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                categorycode => $a_categorycode,
                branchcode   => $branchcode1,
            }
        }
    );
    is(
        Koha::Patrons->search_patrons_to_update_category( { from => $a_categorycode, fine_max => 5 } )->count, 2,
        'Two patrons with fines under $5, patron with no fine history is found'
    );

    is(
        Koha::Patrons->find( $adult1->borrowernumber )->guarantee_relationships->guarantees->count, 3,
        'Guarantor has 3 guarantees'
    );
    is(
        Koha::Patrons->search_patrons_to_update_category( { from => $c_categorycode } )
            ->update_category_to( { category => $c_categorycode_2 } ), 3,
        'Three child patrons updated to another child category with no params passed'
    );

    # FIXME - The script currently allows you to move patrons to a category that is invalid, this test confirms the current behaviour
    is(
        Koha::Patrons->find( $adult1->borrowernumber )->guarantee_relationships->guarantees->count, 3,
        'Guarantees not removed when made changing child categories'
    );
    is( Koha::Patrons->search_patrons_to_update_category( { from => $c_categorycode_2, too_young => 1 } )
            ->next->borrowernumber, $child1->borrowernumber );
    is(
        Koha::Patrons->search_patrons_to_update_category( { from => $c_categorycode_2, too_young => 1 } )
            ->update_category_to( { category => $a_categorycode } ), 1,
        'One child patron updated to adult category because too young'
    );
    is(
        Koha::Patrons->find( $adult1->borrowernumber )->guarantee_relationships->guarantees->count, 2,
        'Guarantee was removed when made adult'
    );

    is( Koha::Patrons->search_patrons_to_update_category( { from => $c_categorycode_2, too_old => 1 } )
            ->next->borrowernumber, $child3->borrowernumber );
    is(
        Koha::Patrons->search_patrons_to_update_category( { from => $c_categorycode_2, too_old => 1 } )
            ->update_category_to( { category => $a_categorycode } ), 1,
        'One child patron updated to adult category because too old'
    );
    is(
        Koha::Patrons->find( $adult1->borrowernumber )->guarantee_relationships->guarantees->count, 1,
        'Guarantee was removed when made adult'
    );
    is(
        Koha::Patrons->search_patrons_to_update_category( { from => $c_categorycode_2 } )
            ->update_category_to( { category => $a_categorycode_2 } ), 1,
        'Two child patrons updated to adult category'
    );
    is(
        Koha::Patrons->find( $adult1->borrowernumber )->guarantee_relationships->guarantees->count, 1,
        'Guarantees were not removed when made adult which can be guarantee'
    );

    is(
        Koha::Patrons->find( $inst->borrowernumber )->guarantee_relationships->guarantees->count, 1,
        'Guarantor has 1 guarantees'
    );
    is(
        Koha::Patrons->search_patrons_to_update_category( { from => $p_categorycode } )
            ->update_category_to( { category => $a_categorycode } ), 1,
        'One professional patron updated to adult category'
    );
    is(
        Koha::Patrons->find( $inst->borrowernumber )->guarantee_relationships->guarantees->count, 0,
        'Guarantee was removed when made adult'
    );

    is(
        Koha::Patrons->search_patrons_to_update_category( { from => $a_categorycode, fine_max => 5 } )
            ->search( { "me.borrowernumber" => $adult1->borrowernumber } )->next->borrowernumber,
        $adult1->borrowernumber, 'Expected patron is in the list of patrons to update'
    );
    my $userid_before = $adult1->userid;
    ok(
        Koha::Patrons->search_patrons_to_update_category( { from => $a_categorycode, fine_max => 5 } )
            ->update_category_to( { category => $a_categorycode_2 } ),
        'Update of patrons is successful including adult1'
    );
    $adult1->discard_changes;
    is( $adult1->userid, $userid_before, "Patron userid not changed by updated" );
};

$schema->storage->txn_rollback();

