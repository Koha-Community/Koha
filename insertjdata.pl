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
#print $input->Dump;

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

for (my $i=0;$i<3;$i++){
my $query="Select * from borrowers where borrowernumber=$data{'bornumber_child_$i'}";
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

}elsif ($data{"cardnumber_child_$i"} ne ''){
  my $dob=$data{"dateofbirth_child_$i"};
  $dob=ParseDate($dob);
  $dob=UnixDate($dob,'%Y-%m-%d');
  $data{'joining'}=ParseDate("today");
  $data{'joining'}=UnixDate($data{'joining'},'%Y-%m-%d');
  my $cardnumber=$data{"cardnumber_child_$i"};
  my $bornum=$data{"bornumber_child_$i"};
  my $firstname=$data{"firstname_child_$i"};
  my $surname=$data{"surname_child_$i"};
  my $school=$data{"school_child_$i"};
  my $guarant=$data{'borrowernumber'};
  my $notes=$data{"altnotes_child_$i"};
  my $sex=$data{"sex_child_$i"};
  $data{'contactname'}=$data{'firstname_guardian'}." ".$data{'surname_guardian'};
  $data{'altrelationship'}="Guarantor";
  $data{'altphone'}=$data{'phone'};
  $query="insert into borrowers (title,expiry,cardnumber,sex,ethnotes,streetaddress,faxnumber,
  firstname,altnotes,dateofbirth,contactname,emailaddress,dateenrolled,streetcity,
  altrelationship,othernames,phoneday,categorycode,city,area,phone,borrowernotes,altphone,surname,
  initials,ethnicity,borrowernumber,guarantor,school) 
  values ('','$data{'expiry'}',
  '$cardnumber',
  '$sex','$data{'ethnotes'}','$data{'address'}','$data{'faxnumber'}',
  '$firstname','$data{'altnotes'}','$dob','$data{'contactname'}','$data{'emailaddress'}',
  '$data{'joining'}','$data{'streetcity'}','$data{'altrelationship'}','$data{'othernames'}',
  '$data{'phoneday'}','C','$data{'city'}','$data{'area'}','$data{'phone'}',
  '$notes','$data{'altphone'}','$surname','$data{'initials'}',
  '$data{'ethnicity'}','$bornum','$guarant','$school')";
}

#print $query;
  my $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;
$sth->finish;
}
$dbh->disconnect;
print $input->redirect("/cgi-bin/koha/moremember.pl?bornum=$data{'borrowernumber'}");
