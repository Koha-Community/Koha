#!/usr/bin/perl

use strict;
use warnings;

use File::Basename;
use File::Spec;
use Test::More;
use Test::MockModule;
use Test::Warn;

my $contextModule = new Test::MockModule('C4::Context');
$contextModule->mock('preference', sub {
    return '';
});
$contextModule->mock('config', sub {
    my ($self,$key) = @_;
    if ($key eq 'opachtdocs') {
        return get_where() . '/koha-tmpl/opac-tmpl';
    } elsif ($key eq 'intrahtdocs') {
        return get_where() . '/koha-tmpl/intranet-tmpl';
    } else {
        return '';
    }
});

use_ok('Koha::SuggestionEngine');

sub get_where {
    my $location = File::Spec->rel2abs(dirname(__FILE__));
    if ($location =~ /db_dependent/) {
        $location .= '/../..';
    }
    else {
        $location .= '/..';
    }
    return $location;
}

my $langModule;
if (! defined $ENV{KOHA_CONF}) {
    warning_like { $langModule = new Test::MockModule('C4::Languages'); }
        qr /unable to locate Koha configuration file koha-conf.xml/,
        'Expected warning for unset $KOHA_CONF';
}
else {
    $langModule = new Test::MockModule('C4::Languages');
}
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
my $tmplModule;
if (! defined $ENV{KOHA_CONF}) {
    warning_like { $tmplModule = new Test::MockModule('C4::Templates'); }
        qr /unable to locate Koha configuration file koha-conf.xml/,
        'Expected warning for unset $KOHA_CONF';
}
else {
    $tmplModule = new Test::MockModule('C4::Templates');
}
$tmplModule->mock('_get_template_file', sub {
    my ($tmplbase, $interface, $query) = @_;
    my $opactmpl = get_where() . '/koha-tmpl/opac-tmpl';
    return ($opactmpl, 'bootstrap', 'en', "$opactmpl/bootstrap/en/modules/$tmplbase");
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
