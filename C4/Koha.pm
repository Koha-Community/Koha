package C4::Koha;

use strict;
require Exporter;

use vars qw($VERSION @ISA @EXPORT);
  
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&slashifyDate); 

use vars qw();
	

sub slashifyDate {
    # accepts a date of the form xx-xx-xx[xx] and returns it in the 
    # form xx/xx/xx[xx]
    my @dateOut = split('-', shift);
    return("$dateOut[2]/$dateOut[1]/$dateOut[0]")
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





