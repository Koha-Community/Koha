#!/usr/bin/perl
# script that starts the zebraquee
#  Written by TG on 01/08/2006
use strict;

use Win32::Process;
use Win32;
use C4::Context;
use CGI;
my $input=new CGI;
my $fileplace=C4::Context->config('intranetdir');
my $fullpath=$fileplace."/cgi-bin/z3950";
my $ZebraObj;
 my $pid=Win32::Process::Create($ZebraObj,	"C:/usr/bin/perl.exe",'perl zebraqueue_start.pl',	0, DETACHED_PROCESS,$fullpath)  ;

print $input->redirect("/cgi-bin/koha/mainpage.pl?pid=$pid");
