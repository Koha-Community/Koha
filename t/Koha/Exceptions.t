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

use Test::More tests => 11;
use Test::MockObject;
use Test::Exception;

subtest 'Koha::Exceptions::Hold tests' => sub {

    plan tests => 5;

    use_ok('Koha::Exceptions::Hold');

    throws_ok
        { Koha::Exceptions::Hold::CannotSuspendFound->throw( status => 'W' ); }
        'Koha::Exceptions::Hold::CannotSuspendFound',
        'Exception is thrown :-D';

    # stringify the exception
    is( "$@", 'Found hold cannot be suspended. Status=W', 'Exception stringified correctly' );

    throws_ok
        { Koha::Exceptions::Hold::CannotSuspendFound->throw( "Manual message exception" ) }
        'Koha::Exceptions::Hold::CannotSuspendFound',
        'Exception is thrown :-D';
    is( "$@", 'Manual message exception', 'Exception not stringified if manually passed' );
};

subtest 'Koha::Exceptions::Object::FKConstraint tests' => sub {

    plan tests => 9;

    use_ok('Koha::Exceptions::Object');

    throws_ok
        { Koha::Exceptions::Object::FKConstraint->throw( broken_fk => 'nasty', value => 'fk' ); }
        'Koha::Exceptions::Object::FKConstraint',
        'Exception is thrown :-D';

    # stringify the exception
    is( "$@", 'Invalid parameter passed, nasty=fk does not exist', 'Exception stringified correctly' );

    throws_ok
        { Koha::Exceptions::Object::FKConstraint->throw( "Manual message exception" ) }
        'Koha::Exceptions::Object::FKConstraint',
        'Exception is thrown :-D';
    is( "$@", 'Manual message exception', 'Exception not stringified if manually passed' );

    throws_ok {
        Koha::Exceptions::Object::BadValue->throw(
            type     => 'datetime',
            property => 'a_property',
            value    => 'a_value'
        );
    }
    'Koha::Exceptions::Object::BadValue',
        'Koha::Exceptions::Object::BadValue exception is thrown :-D';

    # stringify the exception
    is( "$@", 'Invalid value passed, a_property=a_value expected type is datetime', 'Koha::Exceptions::Object::BadValue stringified correctly' );

    throws_ok
        { Koha::Exceptions::Object::BadValue->throw( "Manual message exception" ) }
        'Koha::Exceptions::Object::BadValue',
        'Koha::Exceptions::Object::BadValue is thrown :-D';
    is( "$@", 'Manual message exception', 'Koha::Exceptions::Object::BadValue not stringified if manually passed' );
};

subtest 'Koha::Exceptions::Password tests' => sub {

    plan tests => 5;

    use_ok('Koha::Exceptions::Password');

    throws_ok
        { Koha::Exceptions::Password::TooShort->throw( length => 4, min_length => 5 ); }
        'Koha::Exceptions::Password::TooShort',
        'Exception is thrown :-D';

    # stringify the exception
    is( "$@", 'Password length (4) is shorter than required (5)', 'Exception stringified correctly' );

    throws_ok
        { Koha::Exceptions::Password::TooShort->throw( "Manual message exception" ) }
        'Koha::Exceptions::Password::TooShort',
        'Exception is thrown :-D';
    is( "$@", 'Manual message exception', 'Exception not stringified if manually passed' );
};

subtest 'Koha::Exceptions::Metadata tests' => sub {

    plan tests => 5;

    use_ok('Koha::Exceptions::Metadata');

    my $object = Test::MockObject->new;
    $object->mock( 'id', 'an_id' );
    $object->mock( 'biblionumber', 'a_biblionumber' );
    $object->mock( 'format', 'a_format' );
    $object->mock( 'schema', 'a_schema' );

    throws_ok
        { Koha::Exceptions::Metadata::Invalid->throw(
            id => 'an_id', biblionumber => 'a_biblionumber', format => 'a_format',
            schema => 'a_schema', decoding_error => 'a_nasty_error' ); }
        'Koha::Exceptions::Metadata::Invalid',
        'Exception is thrown :-D';

    # stringify the exception
    is( "$@", 'Invalid data, cannot decode metadata object (biblio_metadata.id=an_id, biblionumber=a_biblionumber, format=a_format, schema=a_schema, decoding_error=\'a_nasty_error\')', 'Exception stringified correctly' );

    throws_ok
        { Koha::Exceptions::Metadata::Invalid->throw( "Manual message exception" ) }
        'Koha::Exceptions::Metadata::Invalid',
        'Exception is thrown :-D';
    is( "$@", 'Manual message exception', 'Exception not stringified if manually passed' );
};

subtest 'Koha::Exceptions::Patron::Relationship tests' => sub {

    plan tests => 9;

    use_ok('Koha::Exceptions::Patron::Relationship');

    throws_ok
        { Koha::Exceptions::Patron::Relationship::InvalidRelationship->throw( no_relationship => 1 ); }
        'Koha::Exceptions::Patron::Relationship::InvalidRelationship',
        'Exception is thrown :-D';

    # stringify the exception
    is( "$@", 'No relationship passed.', 'Exception stringified correctly' );

    throws_ok
        { Koha::Exceptions::Patron::Relationship::InvalidRelationship->throw( relationship => 'some' ); }
        'Koha::Exceptions::Patron::Relationship::InvalidRelationship',
        'Exception is thrown :-D';

    # stringify the exception
    is( "$@", "Invalid relationship passed, 'some' is not defined.", 'Exception stringified correctly' );

    my $guarantor_id = 1;
    my $guarantee_id = 2;

    throws_ok {
        Koha::Exceptions::Patron::Relationship::DuplicateRelationship->throw(
            guarantor_id => $guarantor_id,
            guarantee_id => $guarantee_id
        );
    }
    'Koha::Exceptions::Patron::Relationship::DuplicateRelationship', 'Exception is thrown :-D';

    # stringify the exception
    is( "$@",
        "There already exists a relationship for the same guarantor ($guarantor_id) and guarantee ($guarantee_id) combination",
        'Exception stringified correctly'
    );

    throws_ok
        { Koha::Exceptions::Patron::Relationship::InvalidRelationship->throw( "Manual message exception" ) }
        'Koha::Exceptions::Patron::Relationship::InvalidRelationship',
        'Exception is thrown :-D';
    is( "$@", 'Manual message exception', 'Exception not stringified if manually passed' );
};

subtest 'Koha::Exceptions::Object::NotInstantiated tests' => sub {

    plan tests => 4;

    throws_ok
        { Koha::Exceptions::Object::NotInstantiated->throw(
            method => 'brain_explode', class => 'Koha::JD' ); }
        'Koha::Exceptions::Object::NotInstantiated',
        'Exception is thrown :-D';

    # stringify the exception
    is( "$@", 'Tried to access the \'brain_explode\' method, but Koha::JD is not instantiated', 'Exception stringified correctly' );

    throws_ok
        { Koha::Exceptions::Object::NotInstantiated->throw( "Manual message exception" ) }
        'Koha::Exceptions::Object::NotInstantiated',
        'Exception is thrown :-D';
    is( "$@", 'Manual message exception', 'Exception not stringified if manually passed' );
};

subtest 'Koha::Exceptions::Patron::Attribute::* tests' => sub {

    plan tests => 13;

    use_ok("Koha::Exceptions::Patron::Attribute");

    my $code      = 'CODE';
    my $attribute = 'ATTRIBUTE';

    my $mocked_attribute = Test::MockObject->new();
    $mocked_attribute->mock('code', sub { return $code } );
    $mocked_attribute->mock('attribute', sub { return $attribute } );

    throws_ok
        { Koha::Exceptions::Patron::Attribute::NonRepeatable->throw(
            attribute => $mocked_attribute ); }
        'Koha::Exceptions::Patron::Attribute::NonRepeatable',
        'Exception is thrown :-D';

    # stringify the exception
    is(
        "$@",
        "Tried to add more than one non-repeatable attributes. type=$code value=$attribute",
        'Exception stringified correctly'
    );

    throws_ok
        { Koha::Exceptions::Patron::Attribute::NonRepeatable->throw( "Manual message exception" ) }
        'Koha::Exceptions::Patron::Attribute::NonRepeatable',
        'Exception is thrown :-D';

    is(
        "$@",
        'Manual message exception',
        'Exception not stringified if manually passed'
    );

    throws_ok
        { Koha::Exceptions::Patron::Attribute::UniqueIDConstraint->throw(
            attribute => $mocked_attribute ); }
        'Koha::Exceptions::Patron::Attribute::UniqueIDConstraint',
        'Exception is thrown :-D';

    # stringify the exception
    is(
        "$@",
        "Your action breaks a unique constraint on the attribute. type=$code value=$attribute",
        'Exception stringified correctly'
    );

    throws_ok
        { Koha::Exceptions::Patron::Attribute::UniqueIDConstraint->throw( "Manual message exception" ) }
        'Koha::Exceptions::Patron::Attribute::UniqueIDConstraint',
        'Exception is thrown :-D';

    is(
        "$@",
        'Manual message exception',
        'Exception not stringified if manually passed'
    );

    my $type = "SOME_TYPE";

    throws_ok
        { Koha::Exceptions::Patron::Attribute::InvalidType->throw(
            type => $type ); }
        'Koha::Exceptions::Patron::Attribute::InvalidType',
        'Exception is thrown :-D';

    # stringify the exception
    is(
        "$@",
        "Tried to use an invalid attribute type. type=$type",
        'Exception stringified correctly'
    );

    throws_ok
        { Koha::Exceptions::Patron::Attribute::InvalidType->throw( "Manual message exception" ) }
        'Koha::Exceptions::Patron::Attribute::InvalidType',
        'Exception is thrown :-D';

    is(
        "$@",
        'Manual message exception',
        'Exception not stringified if manually passed'
    );
};

subtest 'Koha::Exceptions::Patron tests' => sub {

    plan tests => 5;

    use_ok("Koha::Exceptions::Patron");

    my $type = 'yahey';

    throws_ok
        { Koha::Exceptions::Patron::MissingMandatoryExtendedAttribute->throw(
            type => $type ); }
        'Koha::Exceptions::Patron::MissingMandatoryExtendedAttribute',
        'Exception is thrown :-D';

    # stringify the exception
    is( "$@", "Missing mandatory extended attribute (type=$type)", 'Exception stringified correctly' );

    throws_ok
        { Koha::Exceptions::Patron::MissingMandatoryExtendedAttribute->throw( "Manual message exception" ) }
        'Koha::Exceptions::Patron::MissingMandatoryExtendedAttribute',
        'Exception is thrown :-D';
    is( "$@", 'Manual message exception', 'Exception not stringified if manually passed' );
};

subtest 'Koha::Exceptions::Plugin tests' => sub {

    plan tests => 5;

    use_ok("Koha::Exceptions::Plugin");

    my $plugin_class = 'yahey';

    throws_ok
        { Koha::Exceptions::Plugin::InstallDied->throw(
            plugin_class => $plugin_class ); }
        'Koha::Exceptions::Plugin::InstallDied',
        'Exception is thrown :-D';

    # stringify the exception
    is( "$@", "Calling 'install' died for plugin $plugin_class", 'Exception stringified correctly' );

    throws_ok
        { Koha::Exceptions::Plugin::UpgradeDied->throw(
            plugin_class => $plugin_class ); }
        'Koha::Exceptions::Plugin::UpgradeDied',
        'Exception is thrown :-D';

    # stringify the exception
    is( "$@", "Calling 'upgrade' died for plugin $plugin_class", 'Exception stringified correctly' );
};

subtest 'Koha::Exception tests' => sub {

    plan tests => 8;

    use Koha::Exception;

    use Exception::Class (
        'Koha::Exceptions::Weird' => {
            isa         => 'Koha::Exception',
            description => 'Weird exception!',
            fields      => [ 'a', 'b' ]
        }
    );

    my $exception_message = "This is a message";

    throws_ok
        { Koha::Exceptions::Weird->throw( $exception_message ) }
        'Koha::Exception',
        'Exception is thrown :-D';

    is(
        "$@",
        "Exception 'Koha::Exceptions::Weird' thrown '$exception_message'\n",
        'Exception not stringified if manually passed'
    );

    throws_ok
        { Koha::Exceptions::Weird->throw( a => "A", b => "B" ) }
        'Koha::Exception',
        'Exception is thrown :-D';

    is(
        "$@",
        "Exception 'Koha::Exceptions::Weird' thrown 'Weird exception!' with a => A, b => B\n",
        'Exception stringified correctly'
    );

    throws_ok
        { Koha::Exceptions::Weird->throw( a => "A" ) }
        'Koha::Exception',
        'Exception is thrown :-D';

    is(
        "$@",
        "Exception 'Koha::Exceptions::Weird' thrown 'Weird exception!' with a => A\n",
        'Exception stringified correctly, b skipped entirely'
    );

    throws_ok
        { Koha::Exceptions::Weird->throw() }
        'Koha::Exception',
        'Exception is thrown :-D';

    is(
        "$@",
        "Exception 'Koha::Exceptions::Weird' thrown 'Weird exception!'\n",
        'Exception stringified correctly'
    );
};

subtest 'Passing parameters when throwing exception' => sub {
    plan tests => 4;

    use Koha::Exceptions;

    throws_ok { Koha::Exceptions::WrongParameter->throw( name => 'wrong1', type => 'ARRAY', value => [ 1, 2 ] ) } qr/Koha::Exceptions::WrongParameter/, 'Exception thrown';
    my $desc = $@;
    like( $desc, qr/name => wrong1/, 'Found name' );
    like( $desc, qr/type => ARRAY/, 'Found type' );
    like( $desc, qr/value => ARRAY\(\w+\)/, 'Found value' );
};
