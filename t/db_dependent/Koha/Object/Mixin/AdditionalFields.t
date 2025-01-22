#!/usr/bin/perl

use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 7;
use t::lib::TestBuilder;
use String::Random qw(random_string);
use Koha::Database;
use Koha::Subscription;
use Koha::AdditionalField;
use Koha::AuthorisedValueCategory;
use Koha::ERM::License;
use C4::Context;
use CGI;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->schema;

subtest 'set_additional_fields with marcfield_mode = "get"' => sub {
    plan tests => 2;

    $schema->txn_begin;

    my $biblio = $builder->build_sample_biblio();
    my $record = $biblio->record;
    $record->append_fields(
        MARC::Field->new( '998', '', '', 'Z' => 'some value' ),
    );
    $biblio->metadata->metadata( $record->as_xml_record( C4::Context->preference('marcflavour') ) );
    $biblio->metadata->store()->discard_changes();
    my $subscription = Koha::Subscription->new(
        {
            biblionumber => $biblio->biblionumber,
        }
    );
    $subscription->store()->discard_changes();

    my $field = Koha::AdditionalField->new(
        {
            tablename      => 'subscription',
            name           => random_string( 'c' x 100 ),
            marcfield      => '998$Z',
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

    is( $values->[0]->value, 'some value', 'value was copied from the biblio record to the field' );

    $field->delete;
    my $get_marcfield_field = Koha::AdditionalField->new(
        {
            tablename      => 'subscription',
            name           => random_string( 'c' x 100 ),
            marcfield      => '998$Z',
            marcfield_mode => 'get',
        }
    );
    $get_marcfield_field->store()->discard_changes();
    my $q = CGI->new;
    $q->param(
        -name  => 'additional_field_' . $get_marcfield_field->id,
        -value => '',
    );

    my @additional_fields =
        Koha::Object::Mixin::AdditionalFields->prepare_cgi_additional_field_values( $q, 'subscription' );
    $subscription->set_additional_fields( \@additional_fields );

    $values = $subscription->additional_field_values()->as_list();

    is( $values->[0]->value, 'some value', 'value was copied from the biblio record to the field' );

    $schema->txn_rollback;
};

subtest 'set_additional_fields with marcfield_mode = "set"' => sub {
    plan tests => 1;

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
            tablename      => 'subscription',
            name           => random_string( 'c' x 100 ),
            marcfield      => '999$Z',
            marcfield_mode => 'set',
        }
    );
    $field->store()->discard_changes();
    $subscription->set_additional_fields(
        [
            {
                id    => $field->id,
                value => 'some value',
            },
        ]
    );

    my $record = $biblio->record;
    is( $record->subfield( '999', 'Z' ), 'some value', 'value was copied from the field to the biblio record' );

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
            $field2->id => ['second field'],
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

subtest 'prepare_cgi_additional_field_values' => sub {
    plan tests => 1;

    $schema->txn_begin;

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
    my $field3 = Koha::AdditionalField->new(
        {
            tablename => 'subscription',
            name      => random_string( 'c' x 100 )
        }
    );
    $field3->store()->discard_changes();

    my $q = CGI->new;
    $q->param(
        -name  => 'additional_field_' . $field->id,
        -value => [qw/value1 value2/],
    );
    $q->param(
        -name  => 'additional_field_' . $field2->id,
        -value => '0',
    );
    $q->param(
        -name  => 'additional_field_' . $field3->id,
        -value => '',
    );
    $q->param(
        -name  => 'irrelevant_param',
        -value => 'foo',
    );

    my @additional_fields =
        Koha::Object::Mixin::AdditionalFields->prepare_cgi_additional_field_values( $q, 'subscription' );

    is_deeply(
        \@additional_fields,
        [
            {
                'value' => 'value1',
                'id'    => $field->id
            },
            {
                'value' => 'value2',
                'id'    => $field->id
            },
            {
                'value' => '0',
                'id'    => $field2->id
            },
            {
                'value' => '',
                'id'    => $field3->id
            }
        ],
        'Return of prepare_cgi_additional_field_values should be correct'
    );
    $schema->txn_rollback;
};

subtest 'strings_map() tests' => sub {
    plan tests => 1;
    $schema->txn_begin;
    Koha::AdditionalFields->search->delete;
    my $license = Koha::ERM::License->new(
        {
            name   => "license name",
            type   => "national",
            status => "in_negotiation",

        }
    );
    $license->store()->discard_changes();
    my $field = Koha::AdditionalField->new(
        {
            tablename => 'erm_licenses',
            name      => 'af_1',

        }
    );
    $field->store()->discard_changes();
    my $field2 = Koha::AdditionalField->new(
        {
            tablename => 'erm_licenses',
            name      => 'af_2',

        }
    );
    $field2->store()->discard_changes();
    my $value = 'some license value';
    $license->set_additional_fields(
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
    $license->add_additional_fields(
        {
            $field2->id => ['second field'],

        },
        'erm_licenses'
    );
    my $av_category = Koha::AuthorisedValueCategory->new( { category_name => "AV_CAT_NAME" } );
    $av_category->store()->discard_changes();
    my $av_value = Koha::AuthorisedValue->new(
        {
            category         => $av_category->category_name,
            authorised_value => 'BOB',
            lib              => "Robert"
        }
    );
    my $av_field = Koha::AdditionalField->new(
        {
            tablename                 => "erm_licenses",
            name                      => "av_field",
            authorised_value_category => $av_category->category_name,

        }
    );
    $av_field->store()->discard_changes();
    $license->add_additional_fields(
        {
            $av_field->id => [ $av_value->authorised_value ],

        },
        'erm_licenses'
    );
    my $values      = $license->get_additional_field_values_for_template;
    my $strings_map = $license->strings_map;
    is_deeply(
        $strings_map,
        {
            additional_field_values => [
                {
                    'field_id'    => $field->id,
                    'type'        => 'text',
                    'field_label' => $field->name,
                    'value_str'   => join( ', ', @{ $values->{ $field->id } } )
                },
                {
                    'field_id'    => $field2->id,
                    'type'        => 'text',
                    'field_label' => $field2->name,
                    'value_str'   => join( ', ', @{ $values->{ $field2->id } } )
                },
                {
                    'field_id'    => $av_field->id,
                    'type'        => 'av',
                    'field_label' => $av_field->name,
                    'value_str'   => join( ', ', @{ $values->{ $av_field->id } } )
                }
            ]
        },
        'strings_map looks good'
    );
    $schema->txn_rollback;

};
