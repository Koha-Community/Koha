#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 28;
BEGIN {
	use FindBin;
	use lib $FindBin::Bin;
	# use override_context_prefs;
        use_ok('C4::Items');
}

my $item_mod_fixes_1 = {
    notforloan => undef,
    damaged    => undef,
    wthdrawn   => undef,
    itemlost   => undef,
};

my $item_mod_fixes_2 = {
    notforloan => '',
    damaged    => '',
    wthdrawn   => '',
    itemlost   => '',
};

my $item_mod_fixes_3 = {
    notforloan => 1,
    damaged    => 2,
    wthdrawn   => 3,
    itemlost   => 4,
};

C4::Items::_do_column_fixes_for_mod($item_mod_fixes_1);
is($item_mod_fixes_1->{'notforloan'}, 0, 'null notforloan fixed during mod');
is($item_mod_fixes_1->{'damaged'}, 0, 'null damaged fixed during mod');
is($item_mod_fixes_1->{'wthdrawn'}, 0, 'null wthdrawn fixed during mod');
is($item_mod_fixes_1->{'itemlost'}, 0, 'null itemlost fixed during mod');

C4::Items::_do_column_fixes_for_mod($item_mod_fixes_2);
is($item_mod_fixes_2->{'notforloan'}, 0, 'empty notforloan fixed during mod');
is($item_mod_fixes_2->{'damaged'}, 0, 'empty damaged fixed during mod');
is($item_mod_fixes_2->{'wthdrawn'}, 0, 'empty wthdrawn fixed during mod');
is($item_mod_fixes_2->{'itemlost'}, 0, 'empty itemlost fixed during mod');

C4::Items::_do_column_fixes_for_mod($item_mod_fixes_3);
is($item_mod_fixes_3->{'notforloan'}, 1, 'do not clobber notforloan during mod');
is($item_mod_fixes_3->{'damaged'}, 2, 'do not clobber damaged during mod');
is($item_mod_fixes_3->{'wthdrawn'}, 3, 'do not clobber wthdrawn during mod');
is($item_mod_fixes_3->{'itemlost'}, 4, 'do not clobber itemlost during mod');

my $item_to_add_1 = {
    itemnotes => 'newitem',
};

C4::Items::_set_defaults_for_add($item_to_add_1);
ok(exists $item_to_add_1->{'dateaccessioned'}, 'dateaccessioned added to new item');
like($item_to_add_1->{'dateaccessioned'}, qr/^\d\d\d\d-\d\d-\d\d$/ , 'new dateaccessioned is dddd-dd-dd');
is($item_to_add_1->{'itemnotes'}, 'newitem', 'itemnotes not clobbered');

my $item_add_fixes_1 = {
    notforloan => undef,
    damaged    => undef,
    wthdrawn   => undef,
    itemlost   => undef,
};

my $item_add_fixes_2 = {
    notforloan => '',
    damaged    => '',
    wthdrawn   => '',
    itemlost   => '',
};

my $item_add_fixes_3 = {
    notforloan => 1,
    damaged    => 2,
    wthdrawn   => 3,
    itemlost   => 4,
};

C4::Items::_set_defaults_for_add($item_add_fixes_1);
is($item_add_fixes_1->{'notforloan'}, 0, 'null notforloan fixed during add');
is($item_add_fixes_1->{'damaged'}, 0, 'null damaged fixed during add');
is($item_add_fixes_1->{'wthdrawn'}, 0, 'null wthdrawn fixed during add');
is($item_add_fixes_1->{'itemlost'}, 0, 'null itemlost fixed during add');

C4::Items::_set_defaults_for_add($item_add_fixes_2);
is($item_add_fixes_2->{'notforloan'}, 0, 'empty notforloan fixed during add');
is($item_add_fixes_2->{'damaged'}, 0, 'empty damaged fixed during add');
is($item_add_fixes_2->{'wthdrawn'}, 0, 'empty wthdrawn fixed during add');
is($item_add_fixes_2->{'itemlost'}, 0, 'empty itemlost fixed during add');

C4::Items::_set_defaults_for_add($item_add_fixes_3);
is($item_add_fixes_3->{'notforloan'}, 1, 'do not clobber notforloan during mod');
is($item_add_fixes_3->{'damaged'}, 2, 'do not clobber damaged during mod');
is($item_add_fixes_3->{'wthdrawn'}, 3, 'do not clobber wthdrawn during mod');
is($item_add_fixes_3->{'itemlost'}, 4, 'do not clobber itemlost during mod');

