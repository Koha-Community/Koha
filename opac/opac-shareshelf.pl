#!/usr/bin/perl

# Copyright 2013 Rijksmuseum
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use constant KEYLENGTH     => 10;
use constant TEMPLATE_NAME => 'opac-shareshelf.tmpl';
use constant SHELVES_URL =>
  '/cgi-bin/koha/opac-shelves.pl?display=privateshelves&viewshelf=';

use CGI;
use Email::Valid;

use C4::Auth;
use C4::Context;
use C4::Letters;
use C4::Members ();
use C4::Output;
use C4::VirtualShelves;

#-------------------------------------------------------------------------------

my $pvar = _init( {} );
if ( !$pvar->{errcode} ) {
    show_invite($pvar)    if $pvar->{op} eq 'invite';
    confirm_invite($pvar) if $pvar->{op} eq 'conf_invite';
    show_accept($pvar)    if $pvar->{op} eq 'accept';
}
load_template_vars($pvar);
output_html_with_http_headers $pvar->{query}, $pvar->{cookie},
  $pvar->{template}->output;

#-------------------------------------------------------------------------------

sub _init {
    my ($param) = @_;
    my $query = new CGI;
    $param->{query}       = $query;
    $param->{shelfnumber} = $query->param('shelfnumber') || 0;
    $param->{op}          = $query->param('op') || '';
    $param->{addrlist}    = $query->param('invite_address') || '';
    $param->{key}         = $query->param('key') || '';
    $param->{appr_addr}   = [];
    $param->{fail_addr}   = [];
    $param->{errcode}     = check_common_errors($param);

    #get some list details
    my @temp;
    @temp = GetShelf( $param->{shelfnumber} ) if !$param->{errcode};
    $param->{shelfname} = @temp ? $temp[1] : '';
    $param->{owner}     = @temp ? $temp[2] : -1;
    $param->{category}  = @temp ? $temp[3] : -1;

    load_template($param);
    return $param;
}

sub check_common_errors {
    my ($param) = @_;
    if ( $param->{op} !~ /^(invite|conf_invite|accept)$/ ) {
        return 1;    #no operation specified
    }
    if ( $param->{shelfnumber} !~ /^\d+$/ ) {
        return 2;    #invalid shelf number
    }
    if ( !C4::Context->preference('OpacAllowSharingPrivateLists') ) {
        return 3;    #not or no longer allowed?
    }
    return;
}

sub show_invite {
    my ($param) = @_;
    return unless check_owner_category($param);
}

sub confirm_invite {
    my ($param) = @_;
    return unless check_owner_category($param);
    process_addrlist($param);
    if ( @{ $param->{appr_addr} } ) {
        send_invitekey($param);
    }
    else {
        $param->{errcode} = 6;    #not one valid address
    }
}

sub show_accept {
    my ($param) = @_;

    my @rv = ShelfPossibleAction( $param->{loggedinuser},
        $param->{shelfnumber}, 'acceptshare' );
    $param->{errcode} = $rv[1] if !$rv[0];
    return if $param->{errcode};

    #errorcode 5: should be private list
    #errorcode 8: should not be owner

    my $dbkey = keytostring( stringtokey( $param->{key}, 0 ), 1 );
    if ( AcceptShare( $param->{shelfnumber}, $dbkey, $param->{loggedinuser} ) )
    {
        notify_owner($param);

        #redirect to view of this shared list
        print $param->{query}->redirect(
            -uri    => SHELVES_URL . $param->{shelfnumber},
            -cookie => $param->{cookie}
        );
        exit;
    }
    else {
        $param->{errcode} = 7;    #not accepted (key not found or expired)
    }
}

sub notify_owner {
    my ($param) = @_;

    my $toaddr = C4::Members::GetNoticeEmailAddress( $param->{owner} );
    return if !$toaddr;

    #prepare letter
    my $letter = C4::Letters::GetPreparedLetter(
        module      => 'members',
        letter_code => 'SHARE_ACCEPT',
        branchcode  => C4::Context->userenv->{"branch"},
        tables      => { borrowers => $param->{loggedinuser}, },
        substitute  => { listname => $param->{shelfname}, },
    );

    #send letter to queue
    C4::Letters::EnqueueLetter(
        {
            letter                 => $letter,
            message_transport_type => 'email',
            from_address => C4::Context->preference('KohaAdminEmailAddress'),
            to_address   => $toaddr,
        }
    );
}

sub process_addrlist {
    my ($param) = @_;
    my @temp = split /[,:;]/, $param->{addrlist};
    my @appr_addr;
    my @fail_addr;
    foreach my $a (@temp) {
        $a =~ s/^\s+//;
        $a =~ s/\s+$//;
        if ( IsEmailAddress($a) ) {
            push @appr_addr, $a;
        }
        else {
            push @fail_addr, $a;
        }
    }
    $param->{appr_addr} = \@appr_addr;
    $param->{fail_addr} = \@fail_addr;
}

sub send_invitekey {
    my ($param) = @_;
    my $fromaddr = C4::Context->preference('KohaAdminEmailAddress');
    my $url =
        'http://'
      . C4::Context->preference('OPACBaseURL')
      . "/cgi-bin/koha/opac-shareshelf.pl?shelfnumber="
      . $param->{shelfnumber}
      . "&op=accept&key=";

    #TODO Waiting for the right http or https solution (BZ 8952 a.o.)

    my @ok;    #the addresses that were processed well
    foreach my $a ( @{ $param->{appr_addr} } ) {
        my @newkey = randomlist( KEYLENGTH, 64 );    #generate a new key

        #add a preliminary share record
        if ( !AddShare( $param->{shelfnumber}, keytostring( \@newkey, 1 ) ) ) {
            push @{ $param->{fail_addr} }, $a;
            next;
        }
        push @ok, $a;

        #prepare letter
        my $letter = C4::Letters::GetPreparedLetter(
            module      => 'members',
            letter_code => 'SHARE_INVITE',
            branchcode  => C4::Context->userenv->{"branch"},
            tables      => { borrowers => $param->{loggedinuser}, },
            substitute  => {
                listname => $param->{shelfname},
                shareurl => $url . keytostring( \@newkey, 0 ),
            },
        );

        #send letter to queue
        C4::Letters::EnqueueLetter(
            {
                letter                 => $letter,
                message_transport_type => 'email',
                from_address           => $fromaddr,
                to_address             => $a,
            }
        );
    }
    $param->{appr_addr} = \@ok;
}

sub check_owner_category {
    my ($param) = @_;

    #sharing user should be the owner
    #list should be private
    $param->{errcode} = 4 if $param->{owner} != $param->{loggedinuser};
    $param->{errcode} = 5 if !$param->{errcode} && $param->{category} != 1;
    return !defined $param->{errcode};
}

sub load_template {
    my ($param) = @_;
    ( $param->{template}, $param->{loggedinuser}, $param->{cookie} ) =
      get_template_and_user(
        {
            template_name   => TEMPLATE_NAME,
            query           => $param->{query},
            type            => "opac",
            authnotrequired => 0,                 #should be a user
        }
      );
}

sub load_template_vars {
    my ($param) = @_;
    my $template = $param->{template};
    my $appr = join '; ', @{ $param->{appr_addr} };
    my $fail = join '; ', @{ $param->{fail_addr} };
    $template->param(
        errcode         => $param->{errcode},
        op              => $param->{op},
        shelfnumber     => $param->{shelfnumber},
        shelfname       => $param->{shelfname},
        approvedaddress => $appr,
        failaddress     => $fail,
    );
}

sub IsEmailAddress {

    #TODO candidate for a module?
    return Email::Valid->address( $_[0] ) ? 1 : 0;
}

sub randomlist {

    #uses rand, safe enough for this application but not for more sensitive data
    my ( $length, $base ) = @_;
    return map { int( rand($base) ); } 1 .. $length;
}

sub keytostring {
    my ( $keyref, $flgBase64 ) = @_;
    if ($flgBase64) {
        my $alphabet = [ 'A' .. 'Z', 'a' .. 'z', 0 .. 9, '+', '/' ];
        return join '', map { alphabet_char( $_, $alphabet ); } @$keyref;
    }
    return join '', map { sprintf( "%02d", $_ ); } @$keyref;
}

sub stringtokey {
    my ( $str, $flgBase64 ) = @_;
    my @temp = split '', $str || '';
    if ($flgBase64) {
        my $alphabet = [ 'A' .. 'Z', 'a' .. 'z', 0 .. 9, '+', '/' ];
        return [ map { alphabet_ordinal( $_, $alphabet ); } @temp ];
    }
    return [] if $str !~ /^\d+$/;
    my @retval;
    for ( my $i = 0 ; $i < @temp - 1 ; $i += 2 ) {
        push @retval, $temp[$i] * 10 + $temp[ $i + 1 ];
    }
    return \@retval;
}

sub alphabet_ordinal {
    my ( $char, $alphabet ) = @_;
    for my $ord ( 0 .. $#$alphabet ) {
        return $ord if $char eq $alphabet->[$ord];
    }
    return '';    #ignore missing chars
}

sub alphabet_char {

    #reverse operation for ordinal; ignore invalid numbers
    my ( $num, $alphabet ) = @_;
    return $num =~ /^\d+$/ && $num <= $#$alphabet ? $alphabet->[$num] : '';
}
