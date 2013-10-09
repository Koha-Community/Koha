#!/usr/bin/perl
#script to set the password, and optionally a userid, for a borrower
#written 2/5/00
#by chris@katipo.co.nz
#converted to using templates 3/16/03 by mwhansen@hmc.edu

use strict;
use warnings;

use C4::Auth;
use Koha::AuthUtils;
use C4::Output;
use C4::Context;
use C4::Members;
use C4::Branch;
use C4::Circulation;
use CGI;
use C4::Members::Attributes qw(GetBorrowerAttributes);

use Digest::MD5 qw(md5_base64);

my $input = new CGI;

my $theme = $input->param('theme') || "default";
			# only used if allowthemeoverride is set

my ($template, $loggedinuser, $cookie, $staffflags)
    = get_template_and_user({template_name => "members/member-password.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $flagsrequired;
$flagsrequired->{borrowers}=1;

#my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0, $flagsrequired, 'intranet');

my $member=$input->param('member');
my $cardnumber = $input->param('cardnumber');
my $destination = $input->param('destination');
my @errors;
my ($bor)=GetMember('borrowernumber' => $member);
if(( $member ne $loggedinuser ) && ($bor->{'category_type'} eq 'S' ) ) {
	push(@errors,'NOPERMISSION') unless($staffflags->{'superlibrarian'} || $staffflags->{'staffaccess'} );
	# need superlibrarian for koha-conf.xml fakeuser.
}
my $newpassword = $input->param('newpassword');
my $newpassword2 = $input->param('newpassword2');

push(@errors,'NOMATCH') if ( ( $newpassword && $newpassword2 ) && ($newpassword ne $newpassword2) );

my $minpw = C4::Context->preference('minPasswordLength');
push(@errors,'SHORTPASSWORD') if( $newpassword && $minpw && (length($newpassword) < $minpw ) );

if ( $newpassword  && !scalar(@errors) ) {
    my $digest=Koha::AuthUtils::hash_password($input->param('newpassword'));
    my $uid = $input->param('newuserid');
    my $dbh=C4::Context->dbh;
    if (changepassword($uid,$member,$digest)) {
		$template->param(newpassword => $newpassword);
		if ($destination eq 'circ') {
		    print $input->redirect("/cgi-bin/koha/circ/circulation.pl?findborrower=$cardnumber");		
		} else {
		    print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$member");
		}
    } else {
			push(@errors,'BADUSERID');
    }
} else {
    my $userid = $bor->{'userid'};

    my $chars='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    my $length=int(rand(2))+C4::Context->preference("minPasswordLength");
    my $defaultnewpassword='';
    for (my $i=0; $i<$length; $i++) {
	$defaultnewpassword.=substr($chars, int(rand(length($chars))),1);
    }

	$template->param( defaultnewpassword => $defaultnewpassword );
}
    if ( $bor->{'category_type'} eq 'C') {
        my  ( $catcodes, $labels ) =  GetborCatFromCatType( 'A', 'WHERE category_type = ?' );
        my $cnt = scalar(@$catcodes);
        $template->param( 'CATCODE_MULTI' => 1) if $cnt > 1;
        $template->param( 'catcode' =>    $catcodes->[0])  if $cnt == 1;
    }
	
$template->param( adultborrower => 1 ) if ( $bor->{'category_type'} eq 'A' );
my ($picture, $dberror) = GetPatronImage($bor->{'cardnumber'});
$template->param( picture => 1 ) if $picture;

if (C4::Context->preference('ExtendedPatronAttributes')) {
    my $attributes = GetBorrowerAttributes($bor->{'borrowernumber'});
    $template->param(
        ExtendedPatronAttributes => 1,
        extendedattributes => $attributes
    );
}

    $template->param( othernames => $bor->{'othernames'},
	    surname     => $bor->{'surname'},
	    firstname   => $bor->{'firstname'},
	    borrowernumber => $bor->{'borrowernumber'},
	    cardnumber => $bor->{'cardnumber'},
	    categorycode => $bor->{'categorycode'},
	    category_type => $bor->{'category_type'},
	    categoryname => $bor->{'description'},
	    address => $bor->{'address'},
	    address2 => $bor->{'address2'},
	    city => $bor->{'city'},
	    state => $bor->{'state'},
	    zipcode => $bor->{'zipcode'},
	    country => $bor->{'country'},
	    phone => $bor->{'phone'},
	    email => $bor->{'email'},
	    branchcode => $bor->{'branchcode'},
	    branchname => GetBranchName($bor->{'branchcode'}),
	    userid      => $bor->{'userid'},
	    destination => $destination,
		is_child        => ($bor->{'category_type'} eq 'C'),
		activeBorrowerRelationship => (C4::Context->preference('borrowerRelationship') ne ''),
        minPasswordLength => $minpw,
        RoutingSerials => C4::Context->preference('RoutingSerials'),
	);

if( scalar(@errors )){
	$template->param( errormsg => 1 );
	foreach my $error (@errors) {
        $template->param($error) || $template->param( $error => 1);
	}

}

output_html_with_http_headers $input, $cookie, $template->output;
