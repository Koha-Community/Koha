#!/usr/bin/perl
package Koha::Procurement::OrderProcessor::Basket;

use Moose;
use C4::Acquisition;
use Data::Dumper;
my $baskets = {};

sub getBasket {
    my $self = shift;
    my ($bookseler, $authoriser, $basketName) = @_;
    my $basket = 0;
    if(defined $basketName ){
        if(!defined $baskets->{$basketName}){
            my $basketNo = $self->createBasket($bookseler, $authoriser, $basketName);
        }

        if(defined $baskets->{$basketName}){
            $basket = $baskets->{$basketName};
        }
    }
    return $basket;
}

sub createBasket {
    my $self = shift;
    my $bookseller = $_[0];
    my $authoriser = $_[1];
    my $basketName = $_[2];
    my $basket = 0;

    if( defined $basketName && defined $authoriser && defined $bookseller ){
        $basket = NewBasket(($bookseller, $authoriser, $basketName));
        $baskets->{$basketName} = $basket;
    }
    return $basket;
}

sub unsetBasket{
    my $self = shift;
    my $basketName = $_[0];
    my $result = 0;

    if( defined $basketName && defined $baskets->{$basketName} ){
        $result = delete $baskets->{$basketName};
    }
    return $result;
}

sub closeBasket {
    my $self = shift;
    my $basketName = $_[0];
    my $result = 0;
    my $basket;
    if(defined $basketName && defined $baskets->{$basketName}){
        $basket = $baskets->{$basketName};

        if(defined $basket){
            CloseBasket($basket);
            $self->unsetBasket($basketName);
        }
    }
    return $result;
}
