#!/usr/bin/perl

# script to edit a member's flags
# Written by Steve Tonnesen
# July 26, 2002 (my birthday!)

use strict;

use C4::Search;
use CGI;
use C4::Output;
use C4::Auth;
use C4::Context;
use C4::Circulation::Circ2;
#use C4::Acquisitions;
use HTML::Template;
use C4::Interface::CGI::Output;

my $input = new CGI;

my $flagsrequired;
$flagsrequired->{borrowers}=1;
$flagsrequired->{permissions}=1;

my ($template, $loggedinuser, $cookie)
	= get_template_and_user({template_name => "members/member-flags.tmpl",
				query => $input,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {borrowers => 1},
				debug => 1,
				});




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

if ($input->param('newflags')) {
    my $dbh=C4::Context->dbh();
    my $flags=0;
    foreach ($input->param) {
	if (/flag-(\d+)/) {
	    my $flag=$1;
	    $flags=$flags+2**$flag;
	}
    }
    my $sth=$dbh->prepare("update borrowers set flags=? where borrowernumber=?");
    $sth->execute($flags, $member);
    print $input->redirect("/cgi-bin/koha/members/moremember.pl?bornum=$member");
} else {
    my ($bor,$flags,$accessflags)=getpatroninformation(\%env, $member,'');

    my $dbh=C4::Context->dbh();
    my $sth=$dbh->prepare("select bit,flag,flagdesc from userflags order by bit");
    $sth->execute;
    my @loop;
    while (my ($bit, $flag, $flagdesc) = $sth->fetchrow) {
	my $checked='';
	if ($accessflags->{$flag}) {
	    $checked='checked';
	}
	my %row = ( bit => $bit,
		 flag => $flag,
		 checked => $checked,
		 flagdesc => $flagdesc );
	push @loop, \%row;
    }

    $template->param(member => $member,
			surname => $bor->{'surname'},
			firstname => $bor->{'firstname'},
			loop => \@loop);

    output_html_with_http_headers $input, $cookie, $template->output;

}
