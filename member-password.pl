#!/usr/bin/perl
#script to set the password, and optionally a userid, for a borrower
#written 2/5/00
#by chris@katipo.co.nz
#converted to using templates 3/16/03 by mwhansen@hmc.edu

use strict;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Search;
use C4::Context;
use C4::Circulation::Circ2;
use CGI;
use HTML::Template;
use Digest::MD5 qw(md5_base64);

my $input = new CGI;

my $theme = $input->param('theme') || "default";
			# only used if allowthemeoverride is set

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/member-password.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $flagsrequired;
$flagsrequired->{borrowers}=1;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0, $flagsrequired);

my $member=$input->param('member');
my %env;
$env{'nottodayissues'}=1;
my %member2;
$member2{'borrowernumber'}=$member;
my $issues=currentissues(\%env,\%member2);
my $i=0;
foreach (sort keys %$issues) {
    $i++;
}

my ($bor,$flags)=getpatroninformation(\%env, $member,'');
my $newpassword = $input->param('newpassword');

if ( $newpassword ) {
    my $digest=md5_base64($input->param('newpassword'));
    my $uid = $input->param('newuserid');
    my $dbh=C4::Context->dbh;

    #Make sure the userid chosen is unique. If it is not,
    #Then we need to tell the user and have them create a new one.
    my $sth2=$dbh->prepare("select * from borrowers where userid=?");
    $sth2->execute($uid);

    if ( $sth2->fetchrow ) {
	#The userid exists so we should display a warning.
	my $warn = 1;
        $template->param( warn => $warn,
		        othernames => $bor->{'othernames'},
                        surname     => $bor->{'surname'},
                        firstname   => $bor->{'firstname'},
                        userid      => $bor->{'userid'},
                        defaultnewpassword => $newpassword );
    } else {
	#Everything is good so we can update the information.
	my $sth=$dbh->prepare("update borrowers set userid=?, password=? where borrowernumber=?");
    	$sth->execute($uid, $digest, $member);
	$template->param(newpassword => $newpassword);
    }

} else {
    my $userid = $bor->{'userid'};

    my $chars='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    my $length=int(rand(2))+4;
    my $defaultnewpassword='';
    for (my $i=0; $i<$length; $i++) {
	$defaultnewpassword.=substr($chars, int(rand(length($chars))),1);
    }
	$template->param(	othernames => $bor->{'othernames'},
			surname     => $bor->{'surname'},
			firstname   => $bor->{'firstname'},
			userid      => $bor->{'userid'},
			defaultnewpassword => $defaultnewpassword );


}

$template->param( member => $member );

output_html_with_http_headers $input, $cookie, $template->output;
