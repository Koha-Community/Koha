#!/usr/bin/perl

#script to delete items
#written 2/5/00
#by chris@katipo.co.nz

use strict;

use C4::Search;
use CGI;
use Digest::MD5 qw(md5_base64);
use C4::Output;
use C4::Database;
use C4::Circulation::Circ2;
#use C4::Acquisitions;

my $input = new CGI;
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
    my $dbh=C4Connect();
    my $sth=$dbh->prepare("update borrowers set password=? where borrowernumber=?");
    $sth->execute($digest, $member);
    warn "$member $digest";
    print $input->redirect("/members/");
} else {
    my ($bor,$flags)=getpatroninformation(\%env, $member,'');

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

    print $input->header;
    print startpage();
    print startmenu('member');
    print qq|
    <h2>$bor->{'surname'}, $bor->{'firstname'}</h2>
    <form method=post>
    <input type=hidden name=member value=$member>
    New Password: <input name=newpassword size=20 value=$defaultnewpassword> (default is $spellitout)
    <p>
    <input type=submit value="Set Password">
    </form>
    |;

    print endmenu('member');
    print endpage();
}
