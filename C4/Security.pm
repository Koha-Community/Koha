package C4::Security; #assumes C4/Security


# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

# FIXME - As far as I can tell, this module is only used by the CDK
# stuff, which appears to be stillborn. In other words, this module
# isn't used.

use strict;
require Exporter;
use DBI;
use C4::Context;
use C4::Format;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&Login &CheckAccess);

sub Login {
  my ($env)=@_;
  my $dbh = C4::Context->dbh;
  my @branches;
  my $query = "select * from branches order by branchname";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  while (my $branchrec=$sth->fetchrow_hashref) {
    my $branchdet = 
     fmtstr($env,$branchrec->{'branchcode'},"L2")." ".$branchrec->{'branchname'};
    push @branches,$branchdet;
  }
  $sth->finish;
  my $valid = "f";
  &startint($env,"Logging In");
  until ($valid eq "t") {
    my ($reason,$username,$password,$branch) = logondialog ($env,"Logon to System",\@branches);
    $username = uc $username;
    $password = uc $password;
    my $query = "select * from users where usercode = '$username' and password ='$password'";
    $sth=$dbh->prepare($query);
    $sth->execute;
#          debug_msg("",$query);
    if (my $userrec = $sth->fetchrow_hashref) {
    if ($userrec->{'usercode'} ne ''){
      if ($branch ne "") {
        $valid = "t";
        my @dummy = split ' ', $branch;
        $branch = $dummy[0];
        $env->{'usercode'} = $username;
        $env->{'branchcode'} = $branch;
      }
     
    } else {
      debug_msg("","not found");
    }
    }
    $sth->finish;
  }
  &endint();
}
  
sub CheckAccess {
  my ($env)=@_;
  }
    
END { }       # module clean-up code here (global destructor)
    
