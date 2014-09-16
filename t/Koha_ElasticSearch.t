#
#===============================================================================
#
#         FILE: Koha_ElasticSearch.t
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Chris Cormack (rangi), chrisc@catalyst.net.nz
# ORGANIZATION: Koha Development Team
#      VERSION: 1.0
#      CREATED: 09/12/13 08:56:44
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More tests => 1;                      # last test to print

use_ok('Koha::ElasticSearch');
