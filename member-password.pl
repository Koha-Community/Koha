#!/usr/bin/perl

#script to set the password, and optionally a userid, for a borrower
#written 2/5/00
#by chris@katipo.co.nz

use strict;

use C4::Search;
use CGI;
use Digest::MD5 qw(md5_base64);
use C4::Output;
use C4::Auth;
use C4::Context;
use C4::Circulation::Circ2;
#use C4::Acquisitions;

my $input = new CGI;

my $flagsrequired;
$flagsrequired->{borrowers}=1;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0, $flagsrequired);

#print $input->header;
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
if ($input->param('newpassword')) {
    my $digest=md5_base64($input->param('newpassword'));
    my $uid = $input->param('newuserid');
    my $dbh=C4::Context->dbh;
    my $sth=$dbh->prepare("update borrowers set userid=?, password=? where borrowernumber=?");
    $sth->execute($uid, $digest, $member);
    print $input->redirect("/cgi-bin/koha/moremember.pl?bornum=$member");
} else {
    my ($bor,$flags)=getpatroninformation(\%env, $member,'');
    my $userid = $bor->{'userid'};

    my $chars='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    my $length=int(rand(2))+4;
    my $defaultnewpassword='';
    for (my $i=0; $i<$length; $i++) {
	$defaultnewpassword.=substr($chars, int(rand(length($chars))),1);
    }
    my $spellitout=$defaultnewpassword;
    $spellitout=~s/l/\001/g;
    $spellitout=~s/1/\002/g;
    $spellitout=~s/O/\003/g;
    $spellitout=~s/o/\004/g;
    $spellitout=~s/0/\005/g;
    $spellitout=~s/\001/ <b>el<\/b> /g;
    $spellitout=~s/\002/ <b>one<\/b> /g;
    $spellitout=~s/\003/ <b>Oh<\/b> /g;
    $spellitout=~s/\004/ <b>oh<\/b> /g;
    $spellitout=~s/\005/ <b>zero<\/b> /g;

    print $input->header(-cookie => $cookie);
    print startpage();
    print startmenu('member');
    print qq|
    <h2>$bor->{'surname'}, $bor->{'firstname'}</h2>
    <form method=post>
    <input type=hidden name=member value=$member>
    New UserID: <input name=newuserid size=20 value=$userid> <br>
    New Password: <input name=newpassword size=20 value=$defaultnewpassword>
    <p>
    <input type=submit value="Confirm Password">
    </form>
    |;

    print endmenu('member');
    print endpage();
}
