#!/usr/bin/perl

#
# Copyright 2009 Tamil s.a.r.l.
#
# This software is placed under the gnu General Public License, v2 
# (http://www.gnu.org/licenses/gpl.html)
#



package C4::URL::Checker;

=head1 NAME 

C4::URL::Checker - base object for checking URL stored in Koha DB

=head1 SYNOPSIS

 use C4::URL::Checker;

 my $checker = C4::URL::Checker->new( );
 $checker->{ host_default } = 'http://mylib.kohalibrary.com';
 my $checked_urls = $checker->check_biblio( 123 );
 foreach my $url ( @$checked_urls ) {
     print "url:        ", $url->{ url        }, "\n",
           "is_success: ", $url->{ is_success }, "\n",
           "status:     ", $url->{ status     }, "\n";
 }
 
=head1 FUNCTIONS

=head2 new

Create a URL Checker. The returned object can be used to set
default host variable :

 my $checker = C4::URL::Checker->new( );
 $checker->{ host_default } = 'http://mylib.kohalibrary.com';

=head2 check_biblio

Check all URL from a biblio record. Returns a pointer to an array
containing all URLs with checking for each of them.

 my $checked_urls = $checker->check_biblio( 123 );

With 2 URLs, the returned array will look like that:

  [
    {
      'url' => 'http://mylib.tamil.fr/img/62265_0055B.JPG',
      'is_success' => 1,
      'status' => 'ok'
    },
    {
      'url' => 'http://mylib.tamil.fr//img/62265_0055C.JPG',
      'is_success' => 0,
      'status' => '404 - Page not found'
    }
  ],
  

=cut

use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Request;
use C4::Biblio;



sub new {

    my $self = {};
    my $class = shift;
    
    $self->{ user_agent } = new LWP::UserAgent;
    
    bless $self, $class;
    return $self;
}


sub check_biblio {
    my $self            = shift;
    my $biblionumber    = shift;
    my $uagent          = $self->{ user_agent   };
    my $host            = $self->{ host_default };

    my $record = GetMarcBiblio( $biblionumber ); 
    return unless $record->field('856');

    my @urls = ();
    foreach my $field ( $record->field('856') ) {
        my $url = $field->subfield('u');
        next unless $url; 
        $url = "$host/$url" unless $url =~ /^http/;
        my $check = { url => $url };
        my $req = HTTP::Request->new( GET => $url );
        my $res = $uagent->request( $req, sub { die }, 1 );
        if ( $res->is_success ) {
            $check->{ is_success } = 1;
            $check->{ status     } = 'ok';
        }
        else {
            $check->{ is_success } = 0;
            $check->{ status     } = $res->status_line;
        }
        push( @urls, $check );       
    }
    return \@urls;
}



package Main;

use strict;
use warnings;
use diagnostics;
use Carp;

use Pod::Usage;
use Getopt::Long;
use C4::Context;



my $verbose     = 0;
my $help        = 0;
my $host        = '';
my $host_pro    = '';
my $html        = 0;
my $uriedit     = "/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=";
GetOptions( 
    'verbose'       => \$verbose,
    'html'          => \$html,
    'help'          => \$help,
    'host=s'        => \$host,
    'host-pro=s'    => \$host_pro,
);


sub usage {
    pod2usage( -verbose => 2 );
    exit;
} 


sub bibediturl {
    my $biblionumber = shift;
    my $html = "<a href=\"$host_pro$uriedit$biblionumber\">$biblionumber</a>";
    return $html;
}


# 
# Check all URLs from all current Koha biblio records
#
sub check_all_url {
    my $checker = C4::URL::Checker->new();
    $checker->{ host_default }  = $host;
    
    my $context = new C4::Context(  );  
    my $dbh = $context->dbh;
    my $sth = $dbh->prepare( 
        "SELECT biblionumber FROM biblioitems WHERE url <> ''" );
    $sth->execute;
    print "<html>\n<body>\n<table>\n" if $html;
    while ( my ($biblionumber) = $sth->fetchrow ) {
        my $result = $checker->check_biblio( $biblionumber );  
        next unless $result;  # No URL
        foreach my $url ( @$result ) {
            if ( ! $url->{ is_success } || $verbose ) {
                print $html
                      ? "<tr>\n<td>" . bibediturl( $biblionumber ) . 
                        "</td>\n<td>" . $url->{url} . "</td>\n<td>" . 
                        $url->{status} . "</td>\n</tr>\n\n"
                      : "$biblionumber\t" . $url->{ url } . "\t" .
                        $url->{ status } . "\n";
            }
        }
    }
    print "</table>\n</body>\n</html>\n" if $html;
}


# BEGIN

usage() if $help;          

if ( $html && !$host_pro ) {
    if ( $host ) {
        $host_pro = $host;
    }
    else {
        print "Error: host-pro parameter or host must be provided in html mode\n";
        exit;
    }
}

check_all_url(); 



=head1 NAME

check-url.pl - Check URLs from 856$u field.

=head1 USAGE

=over

=item check-url.pl [--verbose|--help] [--host=http://default.tld] 

Scan all URLs found in 856$u of bib records 
and display if resources are available or not.

=back

=head1 PARAMETERS

=over

=item B<--host=http://default.tld>

Server host used when URL doesn't have one, ie doesn't begin with 'http:'. 
For example, if --host=http://www.mylib.com, then when 856$u contains 
'img/image.jpg', the url checked is: http://www.mylib.com/image.jpg'.

=item B<--verbose|-v>

Outputs both successful and failed URLs.

=item B<--html>

Formats output in HTML. The result can be redirected to a file
accessible by http. This way, it's possible to link directly to biblio
record in edit mode. With this parameter B<--host-pro> is required.

=item B<--host-pro=http://koha-pro.tld>

Server host used to link to biblio record editing page.

=item B<--help|-h>

Print this help page.

=back

=cut


