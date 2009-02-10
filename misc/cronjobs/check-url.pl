#!/usr/bin/perl

#
# Copyright 2009 Tamil s.a.r.l.
#
# This software is placed under the gnu General Public License, v2 
# (http://www.gnu.org/licenses/gpl.html)
#

use strict;
use warnings;
use diagnostics;
use Carp;
use LWP::Simple;
use Pod::Usage;
use Getopt::Long;
use C4::Context;
use C4::Biblio;


my $verbose     = 0;
my $help        = 0;
my $host        = '';
GetOptions( 
    'verbose'   => \$verbose,
    'help'      => \$help,
    'host=s'    => \$host,
);

sub usage {
    pod2usage( -verbose => 2 );
    exit;
} 

usage() if $help;          

my $context = new C4::Context(  );  
my $dbh = $context->dbh;
my $sth = $dbh->prepare( 
    "SELECT biblionumber FROM biblioitems WHERE url <> ''" );
$sth->execute;
while ( my ($biblionumber) = $sth->fetchrow ) { 
    my $record = GetMarcBiblio( $biblionumber );    
    next unless $record->field('856');
    foreach my $field ( $record->field('856') ) {
        my $url = $field->subfield('u');
        next unless $url;
        $url = "$host/$url" unless $url =~ /^http/;
        if ( head( $url ) ) {
            print "$biblionumber\t$url\tsucceed\n" if $verbose;
        }
        else {
            print "$biblionumber\t$url\tfailed\n";
        }
    }
}
exit;      

=head1 NAME

check-url.pl - Check URLs from 856$u field.

=head1 USAGE

=over

=item check-url.pl [--verbose|--help] [--host=http://default.tld] 

Scan all URL found in 856$u and display if ressources are available or not.

=back

=head1 PARAMETERS

=over

=item B<--host=http://default.tld>

Server host used when URL doesn't have one, ie doesn't begin with 'http:'. 
For example, if --host=http://www.mylib.com, then when 856$u contains 
'img/image.jpg', the url checked is: http://www.mylib.com/image.jpg'.

=item B<--verbose|-v>

Output succeed URL checks with failed ones. 

=item B<--help|-h>

Print this help page.

=back

=cut


