#!/usr/bin/perl
use HTML::Tree;
use Getopt::Std;
getopt("f:");
	my $tree = HTML::TreeBuilder->new; # empty tree

	$tree->parse_file($opt_f);
	sub give_id {
		my $x = $_[0];
		foreach my $c ($x->content_list) {
			next if (ref($c) && $c->tag() eq "~comment");
			print "$c\n" unless ref($c);
			if (ref($c) && $c->attr('alt')) {
				print $c->attr('alt')."\n";
			}
			if (ref($c) && $c->tag() eq 'meta') {
				print $c->attr('content')."\n ";
			}
			give_id($c) if ref $c; # ignore text nodes
		}
	};
	give_id($tree);
	$tree = $tree->delete;
