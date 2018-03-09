#! /usr/bin/perl
# IN THIS FILE #
#
# Connects to our booksellers services to fetch the selection lists and stages them to the MARC reservoir
# Calls the /misc/stage_file.pl to do the dirty staging!

use Modern::Perl;

use Net::FTP;
use POSIX qw/strftime/;
use DateTime;
use Date::Calc;
use Data::Dumper;
use Carp;

use C4::KohaSuomi::AcquisitionIntegration;
use C4::KohaSuomi::SelectionListProcessor;
use C4::KohaSuomi::RemoteBiblioPackageImporter;
use C4::ImportBatch;

use Getopt::Long;
use Try::Tiny;
use Scalar::Util qw(blessed);
use File::Basename;

use Koha::Exception::DuplicateObject;
use Koha::Exception::RemoteInvocation;
use Koha::Exception::BadEncoding;
use Koha::Exception::SystemCall;
use Koha::Exception::File;

binmode( STDOUT, ":utf8" );
binmode( STDERR, ":utf8" );

my ($kv_selects, $btj_selects, $btj_biblios, $help);
my $verbose = 0;

GetOptions(
    'kv-selects'  => \$kv_selects,
    'btj-selects' => \$btj_selects,
    'btj-biblios'   => \$btj_biblios,
    'verbose=i'       => \$verbose,
    'h|help'        => \$help,
);

my $usage = "
pullSelectionListsFromBookvendors.pl :
Copies MARC ISO -files from bookvendors distribution services and stages them to Koha.

This script takes the following parameters :

    --kv-selects        Stage Kirjavälitys' selection lists from their acquisitions ftp-server to Koha,
                        so we can make orders from their catalogue.

    --btj-selects       Stage BTJ's selection lists from their acquisitions ftp-server to Koha,
                        so we can make orders from their catalogue.

    --btj-biblios       USE THIS ONLY ON THE SEPARATE Z39.50 OVERLAY CONTAINER kohacatalogs.
                        Stages BTJ's fully catalogued biblios from their ftp server to Koha.
                        Then push the staged files to the biblios table. This screws up our
                        production catalog if this script is ran there.
                        ONLY FOR THE SEPARATE Z39.50 CONTAINER!

    --verbose | v       verbose. An integer, 1 for slightly verbose, 2 for largely verbose!
                        If using --btj-biblios, this is the verbosity level of Koha::Logger,
                        in this case set it to 0 to enabled default logging, levels increase verbosity.
";

if ( $help ) {
    print $usage;
    exit 0;
}
unless ( $kv_selects || $btj_selects || $btj_biblios ) {
    print $usage;
    die "ERROR: you must define atleast one of these\n--kv_selects\n--btj_selects";
}

C4::Context->setCommandlineEnvironment();
Koha::Logger->setConsoleVerbosity($verbose);

#my $listdirectory = '/tmp/'; #Where to store selection lists
my $stagedFileVerificationDuration_days = 700; #Stop looking for selection lists older than this when staging MARC for the Koha reservoir
                                               #Be aware that the Koha cleanup_database.pl -script also removes the imported lists.
my $importedSelectionlists = getImportedSelectionlists();

my $now = DateTime->now();
my $year = strftime( '%Y', localtime() );


my $errors = []; #Collect all the errors here!

#We don't throw a warning for these files if they are present in the FTP server root directory.
my $kvFtpExceptionFiles = { 'marcarkisto' => 1,
                            'Order' => 1,
                            'tmp' => 1,
                            'heinavesi' => 1,
                            'varkaus' => 1,
                            'pieksamaki' =>1
                          };



##Starting subroutine definitions##
##  bookseller specific processing starts from the for<Vendorname>()-subroutine.

##############
## KIRJAVÄLITYS HERE ##
##############
sub forKirjavalitys {
    print "Starting for Kirjavalitys\n" if $verbose;
    #Prepare all the files to look for in the KV ftp-server
    my $kvenn_selectionlist_filenames = [];
    my $kvulk_selectionlist_filenames = [];

    my $vendorConfig = C4::KohaSuomi::AcquisitionIntegration::getVendorConfig('Kirjavalitys');

    my $listdirectory = $vendorConfig->{localStorageDir};

    my $directories = $vendorConfig->{KVDirectories};

    unless ($listdirectory) {
        print "Local storage directory is not defined";
    } else {

        getAllKirjavalitysSelectionlists($kvenn_selectionlist_filenames, $kvulk_selectionlist_filenames);

        processKirjavalitysSelectionlistType($vendorConfig, $kvenn_selectionlist_filenames, 'ennakot', $listdirectory, $directories);
        processKirjavalitysSelectionlistType($vendorConfig, $kvulk_selectionlist_filenames, 'ulkomaiset', $listdirectory, $directories);
    }

    if (scalar @$errors) {
        print "\nFOLLOWING ERRORS WERE FOUND!\n".
                "----------------------------\n".
                join "\n", @$errors;
    }
}
sub processKirjavalitysSelectionlistType {
    my ($vendorConfig, $selectionListBatches, $listType, $listdirectory, $directories) = @_;

    my $ftp = Koha::FTP->new( C4::KohaSuomi::AcquisitionIntegration::connectToKirjavalitys() );
    my $selectionListProcessor = C4::KohaSuomi::SelectionListProcessor->new({listType => $listType});

    if ($directories) {
        #Go through all the required directories
        foreach my $directory (@{ $directories }){
            #Check if the required directory exists
            if(-d $directory){
                #Everything is allright here
                print "Required directory '$directory' exists!\n";
            }else{
                #Here we have to create the missing directory
                print "Required directory '$directory' is missing. Creating the required directory...\n";
                mkdir $directory, 0755;
                print "Required directory '$directory' created.\n";
            }

        }
    }

    for(my $i = 0 ; $i < scalar @$selectionListBatches ; $i++) {
        try {
            my $selectionListBatch = $selectionListBatches->[$i];

            #Splitting selectionListBatch to get a working filepath
            my $index = index($selectionListBatch, "/", 1);
            my $directory = substr $selectionListBatch, 0, $index;

            my $merged_directory = $directories ? $directory."/marcarkisto" : 'marcarkisto';

            print "Importing $selectionListBatch\n" if $verbose > 1;

            $selectionListBatch =~ /(\d{8})\./;
            my $ymd = $1;

            $ftp->get($selectionListBatch, $listdirectory.$selectionListBatch);

            verifyCharacterEncoding($listdirectory, $selectionListBatch, $vendorConfig->{selectionListEncoding});

            ##Split the incoming selection list to sub selection lists based on the 971$d
            my $selectionLists = $selectionListProcessor->splitToSubSelectionListsFromFile({
                                                        file => $listdirectory.$selectionListBatch,
                                                        encoding => $vendorConfig->{selectionListEncoding},
                                                        singleList => $selectionListBatch,
                                                        format => $vendorConfig->{selectionListFormat},
                                                    });

            stageSelectionlists($selectionLists, $vendorConfig->{selectionListEncoding}, $listType, $ymd);
            moveKirjavalitysSelectionListBatch($listdirectory.$selectionListBatch, $merged_directory, $ftp);

        } catch {
            if (blessed($_)) {
                warn $_->error()."\n";
                push @$errors, $_->error();
#                next(); #Perl bug here. next() doesn't point to the foreach loop here but possibly to something internal to Try::Tiny.
                 #Thus we get the "Exiting subroutine via next" -warning. Because there are no actions after the catch-statement,
                 #this doesn't really hurt here, but just a remnder for anyone brave enough to venture further here.
            }
            else {
                #die "Exception not caught by try-catch:> ".$_;
                print "Exception not caught by try-catch:> ".$_;
            }
        };
    }
    $ftp->quit();
}

sub getAllKirjavalitysSelectionlists {
    my ($kvenn_selectionlist_filenames, $kvulk_selectionlist_filenames) = @_;

    my $ftpcon = C4::KohaSuomi::AcquisitionIntegration::connectToKirjavalitys();

    my $ftpfiles = $ftpcon->ls();
    foreach my $clients (@$ftpfiles) {
        my $client = $ftpcon->ls($clients);
        foreach my $file (@$client) {
            if ($file =~ /kvmarcxmlenn\d{8}\.xml/) {
                print "Kirjavalitys: Found file: $file\n" if $verbose;
                push @$kvenn_selectionlist_filenames, $file;
            }elsif ($file =~ /kvmarcxmlulk\d{8}\.xml/) {
                print "Kirjavalitys: Found file: $file\n" if $verbose;
                push @$kvulk_selectionlist_filenames, $file;
            }elsif ($kvFtpExceptionFiles->{$file}) {
                #We have a list of files that are allowed to be in the KV ftp directory and we won't warn about.
            }
            else {
                print "Kirjavalitys: Unknown file in ftp-server '$file'\n";
            }
        }
    }

    $ftpcon->close();

    @$kvenn_selectionlist_filenames = sort @$kvenn_selectionlist_filenames;
    @$kvulk_selectionlist_filenames = sort @$kvulk_selectionlist_filenames;
}

=head stageSelectionlist
@THROWS Koha::Exception::SystemCall
=cut

sub stageSelectionlist {
    my ($selectionList, $encoding, $listType) = @_;

    my ($batch_id, $num_valid_records, $num_items, @import_errors) =
        C4::ImportBatch::BatchStageMarcRecords('biblio', $encoding, $selectionList->getMarcRecords(), $selectionList->getIdentifier(), undef, undef, $selectionList->getDescription(), '', 0, 0, 100, undef);
    print join("\n",
    "MARC record staging report for selection list ".$selectionList->getIdentifier(),
    "------------------------------------",
    "Number of input records:    ".scalar(@{$selectionList->getMarcRecords()}),
    "Number of valid records:    $num_valid_records",
    "------------------------------------",
    ((scalar(@import_errors)) ? (
    "Errors",
    "@import_errors",
    "",)
    :
    "",
    )
    );
}

sub stageSelectionlists {
    my ($selectionLists, $encoding, $listType, $ymd) = @_;

    my $errors = '';
    while( my ($newName, $sl) =  each %$selectionLists) {
        try {
            #We directly stage these selection lists so we can better control their descriptions and content and get nicer output.
            isSelectionListImported( $sl->getIdentifier() );
            stageSelectionlist($sl, $encoding, $listType);
        } catch {
            if (blessed($_)){
                if ($_->isa('Koha::Exception::SystemCall')) {
                    warn $_->error()."\n";
                    $errors .= $_->error()."\n";
                }
                else {
                    $_->rethrow();
                }
            }
            else {
                die $_;
            }
        };
    }
    Koha::Exception::SystemCall->throw(error => $errors) if $errors && length $errors > 0;
}

=head moveKirjavalitysSelectionListBatch
Aknowledge the reception by moving the selectionListBatches to marcarkisto-directory
=cut

sub moveKirjavalitysSelectionListBatch {
    my ($filePath, $targetDirectory, $ftp) = @_;
    my($fileName, $dirs, $suffix) = File::Basename::fileparse( $filePath );

    #Variables used for getting the file's directory
    my $firstslash = rindex($filePath, "/");
    my $secondslash = rindex($filePath, "/", $firstslash-1);

    #Getting the file's directory as a string
    my $delDirectory = substr $filePath, $secondslash, $firstslash - $secondslash + 1;

    my $currentDir = $ftp->getCurrentFtpDirectory();
    $ftp->changeFtpDirectory($targetDirectory);
    $ftp->put($filePath);
    #FIXME: Create better solution for handling lists in root and separated directories.
    if ($targetDirectory =~ m/^marcarkisto$/i ) {
        $ftp->changeFtpDirectory($currentDir);
        $ftp->delete($fileName);
    } else {
        $ftp->changeFtpDirectory($currentDir.$delDirectory);
        $ftp->delete($fileName);
        $ftp->changeFtpDirectory($currentDir);
    }

}










##############
## BTJ HERE ##
##############
sub forBTJ {
    print "Starting for BTJ\n" if $verbose;

    #Prepare all the files to look for in the KV ftp-server
    my $ma_selectionlist_filenames = [];
    my $mk_selectionlist_filenames = [];

    my $vendorConfig = C4::KohaSuomi::AcquisitionIntegration::getVendorConfig('BTJSelectionLists');

    my $listdirectory = $vendorConfig->{localStorageDir};

    unless ($listdirectory) {
        print "Local storage directory is not defined";
    } else {
        getAllBTJSelectionlists($ma_selectionlist_filenames, $mk_selectionlist_filenames);

        processBTJSelectionlistType($vendorConfig, $ma_selectionlist_filenames, 'av-aineisto', $listdirectory);
        processBTJSelectionlistType($vendorConfig, $mk_selectionlist_filenames, 'kirja-aineisto', $listdirectory);
    }



    if (scalar @$errors) {
        print "\nFOLLOWING ERRORS WERE FOUND!\n".
                "----------------------------\n".
                join "\n", @$errors;
    }
}
sub processBTJSelectionlistType {
    my ($vendorConfig, $selectionListBatches, $listType, $listdirectory) = @_;

    my $ftp = Koha::FTP->new( C4::KohaSuomi::AcquisitionIntegration::connectToBTJselectionLists() );
    my $selectionListProcessor = C4::KohaSuomi::SelectionListProcessor->new({listType => $listType});

    for(my $i = 0 ; $i < scalar @$selectionListBatches ; $i++) {
        try {
            my $selectionListBatch = $selectionListBatches->[$i];

            print "Importing $selectionListBatch\n" if $verbose > 1;

            $selectionListBatch =~ /(\d{4})/;
            my $md = $1;

            $ftp->get($selectionListBatch, $listdirectory.$selectionListBatch);

            verifyCharacterEncoding($listdirectory, $selectionListBatch, $vendorConfig->{selectionListEncoding});

            ##Split the incoming selection list to sub selection lists based on the 971$d
            my $selectionLists = $selectionListProcessor->splitToSubSelectionListsFromFile({
                                                        file => $listdirectory.$selectionListBatch,
                                                        encoding => $vendorConfig->{selectionListEncoding},
                                                        singleList => $selectionListBatch,
                                                        format => $vendorConfig->{selectionListFormat},
                                                    });

            stageSelectionlists($selectionLists, $vendorConfig->{selectionListEncoding}, $listType, $md);

        } catch {
            if (blessed($_)) {
                if ($_->isa('Koha::Exception::DuplicateObject')) {
                    #print $_->error()."\n";
                    #It is normal for BTJ to find the same selection lists again and again,
                    #because they keep the selection lists from the past month.
                }
                else {
                    warn $_->error()."\n";
                    push @$errors, $_->error();
                }
#                next(); #Perl bug here. next() doesn't point to the foreach loop here but possibly to something internal to Try::Tiny.
                 #Thus we get the "Exiting subroutine via next" -warning. Because there are no actions after the catch-statement,
                 #this doesn't really hurt here, but just a remnder for anyone brave enough to venture further here.
            }
            else {
                #Giving the command print instead of die allows as to continue while ignoring possible errors.
                print "Exception not caught by try-catch:> ".$_;
            }
        };
    }
    $ftp->quit();
}
sub getAllBTJSelectionlists {
    my ($ma_selectionlist_filenames, $mk_selectionlist_filenames) = @_;

    my $ftpcon = C4::KohaSuomi::AcquisitionIntegration::connectToBTJselectionLists();
    my $vendorConfig = C4::KohaSuomi::AcquisitionIntegration::getVendorConfig('BTJSelectionLists');
    my $ftpfiles = $ftpcon->ls();
    my $fileRegexp = qr($vendorConfig->{fileRegexp});
    foreach my $file (@$ftpfiles) {
        if ($file =~ /$fileRegexp/) { #Pick only files of specific format
            #Subtract file's date from current date.
            #The year must be selected, but there is no way of knowing which year is set on the selection list files so using arbitrary 2000
            my $difference_days = Date::Calc::Delta_Days(2000,$1,$2,2000,$now->month(),$now->day());

            if ( $difference_days >= 0 && #If the year changes there is trouble, because during subtraction year is always the same
                 $difference_days < $stagedFileVerificationDuration_days) { #if selection list is too old, skip trying to stage it.

                if ($file =~ /xmk$/) {
                    print "BTJ: Found file: $file\n" if $verbose;
                    push @$ma_selectionlist_filenames, $file;
                }elsif ($file =~ /xk$/) {
                    print "BTJ: Found file: $file\n" if $verbose;
                    push @$mk_selectionlist_filenames, $file;
                }elsif ($file =~ /U2\d\d\dbtj_enn/) {
                    print "BTJ: Found file: $file\n" if $verbose;
                    push @$mk_selectionlist_filenames, $file;
                } else {
                    print "BTJ: Unknown file: $file\n" if $verbose;
                }
            }
            else {
                print "BTJ: Skipping file $file due to \$stagedFileVerificationDuration_days\n" if $verbose > 1;
            }
        } else {
            print "BTJ: Skipping file $file\n" if $verbose > 1;
        }
    }
    $ftpcon->close();

    @$ma_selectionlist_filenames = sort @$ma_selectionlist_filenames;
    @$mk_selectionlist_filenames = sort @$mk_selectionlist_filenames;
}

sub forBTJBiblios {
    my $importer = C4::KohaSuomi::RemoteBiblioPackageImporter->new({remoteId => 'BTJBiblios'});
    $importer->importFromRemote();
}



forKirjavalitys() if $kv_selects;
forBTJ()          if $btj_selects;
forBTJBiblios()   if $btj_biblios;



######################
## Common functions ##
######################
#get a koha.import_batches-rows which are not too old
# These are processed to a searchable format.
sub getImportedSelectionlists {
    my $dbh = C4::Context->dbh();

    my $sth = $dbh->prepare('SELECT file_name FROM import_batches WHERE (TO_DAYS(curdate())-TO_DAYS(upload_timestamp)) < ? ORDER BY file_name;');
    $sth->execute(  $stagedFileVerificationDuration_days  );
    my $ary = $sth->fetchall_arrayref();

    #Get the filename from the path for all SELECTed filenames/paths
    my $fns = {}; #hash of filenames!
    foreach my $filename (@$ary) {
        my @a = split("/",$filename->[0]);
        my $basename = lc(   @a[ (scalar(@a)-1) ]   );
        $fns->{ $basename } = 1 if scalar @a > 0; #Take the last value! filename from path.
        print 'Found existing staged selection list '.$filename->[0]."\n" if $verbose > 1;
    }
    return $fns;
}
sub isSelectionListImported {
    my $selectionlist = lc( shift );

    if (exists $importedSelectionlists->{$selectionlist}) {
        Koha::Exception::DuplicateObject->throw(error => "Selection list $selectionlist already imported.")
    }
}

sub verifyCharacterEncoding {
    my ($listdirectory, $selectionlist, $marc_encoding) = @_;
    ##Inspect the character encoding of the selection list
    my $fileType = `file -bi $listdirectory$selectionlist`;
    chomp $fileType;
    if (  not($fileType =~ /utf-?8/i) && not($fileType =~ /us-?ascii/i)  ) {
        Koha::Exception::BadEncoding->throw(error => "Selection list '$selectionlist' is of type '$fileType', expected '$marc_encoding'");
    }
    elsif ( $verbose > 1 ) {
        print "Filetype $fileType\n";
    }
}
