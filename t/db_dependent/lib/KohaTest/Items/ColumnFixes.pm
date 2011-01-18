package KohaTest::Items::ColumnFixes;
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

=head3 not_defined


=cut

sub not_defined : Test( 4 ) {

    my $item_mod_fixes_1 = {
        notforloan => undef,
        damaged    => undef,
        wthdrawn   => undef,
        itemlost   => undef,
    };

    C4::Items::_do_column_fixes_for_mod($item_mod_fixes_1);
    is( $item_mod_fixes_1->{'notforloan'}, 0, 'null notforloan fixed during mod' );
    is( $item_mod_fixes_1->{'damaged'},    0, 'null damaged fixed during mod' );
    is( $item_mod_fixes_1->{'wthdrawn'},   0, 'null wthdrawn fixed during mod' );
    is( $item_mod_fixes_1->{'itemlost'},   0, 'null itemlost fixed during mod' );

}

sub empty : Test( 4 ) {

    my $item_mod_fixes_2 = {
        notforloan => '',
        damaged    => '',
        wthdrawn   => '',
        itemlost   => '',
    };

    C4::Items::_do_column_fixes_for_mod($item_mod_fixes_2);
    is( $item_mod_fixes_2->{'notforloan'}, 0, 'empty notforloan fixed during mod' );
    is( $item_mod_fixes_2->{'damaged'},    0, 'empty damaged fixed during mod' );
    is( $item_mod_fixes_2->{'wthdrawn'},   0, 'empty wthdrawn fixed during mod' );
    is( $item_mod_fixes_2->{'itemlost'},   0, 'empty itemlost fixed during mod' );

}

sub not_clobbered : Test( 4 ) {

    my $item_mod_fixes_3 = {
        notforloan => 1,
        damaged    => 2,
        wthdrawn   => 3,
        itemlost   => 4,
    };

    C4::Items::_do_column_fixes_for_mod($item_mod_fixes_3);
    is( $item_mod_fixes_3->{'notforloan'}, 1, 'do not clobber notforloan during mod' );
    is( $item_mod_fixes_3->{'damaged'},    2, 'do not clobber damaged during mod' );
    is( $item_mod_fixes_3->{'wthdrawn'},   3, 'do not clobber wthdrawn during mod' );
    is( $item_mod_fixes_3->{'itemlost'},   4, 'do not clobber itemlost during mod' );

}

1;
