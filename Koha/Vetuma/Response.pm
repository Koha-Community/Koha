#!/usr/bin/perl
package Koha::Vetuma::Response;
use Moose;
extends 'Koha::Vetuma::Abstract';

sub BUILD {
    my $self = shift;
    $self->initEmptyParams();
}

sub initEmptyParams{
    my $self = shift;

    tie(%{$self->getParams()}, 'Tie::IxHash',
    RCVID => '*',
    TIMESTMP => '*',
    SO => '*',
    LG => '*',
    RETURL => '*',
    CANURL=> '*',
    ERRURL => '*',
    MAC => '*',
    PAYID => '-',
    REF => '*',
    ORDNR => '',
    PAID => '-',
    STATUS => '*',
    TRID  => '*');
}

sub initFromCgi{
    my $self = shift;
    my $request = $_[0];

    while (my ($key, $val) = each %{$self->getParams()}) {
        my $responseParam = $request->param($key);
        if(defined $responseParam){
            if($val eq '-' && $responseParam eq ''){
                next;
            }
            $self->setParam($key,$responseParam);
        }
        else{
	        $self->unsetParam($key);
        }
    }
}

sub validateResponse{
    my $self = shift;
    $self->validateParams();
    my $calculatedMac = $self->calculateMac();
    if($calculatedMac eq $self->getParam('MAC')){
        return 1;
    }
    return 0;
}


1;
