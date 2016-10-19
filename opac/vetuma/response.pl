#!/usr/bin/perl

use CGI;
use C4::Auth;
use Koha::Vetuma::Model::Transaction;

my $query = new CGI;
my ( $user, $cookie, $sessionID, $flags ) = checkauth($query, 0, {}, "opac");
$borrowernumber = C4::Auth->getborrowernumber($user) if defined($user);

my $transaction = Koha::Vetuma::Model::Transaction->new();
$transaction->setBorrowerNumber($borrowernumber);
$transaction->continueTransaction($query);

print $query->redirect("/cgi-bin/koha/opac-account.pl");
