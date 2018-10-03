#!/usr/bin/perl
#use strict;
#use warnings; FIXME - Bug 2505

use FindBin;
use lib $FindBin::Bin;

use HTML::Tree;
use Getopt::Std;
getopt("f:");
	my $tree = HTML::TreeBuilder->new; # empty tree

	$tree->parse_file($opt_f);
	sub give_id {
		my $x = $_[0];
		foreach my $c ($x->content_list) {
			next if (ref($c) && $c->tag() eq "~comment");
			next if (ref($c) && $c->tag() eq "script");
			next if (ref($c) && $c->tag() eq "style");
			if (!ref($c)) {
				print "$c\n";
			}
			if (ref($c) && $c->attr('alt')) {
				print $c->attr('alt')."\n";
			}
			if (ref($c) && $c->attr('title')) {
				print $c->attr('title')."\n";
			}
			if (ref($c) && $c->tag() eq "input" && $c->attr('value')) {
				print $c->attr('value')."\n";
			}
			if (ref($c) && $c->tag() eq 'meta') {
				print $c->attr('content')."\n ";
			}
			give_id($c) if ref $c; # ignore text nodes
		}
	};
	give_id($tree);
	$tree = $tree->delete;
