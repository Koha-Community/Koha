package KohaTest::Serials;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Serials;
sub testing_class { 'C4::Serials' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw( GetSuppliersWithLateIssues
                      GetLateIssues
                      GetSubscriptionHistoryFromSubscriptionId
                      GetSerialStatusFromSerialId
                      GetSerialInformation
                      AddItem2Serial
                      UpdateClaimdateIssues
                      GetSubscription
                      GetFullSubscription
                      PrepareSerialsData
                      GetSubscriptionsFromBiblionumber
                      GetFullSubscriptionsFromBiblionumber
                      GetSubscriptions
                      GetSerials
                      GetSerials2
                      GetLatestSerials
                      GetNextSeq
                      GetSeq
                      GetExpirationDate
                      CountSubscriptionFromBiblionumber
                      ModSubscriptionHistory
                      ModSerialStatus
                      ModSubscription
                      NewSubscription
                      ReNewSubscription
                      NewIssue
                      ItemizeSerials
                      HasSubscriptionExpired
                      DelSubscription
                      DelIssue
                      GetLateOrMissingIssues
                      removeMissingIssue
                      updateClaim
                      getsupplierbyserialid
                      check_routing
                      addroutingmember
                      reorder_members
                      delroutingmember
                      getroutinglist
                      countissuesfrom
                      abouttoexpire
                      old_newsubscription
                      old_modsubscription
                      old_getserials
                      in_array
                      GetNextDate
                      itemdata
                );
    
    can_ok( $self->testing_class, @methods );    
}

1;

