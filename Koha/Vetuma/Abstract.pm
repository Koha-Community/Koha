#!/usr/bin/perl
package Koha::Vetuma::Abstract;

use Modern::Perl;
use POSIX qw(strftime);
use Digest::SHA qw(sha256_hex);
use Tie::IxHash;

use Moose;

my  %Params;

sub setParam{
    my $self = shift;
    my $paramKey = $_[0];
    my $paramValue = $_[1];
    if( exists $Params{$paramKey} ){
        $Params{$paramKey} = $paramValue;
    }
}

sub getParam{
    my $self = shift;
    my $paramKey = $_[0];
    if( exists $Params{$paramKey} ){
        return  $Params{$paramKey};
    }
}

sub unsetParam{
    my $self = shift;
    my $paramKey = $_[0];
    delete $Params{$paramKey};
}

sub setParams{
    my $self = shift;
    my $params = $_[0];
    %Params = %{$params};
}

sub getParams{
    my $self = shift;
    return \%Params;
}

sub setSharedSecret{
    my $self = shift;
    $self->{sharedSecret} = $_[0];
}

sub getSharedSecret{
    my $self = shift;
    return $self->{sharedSecret};
}

sub calculateMac{
    my $self = shift;
    my $macString = '';
    my $sharedSecret = $self->getSharedSecret();

    if(!defined $sharedSecret){
      return;
    }

    while (my ($key, $val) = each %Params) {
        if( $key eq 'MAC'){
            next;
        }

        if( $macString eq ''){
            $macString = $val;
        }
        else{
            $macString = $macString . '&' . $val;
        }
    }

    $macString = $macString . '&' . $sharedSecret . '&';
    my $hashedMac = sha256_hex($macString);
    $hashedMac = uc($hashedMac);
    return $hashedMac;
}

sub validateParams{
    my $self = shift;
    while (my ($key, $val) = each %Params) {
        if( $val eq '*' && $key ne 'MAC' ){
            return 0;
        }
        if($val eq ''){
            $self->unsetParam($key);
        }
        if($val eq '-'){ #param exists in request and was empty
            $self->setParam($key,'');
        }
    }
    return 1;
}

sub getTimestampMysql{
    my $self = shift;
    my $unixTimestamp = $_[0];
    my $timeStamp = strftime('%Y-%m-%d %H:%M:%S',localtime($unixTimestamp));
    return $timeStamp;
}


1;
