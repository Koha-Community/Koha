package C4::Koha;

use strict;
require Exporter;

use vars qw($VERSION @ISA @EXPORT);
  
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&slashifyDate
	     &fixEthnicity
	     $DEBUG); 

use vars qw();
	
my $DEBUG = 0;

sub slashifyDate {
    # accepts a date of the form xx-xx-xx[xx] and returns it in the 
    # form xx/xx/xx[xx]
    my @dateOut = split('-', shift);
    return("$dateOut[2]/$dateOut[1]/$dateOut[0]")
}

sub fixEthnicity($) { # a temporary fix ethnicity, it should really be handled
                      # in Search.pm or the DB ... 

    my $ethnicity = shift;
    if ($ethnicity eq 'maori') {
	$ethnicity = 'Maori';
    } elsif ($ethnicity eq 'european') {
	$ethnicity = 'European/Pakeha';
    } elsif ($ethnicity eq 'pi') {
	$ethnicity = 'Pacific Islander'
    } elsif ($ehtnicity eq 'asian') {
	$ethnicity = 'Asian';
    }
    return $ethnicity;
}


1;
__END__

=head1 NAME

Koha - Perl Module containing convenience functions for Koha scripts

=head1 SYNOPSIS

  use Koha;


  $date = slashifyDate("01-01-2002")



=head1 DESCRIPTION

Koha.pm provides many functions for Koha scripts.

slashifyDate() takes a dash separated date string and returns a slash 
separated date string

=head1 AUTHOR

Pat Eyler, pate@gnu.org

=head1 SEE ALSO

perl(1).

=cut





