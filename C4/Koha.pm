package C4::Koha;


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

use strict;
require Exporter;
use C4::Database;

use vars qw($VERSION @ISA @EXPORT);
  
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&slashifyDate
	     &fixEthnicity
	     &borrowercategories
	     &ethnicitycategories
	     $DEBUG); 

use vars qw();
	
my $DEBUG = 0;

sub slashifyDate {
    # accepts a date of the form xx-xx-xx[xx] and returns it in the 
    # form xx/xx/xx[xx]
    my @dateOut = split('-', shift);
    return("$dateOut[2]/$dateOut[1]/$dateOut[0]")
}

sub fixEthnicity($) { 

    my $ethnicity = shift;
    my $dbh=C4Connect();
    my $sth=$dbh->prepare("Select name from ethnicity where code = ?");
    $sth->execute($ethnicity);
    my $data=$sth->fetchrow_hashref;
    $sth->finish;
    $dbh->disconnect;
    return $data->{'name'};
}

sub borrowercategories {
    my $dbh=C4Connect();
    my $sth=$dbh->prepare("Select categorycode,description from categories order by description");
    $sth->execute;
    my %labels;
    my @codes;
    while (my $data=$sth->fetchrow_hashref){
      push @codes,$data->{'categorycode'};
      $labels{$data->{'categorycode'}}=$data->{'description'};
    }
    $sth->finish;
    $dbh->disconnect;
    return(\@codes,\%labels);
}

sub ethnicitycategories {
    my $dbh=C4Connect();
    my $sth=$dbh->prepare("Select code,name from ethnicity order by name");
    $sth->execute;
    my %labels;
    my @codes;
    while (my $data=$sth->fetchrow_hashref){
      push @codes,$data->{'code'};
      $labels{$data->{'code'}}=$data->{'name'};
    }
    $sth->finish;
    $dbh->disconnect;
    return(\@codes,\%labels);
}

1;
__END__

=head1 NAME

Koha - Perl Module containing convenience functions for Koha scripts

=head1 SYNOPSIS

  use Koha;


  $date = slashifyDate("01-01-2002")
  $ethnicity=fixEthnicity('asian');
  ($categories,$labels)=borrowercategories();

=head1 DESCRIPTION

Koha.pm provides many functions for Koha scripts.

slashifyDate() takes a dash separated date string and returns a slash 
separated date string

=head1 AUTHOR

Pat Eyler, pate@gnu.org

=head1 SEE ALSO

perl(1).

=cut





