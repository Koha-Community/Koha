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

use Test::More tests => 6;
use Test::Exception;

use t::lib::TestBuilder;

use Digest::MD5 qw( md5_base64 md5_hex );
use Try::Tiny;

use C4::Context;
use C4::Members;
use C4::Members::Attributes qw( GetBorrowerAttributes );
use Koha::Patrons;

BEGIN {
    use_ok('Koha::Patron::Modification');
    use_ok('Koha::Patron::Modifications');
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'new() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    Koha::Patron::Modifications->search->delete;

    # Create new pending modification
    Koha::Patron::Modification->new(
        {   verification_token => '1234567890',
            surname            => 'Hall',
            firstname          => 'Kyle'
        }
    )->store();

    ## Get the new pending modification
    my $borrower = Koha::Patron::Modifications->find(
        { verification_token => '1234567890' } );

    ## Verify we get the same data
    is( $borrower->surname, 'Hall',
        'Found modification has matching surname' );

    throws_ok {
        Koha::Patron::Modification->new(
            {   verification_token => '1234567890',
                surname            => 'Hall',
                firstname          => 'Daria'
            }
        )->store();
    }
    'Koha::Exceptions::Patron::Modification::DuplicateVerificationToken',
        'Attempting to add a duplicate verification raises the correct exception';
    is( $@,
        'Duplicate verification token 1234567890',
        'Exception carries the right message'
    );

    $schema->storage->txn_rollback;
};

subtest 'store( extended_attributes ) tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    Koha::Patron::Modifications->search->delete;

    my $patron
        = $builder->build( { source => 'Borrower' } )->{borrowernumber};
    my $verification_token = md5_hex( time().{}.rand().{}.$$ );
    my $valid_json_text    = '[{"code":"CODE","value":"VALUE"}]';
    my $invalid_json_text  = '[{"code":"CODE";"value":"VALUE"}]';

    Koha::Patron::Modification->new(
        {   verification_token  => $verification_token,
            borrowernumber      => $patron,
            surname             => 'Hall',
            extended_attributes => $valid_json_text
        }
    )->store();

    my $patron_modification
        = Koha::Patron::Modifications->search( { borrowernumber => $patron } )
        ->next;

    is( $patron_modification->surname,
        'Hall', 'Patron modification correctly stored with valid JSON data' );
    is( $patron_modification->extended_attributes,
        $valid_json_text,
        'Patron modification correctly stored with valid JSON data' );

    $verification_token = md5_hex( time().{}.rand().{}.$$ );
    throws_ok {
        Koha::Patron::Modification->new(
            {   verification_token  => $verification_token,
                borrowernumber      => $patron,
                surname             => 'Hall',
                extended_attributes => $invalid_json_text
            }
        )->store();
    }
    'Koha::Exceptions::Patron::Modification::InvalidData',
        'Trying to store invalid JSON in extended_attributes field raises exception';

    is( $@, 'The passed extended_attributes is not valid JSON' );

    $schema->storage->txn_rollback;
};

subtest 'approve tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    Koha::Patron::Modifications->search->delete;

    my $patron_hashref = $builder->build( { source => 'Borrower' } );
    $builder->build(
        { source => 'BorrowerAttributeType', value => { code => 'CODE_1' } }
    );
    $builder->build(
        { source => 'BorrowerAttributeType', value => { code => 'CODE_2' } }
    );
    my $verification_token = md5_hex( time().{}.rand().{}.$$ );
    my $valid_json_text
        = '[{"code":"CODE_1","value":"VALUE_1"},{"code":"CODE_2","value":"VALUE_2"}]';
    my $patron_modification = Koha::Patron::Modification->new(
        {   borrowernumber      => $patron_hashref->{borrowernumber},
            firstname           => 'Kyle',
            verification_token  => $verification_token,
            extended_attributes => $valid_json_text
        }
    )->store();

    ok( $patron_modification->approve,
        'Patron modification correctly approved' );
    my $patron = Koha::Patrons->find( $patron_hashref->{borrowernumber} );
    isnt(
        $patron->firstname,
        $patron_hashref->{firstname},
        'Patron modification changed firstname'
    );
    is( $patron->firstname, 'Kyle',
        'Patron modification set the right firstname' );
    my @patron_attributes = GetBorrowerAttributes( $patron->borrowernumber );
    is( $patron_attributes[0][0]->{code},
        'CODE_1', 'Patron modification correctly saved attribute code' );
    is( $patron_attributes[0][0]->{value},
        'VALUE_1', 'Patron modification correctly saved attribute value' );

    # Create a new Koha::Patron::Modification, skip extended_attributes to
    # bypass checks
    $patron_modification = Koha::Patron::Modification->new(
        {   borrowernumber     => $patron_hashref->{borrowernumber},
            firstname          => 'Kylie',
            verification_token => $verification_token
        }
    )->store();

    # Add invalid JSON to extended attributes
    $patron_modification->extended_attributes(
        '[{"code":"CODE";"values:VALUES"}]');
    throws_ok { $patron_modification->approve }
    'Koha::Exceptions::Patron::Modification::InvalidData',
        'The right exception is thrown if invalid data is on extended_attributes';

    $patron = Koha::Patrons->find( $patron_hashref->{borrowernumber} );
    isnt( $patron->firstname, 'Kylie', 'Patron modification didn\'t apply' );

    $schema->storage->txn_rollback;
};

subtest 'pending_count() and pending() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    Koha::Patron::Modifications->search->delete;
    my $library_1 = $builder->build( { source => 'Branch' } )->{branchcode};
    my $library_2 = $builder->build( { source => 'Branch' } )->{branchcode};
    my $patron_1
        = $builder->build(
        { source => 'Borrower', value => { branchcode => $library_1 } } )
        ->{borrowernumber};
    my $patron_2
        = $builder->build(
        { source => 'Borrower', value => { branchcode => $library_2 } } )
        ->{borrowernumber};
    my $patron_3
        = $builder->build(
        { source => 'Borrower', value => { branchcode => $library_2 } } )
        ->{borrowernumber};
    my $verification_token_1 = md5_hex( time().{}.rand().{}.$$ );
    my $verification_token_2 = md5_hex( time().{}.rand().{}.$$ );
    my $verification_token_3 = md5_hex( time().{}.rand().{}.$$ );


    my $modification_1 = Koha::Patron::Modification->new(
        {   borrowernumber     => $patron_1,
            surname            => 'Hall',
            firstname          => 'Kyle',
            verification_token => $verification_token_1
        }
    )->store();

    is( Koha::Patron::Modifications->pending_count,
        1, 'pending_count() correctly returns 1' );

    my $modification_2 = Koha::Patron::Modification->new(
        {   borrowernumber     => $patron_2,
            surname            => 'Smith',
            firstname          => 'Sandy',
            verification_token => $verification_token_2
        }
    )->store();

    my $modification_3 = Koha::Patron::Modification->new(
        {   borrowernumber     => $patron_3,
            surname            => 'Smith',
            firstname          => 'Sandy',
            verification_token => $verification_token_3
        }
    )->store();

    is( Koha::Patron::Modifications->pending_count,
        3, 'pending_count() correctly returns 3' );

    is( Koha::Patron::Modifications->pending_count($library_1),
        1, 'pending_count() correctly returns 1 if filtered by library' );

    is( Koha::Patron::Modifications->pending_count($library_2),
        2, 'pending_count() correctly returns 2 if filtered by library' );

    $modification_1->approve;

    is( Koha::Patron::Modifications->pending_count,
        2, 'pending_count() correctly returns 2' );

    $modification_2->approve;

    is( Koha::Patron::Modifications->pending_count,
        1, 'pending_count() correctly returns 1' );

    $modification_3->approve;

    is( Koha::Patron::Modifications->pending_count,
        0, 'pending_count() correctly returns 0' );

    $schema->storage->txn_rollback;
};

1;
