package KohaTest::Items::SetDefaults;
use base qw( KohaTest::Items );

use strict;
use warnings;

use Test::More;

use C4::Items;

=head2 STARTUP METHODS

These get run once, before the main test methods in this module

=cut

=head2 TEST METHODS

standard test methods

=head3 


=cut

sub add_some_items : Test( 3 ) {

    my $item_to_add_1 = { itemnotes => 'newitem', };

    C4::Items::_set_defaults_for_add($item_to_add_1);
    ok( exists $item_to_add_1->{'dateaccessioned'}, 'dateaccessioned added to new item' );
    like( $item_to_add_1->{'dateaccessioned'}, qr/^\d\d\d\d-\d\d-\d\d$/, 'new dateaccessioned is dddd-dd-dd' );
    is( $item_to_add_1->{'itemnotes'}, 'newitem', 'itemnotes not clobbered' );

}

sub undefined : Test( 4 ) {
    my $item_add_fixes_1 = {
        notforloan => undef,
        damaged    => undef,
        wthdrawn   => undef,
        itemlost   => undef,
    };

    C4::Items::_set_defaults_for_add($item_add_fixes_1);
    is( $item_add_fixes_1->{'notforloan'}, 0, 'null notforloan fixed during add' );
    is( $item_add_fixes_1->{'damaged'},    0, 'null damaged fixed during add' );
    is( $item_add_fixes_1->{'wthdrawn'},   0, 'null wthdrawn fixed during add' );
    is( $item_add_fixes_1->{'itemlost'},   0, 'null itemlost fixed during add' );
}

sub empty_gets_fixed : Test( 4 ) {

    my $item_add_fixes_2 = {
        notforloan => '',
        damaged    => '',
        wthdrawn   => '',
        itemlost   => '',
    };

    C4::Items::_set_defaults_for_add($item_add_fixes_2);
    is( $item_add_fixes_2->{'notforloan'}, 0, 'empty notforloan fixed during add' );
    is( $item_add_fixes_2->{'damaged'},    0, 'empty damaged fixed during add' );
    is( $item_add_fixes_2->{'wthdrawn'},   0, 'empty wthdrawn fixed during add' );
    is( $item_add_fixes_2->{'itemlost'},   0, 'empty itemlost fixed during add' );

}

sub do_not_clobber : Test( 4 ) {

    my $item_add_fixes_3 = {
        notforloan => 1,
        damaged    => 2,
        wthdrawn   => 3,
        itemlost   => 4,
    };

    C4::Items::_set_defaults_for_add($item_add_fixes_3);
    is( $item_add_fixes_3->{'notforloan'}, 1, 'do not clobber notforloan during mod' );
    is( $item_add_fixes_3->{'damaged'},    2, 'do not clobber damaged during mod' );
    is( $item_add_fixes_3->{'wthdrawn'},   3, 'do not clobber wthdrawn during mod' );
    is( $item_add_fixes_3->{'itemlost'},   4, 'do not clobber itemlost during mod' );

}

1;
