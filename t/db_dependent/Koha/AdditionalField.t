#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 2;
use String::Random qw(random_string);

use Koha::AuthorisedValueCategory;

BEGIN {
    use_ok('Koha::AdditionalField');
}

my $schema = Koha::Database->schema;

subtest 'effective_authorised_value_category' => sub {
    plan tests => 4;

    $schema->txn_begin;

    my $av_category_name = random_string('C' x 32);
    my $av_category = Koha::AuthorisedValueCategory->new({ category_name => $av_category_name });
    $av_category->store()->discard_changes();

    my $field = Koha::AdditionalField->new(
        {
            tablename => random_string('c' x 100),
            name => random_string('c' x 100),
        }
    );
    $field->store()->discard_changes();

    is($field->effective_authorised_value_category, '', 'no default category');

    $field = Koha::AdditionalField->new(
        {
            tablename => random_string('c' x 100),
            name => random_string('c' x 100),
            authorised_value_category => $av_category_name,
        }
    );
    $field->store()->discard_changes();

    is($field->effective_authorised_value_category, $av_category_name, 'returns authorised_value_category if set');

    my $mss = Koha::MarcSubfieldStructure->new(
        {
            frameworkcode => '',
            tagfield => '999',
            tagsubfield => 'Z',
            authorised_value => $av_category_name,
        }
    );
    $mss->store();
    $field = Koha::AdditionalField->new(
        {
            tablename => random_string('c' x 100),
            name => random_string('c' x 100),
            marcfield => '999$Z',
        }
    );
    $field->store()->discard_changes();

    is($field->effective_authorised_value_category, $av_category_name, 'returns MARC subfield authorised value category if set');

    my $av2_category_name = random_string('C' x 32);
    my $av2_category = Koha::AuthorisedValueCategory->new({ category_name => $av2_category_name });
    $av2_category->store()->discard_changes();
    $field = Koha::AdditionalField->new(
        {
            tablename => random_string('c' x 100),
            name => random_string('c' x 100),
            authorised_value_category => $av2_category_name,
            marcfield => '999$Z',
        }
    );
    $field->store()->discard_changes();

    is($field->effective_authorised_value_category, $av2_category_name, 'returns authorised_value_category if both authorised_value_category and marcfield are set');

    $schema->txn_rollback;
};
