#!/usr/bin/perl

use Modern::Perl;

use Test::More;

use C4::ClassSource;

use Koha::ClassSources;
use Koha::DateUtils qw( dt_from_string );
use Koha::ItemTypes;
use Koha::Libraries;

use_ok('Koha::UI::Form::Builder::Biblio');

subtest 'generate_subfield_form default value' => sub {
    my $builder = Koha::UI::Form::Builder::Biblio->new();

    my $subfield = $builder->generate_subfield_form(
        {
            tag => '999',
            subfield => '9',
            value => '',
            index_tag => int(rand(1000000)),
            tagslib => {
                '999' => {
                    '9' => {
                        defaultvalue => 'The date is <<YYYY>>-<<MM>>-<<DD>> and user is <<USER>>',
                        hidden => 0,
                    }
                }
            },
        },
    );

    my $today = dt_from_string()->ymd;
    is($subfield->{marc_value}->{value}, "The date is $today and user is superlibrarian");
};

subtest 'generate_subfield_form branches' => sub {
    my $builder = Koha::UI::Form::Builder::Biblio->new();

    my $subfield = $builder->generate_subfield_form(
        {
            tag => '999',
            subfield => '9',
            value => '',
            index_tag => int(rand(1000000)),
            tagslib => {
                '999' => {
                    '9' => {
                        authorised_value => 'branches',
                        hidden => 0,
                    }
                }
            },
        },
    );

    my @libraries = Koha::Libraries->search({}, {order_by => 'branchname'})->as_list;
    my %labels = map { $_->branchcode => $_->branchname } @libraries;
    my @values = map { $_->branchcode } @libraries;

    is($subfield->{marc_value}->{type}, 'select');
    is_deeply($subfield->{marc_value}->{labels}, \%labels);
    is_deeply($subfield->{marc_value}->{values}, \@values);
};

subtest 'generate_subfield_form itemtypes' => sub {
    my $builder = Koha::UI::Form::Builder::Biblio->new();

    my $subfield = $builder->generate_subfield_form(
        {
            tag => '999',
            subfield => '9',
            value => '',
            index_tag => int(rand(1000000)),
            tagslib => {
                '999' => {
                    '9' => {
                        authorised_value => 'itemtypes',
                        hidden => 0,
                    }
                }
            },
        },
    );

    my @itemtypes = Koha::ItemTypes->search_with_localization()->as_list;
    my %labels = map { $_->itemtype => $_->description } @itemtypes;
    my @values = ('', map { $_->itemtype } @itemtypes);

    is($subfield->{marc_value}->{type}, 'select');
    is_deeply($subfield->{marc_value}->{labels}, \%labels);
    is_deeply($subfield->{marc_value}->{values}, \@values);
};

subtest 'generate_subfield_form class sources' => sub {
    my $builder = Koha::UI::Form::Builder::Biblio->new();

    my $subfield = $builder->generate_subfield_form(
        {
            tag => '999',
            subfield => '9',
            value => '',
            index_tag => int(rand(1000000)),
            tagslib => {
                '999' => {
                    '9' => {
                        authorised_value => 'cn_source',
                        hidden => 0,
                    }
                }
            },
        },
    );

    my @class_sources = Koha::ClassSources->search({used => 1}, {order_by => 'cn_source'})->as_list;
    my %labels = map { $_->cn_source => $_->description } @class_sources;
    my @values = ('', map { $_->cn_source } @class_sources);

    is($subfield->{marc_value}->{type}, 'select');
    is_deeply($subfield->{marc_value}->{labels}, \%labels);
    is_deeply($subfield->{marc_value}->{values}, \@values);
};

subtest 'generate_subfield_form authorised value' => sub {
    my $builder = Koha::UI::Form::Builder::Biblio->new();

    my $subfield = $builder->generate_subfield_form(
        {
            tag => '999',
            subfield => '9',
            value => '',
            index_tag => int(rand(1000000)),
            tagslib => {
                '999' => {
                    '9' => {
                        authorised_value => 'YES_NO',
                        hidden => 0,
                    }
                }
            },
        },
    );

    my @authorised_values = Koha::AuthorisedValues->search({category => 'YES_NO'}, {order_by => ['lib', 'lib_opac']})->as_list;
    my %labels = map { $_->authorised_value => $_->lib } @authorised_values;
    my @values = ('', map { $_->authorised_value } @authorised_values);

    is($subfield->{marc_value}->{type}, 'select');
    is_deeply($subfield->{marc_value}->{labels}, \%labels);
    is_deeply($subfield->{marc_value}->{values}, \@values);
};

subtest 'generate_subfield_form framework plugin' => sub {
    my $builder = Koha::UI::Form::Builder::Biblio->new();

    my $subfield = $builder->generate_subfield_form(
        {
            tag => '999',
            subfield => '9',
            value => '',
            index_tag => int(rand(1000000)),
            tagslib => {
                '999' => {
                    '9' => {
                        value_builder => 'barcode.pl',
                        hidden => 0,
                    }
                }
            },
        },
    );

    is($subfield->{marc_value}->{type}, 'text_complex');
    is($subfield->{marc_value}->{plugin}, 'barcode.pl');
    is($subfield->{marc_value}->{noclick}, 1);
    like($subfield->{marc_value}->{javascript}, qr,<script>.*</script>,s);
};

done_testing();
