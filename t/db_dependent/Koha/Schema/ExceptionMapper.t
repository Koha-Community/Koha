#!/usr/bin/perl

# Copyright 2025 Koha Development team
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 11;
use Test::Exception;

use Koha::Database;
use Koha::Schema::ExceptionMapper;

use t::lib::TestBuilder;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

subtest 'foreign_key_constraint_translation' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $msg =
        "Cannot add or update a child row: a foreign key constraint fails (`koha`.`items`, CONSTRAINT `items_ibfk_1` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`))";

    throws_ok {
        Koha::Schema::ExceptionMapper->translate_exception($msg);
    }
    'Koha::Exceptions::Object::FKConstraint', 'FK constraint exception is properly translated';

    is( $@->broken_fk, 'biblionumber', 'broken_fk is correctly extracted' );

    $schema->storage->txn_rollback;
};

subtest 'duplicate_key_translation' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $msg = "Duplicate entry 'test\@example.com' for key 'borrowers.email'";

    throws_ok {
        Koha::Schema::ExceptionMapper->translate_exception($msg);
    }
    'Koha::Exceptions::Object::DuplicateID', 'Duplicate key exception is properly translated';

    is( $@->duplicate_id, 'borrowers.email', 'duplicate_id is correctly extracted' );

    $schema->storage->txn_rollback;
};

subtest 'bad_value_translation' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $msg = "Incorrect datetime value: '2025-13-45' for column 'date_due' at row 1";

    throws_ok {
        Koha::Schema::ExceptionMapper->translate_exception($msg);
    }
    'Koha::Exceptions::Object::BadValue', 'Bad value exception is properly translated';

    is( $@->type, 'datetime', 'type is correctly extracted' );

    $schema->storage->txn_rollback;
};

subtest 'enum_truncation_translation' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $msg = "Data truncated for column 'status' at row 1";

    throws_ok {
        Koha::Schema::ExceptionMapper->translate_exception($msg);
    }
    'Koha::Exceptions::Object::BadValue', 'Enum truncation exception is properly translated';

    is( $@->type, 'enum', 'type is enum' );

    $schema->storage->txn_rollback;
};

subtest 'unmatched_message_returns' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    my $msg    = "Some unknown database error at row 1";
    my $result = Koha::Schema::ExceptionMapper->translate_exception($msg);

    is( $result, undef, 'Unmatched message returns without throwing' );

    $schema->storage->txn_rollback;
};

subtest 'fk_constraint_deletion_translation' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $msg =
        "Cannot delete or update a parent row: a foreign key constraint fails (`koha`.`items`, CONSTRAINT `items_ibfk_1` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`))";

    throws_ok {
        Koha::Schema::ExceptionMapper->translate_exception($msg);
    }
    'Koha::Exceptions::Object::FKConstraintDeletion', 'FK constraint deletion exception is properly translated';

    is( $@->fk, 'biblionumber', 'fk is correctly extracted' );

    $schema->storage->txn_rollback;
};

subtest 'not_null_translation' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    throws_ok {
        Koha::Schema::ExceptionMapper->translate_exception("Column 'host' cannot be null");
    }
    'Koha::Exceptions::Object::NotNull', 'NOT NULL violation is properly translated';

    is( $@->property, 'host', 'property is correctly extracted' );

    $schema->storage->txn_rollback;
};

subtest 'not_in_database_translation' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    throws_ok {
        Koha::Schema::ExceptionMapper->translate_exception("Not in database");
    }
    'Koha::Exceptions::Object::NotInStorage', 'Not in database is properly translated';

    $schema->storage->txn_rollback;
};

subtest 'exception_action integration' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    # Test that the schema's exception_action translates known errors
    throws_ok {
        $schema->throw_exception("Duplicate entry 'test' for key 'primary'");
    }
    'Koha::Exceptions::Object::DuplicateID', 'exception_action translates known errors';

    # Test that unknown DBI errors throw as UnhandledDBError
    throws_ok {
        $schema->throw_exception("DBI Exception: DBD::mysql::st execute failed: Some unknown DB error");
    }
    'Koha::Exceptions::Object::UnhandledDBError', 'exception_action wraps unknown DBI errors as UnhandledDBError';

    # Test that non-DBI DBIC internal errors remain DBIx::Class::Exception
    throws_ok {
        $schema->throw_exception("Some internal DBIC error");
    }
    'DBIx::Class::Exception', 'exception_action preserves DBIC internal errors';

    $schema->storage->txn_rollback;
};

subtest 'Object::store integration' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron2 = $builder->build_object( { class => 'Koha::Patrons' } );

    # Force a duplicate cardnumber
    $patron2->cardnumber( $patron->cardnumber );

    throws_ok {
        $patron2->store();
    }
    'Koha::Exceptions::Object::DuplicateID', 'Object::store gets automatic exception translation';

    $schema->storage->txn_rollback;
};

1;
