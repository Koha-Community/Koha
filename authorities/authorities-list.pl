#!/usr/bin/perl
use strict;
use warnings;
use C4::Context;
use C4::AuthoritiesMarc;
use utf8;
use open qw[ :std :encoding(utf8) ];

my $dbh=C4::Context->dbh;
my $datatypes_query = $dbh->prepare(<<ENDSQL);
SELECT authtypecode,authtypetext,auth_tag_to_report from auth_types;
ENDSQL
$datatypes_query->execute;
my $datatypes=$datatypes_query->fetchall_arrayref({});
my %authtypes;
map { $authtypes{$_->{'authtypecode'}}={"tag"=> $_->{'auth_tag_to_report'}, "lib"=> $_->{'authtypetext'}};} @$datatypes;
my $data_query = $dbh->prepare(<<ENDSQL);
SELECT authid, authtypecode from auth_header
ENDSQL
$data_query->execute;
my $dataauthorities=$data_query->fetchall_arrayref({});
foreach my $authority (@$dataauthorities){
  my $marcauthority=GetAuthority($authority->{'authid'});
  my $query;
  $query= "an=".$authority->{'authid'};
  # search for biblios mapped
  my ($err,$res,$used) = C4::Search::SimpleSearch($query,0,10);
  if (defined $err) {
      $used = 0;
  }
  if ($marcauthority && $marcauthority->field($authtypes{$authority->{'authtypecode'}}->{'tag'})){
    print qq("),$marcauthority->field($authtypes{$authority->{'authtypecode'}}->{"tag"})->as_string(),qq(";),qq($authority->{'authid'};"),$authtypes{$authority->{'authtypecode'}}->{'lib'},qq(";$used\n);
  }
}
