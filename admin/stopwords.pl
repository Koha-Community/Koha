#!/usr/bin/perl

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
#
###
#
# script to administer the stopwords table
#
# - written on 2002/02/20 by paul.poulain@free.fr
#
# - experimentaly rewrittten on 2006/04/06 by Pierrick LE GALL (INEO media
#   system)
#

use strict;
use CGI;
use List::Util qw/min/;

use C4::Context;
use C4::Output;
use C4::Search;
use HTML::Template;
use C4::Auth;
use C4::Interface::CGI::Output;

sub StringSearch  {
    my ($searchstring) = @_;

    my $dbh = C4::Context->dbh;
    $searchstring =~ s/\'/\\\'/g;
    my @tokens = split(' ',$searchstring);

    my $query = '
SELECT word
  FROM stopwords
  WHERE (word like ?)
  ORDER BY word
';
    my $sth = $dbh->prepare($query);
    $sth->execute($tokens[0].'%');
    my @results;
    while (my $row = $sth->fetchrow_hashref) {
        push(@results, $row->{word});
    }
    $sth->finish;

    return @results;
}

my $dbh = C4::Context->dbh;
my $sth;
my $query;
my $input = new CGI;
my $searchfield = $input->param('searchfield');
my $script_name="/cgi-bin/koha/admin/stopwords.pl";

my $pagesize = 40;
my $op = $input->param('op');
$searchfield=~ s/\,//g;

my ($template, $loggedinuser, $cookie) 
    = get_template_and_user({template_name => "admin/stopwords.tmpl",
                            query => $input,
                            type => "intranet",
 			    flagsrequired => {parameters => 1, management => 1},
			    authnotrequired => 0,
                            debug => 1,
                            });

$template->param(script_name => $script_name,
		 searchfield => $searchfield);

if ($input->param('add')) {
    if ($input->param('word')) {
        my @words = split / |,/, $input->param('word');

        $query = '
DELETE
  FROM stopwords
  WHERE word IN (?'.(',?' x scalar @words - 1).')
';
        $sth = $dbh->prepare($query);
        $sth->execute(@words);
        $sth->finish;

        $query = '
INSERT
  INTO stopwords
  (word)
  VALUES
  (?)'.(',(?)' x scalar @words - 1).'
';
        $sth = $dbh->prepare($query);
        $sth->execute(@words);
        $sth->finish;

        $template->param(stopword_added => 1);
    }
}
elsif ($input->param('deleteSelected')) {
    if ($input->param('stopwords[]')) {
        my @stopwords_loop = ();

        foreach my $word ($input->param('stopwords[]')) {
            push @stopwords_loop,  {word => $word};
        }

        $template->param(
            delete_confirm => 1,
            stopwords_to_delete => \@stopwords_loop,
        );
    }
}
elsif ($input->param('confirmDeletion')) {
    my @words = $input->param('confirmed_stopwords[]');

    $query = '
DELETE
  FROM stopwords
  WHERE word IN (?'.(',?' x scalar @words - 1).')
';
    $sth = $dbh->prepare($query);
    $sth->execute(@words);
    $sth->finish;

    $template->param(delete_confirmed => 1);
}

my $page = $input->param('page') || 1;

my @results = StringSearch($searchfield);
my @loop;

my $first = ($page - 1) * $pagesize;

# if we are on the last page, the number of the last word to display must
# not exceed the length of the results array
my $last = min(
    $first + $pagesize - 1,
    scalar(@results) - 1,
);

foreach my $word (@results[$first .. $last]) {
    push @loop, {word => $word};
}

$template->param(
    loop => \@loop,
    pagination_bar => pagination_bar(
        $script_name,
        int(scalar(@results) / $pagesize) + 1,
        $page,
        'page'
    )
);

output_html_with_http_headers $input, $cookie, $template->output;
