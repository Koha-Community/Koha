#!/usr/bin/perl

# Copyright 2012 Tamil s.a.r.l.
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

use Modern::Perl;
use Pod::Usage;
use Getopt::Long;
use C4::Context;
use C4::Biblio;
use AnyEvent;
use AnyEvent::HTTP;

my ( $verbose, $help, $html ) = ( 0, 0, 0 );
my ( $host,    $host_intranet ) = ( '', '' );
my ( $timeout, $maxconn )       = ( 10, 200 );
my @tags;
my $uriedit    = "/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=";
my $user_agent = 'Mozilla/5.0 (compatible; U; Koha checkurl)';
GetOptions(
    'verbose'         => \$verbose,
    'html'            => \$html,
    'h|help'          => \$help,
    'host=s'          => \$host,
    'host-intranet=s' => \$host_intranet,
    'timeout=i'       => \$timeout,
    'maxconn=i'       => \$maxconn,
    'tags=s{,}'       => \@tags,
);

# Validate tags to check
{
    my %h = map { $_ => undef } @tags;
    @tags = sort keys %h;
    my @invalids;
    for (@tags) {
        push @invalids, $_ unless /^\d{3}$/;
    }
    if (@invalids) {
        say "Invalid tag(s): ", join( ' ', @invalids );
        exit;
    }
    push @tags, '856' unless @tags;
}

sub usage {
    pod2usage( -verbose => 2 );
    exit;
}

sub report {
    my ( $hdr, $biblionumber, $url ) = @_;
    print $html
      ? "<tr>\n <td><a href=\""
      . $host_intranet
      . $uriedit
      . $biblionumber
      . "\">$biblionumber</a>"
      . "</td>\n <td>$url</td>\n <td>"
      . "$hdr->{Status} $hdr->{Reason}</td>\n</tr>\n"
      : "$biblionumber\t$url\t" . "$hdr->{Status} $hdr->{Reason}\n";
}

# Check all URLs from all current Koha biblio records

sub check_all_url {
    my $sth = C4::Context->dbh->prepare(
        "SELECT biblionumber FROM biblioitems ORDER BY biblionumber");
    $sth->execute;

    my $count = 0;                   # Number of requested URL
    my $cv    = AnyEvent->condvar;
    say "<html>\n<body>\n<div id=\"checkurl\">\n<table>" if $html;
    my $idle = AnyEvent->timer(
        interval => .3,
        cb       => sub {
            return if $count > $maxconn;
            while ( my ($biblionumber) = $sth->fetchrow ) {
                my $record = GetMarcBiblio($biblionumber);
                for my $tag (@tags) {
                    foreach my $field ( $record->field($tag) ) {
                        my $url = $field->subfield('u');
                        next unless $url;
                        $url = "$host/$url" unless $url =~ /^http/i;
                        $count++;
                        http_request(
                            HEAD    => $url,
                            headers => { 'user-agent' => $user_agent },
                            timeout => $timeout,
                            sub {
                                my ( undef, $hdr ) = @_;
                                $count--;
                                report( $hdr, $biblionumber, $url )
                                  if $hdr->{Status} !~ /^2/ || $verbose;
                            },
                        );
                    }
                }
                return if $count > $maxconn;
            }
            $cv->send;
        }
    );
    $cv->recv;
    $idle = undef;

    # Few more time for pending requests
    $cv = AnyEvent->condvar;
    my $timer = AnyEvent->timer(
        after    => $timeout,
        interval => $timeout,
        cb       => sub { $cv->send if $count == 0; }
    );
    $cv->recv;
    say "</table>\n</div>\n</body>\n</html>" if $html;
}

usage() if $help;

if ( $html && !$host_intranet ) {
    if ($host) {
        $host_intranet = $host;
    }
    else {
        say
"Error: host-intranet parameter or host must be provided in html mode";
        exit;
    }
}

check_all_url();

=head1 NAME

check-url-quick.pl - Check URLs from biblio records

=head1 USAGE

=over

=item check-url-quick [--verbose|--help|--html] [--tags 310 856] [--host=http://default.tld]
[--host-intranet]

Scan all URLs found by default in 856$u of bib records and display if resources
are available or not. HTTP requests are sent in parallel for efficiency, and
speed.  This script replaces check-url.pl script.

=back

=head1 PARAMETERS

=over

=item B<--host=http://default.tld>

Server host used when URL doesn't have one, ie doesn't begin with 'http:'.
For example, if --host=http://www.mylib.com, then when 856$u contains
'img/image.jpg', the url checked is: http://www.mylib.com/image.jpg'.

=item B<--tags>

Tags containing URLs in $u subfields. If not provided, 856 tag is checked. Multiple tags can be specified, for example:

 check-url-quick.pl --tags 310 410 856

=item B<--verbose|-v>

Outputs both successful and failed URLs.

=item B<--html>

Formats output in HTML. The result can be redirected to a file
accessible by http. This way, it's possible to link directly to biblio
record in edit mode. With this parameter B<--host-intranet> is required.

=item B<--host-intranet=http://koha-pro.tld>

Server host used to link to biblio record editing page in Koha intranet
interface.

=item B<--timeout=10>

Timeout for fetching URLs. By default 10 seconds.

=item B<--maxconn=1000>

Number of simulaneous HTTP requests. By default 200 connexions.

=item B<--help|-h>

Print this help page.

=back

=cut
