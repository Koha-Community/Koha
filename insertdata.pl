#!/usr/bin/perl

#script to enter borrower data into the data base
#needs to be moved into a perl module
# written 9/11/99 by chris@katipo.co.nz

use CGI;
use C4::Database;
use C4::Input;
use Date::Manip;
use strict;

my $input= new CGI;
#print $input->header;
#print $input->dump;

#get all the data into a hash
my @names=$input->param;
my %data;
my $keyfld;
my $keyval;
my $problems;
my $env;
foreach my $key (@names){
  $data{$key}=$input->param($key);
}
my $dbh=C4Connect;
my $query="Select * from borrowers where borrowernumber=$data{'borrowernumber'}";
my $sth=$dbh->prepare($query);
$sth->execute;
if (my $data=$sth->fetchrow_hashref){
  $query="update borrowers set title='$data{'title'}',expiry='$data{'expiry'}',
  cardnumber='$data{'cardnumber'}',sex='$data{'sex'}',ethnotes='$data{'ethnicnotes'}',
  streetaddress='$data{'address'}',faxnumber='$data{'faxnumber'}',firstname='$data{'firstname'}',
  altnotes='$data{'altnotes'}',dateofbirth='$data{'dateofbirth'}',contactname='$data{'contactname'}',
  emailaddress='$data{'emailaddress'}',dateenrolled='$data{'joining'}',streetcity='$data{'streetcity'}',
  altrelationship='$data{'altrelationship'}',othernames='$data{'othernames'}',phoneday='$data{'phoneday'}',
  categorycode='$data{'categorycode'}',city='$data{'city'}',area='$data{'area'}',phone='$data{'phone'}',
  borrowernotes='$data{'borrowernotes'}',altphone='$data{'altphone'}',surname='$data{'surname'}',
  initials='$data{'initials'}',streetaddress='$data{'address'}',ethnicity='$data{'ethnicity'}'
  where borrowernumber=$data{'borrowernumber'}";
#  print $query;

}else{
  $data{'dateofbirth'}=ParseDate($data{'dateofbirth'});
  $data{'dateofbirth'}=UnixDate($data{'dateofbirth'},'%Y-%m-%d');
  $data{'joining'}=ParseDate($data{'joining'});
  $data{'joining'}=UnixDate($data{'joining'},'%Y-%m-%d');
  $query="insert into borrowers (title,expiry,cardnumber,sex,ethnotes,streetaddress,faxnumber,
  firstname,altnotes,dateofbirth,contactname,emailaddress,dateenrolled,streetcity,
  altrelationship,othernames,phoneday,categorycode,city,area,phone,borrowernotes,altphone,surname,
  initials,ethnicity,borrowernumber) values ('$data{'title'}','$data{'expiry'}','$data{'cardnumber'}',
  '$data{'sex'}','$data{'ethnotes'}','$data{'address'}','$data{'faxnumber'}',
  '$data{'firstname'}','$data{'altnotes'}','$data{'dateofbirth'}','$data{'contactname'}','$data{'emailaddress'}',
  '$data{'joining'}','$data{'streetcity'}','$data{'altrelationship'}','$data{'othernames'}',
  '$data{'phoneday'}','$data{'categorycode'}','$data{'city'}','$data{'area'}','$data{'phone'}',
  '$data{'borrowernotes'}','$data{'altphone'}','$data{'surname'}','$data{'initials'}',
  '$data{'ethnicity'}','$data{'borrowernumber'}')";
}
#print $query;
  my $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;
$sth->finish;
$dbh->disconnect;
print $input->redirect("/cgi-bin/koha/moremember.pl?bornum=$data{'borrowernumber'}");
