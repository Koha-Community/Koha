package C4::Koha;

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
	     &configfile
	     $DEBUG); 

use vars qw();
	
my $DEBUG = 0;

sub configfile {
    my $configfile;
    open (KC, "/etc/koha.conf");
    while (<KC>) {
	chomp;
	(next) if (/^\s*#/);
	if (/(.*)\s*=\s*(.*)/) {
	    my $variable=$1;
	    my $value=$2;
	    # Clean up white space at beginning and end
	    $variable=~s/^\s*//g;
	    $variable=~s/\s*$//g;
	    $value=~s/^\s*//g;
	    $value=~s/\s*$//g;
	    $configfile->{$variable}=$value;
	}
    }
    return $configfile;
}

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





