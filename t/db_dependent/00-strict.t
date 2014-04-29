# This script is called by the pre-commit git hook to test modules compile

use strict;
use warnings;
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
    'patroncards', 'reports', 'reserve', 'resetversion.pl', 'reviews',
    'rewrite-config.PL', 'rotating_collections', 'serials', 'services', 'skel',
    'sms', 'suggestion', 'svc', 'tags', 'tools', 'virtualshelves' );

$Test::Strict::TEST_STRICT = 0;
$Test::Strict::TEST_SKIP = [ 'misc/kohalib.pl', 'sms/sms_listen_windows_start.pl', 'misc/plack/koha.psgi' ];

all_perl_files_ok(@dirs);
