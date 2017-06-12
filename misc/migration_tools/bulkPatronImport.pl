#!/usr/bin/perl

use strict;
use warnings;
#use diagnostics;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use open qw( :std :encoding(UTF-8) );
binmode( STDOUT, ":encoding(UTF-8)" );

use Getopt::Long;
use DateTime;

use C4::Members;
use C4::Members::Attributes;
use C4::Members::Messaging;
use Koha::AuthUtils qw(hash_password);
use Koha::Patron::Debarments qw/AddDebarment/;
use Koha::Auth::PermissionManager;
use Koha::Patron;

use ConversionTable::BorrowernumberConversionTable;

binmode( STDOUT, ":encoding(UTF-8)" );
my ( $input_file, $number, $deduplicate, $defaultAdmin) = ('',0,undef,0);

$|=1;

GetOptions(
    'file:s'       => \$input_file,
    'n:f'          => \$number,
    'deduplicate'  => \$deduplicate,
    'defaultadmin' => \$defaultAdmin,
);

my $help = <<HELP;

perl bulkPatronImport.pl --file /home/koha/pielinen/patrons.migrateme -n 1200 --deduplicate

Migrates the Perl-serialized MMT-processed patrons-files to Koha.

  --file        The perl-serialized HASH of patrons.
  -n            How many patrons to migrate?
  --deduplicate Should we deduplicate the Patrons? Case-insensitively checks for same
                surname, firstnames, othernames, dateofbirth
  --defaultadmin  Should we populate the default test admin 1234?
HELP

unless ($input_file) {
    die "$help\n\nYou must give the Patrons-file.";
}

my $fh = IO::File->new($input_file);
my $borrowernumberConversionTable = ConversionTable::BorrowernumberConversionTable->new('borrowernumberConversionTable', 'write');
my $now = DateTime->now()->ymd();
my @guarantees;#Store all the juveniles with a guarantor here.
#Guarantor is linked via barcode, but it won't be available if a guarantor
#is added after the guarantee. After all borrowers have been migrated, migrate guarantees.

my $permissionManager = Koha::Auth::PermissionManager->new();

my $dbh = C4::Context->dbh;
my $fineStatement = $dbh->prepare( #Used for Libra3
            'INSERT INTO  accountlines
                        (borrowernumber, accountno, date, amount, description, accounttype, amountoutstanding, notify_id, manager_id)
        VALUES (?, ?, ?, ?,?, ?,?,?,?)');


sub newFromRow {
    no strict 'vars';
    eval shift;
    my $s = $VAR1;
    use strict 'vars';
    warn $@ if $@;
    return %$s;
}

sub AddMember {
    my ($data) = @_;
#    my $dbh = C4::Context->dbh;

    # generate a proper login if none provided
    $data->{'userid'} = C4::Members::Generate_Userid($data->{'borrowernumber'}, $data->{'firstname'}, $data->{'surname'}) if $data->{'userid'} eq '';
    delete $data->{'borrowernumber'};

    # add expiration date if it isn't already there
    unless ( $data->{'dateexpiry'} ) {
        $data->{'dateexpiry'} = C4::Members::GetExpiryDate( $data->{'categorycode'}, C4::Dates->new()->output("iso") );
    }

    # add enrollment date if it isn't already there
    unless ( $data->{'dateenrolled'} ) {
        $data->{'dateenrolled'} = C4::Dates->new()->output("iso");
    }

    # create a disabled account if no password provided
    $data->{'password'} = ($data->{'password'})? hash_password($data->{'password'}) : '!';
    $data->{'borrowernumber'}=Koha::Patron->new($data)->store->borrowernumber;

    #Adding the SSN
    if (exists $data->{ssn}) { #Prevent a error generated when Patrons don't have a SSN
        C4::Members::Attributes::SetBorrowerAttributes($data->{borrowernumber}, [{ code => 'SSN', value => $data->{ssn}, password => undef }] );
    }


    return $data->{'borrowernumber'};
}


addDefaultPatrons() if $defaultAdmin;


my $i = 0;
while (<$fh>) {
    $i++;
    print ".";
    print "\n$i" unless $i % 100;

    my %patron = newFromRow($_);

    if ($patron{guarantorid} || $patron{guarantorbarcode}) {
        push @guarantees, \%patron;
        next;
    }

    processNewFromRow(\%patron);
}
#Migrate all guarantees now that we certainly know their guarantors exist in the DB.
my $borrowernumberConversionTableReadable = ConversionTable::BorrowernumberConversionTable->new('borrowernumberConversionTable', 'read');
foreach my $patron (@guarantees) {
    processNewFromRow( $patron );
}

sub processNewFromRow {
    my $patron = shift;
    my $legacy_borrowernumber = $patron->{borrowernumber};
    my ($old_borrowernumber, $old_categorycode);
    #Get the guarantor's id
    if ($patron->{guarantorbarcode}) { #For Libra3
        my $guarantor = C4::Members::GetMember( cardnumber => $patron->{guarantorbarcode} );
        $patron->{guarantorid} = $guarantor->{borrowernumber};
    }
    elsif ($patron->{guarantorid}) { #For Pallas
        my $newGuarantorid = $borrowernumberConversionTableReadable->fetch($patron->{guarantorid});
        $patron->{guarantorid} = $newGuarantorid;
    }

    #Check if the same borrower exists already
    if ($deduplicate) {
        ($old_borrowernumber, $old_categorycode) = C4::Members::checkuniquemember(0, $patron->{surname}, $patron->{firstname}, $patron->{dateofbirth});
        if ($old_borrowernumber) {
            print "Matching borrower found for $patron->{surname}, $patron->{firstname}, $patron->{dateofbirth} having borrowernumber $old_borrowernumber\n";
            $patron->{borrowernumber} = $old_borrowernumber;
            $patron->{categorycode} = $old_categorycode;
        }
    }
    #If not, then just add a borrower
    $patron->{borrowernumber} = AddMember($patron) unless $old_borrowernumber;

    if ($patron->{borrowernumber} && exists $patron->{standing_penalties}) { #Catch borrower_debarments
        my $standing_penalties = [  split('<\d\d>', $patron->{standing_penalties})  ];
        shift @$standing_penalties; #Remove the empty index in the beginning

        for (my $j=0 ; $j<@$standing_penalties ; $j++) {
            my $penaltyComment = $standing_penalties->[$j];

            if ($penaltyComment =~ /maksamattomia maksuja (\d+\.\d+)/) { #In Libra3, only the sum of fines is migrated.
                fineImport($patron->{borrowernumber}, $penaltyComment, 'Konve', $1, $now);
            }
            else {
                my @dateComment = split("<>",$penaltyComment);
                AddDebarment({
                    borrowernumber => $patron->{borrowernumber},
                    type           => 'MANUAL', ## enum('FINES','OVERDUES','MANUAL')
                    comment        => $dateComment[1],
                    created        => $dateComment[0],
                });
            }
        }
    }

    if ($patron->{borrowernumber}) {
        C4::Members::Messaging::SetMessagingPreferencesFromDefaults( { borrowernumber => $patron->{borrowernumber}, categorycode => $patron->{categorycode} } );

        ##Save the new borrowernumber to a conversion table so legacy systems references can keep track of the change.
        $borrowernumberConversionTable->writeRow($legacy_borrowernumber, $patron->{borrowernumber}, $patron->{cardnumber});
    }


    last if $i == $number;
}

sub addDefaultPatrons {
    my $dbh = C4::Context->dbh;
    my %defaultAdmin = (
        cardnumber => "kalifi",
        surname =>    "Kalifi",
        firstname =>  "Kalifin",
        othernames => "paikalla",
        address =>    "Kalifinkuja 12 b 7",
        city =>       "Kalifila",
        zipcode =>    "12345",
        dateofbirth => "1985-09-06",
        branchcode => "JOE_KAUKO",
        categorycode => "VIRKAILIJA",
        dateenrolled => "2015-09-25",
        dateexpiry => "2018-09-25",
        password => "Baba-Gnome",
        userid => "kalifi",
        privacy => 1,
    );
    $defaultAdmin{borrowernumber} = C4::Members::AddMember(%defaultAdmin);

    $permissionManager->grantPermission($defaultAdmin{borrowernumber}, 'superlibrarian', 'superlibrarian');
}
#addDefaultPatrons();



sub fineImport {
    my ( $borrowernumber, $desc, $accounttype, $amount, $date ) = @_;

    #Make sure the borrowerexists!
    my $testingBorrower = C4::Members::GetMember(borrowernumber => $borrowernumber);
    unless (defined $testingBorrower) {
        warn "Patron $borrowernumber doesn't exist in Koha!\n";
        return;
    }

    my $accountno  = C4::Accounts::getnextacctno( $borrowernumber );
    my $amountleft = $amount;
    my $notifyid = 0;
    my $manager_id = C4::Context->userenv ? C4::Context->userenv->{'number'} : 1;

    $fineStatement->execute($borrowernumber, $accountno, $date, $amount, $desc, $accounttype, $amountleft, $notifyid, $manager_id);

    if ($fineStatement->errstr) {
        println $fineStatement->errstr;
    }

}

sub AddDebarment {
    my ($params) = @_;

    my $borrowernumber = $params->{'borrowernumber'};
    my $expiration     = $params->{'expiration'} || undef;
    my $type           = $params->{'type'} || 'MANUAL';
    my $comment        = $params->{'comment'} || undef;
    my $created        = $params->{'created'} || undef;

    return unless ( $borrowernumber && $type );

    my $manager_id;
    $manager_id = C4::Context->userenv->{'number'} if C4::Context->userenv;

    my $sql = "
        INSERT INTO borrower_debarments ( borrowernumber, expiration, type, comment, manager_id, created )
        VALUES ( ?, ?, ?, ?, ?, ? )
    ";

    my $r = C4::Context->dbh->do( $sql, {}, ( $borrowernumber, $expiration, $type, $comment, $manager_id, $created ) );

    Koha::Patron::Debarments::_UpdateBorrowerDebarmentFlags($borrowernumber);

    return $r;
}
