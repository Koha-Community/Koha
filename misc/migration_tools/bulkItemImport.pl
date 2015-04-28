#!/usr/bin/perl

use Modern::Perl;

use Getopt::Long;

use C4::RotatingCollections;
use ConversionTable::ItemnumberConversionTable;
use ConversionTable::BiblionumberConversionTable;

binmode( STDOUT, ":encoding(UTF-8)" );
binmode( STDIN, ":encoding(UTF-8)" );

my ($itemsFile, $number, $biblionumberConversionTable, $itemnumberConversionTable, $verbose) =
   (undef, undef, 'biblionumberConversionTable', 'itemnumberConversionTable', undef);

GetOptions(
    'file:s'                   => \$itemsFile,
    'n:f'                      => \$number,
    'b|bnConversionTable:s'    => \$biblionumberConversionTable,
    'i|inConversionTable:s'    => \$itemnumberConversionTable,
    'v|verbose'                => \$verbose,
);


my $help = <<HELP;

perl ./bulkItemsImport.pl --file /home/koha/pielinen/items.migrateme -n 750 -v \
    --bnConversionTable 'bulkmarcimport.log'

Migrates the Perl-serialized MMT-processed Items to Koha.
Also creates the RotatingCollections when needed.

  --file                The perl-serialized HASH of Items.

  -n                    How many Items to migrate? Defaults to ALL.

  --bnConversionTable   From which file to read the converted biblionumber?
                        We are adding Biblios to a database with existing Biblios, so we need to convert
                        biblionumbers so they won't overlap with existing ones.
                        biblionumberConversionTable has the following format, where first column is the original
                        biblio id and the second column is the mapped Koha biblionumber:

                            id;newid;operation;status
                            685009;685009;insert;ok
                            685010;685010;insert;ok
                            685011;685011;insert;ok
                            685012;685012;insert;ok
                            ...

                        Defaults to 'biblionumberConversionTable'

  --inConversionTable   To which file to write the itemnumber to barcode conversion. Items are best referenced
                        by their barcodes, because the itemnumbers can overlap with existing Items.
                        Defaults to 'itemnumberConversionTable'

    --verbose -v        Might do nothing :)
HELP

unless ($itemsFile) {
    die "$help\n\nYou must give the Items-file.";
}

sub openItemsFile {
    my ($itemsFile, $skipRows) = @_;
    $skipRows = 0 unless $skipRows;

    open(my $fh, "<:encoding(utf-8)", $itemsFile );
    my $i=0;
    while($i++ < $skipRows) {
        my $waste = <$fh>;
        #Skip rows.
    }
    return $fh;
}

my $dbh = C4::Context->dbh;
$dbh->{'mysql_enable_utf8'} = 1;
$dbh->do('SET NAMES utf8');

my $createCheckoutStatisticsSQL_issue =
  "INSERT INTO statistics (branch, type, other, itemnumber, itemtype) VALUES ";
my $createCheckoutStatisticsSQL_return =
  "INSERT INTO statistics (branch, type, other, itemnumber, itemtype) VALUES ";
my $query = "INSERT INTO items SET
            itemnumber          = ?,
            biblionumber        = ?,
            biblioitemnumber    = ?,
            barcode             = ?,
            dateaccessioned     = ?,
            booksellerid        = ?,
            homebranch          = ?,
            price               = ?,
            replacementprice    = ?,
            replacementpricedate = ?,
            datelastborrowed    = ?,
            datelastseen        = ?,
            stack               = ?,
            notforloan          = ?,
            damaged             = ?,
            itemlost            = ?,
            withdrawn            = ?,
            itemcallnumber      = ?,
            coded_location_qualifier = ?,
            restricted          = ?,
            itemnotes           = ?,
            holdingbranch       = ?,
            paidfor             = ?,
            location            = ?,
            permanent_location            = ?,
            onloan              = ?,
            issues              = ?,
            renewals            = ?,
            reserves            = ?,
            cn_source           = ?,
            cn_sort             = ?,
            ccode               = ?,
            itype               = ?,
            materials           = ?,
            uri = ?,
            enumchron           = ?,
            more_subfields_xml  = ?,
            copynumber          = ?,
            stocknumber         = ?
          ";
my $sth   = $dbh->prepare($query);
my $today = C4::Dates->today('iso');


my $issues = [];
my $returns = [];    #Collect all the statistics elements here for one huge insertion!
$biblionumberConversionTable = ConversionTable::BiblionumberConversionTable->new( $biblionumberConversionTable, 'read' );

$itemnumberConversionTable = ConversionTable::ItemnumberConversionTable->new( $itemnumberConversionTable, 'write' );

my $rotatingCollections = {}; #Collect the references to already created rotating collections here.

my $i = 0;
my $fh = openItemsFile($itemsFile, $i);
while (<$fh>) {
    $i++;
    print ".";
    print "\n$i" unless $i % 100;

    my $item = newFromRow($_);


    ##After a few hundreds of thousands Items, the filehandle gets corrupt and mangles utf8.
    ##If you have trouble with that you can try these snippets to pin-point the issue
    ##It is most likely due to the statistics writing module trying to send too many INSERTs
    ##  at once and crashing repeatedly. MariaDB can't take everything I guess.
    my $next = tryToCaptureMangledUtf8InDB($item);
    next if $next;


    my $existingBarcodeItem = C4::Items::GetItem(undef, $item->{barcode});
    if ($existingBarcodeItem) {
        $item->{barcode} .= '_TUPLA';
        print "\n".'DUPLICATE BARCODE "'.$item->{barcode}.'" FOUND'."\n";
    }
    my $newBiblionumber = getNewBiblionumber( $biblionumberConversionTable, $item );
    $item->{biblionumber} = $newBiblionumber;
    $item->{biblioitemnumber} = $newBiblionumber;

    my ($newItemnumber, $error) = _koha_new_item( $item, $item->{barcode} ) if $newBiblionumber;

    if ($error) {
        print "ERROR FOR:\n".$error."\n";
        next();
    }
    if (not($newItemnumber)) {
        print "ERROR: Failed to get itemnumber for Item ".$item->{barcode}."\n";
        next();
    }

    $itemnumberConversionTable->writeRow($item->{itemnumber}, $newItemnumber, $item->{barcode});
    $item->{itemnumber} = $newItemnumber;

    createCheckoutStatistics($item);

    if (exists $item->{rotatingcollection}) {
        my $rcItem = $item->{rotatingcollection};
        my $rc = getRotatingCollectionFromHomebranch($rcItem->{homebranch});
        C4::RotatingCollections::AddItemToCollection($rc, $newItemnumber);
    }
}
createCheckoutStatistics( undef, 'lastrun' );

close $fh;


sub _koha_new_item {
    my ( $item, $barcode ) = @_;
    my $error;

    $sth->execute(
#        $item->{'itemnumber'},
        undef,
        $item->{'biblionumber'},
        $item->{'biblioitemnumber'},
        $barcode,
        $item->{'dateaccessioned'},
        $item->{'booksellerid'},
        $item->{'homebranch'},
        $item->{'price'},
        $item->{'replacementprice'},
        $item->{'replacementpricedate'} || $today,
        $item->{datelastborrowed},
        $item->{datelastseen} || $today,
        $item->{stack},
        $item->{'notforloan'} || 0,
        $item->{'damaged'} || 0,
        $item->{'itemlost'} || 0,
        $item->{'withdrawn'} || 0,
        $item->{'itemcallnumber'},
        $item->{'coded_location_qualifier'},
        $item->{'restricted'},
        $item->{'itemnotes'},
        $item->{'holdingbranch'},
        $item->{'paidfor'},
        $item->{'location'},
        $item->{'permanent_location'},
        $item->{'onloan'},
        $item->{'issues'},
        $item->{'renewals'},
        $item->{'reserves'},
        $item->{'items.cn_source'},
        $item->{'items.cn_sort'},
        $item->{'ccode'},
        $item->{'itype'},
        $item->{'materials'},
        $item->{'uri'},
        $item->{'enumchron'},
        $item->{'more_subfields_xml'},
        $item->{'copynumber'},
        $item->{'stocknumber'},
    );

    my $itemnumber;
    if ( $sth->errstr() ) {
        $error .= "ERROR in _koha_new_item $query" . $sth->errstr();
    }
    else {
        $itemnumber = $dbh->{'mysql_insertid'};
        unless ($itemnumber) {
            $dbh->disconnect();
            $dbh = C4::Context->new_dbh();
            $itemnumber = C4::Items::GetItemnumberFromBarcode($barcode);
            if ($itemnumber) {
                print "\nRecovered from broken 'mysql_insertid' with barcode \"$barcode\".\n";
            }
            else {
                print "\nUnrecoverable 'mysql_insertid' with barcode \"$barcode\".\n";
            }
        }
    }

    return ( $itemnumber, $error );
}

sub newFromRow {
    no strict 'vars';
    eval shift;
    my $s = $VAR1;
    use strict 'vars';
    warn $@ if $@;
    return $s;
}

sub createCheckoutStatistics {

=head
    +---------------------+--------+----------+--------+----------+-------+----------+------------+----------+----------------+--------------------+-------+
    | datetime            | branch | proccode | value  | type     | other | usercode | itemnumber | itemtype | borrowernumber | associatedborrower | ccode |
    +---------------------+--------+----------+--------+----------+-------+----------+------------+----------+----------------+--------------------+-------+
    | 2013-10-03 10:31:45 | IPT    | NULL     | 0.0000 | issue    |       | NULL     |          4 | BK       |             51 |               NULL | NULL  |
    | 2013-10-03 10:33:38 | IPT    | NULL     | 0.0000 | return   |       | NULL     |          4 | NULL     |             51 |               NULL | NULL  |
    | 2013-10-03 11:14:19 | IPT    | NULL     | 0.0000 | issue    |       | NULL     |          4 | BK       |             51 |               NULL | NULL  |
    | 2013-10-04 11:29:48 | IPT    | NULL     | 0.0000 | issue    |       | NULL     |          2 | BK       |             52 |               NULL | NULL  |
=cut

    my ( $item, $lastrun ) = @_;
    if ($item) {
        my $issuesCount = $item->{issues};

        if ( defined $issuesCount && $issuesCount > 0 ) {
            foreach ( 0 .. $issuesCount ) {
                push @$issues,
                    '("'
                  . $item->{homebranch}
                  . '", "issue",  "KONVERSIO", "'
                  . $item->{itemnumber} . '", "'
                  . $item->{itype} . '")';
                push @$returns,
                    '("'
                  . $item->{homebranch}
                  . '", "return", "KONVERSIO", "'
                  . $item->{itemnumber} . '", "'
                  . $item->{itype} . '")';
            }
        }
    }

    if ( scalar(@$issues) > 1000 || $lastrun ) {
        my $star = time;
        print "Writing statistics---";

        #print $createCheckoutStatisticsSQL_issue  . join(',',@$issues);
        $dbh->do( $createCheckoutStatisticsSQL_issue . join( ',', @$issues ) );
        $dbh->do(
            $createCheckoutStatisticsSQL_return . join( ',', @$returns ) );

        $issues  = [];
        $returns = [];
        print "Statistics written in " . ( $star - time ) . "s\n";
        $dbh->disconnect();
        $dbh = C4::Context->dbh; #Refresh the DB handle, because it occasionally gets mangled and spits bad utf8.
    }
}

sub getNewBiblionumber {
    my ($biblionumberConversionTable, $item) = @_;

    my $newBiblionumber = $biblionumberConversionTable->fetch($item->{biblionumber});
    return $newBiblionumber if $newBiblionumber;

    print "\nItem with barcode ".$item->{barcode}." doesn't have a Biblio in Koha! Skipping.\n";
    return undef;
}


sub getRotatingCollectionFromHomebranch {
    my $homebranch = shift;

    if ($rotatingCollections->{ $homebranch }) {
        return $rotatingCollections->{ $homebranch };
    }

    my ($colId, $colTitle, $colDesc, $colBranchcode) = C4::RotatingCollections::GetCollectionByTitle('KONVERSIO'.$homebranch);
    if (not($colId)) {
        my ( $success, $errorcode, $errormessage ) = CreateCollection( 'KONVERSIO'.$homebranch, "Konversiossa $homebranch:ssa olleet siirtolainat", $homebranch );
        if ($errormessage) {
            print $errormessage;
            return undef;
        }
        ($colId, $colTitle, $colDesc, $colBranchcode) = C4::RotatingCollections::GetCollectionByTitle('KONVERSIO'.$homebranch);
    }

    $rotatingCollections->{ $homebranch } = $colId;

    return $rotatingCollections->{ $homebranch };
}

sub tryToCaptureMangledUtf8InDB {
    my ($item) = @_;
    my $itemnotes = $item->{itemnotes};
    if ($itemnotes) {
        my $hstring = unpack ("H*",$itemnotes);
        #printf( "\n%12d - %20s - %s\n",$item->{biblionumber},$itemnotes,$hstring );

        if ($itemnotes =~ /\xc3\x83\xc2\xa4/ || $item->{itemcallnumber} =~ /\xc3\x83\xc2\xa4/ ||
            $itemnotes =~ /Ã¤/ || $item->{itemcallnumber} =~ /Ã¤/) {

            my $mangled = $item->{itemnotes}." ".$item->{itemcallnumber};
            warn "Item ".$item->{itemnumber}." mangled like this:\n$mangled\n";
            $fh = openItemsFile($itemsFile, $i-1); #Reopen and rewind the filehandle to this position.
            return 1;
        }
    }
    return undef;
}
