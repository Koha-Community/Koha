#!/usr/bin/perl
#
# This Koha test module uses Test::MockModule to get around the need for known
# contents in the authority file by returning a single known authority record
# for every call to SearchAuthorities

use strict;
use warnings;
use File::Spec;
use MARC::Record;

use Test::More;
use Test::MockModule;

BEGIN {
        use_ok('Koha::SuggestionEngine');
}

my $module = new Test::MockModule('C4::AuthoritiesMarc');
$module->mock('SearchAuthorities', sub {
        return [ { 'authid' => '1234',
                    'reported_tag' => undef,
                    'even' => 0,
                    'summary' => {
                        'authorized' => [ { 'heading' => 'Cooking' } ],
                        'otherscript' => [],
                        'seefrom' => [ 'Cookery' ],
                        'notes' => [ 'Your quintessential poor heading selection' ],
                        'seealso' => []
                    },
                    'used' => 1,
                    'authtype' => 'Topical Term'
                } ], 1
});

my $suggestor = Koha::SuggestionEngine->new( { plugins => [ 'AuthorityFile' ] } );
is(ref($suggestor), 'Koha::SuggestionEngine', 'Created suggestion engine');

my $result = $suggestor->get_suggestions({search => 'Cookery'});

is_deeply($result, [ { 'search' => 'an=1234', 'relevance' => 1, 'label' => 'Cooking' } ], "Suggested correct alternative to 'Cookery'");

done_testing();
