#!/usr/bin/perl

use strict;
use CGI;
use C4::Context;
use C4::Auth;
use C4::Members;
use C4::Output;
use C4::Languages;

use warnings;
use Koha::Vetuma::Model::Transaction;
use Koha::Vetuma::Request;
my $query = new CGI;
my $requestedAmount;
my $language = C4::Languages::getlanguage($query);

if(defined $query->param('requested_amount')){
    $requestedAmount = $query->param('requested_amount');
}

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "vetuma/vetuma_request.tmpl",
        query           => $query,
        type            => "opac",
        authnotrequired => 0,
        debug           => 1,
    }
);

print "Content-Type: application/x-www-form-urlencoded\n\n";
#print "Content-Type: text/html\n\n";
my $transaction = Koha::Vetuma::Model::Transaction->new();

if($transaction->createTransaction($borrowernumber,$requestedAmount,$language)){
    my $request = $transaction->getVetumaRequest()->getParams();
    my $requestUrl = $transaction->getVetumaRequest()->getRequestUrl();
    $template->param(
        'request' => $request,
        'requestUrl' => $requestUrl
    );
    print $template->output;
}
