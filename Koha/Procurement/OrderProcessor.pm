#!/usr/bin/perl
package Koha::Procurement::OrderProcessor;

use Moose;
use C4::Context;
use Data::Dumper;
use POSIX qw(strftime);

use Koha::Database;
use Koha::Item;
use Koha::Biblio;
use Koha::Biblioitem;
use Koha::Biblio::Metadata;
use C4::Biblio;
use utf8;
use List::MoreUtils qw(uniq);

use Koha::Procurement::OrderProcessor::Order;
use Koha::Procurement::OrderProcessor::Basket;
use Koha::Procurement::EditX::LibraryShipNotice::MarcHelper;
use Koha::Procurement::Logger;
use Koha::Procurement::Config;

has 'schema' => (
    is      => 'rw',
    isa => 'DBIx::Class::Schema',
    reader => 'getSchema',
    writer => 'setSchema'
);

has 'logger' => (
    is      => 'rw',
    isa => 'Koha::Procurement::Logger',
    reader => 'getLogger',
    writer => 'setLogger'
);

has 'config' => (
    is      => 'rw',
    isa => 'Koha::Procurement::Config',
    reader => 'getConfig',
    writer => 'setConfig'
);

sub BUILD {
    my $self = shift;
    my $schema = Koha::Database->new()->schema();
    $self->setSchema($schema);
    $self->setLogger(new Koha::Procurement::Logger);
    $self->setConfig(new Koha::Procurement::Config);
}


sub startProcessing{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $schema = $self->getSchema();
    $dbh->do('START TRANSACTION');
}


sub endProcessing{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    $dbh->do('COMMIT');
}


sub rollBack{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    $dbh->do('ROLLBACK');
}


sub process{
    my $self = shift;
    my $order = $_[0];
    my $orderCreator = Koha::Procurement::OrderProcessor::Order->new;
    my $basketHelper = Koha::Procurement::OrderProcessor::Basket->new;
    if(!$order){
        $self->getLogger()->logError("Order not set.");
        return 0;
    }
    my $itemDetails = $order->getItems();
    if(scalar @$itemDetails <= 0){
        $self->getLogger()->logError('Order has no items.');
        return 0;
    }

    my ($item, $copyDetail, $copyQty, $barCode, $biblio, $biblioitem, $isbn, $basketNumber, $bookseller, $itemId, $orderId);
    my $authoriser = $self->getAuthoriser();
    my $basketName = $order->getBasketName();

    foreach(@$itemDetails){
        $item = $_;
        my $copyDetails = $item->getCopyDetail();
        foreach(@$copyDetails){
            $copyDetail = $_;
            ($biblio, $biblioitem) = $self->getBiblioDatas($copyDetail, $item, $order);
            $copyQty = $copyDetail->getCopyQuantity();
            if($copyQty > 0){
                $bookseller = $self->getBookseller($order);
                $basketNumber = $basketHelper->getBasket($bookseller, $authoriser, $basketName );
                $orderId = $orderCreator->createOrder($copyDetail, $item, $order, $biblio, $basketNumber);
                for(my $i = 0; $copyQty > $i; $i++ ){
                    $self->advanceBarcodeValue();
                    $barCode = $self->getBarcodeValue();
                    $itemId = $self->createItem($copyDetail, $item, $order, $barCode, $biblio, $biblioitem);
                    $orderCreator->createOrderItem($itemId, $orderId);
                }
                ModZebra( $biblio, "specialUpdate", "biblioserver" );
                $self->updateAqbudgetLog($copyDetail, $item, $order, $biblio);
            }
        }
    }
    $basketHelper->closeBasket($basketName);
}


sub getBiblioDatas {
    my $self = shift;
    my ($copyDetail, $itemDetail, $order) = @_;
    my ($biblio, $biblioitem, $bibliometa);

    if($self->getConfig()->getUseAutomatchBiblios() ne 'no'){
        ($biblio, $biblioitem) = $self->getBiblioItemData($copyDetail, $itemDetail, $order);
    }
    if( !$biblio && !$biblioitem ){
        $biblio = $self->createBiblio($copyDetail, $itemDetail, $order);
        $copyDetail->addMarc942($self->getProductForm($itemDetail->getProductForm()));
        $copyDetail->fixMarcIsbn();
        ($biblioitem) = $self->createBiblioItem($copyDetail, $itemDetail, $order, $biblio);
        ($bibliometa) = $self->createBiblioMetadata($copyDetail, $itemDetail, $order, $biblio);

        my $marcBiblio = GetMarcBiblio($biblio);
        if(! $marcBiblio){
           die('Getting marcbiblio failed.');
        }
        if(! ModBiblio($marcBiblio, $biblio, '')){
           die('Modbiblio failed.');
        }
    }
    return ($biblio, $biblioitem);
}


sub getBiblioItemData {
    my $self = shift;
    my ($copyDetail, $itemDetail, $order) = @_;
    my (@isbns, $ean, $publishercode, $editionresponsibility, $rows, $row, @result);
    my $isbns1 = $itemDetail->getIsbns();
    push @isbns, @$isbns1;
    my $isbns2 = $copyDetail->getIsbns();
    push @isbns, @$isbns2;
    @isbns = uniq @isbns;

    $ean = $copyDetail->getMarcStdIdentifier();
    $publishercode = $copyDetail->getMarcPublisherIdentifier();
    $editionresponsibility = $copyDetail->getMarcPublisher();

    if(@isbns){
        $rows = $self->getItemsByIsbns(@isbns);
    }

    if($ean && (!$rows || $rows->count <= 0)){
        $rows = $self->getItemByColumns({ ean =>$ean});
    }
    if($publishercode && $editionresponsibility && (!$rows || $rows->count <= 0)){
        $rows = $self->getItemByColumns({ publishercode => $publishercode, editionresponsibility => $editionresponsibility });
    }

    if($rows && $rows->count > 0 ){
         $row = $rows->next;
         if($row && defined $row->biblionumber->biblionumber && defined $row->biblioitemnumber ){
            @result = ($row->biblionumber->biblionumber, $row->biblioitemnumber, $row->isbn);
         }
    }

    return @result;
}


sub getFundYear {
    my $self = shift;
    my $budgetCode = $_[0];
    my $budgetperiodid = $_[1];
    my $year;
    my $dbh = C4::Context->dbh;
    my $stmnt = $dbh->prepare("select distinct year(a.budget_period_enddate) from aqbudgetperiods a, aqbudgets b
                             where a.budget_period_active = 1
                             and a.budget_period_id = ?
                             and a.budget_period_id = b.budget_period_id
                             and b.budget_code like ? " );
    my $budgetCodeLike = $budgetCode . "%";

    $stmnt->execute($budgetperiodid, $budgetCodeLike);
    if ($stmnt->rows >= 1){
        $year = $stmnt->fetchrow_array();
    }
    else{
        $year = strftime "%Y", localtime;
    }
     return $year;
}


sub advanceBarcodeValue {
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $stmnt = $dbh->prepare("UPDATE sequences set item_barcode_nextval = item_barcode_nextval+1");
    $stmnt->execute();
}


sub getBarcodeValue{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $stmnt = $dbh->prepare("SELECT max(item_barcode_nextval) from sequences");
    $stmnt->execute();
    return $stmnt->fetchrow_array();
}


sub getItemsByIsbns {
    my $self = shift;
    my @isbnArray = $_[0];
    my $resultSet = $self->getSchema()->resultset(Koha::Biblioitem->_type());
    my $result = -1;

    if(@isbnArray > 0){
        $result = $resultSet->search({'isbn' => {'in' => @isbnArray}},{ select => [qw/isbn biblionumber biblioitemnumber/] });
    }
    return $result;
}

sub getItemByColumns {
    my $self = shift;
    my $columns = $_[0];

    my $resultSet = $self->getSchema()->resultset(Koha::Biblioitem->_type());
    my $result = -1;

    if($columns){
        $result = $resultSet->search($columns, { select => [qw/isbn biblionumber biblioitemnumber/] });
    }

    return $result;
}


sub createBiblio{
    my $self = shift;
    my ($copyDetail, $itemDetail, $order) = @_;
    my $result = 0;
    my $data = {};

    if($itemDetail->isa('Koha::Procurement::EditX::LibraryShipNotice::ItemDetail') ){
        $data->{'author'} = $itemDetail->getAuthor();
        $data->{'title'} = $itemDetail->getTitle();
        $data->{'notes'} = $itemDetail->getNotes();
        $data->{'seriestitle'} = $itemDetail->getSeriesTitle();;
        $data->{'copyrightdate'} = $copyDetail->getYearOfPublication();
        $data->{'timestamp'} = $order->getTimeStamp();
        $data->{'datecreated'} = $order->getDateCreated();

        my @paramsToValidate = ('title', 'notes', 'timestamp', 'datecreated');
        if($self->validate({'params', \@paramsToValidate , 'data', $data })){
            my $biblio  = new Koha::Biblio;
            $biblio->set({'author', $data->{author}});
            $biblio->set({'title', $data->{title}});
            $biblio->set({'notes', $data->{notes}});
            $biblio->set({'timestamp', $data->{timestamp}});
            $biblio->set({'datecreated', $data->{datecreated}});

            if(defined $data->{copyrightdate} && $data->{copyrightdate} ne ''){
                $biblio->set({'copyrightdate', $data->{copyrightdate}});
            }

            if(defined $data->{seriestitle} && $data->{seriestitle} ne ''){
                $biblio->set({'seriestitle', $data->{seriestitle}});
            }
            $biblio->store() or die($DBI::errstr);

            if($biblio->id){
                $result = $biblio->id;
            }
            else{
                die('Biblioid not set after db save.')
            }
        }
        else{
            die('Required params not set.');
        }
    }
    return $result;
}


sub createBiblioItem{
    my $self = shift;
    my ($copyDetail, $itemDetail, $order, $biblio) = @_;
    my (@result, $id);
    my $data = {};
    if($itemDetail->isa('Koha::Procurement::EditX::LibraryShipNotice::ItemDetail') ){
        $data->{'biblio'} = $biblio;
        $data->{'productform'} = $self->getProductForm($itemDetail->getProductForm());

        $data->{'isbn'} = $copyDetail->getIsbn();
        $data->{'ean'} = $copyDetail->getMarcStdIdentifier();
        $data->{'publishercode'} = $copyDetail->getMarcPublisherIdentifier();
        $data->{'editionresponsibility'} = $copyDetail->getMarcPublisher();

        $data->{'productidtype'} = $itemDetail->getProductIdType();
        $data->{'publishername'} = $copyDetail->getPublisherName();
        $data->{'yearofpublication'} = $copyDetail->getYearOfPublication();
        $data->{'editionstatement'} = $copyDetail->getEditionStatement();
        $data->{'timestamp'} = $order->getTimeStamp();
        my $marc = $copyDetail->getMarcXml();
        utf8::decode($marc);
        $data->{'marcxml'} = $marc;
        $data->{'notes'} = $itemDetail->getNotes();
        $data->{'image'} = $copyDetail->getImageDescrition();
        $data->{'pages'} = $copyDetail->getPages();
        $data->{'place'} = $copyDetail->getPlace();
        $data->{'url'} = '';

        my @paramsToValidate = ('biblio', 'productform', 'timestamp', 'marcxml', 'notes');
        my @isbn = ('isbn');
        my @ean = ('ean');
        my @identifierParams = ('publishercode', 'editionresponsibility');
        if($self->validate({'params', \@paramsToValidate , 'data', $data })
            #&& ($self->validate({'params', \@isbn , 'data', $data }) || $self->validate({'params', \@ean , 'data', $data }) || $self->validate({'params', \@identifierParams , 'data', $data }) )
        ){

            my $biblioItem  = new Koha::Biblioitem;
            $biblioItem->set({'biblionumber', $data->{'biblio'}});
            $biblioItem->set({'itemtype', $data->{'productform'}});
            $biblioItem->set({'timestamp', $data->{'timestamp'}});
            $biblioItem->set({'notes', $data->{'notes'}});

            if(defined $data->{'isbn'} && $data->{'isbn'} ne ''){
                $biblioItem->set({'isbn', $data->{'isbn'}});
            }

            if(defined $data->{'ean'} && $data->{'ean'} ne ''){
                $biblioItem->set({'ean', $data->{'ean'}});
            }

            if(defined $data->{'yearofpublication'} && $data->{'yearofpublication'} ne ''){
                $biblioItem->set({'publicationyear', $data->{'yearofpublication'}});
            }

            $biblioItem->set({'publishercode', $data->{'publishername'}});
            if(defined $data->{'publishercode'} && $data->{'publishercode'} ne ''){
                $biblioItem->set({'publishercode', $data->{'publishercode'}});
            }

            if(defined $data->{'editionresponsibility'} && $data->{'editionresponsibility'} ne ''){
                $biblioItem->set({'editionresponsibility', $data->{'editionresponsibility'}});
            }

            if(defined $data->{'editionstatement'} && $data->{'editionstatement'} ne ''){
                $biblioItem->set({'editionstatement', $data->{'editionstatement'}});
            }

            if(defined $data->{'pages'} && $data->{'pages'} ne ''){
                $biblioItem->set({'pages', $data->{'pages'}});
            }

            if(defined $data->{'place'} && $data->{'place'} ne ''){
                $biblioItem->set({'place', $data->{'place'}});
            }

            if(defined $data->{'url'} && $data->{'url'} ne ''){
                $biblioItem->set({'url', $data->{'url'}});
            }

            $biblioItem->store() or die($DBI::errstr);

            if($biblioItem->id){
                $id = $biblioItem->id;
                @result = ($id, $data->{'selleridentifier'});
            }
            else{
                die('Biblioitemid not set after db save.')
            }
        }
        else{
            die('Required params not set.');
        }
    }
    return @result;
}

sub createBiblioMetadata {
    my $self = shift;
    my ($copyDetail, $itemDetail, $order, $biblio) = @_;
    my $result = 0;
    my $data = {};

    if($itemDetail->isa('Koha::Procurement::EditX::LibraryShipNotice::ItemDetail') ){
        $data->{'biblio'} = $biblio;
        my $marc = $copyDetail->getMarcXml();
        utf8::decode($marc);
        $data->{'marcxml'} = $marc;
        $data->{'format'} = 'marcxml';
        $data->{'marcflavour'} = C4::Context->preference('marcflavour');

        my @paramsToValidate = ('biblio', 'marcxml');
        if($self->validate({'params', \@paramsToValidate , 'data', $data })){
            my $biblioMetadata = new Koha::Biblio::Metadata;
            $biblioMetadata->set({'biblionumber', $data->{'biblio'}});
            $biblioMetadata->set({'metadata', $data->{'marcxml'}});
            $biblioMetadata->set({'format', $data->{'format'}});
            $biblioMetadata->set({'marcflavour', $data->{'marcflavour'}});

            $biblioMetadata->store() or die($DBI::errstr);

            if($biblioMetadata->id){
                $result = $biblioMetadata->id;
            }
            else{
                die('Bibliometaid not set after db save.')
            }
        }
        else{
            die('Required params not set.');
        }
    }
    return $result;
}



sub createItem{
    my $self = shift;
    my ($copyDetail, $itemDetail, $order, $barcode, $biblio, $biblioitem) = @_;
    my $result = 0;
    my $data = {};

    if($itemDetail->isa('Koha::Procurement::EditX::LibraryShipNotice::ItemDetail') ){
        $data->{'booksellerid'} = $order->getSellerId();
        $data->{'destinationlocation'} = $copyDetail->getBranchCode();
        $data->{'price'} = $itemDetail->getPriceFixedRPExcludingTax();
        $data->{'replacementprice'} = $itemDetail->getPriceSRPIncludingTax();
        $data->{'timestamp'} = $order->getTimeStamp();
        $data->{'productform'} = $self->getProductForm($itemDetail->getProductForm());
        $data->{'notes'} = $itemDetail->getNotes();
        $data->{'datecreated'} = $order->getDateCreated();
        $data->{'collectioncode'} = $copyDetail->getLocation();
        $data->{'biblio'} = $biblio;
        $data->{'biblioitem'} = $biblioitem;

        if($barcode){
            $data->{'barcode'} = "HANK_" . $barcode;
        }

        my @paramsToValidate = ('biblio', 'biblioitem', 'booksellerid', 'destinationlocation', 'price', 'replacementprice', 'productform', 'notes', 'datecreated', 'collectioncode', 'barcode');
        if($self->validate({'params', \@paramsToValidate , 'data', $data })){
            my $item  = new Koha::Item;
            $item->set({'biblionumber', $data->{'biblio'}});
            $item->set({'biblioitemnumber', $data->{'biblioitem'}});
            $item->set({'booksellerid', $data->{'booksellerid'}});
            $item->set({'homebranch', $data->{'destinationlocation'}});
            $item->set({'replacementprice', $data->{'replacementprice'}});
            $item->set({'timestamp', $data->{'timestamp'}});
            $item->set({'itype', $data->{'productform'}});
            $item->set({'coded_location_qualifier', $data->{'notes'}});
            $item->set({'price', $data->{'price'}});
            $item->set({'dateaccessioned', $data->{'datecreated'}});
            $item->set({'barcode', $data->{'barcode'}});
            $item->set({'datelastseen', $data->{'datecreated'}});
            $item->set({'notforloan', -1});
            $item->set({'holdingbranch', $data->{'destinationlocation'}});
            $item->set({'location', $data->{'collectioncode'}});
            $item->set({'permanent_location', $data->{'collectioncode'}});

            $item->store() or die($DBI::errstr);

            if($item->id){
                $result = $item->id;
            }
            else{
                die('Itemid not set after db save.')
            }
        }
        else{
             die('Required params not set.');
        }
    }
    return $result;
}


sub updateAqbudgetLog {
    my $self = shift;
    my ($copyDetail, $itemDetail, $order, $biblio) = @_;

    my $copyQty = $copyDetail->getCopyQuantity();
    my $totalAmount = $copyDetail->getFundMonetaryAmount() * $copyQty;

    my $monetaryamount = $itemDetail->getPriceFixedRPExcludingTax();
    my $timestamp = $order->getTimeStamp();
    my $tied = $order->getFileName();
    my $fundnumber = $copyDetail->getFundNumber();
    my $personname = $order->getPersonName();
    my $productform = $itemDetail->getProductForm();
    my $copyquantity = $copyQty;
    my $destinationlocation = $copyDetail->getBranchCode();
    my $collectioncode = $copyDetail->getLocation();

    my $dbh = C4::Context->dbh;
    my $stmnt = $dbh->prepare(qq{INSERT INTO aqbudgets_spend_log (monetary_amount,timestamp,origin,fund,account,itemtype,copy_quantity,total_amount,location,collection,biblionumber) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)});
    $stmnt->execute($monetaryamount,$timestamp,$tied,$fundnumber,$personname,$productform,$copyquantity,$totalAmount,$destinationlocation,$collectioncode,$biblio) or die($DBI::errstr);
}


sub getBookseller{
    my $self = shift;
    my ($order) = @_;
    my ($bookseller,$vendorAssignedId) = (0,0);

    $vendorAssignedId = $order->getVendorAssignedId();
    if($vendorAssignedId){
        my $dbh = C4::Context->dbh;
        my $stmnt = $dbh->prepare("SELECT id FROM vendor_edi_accounts WHERE san = ? AND id_code_qualifier='91' AND transport='FILE' AND orders_enabled='1'");
        $stmnt->execute($vendorAssignedId) or die($DBI::errstr);
        $bookseller = $stmnt->fetchrow_array();
    }

    if(!$bookseller){
        $self->getLogger()->logError("No vendor account found with VendorAssignedId: $vendorAssignedId in table vendor_edi_accounts.");
        $self->getLogger()->log("No vendor account found with VendorAssignedId: $vendorAssignedId in table vendor_edi_accounts.");
        die();
    }

    return $bookseller;
}

sub getProductForm {
    my $self = shift;
    my $productForm = $_[0];
    my $result;

    if($productForm){
        my $dbh = C4::Context->dbh;
        my $stmnt = $dbh->prepare("SELECT max(productform) from map_productform where onix_code = ?");
        $stmnt->execute($productForm) or die($DBI::errstr);
        $result = $stmnt->fetchrow_array();
    }

    if($result){
        $productForm = $result;
    }
    return $productForm;
}

sub validate{
    my $self = shift;
    my $values = $_[0];
    my ($params, $data, $param);
    my $result = 1;
    if(defined $values->{params}){
        $params = $values->{params};
    }

    if(defined $values->{data}){
        $data  = $values->{data};
    }

    foreach(@$params){
        $param = $_;

        if(!defined $data->{$param} || $data->{$param} eq ''){
            $self->getLogger()->logError("Required parameter: '\$$param' was not set or it was empty.",1);
            $result = 0;
        }
    }

    return $result;
}

sub getAuthoriser{
    my $self = shift;
    my $authoriser;
    my $settings = $self->getConfig()->getSettings();
    if(defined $settings->{settings}->{authoriser} ){
        $authoriser = $settings->{settings}->{authoriser};
    }
    return $authoriser;
}


1;
