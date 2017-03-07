#!/usr/bin/perl

use strict;
use C4::Context;
use File::Copy;

my $filepath = C4::Context->config("sendoverduebills_pathtoxml");
my $providerConfig = {host=>C4::Context->config("sap_ftp_host"),
							port=>C4::Context->config("sap_ftp_port"),
							timeout=>C4::Context->config("sap_ftp_timeout"),
							ispassive=>C4::Context->config("sap_ftp_ispassive"),
							user=>C4::Context->config("sap_ftp_user"),
							pw=>C4::Context->config("sap_ftp_pw")};
my @files = <$filepath*.xml>;
foreach my $file (@files) {

  my $length = length $file;
  my $last_slash = rindex($file, '/');

  $file = substr($file, $last_slash + 1, $length - $last_slash);
  print $file . "\n";

  system ("sshpass -p $providerConfig->{pw} sftp $providerConfig->{user}\@$providerConfig->{host} > /dev/null 2>&1 << EOF
	cd IN
	put $filepath$file
	bye
	EOF") == 0 or die "system failed: $!";

  move ("$filepath$file", "$filepath$file"."_old") or die "The move operation failed: $!";

}
