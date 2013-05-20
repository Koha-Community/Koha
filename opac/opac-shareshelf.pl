#!/usr/bin/perl

# Copyright 2013 Rijksmuseum
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
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

use CGI;
use Email::Valid;

use C4::Auth;
use C4::Context;
use C4::Letters;
use C4::Output;
use C4::VirtualShelves;

#-------------------------------------------------------------------------------

my $query= new CGI;
my ($shelfname, $owner);
my ($template, $loggedinuser, $cookie);
my $errcode=0;
my (@addr, $fail_addr, @newkey);
my @base64alphabet= ('A'..'Z', 'a'..'z', 0..9, '+', '/');

my $shelfnumber= $query->param('shelfnumber')||0;
my $op= $query->param('op')||'';
my $addrlist= $query->param('invite_address')||'';
my $key= $query->param('key')||'';

#-------------------------------------------------------------------------------

check_common_errors();
load_template("opac-shareshelf.tmpl");
if($errcode) {
    #nothing to do
}
elsif($op eq 'invite') {
    show_invite();
}
elsif($op eq 'conf_invite') {
    confirm_invite();
}
elsif($op eq 'accept') {
    show_accept();
}
load_template_vars();
output_html_with_http_headers $query, $cookie, $template->output;

#-------------------------------------------------------------------------------

sub check_common_errors {
    if($op!~/^(invite|conf_invite|accept)$/) {
        $errcode=1; #no operation specified
        return;
    }
    if($shelfnumber!~/^\d+$/) {
        $errcode=2; #invalid shelf number
        return;
    }
    if(!C4::Context->preference('OpacAllowSharingPrivateLists')) {
        $errcode=3; #not or no longer allowed?
        return;
    }
}

sub show_invite {
    return unless check_owner_category();
}

sub confirm_invite {
    return unless check_owner_category();
    process_addrlist();
    if(@addr) {
        send_invitekey();
    }
    else {
        $errcode=6; #not one valid address
    }
}

sub show_accept {
    #TODO Add some code here to accept an invitation (followup report)
}

sub process_addrlist {
    my @temp= split /[,:;]/, $addrlist;
    $fail_addr='';
    foreach my $a (@temp) {
        $a=~s/^\s+//;
        $a=~s/\s+$//;
        if(IsEmailAddress($a)) {
            push @addr, $a;
        }
        else {
            $fail_addr.= ($fail_addr? '; ': '').$a;
        }
    }
}

sub send_invitekey {
    my $fromaddr= C4::Context->preference('KohaAdminEmailAddress');
    my $url= 'http://'.C4::Context->preference('OPACBaseURL');
    $url.= "/cgi-bin/koha/opac-shareshelf.pl?shelfnumber=$shelfnumber";
    $url.= "&op=accept&key=";
        #FIXME Waiting for the right http or https solution (BZ 8952 a.o.)

    foreach my $a (@addr) {
        @newkey=randomlist(KEYLENGTH, 64); #generate a new key

        #prepare letter
        my $letter= C4::Letters::GetPreparedLetter(
            module => 'members',
            letter_code => 'SHARE_INVITE',
            branchcode => C4::Context->userenv->{"branch"},
            tables => { borrowers => $loggedinuser, },
            substitute => {
                listname => $shelfname,
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
        AddShare($shelfnumber,keytostring(\@newkey,1));
    }
}

sub check_owner_category {
    #FIXME candidate for a module? what held me back is: getting back the two different error codes and the shelfname
    (undef,$shelfname,$owner,my $category)= GetShelf($shelfnumber);
    $errcode=4 if $owner!= $loggedinuser; #should be owner
    $errcode=5 if !$errcode && $category!=1; #should be private
    return $errcode==0;
}

sub load_template {
    my ($file)= @_;
    ($template, $loggedinuser, $cookie)= get_template_and_user({
        template_name   => $file,
        query           => $query,
        type            => "opac",
        authnotrequired => 0, #should be a user
    });
}

sub load_template_vars {
    $template->param(
        errcode         => $errcode,
        op              => $op,
        shelfnumber     => $shelfnumber,
        shelfname       => $shelfname,
        approvedaddress => (join '; ', @addr),
        failaddress     => $fail_addr,
    );
}

sub IsEmailAddress {
    #FIXME candidate for a module?
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
        return join '', map { base64chr($_); } @$keyref;
    }
    return join '', map { sprintf("%02d",$_); } @$keyref;
}

sub stringtokey {
    my ($str, $flgBase64)= @_;
    my @temp=split '', $str||'';
    if($flgBase64) {
        return map { base64ord($_); } @temp;
    }
    return () if $str!~/^\d+$/;
    my @retval;
    for(my $i=0; $i<@temp-1; $i+=2) {
        push @retval, $temp[$i]*10+$temp[$i+1];
    }
    return @retval;
}

sub base64ord { #base64 ordinal
    my ($char)=@_;
    return 0 -ord('A')+ord($char) if $char=~/[A-Z]/;
    return 26-ord('a')+ord($char) if $char=~/[a-z]/;
    return 52-ord('0')+ord($char) if $char=~/[0-9]/;
    return 62 if $char eq '+';
    return 63 if $char eq '/';
    return;
}

sub base64chr { #reverse operation for ord
    return $_[0]=~/^\d+$/ && $_[0]<64? $base64alphabet[$_[0]]: undef;
}
