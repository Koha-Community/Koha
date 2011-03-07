package KohaTest::Reserves;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Reserves;
sub testing_class { 'C4::Reserves' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw(  AddReserve 
                       GetReservesFromBiblionumber 
                       GetReservesFromItemnumber 
                       GetReservesFromBorrowernumber 
                       GetReserveCount 
                       GetOtherReserves 
                       GetReserveFee 
                       GetReservesToBranch 
                       GetReservesForBranch 
                       CheckReserves 
                       CancelReserve 
                       ModReserve 
                       ModReserveFill 
                       ModReserveStatus 
                       ModReserveAffect 
                       ModReserveCancelAll 
                       ModReserveMinusPriority 
                       GetReserveInfo 
                       _FixPriority 
                       _Findgroupreserve 
                );
    
    can_ok( $self->testing_class, @methods );    
}

1;

