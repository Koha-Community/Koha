#!/usr/bin/perl
package Koha::Vetuma::Request;
use Moose;
extends 'Koha::Vetuma::Abstract';

use POSIX qw(strftime);
use Digest::SHA qw(sha1_hex);
use Scalar::Util qw(looks_like_number);

sub BUILD {
    my $self = shift;
    $self->initEmptyParams();
}

#Request parameters in the order required by the api.
#Requirded params marked with '*'.
#Constant params also supplied here.
sub initEmptyParams{
    my $self = shift;

    tie(%{$self->getParams()}, 'Tie::IxHash',
    RCVID => '*',
    APPID => '*',
    TIMESTMP => '*',
    SO => '*',
    SOLIST => '*',
    TYPE => 'PAYMENT',
    AU => 'PAY',
    LG => '*',
    RETURL => '*',
    CANURL=> '*',
    ERRURL => '*',
    AP => '*',
    MAC => '*',
    APPNAME => '',
    AM => '*',
    REF => '',
    ORDNR => '',
    MSGBUYER => '',
    MSGSELLER => '',
    MSGFORM  => '',
    TRID => '',
    PAYM_CALL_ID => '');
}

my $localTimeAtCreation;

sub setRequestUrl{
    my $self = shift;
    $self->{requestUrl} = $_[0];
}

sub getRequestUrl{
    my $self = shift;
    return $self->{requestUrl};
}

sub initRequest{
    my $self = shift;
    my $ok = 0;
    $self->addTimestamp();
    if($self->validateParams()){
        my $hashedMac = $self->calculateMac();
        if(defined $hashedMac){
            $self->setParam('MAC',$hashedMac);
            $ok = 1;
        }
    }
    return $ok;
}

sub setAmount{
     my $self = shift;
     my $amount = $_[0];
     my $amountString = "$amount";

    if(looks_like_number($amount)){
        my ( $whole, $fraction ) = split(/[,.]/,$amountString);
        $fraction .= '00';
        $amountString = $whole . "," . substr( $fraction, 0, 2 );
        $self->setParam('AM',$amountString);
    }
}

sub createReferenceNumber{
     my $self = shift;
     my $cardnumber = $_[0];
     $cardnumber =~ s/\D//g;    #All non numerics removed from the cardnumber ( Outi cardnumber has an 'A' in it. And the vetuma api does not support this ).
     my $libraryReferenceCode = $_[1];
     my $ref;

     if( looks_like_number($libraryReferenceCode) && looks_like_number($cardnumber) ){
         $ref = $libraryReferenceCode . sprintf("%016d", $cardnumber);
         my $checkSum = $self->addRefCheckSum($ref);
         $ref = $ref . $checkSum;
         $self->setParam('REF',$ref);
     }
}

sub addRefCheckSum{
    my $self = shift;
    my $ref = $_[0];
    my $checkSum = 0;
    my @weights = (1,3,7);
    my $i = 0;

    for my $refNumber (split //, $ref) {
        if($i == @weights ){
            $i = 0;
        }
        $checkSum = $checkSum + ( $refNumber * $weights[$i] );
        $i++;
    }
    my $nextTen = $checkSum + 9;
    $nextTen = $nextTen - ($nextTen % 10);
    return $nextTen - $checkSum;
}

sub createTrid{
     my $self = shift;
     my $cardnumber = $_[0];
     my $tridString = $cardnumber . localtime;
     my $trid = sha1_hex($tridString);
     $trid = substr( $trid, 0, 20 );
     $self->setParam('TRID',$trid);
}

sub addTimestamp{
    my $self = shift;
    $localTimeAtCreation = time;
    my $timeStamp = strftime('%Y%m%d%H%M%S',localtime($localTimeAtCreation));
    $timeStamp = $timeStamp . '000';
    $self->setParam('TIMESTMP',$timeStamp);
}

1;
