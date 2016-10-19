#!/usr/bin/perl
package Koha::Vetuma::Message;
use Moose;

use CGI;
use CGI::Session;
use C4::Auth qw( get_session);

our $session;

sub getMessages{
    my $self = shift;;
    if(defined $session){
        return $session->param('vetuma_messages');
    }
}

sub addMessage{
    my $self = shift;
    my $message = $_[0];
    print $session;
    $session->param('vetuma_messages',"hellllo");
    if(defined $session){
       # $session->param('vetuma_messages',"hellllo");
    }
}

sub setSession{
    my $self = shift;
    my $sessionId = $_[0];
    if(defined $sessionId ){
        $session = get_session($sessionId);
    }
}

1;
