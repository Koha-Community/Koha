#!/usr/bin/perl

# Copyright 2017 PTFS-Europe Ltd
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

use CGI qw ( -utf8 );
use C4::Auth;
use C4::Koha;
use C4::Output;

use Koha::Illrequest::Config;
use Koha::Illrequests;
use Koha::Libraries;
use Koha::Patrons;

my $query = new CGI;

# Grab all passed data
# 'our' since Plack changes the scoping
# of 'my'
our $params = $query->Vars();

# if illrequests is disabled, leave immediately
if ( ! C4::Context->preference('ILLModule') ) {
    print $query->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

my ( $template, $loggedinuser, $cookie ) = get_template_and_user({
    template_name   => "opac-illrequests.tt",
    query           => $query,
    type            => "opac",
    authnotrequired => 0,
});

# Are we able to actually work?
my $backends = Koha::Illrequest::Config->new->available_backends;
my $backends_available = ( scalar @{$backends} > 0 );
$template->param( backends_available => $backends_available );

my $op = $params->{'method'} || 'list';

if ( $op eq 'list' ) {

    my $requests = Koha::Illrequests->search(
        { borrowernumber => $loggedinuser }
    );
    my $req = Koha::Illrequest->new;
    $template->param(
        requests => $requests,
        backends    => $req->available_backends
    );

} elsif ( $op eq 'view') {
    my $request = Koha::Illrequests->find({
        borrowernumber => $loggedinuser,
        illrequest_id  => $params->{illrequest_id}
    });
    $template->param(
        request => $request
    );

} elsif ( $op eq 'update') {
    my $request = Koha::Illrequests->find({
        borrowernumber => $loggedinuser,
        illrequest_id  => $params->{illrequest_id}
    });
    $request->notesopac($params->{notesopac})->store;
    print $query->redirect(
        '/cgi-bin/koha/opac-illrequests.pl?method=view&illrequest_id=' .
        $params->{illrequest_id} .
        '&message=1'
    );
    exit;
} elsif ( $op eq 'cancreq') {
    my $request = Koha::Illrequests->find({
        borrowernumber => $loggedinuser,
        illrequest_id  => $params->{illrequest_id}
    });
    $request->status('CANCREQ')->store;
    print $query->redirect(
        '/cgi-bin/koha/opac-illrequests.pl?method=view&illrequest_id=' .
        $params->{illrequest_id} .
        '&message=1'
    );
    exit;
} elsif ( $op eq 'create' ) {
    if (!$params->{backend}) {
        my $req = Koha::Illrequest->new;
        $template->param(
            backends    => $req->available_backends
        );
    } else {
        my $request = Koha::Illrequest->new
            ->load_backend($params->{backend});
        $params->{cardnumber} = Koha::Patrons->find({
            borrowernumber => $loggedinuser
        })->cardnumber;
        $params->{opac} = 1;
        my $backend_result = $request->backend_create($params);
        if ($backend_result->{stage} eq 'copyrightclearance') {
            $template->param(
                stage       => $backend_result->{stage},
                whole       => $backend_result
            );
        } else {
            $template->param(
                media       => [ "Book", "Article", "Journal" ],
                branches    => Koha::Libraries->search->unblessed,
                whole       => $backend_result,
                request     => $request
            );
            if ($backend_result->{stage} eq 'commit') {
                print $query->redirect('/cgi-bin/koha/opac-illrequests.pl?message=2');
                exit;
            }
        }

    }
}

$template->param(
    message         => $params->{message},
    illrequestsview => 1,
    method          => $op
);

output_html_with_http_headers $query, $cookie, $template->output;
