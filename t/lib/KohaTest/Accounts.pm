package KohaTest::Accounts;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Accounts;
sub testing_class { 'C4::Accounts' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw( recordpayment
                      makepayment
                      getnextacctno
                      fixaccounts
                      returnlost
                      manualinvoice
                      fixcredit
                      refund
                      getcharges
                      getcredits
                      getrefunds
                );
    
    can_ok( $self->testing_class, @methods );    
}

1;
