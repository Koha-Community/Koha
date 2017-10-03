# This script is called by the pre-commit git hook to test modules compile

use strict;
use warnings;
use Module::Load::Conditional qw[can_load check_install requires];
use Test::More;
use Test::Strict;
use File::Spec;
use File::Find;
use lib("misc/translator");
use lib("installer");

my @dirs = ( 'acqui', 'admin', 'authorities', 'basket',
    'catalogue', 'cataloguing', 'changelanguage.pl', 'circ', 'debian', 'docs',
    'edithelp.pl', 'errors', 'fix-perl-path.PL', 'help.pl', 'installer',
    'koha_perl_deps.pl', 'kohaversion.pl', 'labels',
    'mainpage.pl', 'Makefile.PL', 'members', 'misc', 'offline_circ', 'opac',
    'patroncards', 'reports', 'reserve', 'reviews',
    'rewrite-config.PL', 'rotating_collections', 'serials', 'services', 'skel',
    'sms', 'suggestion', 'svc', 'tags', 'tools', 'virtualshelves' );

$Test::Strict::TEST_STRICT = 0;

my $general_skips = [ 'misc/kohalib.pl', 'sms/sms_listen_windows_start.pl', 'misc/plack/koha.psgi' ];
my $elastic_search_files = [ 'misc/search_tools/rebuild_elastic_search.pl' ];
my @skips;
push @skips,@$general_skips;
if ( ! can_load(
    modules => { 'Koha::SearchEngine::Elasticsearch::Indexer' => undef, } )
) {
    my $missing_module;
    if ( $Module::Load::Conditional::ERROR =~ /Can\'t locate (.*?) / ) {
        $missing_module = $1;
    }
    my $es_dep_msg = "Required module $missing_module is not installed";
    diag $es_dep_msg;
    my $skip_what_msg = "Skipping: " . join ',', @$elastic_search_files;
    diag $skip_what_msg;
    push @skips, @$elastic_search_files;
}
push @$Test::Strict::TEST_SKIP, @skips;

all_perl_files_ok(@dirs);
