#!/usr/bin/perl
package Koha::Vetuma::Model::Transaction;
use Carp;
use Koha::Database;
use C4::Context;
use Koha::Patrons;
use C4::Accounts;
use POSIX qw(strftime);

use Moose;

use Koha::Vetuma::Request;
use Koha::Vetuma::Response;
use Koha::Vetuma::Config;

my $resultSet;
my $vetumaRequest;
my $vetumaResponse;
my $config;
my $borNumber;

sub type {
    return 'VetumaTransaction';
}

sub createTransaction{
    my $self = shift;
    my $borrowerNumber = $_[0];
    my $requestedAmount = $_[1];
    my $language = $_[2];
    my $minAmount = 0;

    $language = $self->getLanguageCode($language);

    # Switch to syspref on integration/PK/161018
    # if(defined $self->getConfig()->{settings}->{min_amount} && $self->getConfig()->{settings}->{min_amount} > 0){
    #     $minAmount = $self->getConfig()->{settings}->{min_amount};
    # }

    $minAmount = C4::Context->preference("OnlinePaymentMinTotal");

    my ( $total , $accts, $numaccts, $pendingRows) = $self->getAccountlinesOutstanding( $borrowerNumber );
    $total = $self->formatPriceToPrecision($total);

    if( ($requestedAmount != $total ) || $total < $minAmount || $total <= 0){
        return 0;
    }

    my $borrowerData = Koha::Patrons->find( $borrowerNumber );
    my $cardNumber;
    if(defined $borrowerData->cardnumber){
        $cardNumber = $borrowerData->cardnumber;
    }

    if(! $self->initVetumaRequest($cardNumber, $total, $language)){
        return 0;
    }
    my $requestAmount = $self->getVetumaRequest()->getParam('AM');
    $requestAmount =~ tr/,/./;
    my $newTransaction = $self->getResultSet()->create({
        amount   => $requestAmount,
        request_timestamp => $self->getVetumaRequest()->getParam('TIMESTMP'),
        ref => $self->getVetumaRequest()->getParam('REF'),
        trid => $self->getVetumaRequest()->getParam('TRID'),
        status => 'PENDING'
    });

    if(defined $newTransaction && $newTransaction->id ){
        $self->linkAccountlinesToTransaction($accts,$newTransaction->id, $numaccts);
    }
    else{
        return 0;
    }

    return 1;
}

sub continueTransaction{
    my $self = shift;
    my $cgiRequest = $_[0];

    if(defined $cgiRequest){
        $self->getVetumaResponse()->initFromCgi($cgiRequest);
        if(defined $self->getConfig()->{settings}->{shared_secret}){
            $self->getVetumaResponse()->setSharedSecret($self->getConfig()->{settings}->{shared_secret});
        }
    }

    if(!$self->getVetumaResponse()->validateResponse()){
        print "not valid";
        return 0;
    }

    my $transaction = $self->loadTransaction( $self->getVetumaResponse()->getParam('TRID'), $self->getVetumaResponse()->getParam('REF') );
    if(defined $transaction->id && defined $transaction->status && $transaction->status ne 'SUCCESSFUL' ){
        $transaction->update({
            status => $self->getVetumaResponse()->getParam('STATUS'),
            response_timestamp => $self->getVetumaResponse()->getParam('TIMESTMP'),
            response_so => $self->getVetumaResponse()->getParam('SO'),
            payid => $self->getVetumaResponse()->getParam('PAYID'),
            paid => $self->getVetumaResponse()->getParam('PAID')
        });
        if($self->getVetumaResponse()->getParam('STATUS') eq 'SUCCESSFUL'){
            $self->updateAccountLines($transaction);
            $self->addPaymentRow($transaction);
        }
    }
}

sub initVetumaRequest{
    my $self = shift;
    my $cardnumber = $_[0];
    my $amount = $_[1];
    my $language = $_[2];

    if($self->getConfig() && defined $self->getConfig()->{settings}){
        my $request = $self->getVetumaRequest();

	if(defined $self->getConfig()->{settings}->{rcvid}){
            $request->setParam('RCVID',$self->getConfig()->{settings}->{rcvid});
        }

        if(defined $self->getConfig()->{settings}->{ap}){
            $request->setParam('AP',$self->getConfig()->{settings}->{ap});
        }

        if(defined $self->getConfig()->{settings}->{appid}){
            $request->setParam('APPID',$self->getConfig()->{settings}->{appid});
        }

        if(defined $self->getConfig()->{settings}->{so}){
            $request->setParam('SO',$self->getConfig()->{settings}->{so});
        }

        if(defined $self->getConfig()->{settings}->{solist}){
            $request->setParam('SOLIST',$self->getConfig()->{settings}->{solist});
        }

        if(defined $self->getConfig()->{settings}->{returl}){
            $request->setParam('RETURL',$self->getConfig()->{settings}->{returl});
        }

        if(defined $self->getConfig()->{settings}->{canurl}){
            $request->setParam('CANURL',$self->getConfig()->{settings}->{canurl});
        }

        if(defined $self->getConfig()->{settings}->{errurl}){
            $request->setParam('ERRURL',$self->getConfig()->{settings}->{errurl});
        }

        if(defined $self->getConfig()->{settings}->{request_url}){
            $request->setRequestUrl($self->getConfig()->{settings}->{request_url});
        }

        if(defined $self->getConfig()->{settings}->{shared_secret}){
            $request->setSharedSecret($self->getConfig()->{settings}->{shared_secret});
        }

        if(defined $cardnumber && defined $self->getConfig()->{settings}->{library_reference_code} ){
            $request->createReferenceNumber($cardnumber, $self->getConfig()->{settings}->{library_reference_code});
            $request->createTrid($cardnumber);
        }

        if(defined $language){
            $request->setParam('LG',$language);
        }

        if(defined $amount){
            $request->setAmount($amount);
        }

        return $request->initRequest()
    }
    return 0;
}

sub loadTransaction{
    my $self = shift;
    my $trid = $_[0];
    my $ref = $_[1];

    return  $self->getResultSet()->single({ trid => $trid, ref => $ref });
}

sub getAccountlinesOutstanding {
    my $self = shift;
    my ($borrowernumber) = @_;
    my $dbh = C4::Context->dbh;
    my @acctlines;
    my @setLines;
    my $numlines = 0;
    my $pendingRows = 0;
    my $strsth      = "SELECT a.*, t.status, t.request_timestamp FROM accountlines as a";
    $strsth .= $self->addLinkTableJoinFromAccountlines();
    $strsth .= ' WHERE a.amountoutstanding != 0 AND borrowernumber=?';
    $strsth .=" ORDER BY accountlines_id desc";
    $strsth = qq($strsth);

    my $sth= $dbh->prepare( $strsth );
    $sth->execute( $borrowernumber );

    my $total = 0;
    while ( my $data = $sth->fetchrow_hashref ) {
        if(!defined $setLines[$data->{'accountlines_id'}]){
            $setLines[$data->{'accountlines_id'}] = $data->{'accountlines_id'};
            $acctlines[$numlines] = $data;

           # $total += $data->{'amountoutstanding'};
            $total += int(1000 * $data->{'amountoutstanding'});
            $numlines++;
        }

      # if($data->{'status'} eq 'PENDING'){
      #      $pendingRows = 1;
      #  }
      #  $total += int(1000 * $data->{'amountoutstanding'}); # convert float to integer to avoid round-off errors
    }
    $total /= 1000;
    return ( $total, \@acctlines,$numlines, $pendingRows);
}

sub addLinkTableJoinFromAccountlines{
    my $join = " LEFT JOIN vetuma_transaction_accountlines_link as l ON a.accountlines_id = l.accountlines_id";
    $join .= " LEFT JOIN vetuma_transaction as t ON l.transaction_id = t.transaction_id";
    return $join;
}

sub updateAccountLines{
    my $self = shift;
    my $transaction = $_[0];
    my $dbh = C4::Context->dbh;

    if(defined $transaction && defined $transaction->id){
        my $update = "UPDATE accountlines AS a";
           $update .= " INNER JOIN vetuma_transaction_accountlines_link as l on a.accountlines_id = l.accountlines_id";
           $update .= " INNER JOIN vetuma_transaction as t on t.transaction_id = l.transaction_id AND t.transaction_id = ? ";
           $update .= " SET amountoutstanding = 0";
        $update = qq($update);

        my $sth= $dbh->prepare( $update );
        $sth->execute( $transaction->id );
    }
}

sub addPaymentRow{
    my $self = shift;
    my $transaction = $_[0];

    my $dbh = C4::Context->dbh;
    my $strsth = 'INSERT INTO accountlines ';

    my $borrowernumber = $self->getBorrowerNumber();
    my $nextaccntno = getnextacctno($borrowernumber);
    my $date = strftime("%Y-%m-%d", localtime);
    my $amount = $transaction->amount * -1;
    my $description = 'Vetuma maksu: ' . $transaction->ref;
    my $amountoutstanding = 0;
    my $accounttype = 'Pay';
    my $strsth = 'INSERT INTO accountlines ( borrowernumber, accountno, date, amount, description, accounttype, amountoutstanding ) VALUES (?,?,?,?,?,?,?)';

    $strsth = qq($strsth);
    my $sth = $dbh->prepare( $strsth );
    $sth->execute($borrowernumber,$nextaccntno,$date,$amount,$description,$accounttype,$amountoutstanding);
}

sub linkAccountlinesToTransaction{
    my $self = shift;
    my $accountlines = $_[0];
    my $transactionId = $_[1];
    my $numLines = $_[2];
    my $dbh = C4::Context->dbh;

    my $strsth = 'INSERT INTO vetuma_transaction_accountlines_link (accountlines_id, transaction_id) VALUES ';
    for ( my $i = 0 ; $i < $numLines ; $i++ ) {
        my $accountLineId = $accountlines->[$i]{'accountlines_id'};
        $strsth .= '( '. $accountLineId .','. $transactionId .' )';
        if( $i != ( $numLines -1 )){
            $strsth .= ', ';
        }
    }

    $strsth = qq($strsth);

    my $sth = $dbh->prepare( $strsth );
    $sth->execute();
}

sub getLanguageCode{
    my $self = shift;
    my $language = $_[0];
    ($language) = ($language =~ /^([^_-]+)/);
    return $language;
}

sub getResultSet{
    my $self = shift;
    if(! defined $resultSet ){
        $resultSet = Koha::Database->new->schema()->resultset($self->type());
    }
    return $resultSet;
}

sub getVetumaRequest{
    my $self = shift;
    if(! defined $vetumaRequest){
        $vetumaRequest = Koha::Vetuma::Request->new();
    }
    return $vetumaRequest;
}

sub getVetumaResponse{
    my $self = shift;
    if(! defined $vetumaResponse){
       $vetumaResponse = Koha::Vetuma::Response->new();
    }
    return $vetumaResponse;
}

sub getConfig{
    my $self = shift;
    if(! defined $config){
        $config = Koha::Vetuma::Config->new()->loadConfigXml();
    }
    return $config ;
}

sub formatPriceToPrecision{
    my $self = shift;
    my $price = $_[0];
    return sprintf( "%.2f",$price);
}

sub setBorrowerNumber{
    my $self = shift;
    $borNumber = $_[0];
}

sub getBorrowerNumber{
    my $self = shift;
    return $borNumber;
}

1;
