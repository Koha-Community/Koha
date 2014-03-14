#!/usr/bin/perl
# script that starts the zebraqueue
#  Written by TG on 01/08/2006
use strict;
#use warnings; FIXME - Bug 2505

use Win32::Process;
use Win32;
use C4::Context;
use CGI qw ( -utf8 );
my $input=new CGI;
my $fileplace=C4::Context->config('intranetdir');
my $fullpath=$fileplace."/cgi-bin/sms";
my $ZebraObj;
my $pid=Win32::Process::Create($ZebraObj, "C:/perl/bin/perl.exe", 'perl sms_listen.pl', 0, DETACHED_PROCESS, $fullpath);

print $input->redirect("/cgi-bin/koha/mainpage.pl?pid=$pid");
