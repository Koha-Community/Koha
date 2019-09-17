#!/bin/perl

use utf8;
use strict;
use warnings;

use DBI;

use LWP::UserAgent;
use HTTP::Request::Common qw(POST);
use HTTP::Cookies;

use C4::Context;

sub GetSSNDBConfig {
    # Return an array with direct database connection configuration
    my @ssndb;
    push @ssndb, C4::Context->config('ssnProvider')->{'directDB'}->{'host'};
    push @ssndb, C4::Context->config('ssnProvider')->{'directDB'}->{'port'};
    push @ssndb, C4::Context->config('ssnProvider')->{'directDB'}->{'user'};
    push @ssndb, C4::Context->config('ssnProvider')->{'directDB'}->{'password'};
    return @ssndb;
}

sub GetFindSSNConfig {
    # Return findssn service details in an array
    my @findssn;
    push @findssn, C4::Context->config('ssnProvider')->{'url'};
    push @findssn, C4::Context->config('ssnProvider')->{'findSSN'}->{'user'};
    push @findssn, C4::Context->config('ssnProvider')->{'findSSN'}->{'password'};
    return @findssn;
}

sub SSNInterface {
    return C4::Context->config('ssnProvider')->{'interface'};
}

sub directDB {
    my ($host, $port, $user, $password)=GetSSNDBConfig();
    my $dbh_ssn=DBI->connect('DBI:mysql:database=ssn:host=' . $host .':port=' . $port, $user, $password);
    my $sth_ssn=$dbh_ssn->prepare('SELECT ssnvalue
                                 FROM ssn
                                 WHERE ssnkey=?;');

    my $ssnkey=shift;
       $ssnkey=~s/^sotu//;

    $sth_ssn->execute($ssnkey);
    return $sth_ssn->fetchrow_array();
}

sub findSSN {
    # Get ssn for ssnkey using findssn web-service.

    # Allow key to either start with 'sotu' or not (the search is always
    # done with 'sotu' in the beginning because that's how findssn rolls).
    my $ssnkey=shift;
       $ssnkey=~s/^sotu//;
       $ssnkey='sotu' . $ssnkey;

    my ($url, $user, $password)=GetFindSSNConfig();

    my $useragent=LWP::UserAgent->new;
       $useragent->ssl_opts(verify_hostname=>0, SSL_verify_mode=> 0x00); # FIX-ME!

    my $jar=$useragent->cookie_jar(HTTP::Cookies->new());

    # Login
    my $request=POST($url . '/ssn/findssn', [username=>$user, password=>$password]);
    my $response=$useragent->request($request);

    # Get ssn
    $request=POST($url . '/ssn/findssn', [key=>$ssnkey]);
    $response=$useragent->request($request);

    # Findssn returns HTML-document, parse it and return ssn
    my @ssn=grep /<div>sotu[0-9]* *<br\/> */, split '\n', $response->content;
    if (defined $ssn[0]) {
        $ssn[0]=~s/^.*<br\/> *//; $ssn[0]=~s/<\/div>$//;
        undef $ssn[0] if $ssn[0] eq '';
    }
    return $ssn[0];
}

sub GetSSNByKey {
    # Return ssn using configured ssn interface. This is just to keep
    # the code in output filters cleaner (this functionality doesn't need
    # to be duplicated in each of them)
    my $ssninterface=SSNInterface();
    my $ssnkey=shift;
    my $ssn;

    if (defined $ssnkey) {
        no strict 'refs';
        $ssn=&$ssninterface($ssnkey);
    }

    return $ssn;
}

sub GetSSNKey {
    # Get and return borrowers ssn-key
    my $dbh=C4::Context->dbh();
    my $sth_ssn=$dbh->prepare("SELECT attribute
                               FROM borrower_attributes
                               WHERE borrowernumber=?
                               AND code='SSN';");
    $sth_ssn->execute(shift);
    return $sth_ssn->fetchrow_array();
}

sub GetSSNByBorrowerNumber {
    return GetSSNByKey(GetSSNKey(shift));
}

1;
