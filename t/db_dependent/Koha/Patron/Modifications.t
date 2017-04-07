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

use utf8;

use Test::More tests => 6;
use Test::Exception;

use t::lib::TestBuilder;

use Digest::MD5 qw( md5_base64 md5_hex );
use Try::Tiny;

use C4::Context;
use C4::Members;
use C4::Members::Attributes qw( GetBorrowerAttributes );
use Koha::Patrons;
use Koha::Patron::Attribute;

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

    plan tests => 20;

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
        = '[{"code":"CODE_1","value":"VALUE_1"},{"code":"CODE_2","value":0}]';
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
    is( $patron_attributes[0][1]->{code},
        'CODE_2', 'Patron modification correctly saved attribute code' );
    is( $patron_attributes[0][1]->{value},
        0, 'Patron modification correctly saved attribute with value 0, not confused with delete' );

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

    # Try changing only a portion of the attributes
    my $bigger_json
        = '[{"code":"CODE_2","value":"Tomasito"},{"code":"CODE_2","value":"None"}]';
    $verification_token = md5_hex( time() . {} . rand() . {} . $$ );

    $patron_modification = Koha::Patron::Modification->new(
        {   borrowernumber      => $patron->borrowernumber,
            extended_attributes => $bigger_json,
            verification_token  => $verification_token
        }
    )->store();
    ok( $patron_modification->approve,
        'Patron modification correctly approved' );
    @patron_attributes
        = map { $_->unblessed }
        Koha::Patron::Attributes->search(
        { borrowernumber => $patron->borrowernumber } );

    is( $patron_attributes[0]->{code},
        'CODE_1', 'Untouched attribute type is preserved (code)' );
    is( $patron_attributes[0]->{attribute},
        'VALUE_1', 'Untouched attribute type is preserved (attribute)' );

    is( $patron_attributes[1]->{code},
        'CODE_2', 'Attribute updated correctly (code)' );
    is( $patron_attributes[1]->{attribute},
        'Tomasito', 'Attribute updated correctly (attribute)' );

    is( $patron_attributes[2]->{code},
        'CODE_2', 'Attribute updated correctly (code)' );
    is( $patron_attributes[2]->{attribute},
        'None', 'Attribute updated correctly (attribute)' );

    my $empty_code_json = '[{"code":"CODE_2","value":""}]';
    $verification_token = md5_hex( time() . {} . rand() . {} . $$ );

    $patron_modification = Koha::Patron::Modification->new(
        {   borrowernumber      => $patron->borrowernumber,
            extended_attributes => $empty_code_json,
            verification_token  => $verification_token
        }
    )->store();
    ok( $patron_modification->approve,
        'Patron modification correctly approved' );
    @patron_attributes
        = map { $_->unblessed }
        Koha::Patron::Attributes->search(
        { borrowernumber => $patron->borrowernumber } );

    is( $patron_attributes[0]->{code},
        'CODE_1', 'Untouched attribute type is preserved (code)' );
    is( $patron_attributes[0]->{attribute},
        'VALUE_1', 'Untouched attribute type is preserved (attribute)' );

    my $count = Koha::Patron::Attributes->search({ borrowernumber => $patron->borrowernumber, code => 'CODE_2' })->count;
    is( $count, 0, 'Attributes deleted when modification contained an empty one');

    $schema->storage->txn_rollback;
};

subtest 'pending_count() and pending() tests' => sub {

    plan tests => 16;

    $schema->storage->txn_begin;

    Koha::Patron::Modifications->search->delete;
    my $library_1 = $builder->build( { source => 'Branch' } )->{branchcode};
    my $library_2 = $builder->build( { source => 'Branch' } )->{branchcode};
    $builder->build({ source => 'BorrowerAttributeType', value => { code => 'CODE_1' } });
    $builder->build({ source => 'BorrowerAttributeType', value => { code => 'CODE_2', repeatable => 1 } });

    my $patron_1
        = $builder->build(
        { source => 'Borrower', value => { branchcode => $library_1 } } );
    my $patron_2
        = $builder->build(
        { source => 'Borrower', value => { branchcode => $library_2 } } );
    my $patron_3
        = $builder->build(
        { source => 'Borrower', value => { branchcode => $library_2 } } );
    $patron_1 = Koha::Patrons->find( $patron_1->{borrowernumber} );
    $patron_2 = Koha::Patrons->find( $patron_2->{borrowernumber} );
    $patron_3 = Koha::Patrons->find( $patron_3->{borrowernumber} );
    my $verification_token_1 = md5_hex( time().{}.rand().{}.$$ );
    my $verification_token_2 = md5_hex( time().{}.rand().{}.$$ );
    my $verification_token_3 = md5_hex( time().{}.rand().{}.$$ );

    Koha::Patron::Attribute->new({ borrowernumber => $patron_1->borrowernumber, code => 'CODE_1', attribute => 'hello' } )->store();
    Koha::Patron::Attribute->new({ borrowernumber => $patron_2->borrowernumber, code => 'CODE_2', attribute => 'bye' } )->store();

    my $modification_1 = Koha::Patron::Modification->new(
        {   borrowernumber     => $patron_1->borrowernumber,
            surname            => 'Hall',
            firstname          => 'Kyle',
            verification_token => $verification_token_1,
            extended_attributes => '[{"code":"CODE_1","value":""}]'
        }
    )->store();

    is( Koha::Patron::Modifications->pending_count,
        1, 'pending_count() correctly returns 1' );

    my $modification_2 = Koha::Patron::Modification->new(
        {   borrowernumber     => $patron_2->borrowernumber,
            surname            => 'Smith',
            firstname          => 'Sandy',
            verification_token => $verification_token_2,
            extended_attributes => '[{"code":"CODE_2","value":"año"},{"code":"CODE_2","value":"ciao"}]'
        }
    )->store();

    my $modification_3 = Koha::Patron::Modification->new(
        {   borrowernumber     => $patron_3->borrowernumber,
            surname            => 'Smithy',
            firstname          => 'Sandy',
            verification_token => $verification_token_3
        }
    )->store();

    is( Koha::Patron::Modifications->pending_count,
        3, 'pending_count() correctly returns 3' );

    my $pending = Koha::Patron::Modifications->pending();
    is( scalar @{$pending}, 3, 'pending() returns an array with 3 elements' );

    my @filtered_modifications = grep { $_->{borrowernumber} eq $patron_1->borrowernumber } @{$pending};
    my $p1_pm = $filtered_modifications[0];
    my $p1_pm_attribute_1 = $p1_pm->{extended_attributes}->[0];

    is( scalar @{$p1_pm->{extended_attributes}}, 1, 'patron 1 has modification has one pending attribute modification' );
    is( ref($p1_pm_attribute_1), 'Koha::Patron::Attribute', 'patron modification has single attribute object' );
    is( $p1_pm_attribute_1->attribute, '', 'patron 1 has an empty value for the attribute' );

    @filtered_modifications = grep { $_->{borrowernumber} eq $patron_2->borrowernumber } @{$pending};
    my $p2_pm = $filtered_modifications[0];

    is( scalar @{$p2_pm->{extended_attributes}}, 2 , 'patron 2 has 2 attribute modifications' );

    my $p2_pm_attribute_1 = $p2_pm->{extended_attributes}->[0];
    my $p2_pm_attribute_2 = $p2_pm->{extended_attributes}->[1];

    is( ref($p2_pm_attribute_1), 'Koha::Patron::Attribute', 'patron modification has single attribute object' );
    is( ref($p2_pm_attribute_2), 'Koha::Patron::Attribute', 'patron modification has single attribute object' );

    is( $p2_pm_attribute_1->attribute, 'año', 'patron modification has the right attribute change' );
    is( $p2_pm_attribute_2->attribute, 'ciao', 'patron modification has the right attribute change' );


    C4::Context->_new_userenv('xxx');
    set_logged_in_user( $patron_1 );
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

sub set_logged_in_user {
    my ($patron) = @_;
    C4::Context->set_userenv(
        $patron->borrowernumber, $patron->userid,
        $patron->cardnumber,     'firstname',
        'surname',               $patron->library->branchcode,
        'Midway Public Library', $patron->flags,
        '',                      ''
    );
}
