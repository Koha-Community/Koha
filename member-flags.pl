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

my $input = new CGI;

my $flagsrequired;
$flagsrequired->{borrowers}=1;
$flagsrequired->{permissions}=1;
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
    print $input->redirect("/cgi-bin/koha/moremember.pl?bornum=$member");
} else {
    my ($bor,$flags,$accessflags)=getpatroninformation(\%env, $member,'');

    my $dbh=C4::Context->dbh();
    my $sth=$dbh->prepare("select bit,flag,flagdesc from userflags order by bit");
    $sth->execute;
    my $flagtext='';
    while (my ($bit, $flag, $flagdesc) = $sth->fetchrow) {
	my $checked='';
	if ($accessflags->{$flag}) {
	    $checked='checked';
	}
	$flagtext.="<tr><td><input type=checkbox name=flag-$bit $checked></td><td>$flag</td><td>$flagdesc</td></tr>\n";
    }
    print $input->header(-cookie => $cookie);
    print startpage();
    print startmenu('member');
    print qq|
    <h2>$bor->{'surname'}, $bor->{'firstname'}</h2>
    <form method=post>
    <input type=hidden name=member value=$member>
    <input type=hidden name=newflags value=1>
    <table border=1>
    <tr><th background=/koha/images/background-mem.gif colspan=3>FLAGS</th></tr>
    $flagtext
    </table>

    <p>
    <input type=submit value="Set Flags">
    </form>
    |;

    print endmenu('member');
    print endpage();
}
