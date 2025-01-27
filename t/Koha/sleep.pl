#!/usr/bin/perl

use Modern::Perl;

use Koha::Script;

# # Lock execution
my $script = Koha::Script->new( { script => 'sleep.pl' } );

$script->lock_exec;

# Sleep for a while, we need to force the concurrent access to the
# lock file
sleep 2;

# Normal exit
1;
