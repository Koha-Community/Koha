#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 2;
use t::lib::TestBuilder;
use String::Random qw(random_string);
use Koha::Database;
use Koha::Subscription;
use Koha::AdditionalField;
use C4::Context;

my $builder = t::lib::TestBuilder->new;
my $schema = Koha::Database->schema;

subtest 'set_additional_fields with marcfield_mode = "get"' => sub {
    plan tests => 1;

    $schema->txn_begin;

    my $biblio = $builder->build_sample_biblio();
    my $record = $biblio->record;
    $record->append_fields(
        MARC::Field->new('999', '', '', 'Z' => 'some value'),
    );
    $biblio->metadata->metadata($record->as_xml_record(C4::Context->preference('marcflavour')));
    $biblio->metadata->store()->discard_changes();
    my $subscription = Koha::Subscription->new(
        {
            biblionumber => $biblio->biblionumber,
        }
    );
    $subscription->store()->discard_changes();

    my $field = Koha::AdditionalField->new(
        {
            tablename => 'subscription',
            name => random_string('c' x 100),
            marcfield => '999$Z',
            marcfield_mode => 'get',
        }
    );
    $field->store()->discard_changes();
    $subscription->set_additional_fields(
        [
            { id => $field->id },
        ]
    );

    my $values = $subscription->additional_field_values()->as_list();

    is($values->[0]->value, 'some value', 'value was copied from the biblio record to the field');

    $schema->txn_rollback;
};

subtest 'set_additional_fields with marcfield_mode = "set"' => sub {
    plan tests => 1;

    $schema->txn_begin;

    my $biblio = $builder->build_sample_biblio();
    my $subscription = Koha::Subscription->new(
        {
            biblionumber => $biblio->biblionumber,
        }
    );
    $subscription->store()->discard_changes();

    my $field = Koha::AdditionalField->new(
        {
            tablename => 'subscription',
            name => random_string('c' x 100),
            marcfield => '999$Z',
            marcfield_mode => 'set',
        }
    );
    $field->store()->discard_changes();
    $subscription->set_additional_fields(
        [
            {
                id => $field->id,
                value => 'some value',
            },
        ]
    );

    my $record = $biblio->record;
    is($record->subfield('999', 'Z'), 'some value', 'value was copied from the field to the biblio record');

    $schema->txn_rollback;
};
