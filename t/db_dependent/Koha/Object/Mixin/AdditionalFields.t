#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 4;
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
        MARC::Field->new('998', '', '', 'Z' => 'some value'),
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
            marcfield => '998$Z',
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

subtest 'get_additional_field_values_for_template' => sub {
    plan tests => 2;

    $schema->txn_begin;

    my $biblio       = $builder->build_sample_biblio();
    my $subscription = Koha::Subscription->new(
        {
            biblionumber => $biblio->biblionumber,
        }
    );
    $subscription->store()->discard_changes();

    my $field = Koha::AdditionalField->new(
        {
            tablename  => 'subscription',
            name       => random_string( 'c' x 100 )
        }
    );
    $field->store()->discard_changes();

    my $field2 = Koha::AdditionalField->new(
        {
            tablename  => 'subscription',
            name       => random_string( 'c' x 100 )
        }
    );
    $field2->store()->discard_changes();

    my $value = 'some value';
    $subscription->set_additional_fields(
        [
            {
                id    => $field->id,
                value => $value . ' 1',
            },
            {
                id    => $field->id,
                value => $value . ' 2',
            },
            {
                id    => $field2->id,
                value => 'second field',
            },
        ]
    );

    my $template_additional_field_values = $subscription->get_additional_field_values_for_template;

    is(
        ref($template_additional_field_values), 'HASH',
        '->get_additional_field_values_for_template should return a hash'
    );
    is_deeply(
        $template_additional_field_values,
        { $field->id => [ $value . ' 1', $value . ' 2' ], $field2->id => ['second field'] },
        '->get_additional_field_values_for_template should return the correct values'
    );

    $schema->txn_rollback;
};

subtest 'add_additional_fields' => sub {
    plan tests => 1;

    $schema->txn_begin;

    Koha::AdditionalFields->search->delete;

    my $biblio       = $builder->build_sample_biblio();
    my $subscription = Koha::Subscription->new(
        {
            biblionumber => $biblio->biblionumber,
        }
    );
    $subscription->store()->discard_changes();

    my $field = Koha::AdditionalField->new(
        {
            tablename => 'subscription',
            name      => random_string( 'c' x 100 )
        }
    );
    $field->store()->discard_changes();

    my $field2 = Koha::AdditionalField->new(
        {
            tablename => 'subscription',
            name      => random_string( 'c' x 100 )
        }
    );
    $field2->store()->discard_changes();

    my $value = 'some value';
    $subscription->set_additional_fields(
        [
            {
                id    => $field->id,
                value => $value . ' 1',
            },
            {
                id    => $field->id,
                value => $value . ' 2',
            }
        ]
    );

    $subscription->add_additional_fields(
        {
            $field2->id => [
                'second field'
            ],
        },
        'subscription'
    );

    my $template_additional_field_values = $subscription->get_additional_field_values_for_template;



    is_deeply(
        $template_additional_field_values,
        { $field->id => [ $value . ' 1', $value . ' 2' ], $field2->id => ['second field'] },
        '->add_additional_fields should have only added to existing field values'
    );

    $schema->txn_rollback;
};
