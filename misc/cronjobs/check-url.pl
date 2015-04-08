#!/usr/bin/perl

#
# Copyright 2009 Tamil s.a.r.l.
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.



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
    my ($class, $timeout, $agent) = @_;
    
    my $uagent = new LWP::UserAgent;
    $uagent->agent( $agent ) if $agent;
    $uagent->timeout( $timeout) if $timeout;
    $self->{ user_agent } = $uagent;
    $self->{ bad_url    } = { };
    
    bless $self, $class;
    return $self;
}


sub check_biblio {
    my $self            = shift;
    my $biblionumber    = shift;
    my $uagent          = $self->{ user_agent   };
    my $host            = $self->{ host_default };
    my $bad_url         = $self->{ bad_url      };

    my $record = GetMarcBiblio( $biblionumber ); 
    return unless $record->field('856');

    my @urls = ();
    foreach my $field ( $record->field('856') ) {
        my $url = $field->subfield('u');
        next unless $url; 
        $url = "$host/$url" unless $url =~ /^http/;
        my $check = { url => $url };
        if ( $bad_url->{ $url } ) {
            $check->{ is_success } = 1;
            $check->{ status     } = '500 Site already checked';
        }
        else {
            my $req = HTTP::Request->new( GET => $url );
            my $res = $uagent->request( $req, sub { die }, 1 );
            if ( $res->is_success ) {
                $check->{ is_success } = 1;
                $check->{ status     } = 'ok';
            }
            else {
                $check->{ is_success } = 0;
                $check->{ status     } = $res->status_line;
                $bad_url->{ $url     } = 1;
            }
        }
        push @urls, $check;
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
my $agent       = '';
my $timeout     = 15;
GetOptions( 
    'verbose'       => \$verbose,
    'html'          => \$html,
    'help'          => \$help,
    'host=s'        => \$host,
    'host-pro=s'    => \$host_pro,
    'agent=s'       => \$agent,
    'timeout=i',    => \$timeout,
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
    my $checker = C4::URL::Checker->new($timeout,$agent);
    $checker->{ host_default }  = $host;
    
    my $context = new C4::Context(  );  
    my $dbh = $context->dbh;
    my $sth = $dbh->prepare( 
        "SELECT biblionumber FROM biblioitems WHERE url <> ''" );
    $sth->execute;
    if ( $html ) {
        print <<EOS;
<html>
<body>
<table>
EOS
    }
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

=item check-url.pl [--verbose|--help] [--agent=agent-string] [--host=http://default.tld]

Scan all URLs found in 856$u of bib records 
and display if resources are available or not.
This script is deprecated. You should rather use check-url-quick.pl.

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

=item B<--agent=agent-string>

Change default libwww user-agent string to custom.  Some sites do
not like libwww user-agent and return false 40x failure codes,
so this allows Koha to report itself as Koha, or a browser.

=item B<--timeout=15>

Timeout for fetching URLs. By default 15 seconds.

=item B<--help|-h>

Print this help page.

=back

=cut


