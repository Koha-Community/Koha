#!/usr/bin/perl

#script to administer the systempref table
#written 20/02/2002 by paul.poulain@free.fr
# This software is placed under the gnu General Public License, v2 (http://www.gnu.org/licenses/gpl.html)

use strict;
use C4::Output;
use CGI;
use C4::Search;
use C4::Database;
use C4::Auth;

my $input = new CGI;


my $configfile=configfile();
my $includes=$configfile->{'includes'};


my $dbh=C4Connect();

if ($input->param('settemplate')) {
    my $sth=$dbh->prepare("update systempreferences set value=? where variable='template'");
    $sth->execute($input->param('settemplate'));
    print $input->redirect('/cgi-bin/koha/catalogue-home.pl');
    exit;
}

print $input->header();

print startpage();
print startmenu('catalogue');

my $sth=$dbh->prepare("select value from systempreferences where variable='template'");
$sth->execute;
my ($template)=$sth->fetchrow;

my $templateoptions='';
opendir D, "$includes/templates";
my @dirlist=readdir D;
foreach (@dirlist) {
    (next) if (/^\./);
    my $selected='';
    ($_ eq $template) && ($selected=' selected');
    $templateoptions.="<option value=$_$selected> $_\n";
}


print qq|
<form method=get>
Template: <select name=settemplate>
$templateoptions
</select>
<p>
<input type=submit value="Set Template">
</form>
|;


print endmenu('catalogue');
print endpage();
