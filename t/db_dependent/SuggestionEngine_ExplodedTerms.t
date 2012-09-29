#!/usr/bin/perl

use strict;
use warnings;

use File::Basename;
use File::Spec;
use Test::More;
use Test::MockModule;

BEGIN {
        use_ok('Koha::SuggestionEngine');
}

my $langModule = new Test::MockModule('C4::Languages');
$langModule->mock('regex_lang_subtags', sub {
    return {
        'extension' => undef,
        'script' => undef,
        'privateuse' => undef,
        'variant' => undef,
        'language' => 'en',
        'region' => undef,
        'rfc4646_subtag' => 'en'
    };
});
$langModule->mock('getTranslatedLanguages', sub {
   return [
       {
           'sublanguages_loop' => [
           {
               'script' => undef,
               'extension' => undef,
               'language' => 'en',
               'region' => undef,
               'region_description' => undef,
               'sublanguage_current' => 1,
               'privateuse' => undef,
               'variant' => undef,
               'variant_description' => undef,
               'script_description' => undef,
               'rfc4646_subtag' => 'en',
               'native_description' => 'English',
               'enabled' => 1
           },
           ],
           'plural' => 1,
           'language' => 'en',
           'current' => 1,
           'native_description' => 'English',
           'rfc4646_subtag' => 'en',
           'group_enabled' => 1
       }
   ];
});
my $tmplModule = new Test::MockModule('C4::Templates');
$tmplModule->mock('_get_template_file', sub {
    my ($tmplbase, $interface, $query) = @_;
    my $opactmpl = File::Spec->rel2abs(dirname(__FILE__) . '/../koha-tmpl/opac-tmpl');
    return ($opactmpl, 'prog', 'en', "$opactmpl/prog/en/modules/$tmplbase");
});
my $contextModule = new Test::MockModule('C4::Context');
$contextModule->mock('preference', sub {
    return '';
});
$contextModule->mock('config', sub {
    return '';
});


my $suggestor = Koha::SuggestionEngine->new( { plugins => [ 'ExplodedTerms' ] } );
is(ref($suggestor), 'Koha::SuggestionEngine', 'Created suggestion engine');

my $result = $suggestor->get_suggestions({search => 'Cookery'});

ok((grep { $_->{'search'} eq 'su-na=Cookery' } @$result) && (grep { $_->{'search'} eq 'su-br=Cookery' } @$result) && (grep { $_->{'search'} eq 'su-rl=Cookery' } @$result), "Suggested correct alternatives for keyword search 'Cookery'");

$result = $suggestor->get_suggestions({search => 'su:Cookery'});

ok((grep { $_->{'search'} eq 'su-na=Cookery' } @$result) && (grep { $_->{'search'} eq 'su-br=Cookery' } @$result) && (grep { $_->{'search'} eq 'su-rl=Cookery' } @$result), "Suggested correct alternatives for subject search 'Cookery'");

$result = $suggestor->get_suggestions({search => 'nt:Cookery'});

is(scalar @$result, 0, "No suggestions for fielded search");

$result = $suggestor->get_suggestions({search => 'ccl=su:Cookery'});

is(scalar @$result, 0, "No suggestions for CCL search");

done_testing();
