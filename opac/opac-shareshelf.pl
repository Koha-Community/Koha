#!/usr/bin/perl

# Copyright 2013 Rijksmuseum
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;

use constant KEYLENGTH => 10;
use constant TEMPLATE_NAME => 'opac-shareshelf.tmpl';

use CGI;
use Email::Valid;

use C4::Auth;
use C4::Context;
use C4::Letters;
use C4::Output;
use C4::VirtualShelves;

#-------------------------------------------------------------------------------

my $pvar= _init( {} );
if(! $pvar->{errcode} ) {
    show_invite( $pvar ) if $pvar->{op} eq 'invite';
    confirm_invite( $pvar ) if $pvar->{op} eq 'conf_invite';
    show_accept( $pvar ) if $pvar->{op} eq 'accept';
}
load_template_vars( $pvar );
output_html_with_http_headers $pvar->{query}, $pvar->{cookie},
    $pvar->{template}->output;

#-------------------------------------------------------------------------------

sub _init {
    my ($param) = @_;
    my $query = new CGI;
    $param->{query} = $query;
    $param->{shelfnumber} = $query->param('shelfnumber')||0;
    $param->{op} = $query->param('op')||'';
    $param->{addrlist} = $query->param('invite_address')||'';
    $param->{key} = $query->param('key')||'';
    $param->{appr_addr} = [];

    $param->{errcode} = check_common_errors($param);
    load_template($param);
    return $param;
}

sub check_common_errors {
    my ($param) = @_;
    if( $param->{op} !~ /^(invite|conf_invite|accept)$/ ) {
        return 1; #no operation specified
    }
    if( $param->{shelfnumber} !~ /^\d+$/ ) {
        return 2; #invalid shelf number
    }
    if( ! C4::Context->preference('OpacAllowSharingPrivateLists') ) {
        return 3; #not or no longer allowed?
    }
    return;
}

sub show_invite {
    my ($param) = @_;
    return unless check_owner_category( $param );
}

sub confirm_invite {
    my ($param) = @_;
    return unless check_owner_category( $param );
    process_addrlist( $param );
    if( @{$param->{appr_addr}} ) {
        send_invitekey( $param );
    }
    else {
        $param->{errcode}=6; #not one valid address
    }
}

sub show_accept {
    my ($param) = @_;
    #TODO Add some code here to accept an invitation (followup report)
}

sub process_addrlist {
    my ($param) = @_;
    my @temp= split /[,:;]/, $param->{addrlist};
    my @appr_addr;
    my $fail_addr='';
    foreach my $a (@temp) {
        $a=~s/^\s+//;
        $a=~s/\s+$//;
        if( IsEmailAddress($a) ) {
            push @appr_addr, $a;
        }
        else {
            $fail_addr.= ($fail_addr? '; ': '').$a;
        }
    }
    $param->{appr_addr}= \@appr_addr;
    $param->{fail_addr}= $fail_addr;
}

sub send_invitekey {
    my ($param) = @_;
    my $fromaddr= C4::Context->preference('KohaAdminEmailAddress');
    my $url= 'http://'.C4::Context->preference('OPACBaseURL').
        "/cgi-bin/koha/opac-shareshelf.pl?shelfnumber=".
        $param->{shelfnumber}."&op=accept&key=";
        #TODO Waiting for the right http or https solution (BZ 8952 a.o.)

    foreach my $a ( @{$param->{appr_addr}} ) {
        my @newkey= randomlist(KEYLENGTH, 64); #generate a new key

        #prepare letter
        my $letter= C4::Letters::GetPreparedLetter(
            module => 'members',
            letter_code => 'SHARE_INVITE',
            branchcode => C4::Context->userenv->{"branch"},
            tables => { borrowers => $param->{loggedinuser}, },
            substitute => {
                listname => $param->{shelfname},
                shareurl => $url.keytostring(\@newkey,0),
            },
        );

        #send letter to queue
        C4::Letters::EnqueueLetter( {
            letter                 => $letter,
            message_transport_type => 'email',
            from_address           => $fromaddr,
            to_address             => $a,
        });
        #add a preliminary share record
        AddShare( $param->{shelfnumber}, keytostring(\@newkey,1));
    }
}

sub check_owner_category {
    my ($param)= @_;
    #TODO candidate for a module?
    #need to get back the two different error codes and the shelfname

    ( undef, $param->{shelfname}, $param->{owner}, my $category ) =
    GetShelf( $param->{shelfnumber} );
    $param->{errcode}=4 if $param->{owner}!= $param->{loggedinuser};
    $param->{errcode}=5 if !$param->{errcode} && $category!=1;
        #should be private
    return !defined $param->{errcode};
}

sub load_template {
    my ($param)= @_;
    ($param->{template}, $param->{loggedinuser}, $param->{cookie} ) =
    get_template_and_user( {
        template_name   => TEMPLATE_NAME,
        query           => $param->{query},
        type            => "opac",
        authnotrequired => 0, #should be a user
    } );
}

sub load_template_vars {
    my ($param) = @_;
    my $template = $param->{template};
    my $str= join '; ', @{$param->{appr_addr}};
    $template->param(
        errcode         => $param->{errcode},
        op              => $param->{op},
        shelfnumber     => $param->{shelfnumber},
        shelfname       => $param->{shelfname},
        approvedaddress => $str,
        failaddress     => $param->{fail_addr},
    );
}

sub IsEmailAddress {
    #TODO candidate for a module?
    return Email::Valid->address($_[0])? 1: 0;
}

sub randomlist {
#uses rand, safe enough for this application but not for more sensitive data
    my ($length, $base)= @_;
    return map { int(rand($base)); } 1..$length;
}

sub keytostring {
    my ($keyref, $flgBase64)= @_;
    if($flgBase64) {
        my $alphabet= [ 'A'..'Z', 'a'..'z', 0..9, '+', '/' ];
        return join '', map { alphabet_char($_, $alphabet); } @$keyref;
    }
    return join '', map { sprintf("%02d",$_); } @$keyref;
}

sub stringtokey {
    my ($str, $flgBase64)= @_;
    my @temp=split '', $str||'';
    if($flgBase64) {
        my $alphabet= [ 'A'..'Z', 'a'..'z', 0..9, '+', '/' ];
        return map { alphabet_ordinal($_, $alphabet); } @temp;
    }
    return () if $str!~/^\d+$/;
    my @retval;
    for(my $i=0; $i<@temp-1; $i+=2) {
        push @retval, $temp[$i]*10+$temp[$i+1];
    }
    return @retval;
}

sub alphabet_ordinal {
    my ($char, $alphabet) = @_;
    for( 0..$#$alphabet ) {
        return $_ if $char eq $alphabet->[$_];
    }
    return ''; #ignore missing chars
}

sub alphabet_char {
#reverse operation for ordinal; ignore invalid numbers
    my ($num, $alphabet) = @_;
    return $num =~ /^\d+$/ && $num<=$#$alphabet? $alphabet->[$num]: '';
}
