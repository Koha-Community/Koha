#!/usr/bin/perl

use Modern::Perl;
use Getopt::Long;

use C4::Accounts;
use C4::Context;
use Koha::Patron::Debarments;

my ($help, $confirm, $message, $expiration, $file, $year, @category);
GetOptions(
    'h|help'         => \$help,
    'c|confirm:s'    => \$confirm,
    'm|message:s'    => \$message,
    'f|file:s'       => \$file,
    'e|expiration:s' => \$expiration,
    'y|year:s'       => \$year,
    'category=s'     => \@category,
);

my $HELP = <<HELP;

debarrBorrowersWithFines.pl

Creates a debarment for all Borrowers who have fines.

    -h --help       This friendly reminder!

    -c --confirm    Confirm that you want to make your Patrons MAD by barring
                    them from your library because they have ANY unpaid fines.

    -m --message     MANDATORY. The description of the debarment visible to the end-user.
                     or
    -f --messagefile MANDATORY. The file from which to read the message content.

    -e --expiration OPTIONAL. When does the debarment expire?
                    As ISO8601 date, eg  '2015-12-31'
    -y --year       OPTIONAL The year which date matches to accountlines date value.
    --category      OPTIONAL The categorycode if wanted to restrict, can be added more than one 


EXAMPLE:

    debarrBorrowersWithFines.pl --confirm -m "This is a description of you bad deeds"
That did almost work.

    debarrBorrowersWithFines.pl -c MAD -m "You didn't play by our rules!" -e '2015-12-31'
    debarrBorrowersWithFines.pl -c MAD -m "You didn't play by our rules!" -y 2018
    debarrBorrowersWithFines.pl -c MAD -m "You didn't play by our rules!" --category ADULT
    debarrBorrowersWithFines.pl -c MAD -m "You didn't play by our rules!" -y 2018 --category CHILD --category ADULT
    debarrBorrowersWithFines.pl -c MAD -f "/home/koha/kohaclone/messagefile"
This works. Always RTFM.

HELP

if ($help) {
    print $HELP;
    exit 0;
}
elsif (not($confirm) || $confirm ne 'MAD' || (not($message || $file) )) {
    print $HELP;
    exit 1;
}
elsif (not($file) && not(length($message) > 20)) {
    print $HELP;
    print "\nYour --message is too short. A proper message to your end-users must be longer than 20 characters.\n";
    exit 1;
}

my $badBorrowers = GetAllBorrowersWithUnpaidFines();
$message = getMessageContent();

foreach my $bb (@$badBorrowers) {
    #Don't crash, but keep debarring as long as you can!
    eval {
        my $success = Koha::Patron::Debarments::AddDebarment({
            borrowernumber => $bb->{borrowernumber},
            expiration     => $expiration,
            type           => 'MANUAL',
            comment        => $message,
        });
    };
    if ($@) {
        print $@."\n";
    }
}

=head getMessageContent
Gets either the textual message or slurps a file.
=cut

sub getMessageContent {
    return $message if ($message);
    open(my $FH, "<:encoding(UTF-8)", $file) or die "$!\n";
    my @msg = <$FH>;
    close $FH;
    return join("",@msg);
}

=head GetAllBorrowersWithUnpaidFines

    my $badBorrowers = C4::Accounts::GetAllBorrowersWithUnpaidFines();

@RETURNS ARRAYRef of HASHRefs of koha.borrowers + amountoutstanding-key
            containing the total amount outstanding.
            Ordered by borrowernumber ASCending.
=cut

sub GetAllBorrowersWithUnpaidFines {
    my $categories = "('" . join("','", @category) . "')";
    my $query = "SELECT b.*, SUM(a.amountoutstanding) AS amountoutstanding
        FROM borrowers b
            LEFT JOIN accountlines a ON b.borrowernumber = a.borrowernumber ";
    $query .= "WHERE " if (@category || $year);
    $query .= "categorycode in $categories " if @category;
    $query .= "AND " if (@category && $year);
    $query .= "YEAR(a.date) = '$year' " if $year;
    $query .= "GROUP BY b.borrowernumber    
        HAVING SUM(a.amountoutstanding) > 0
        ORDER BY b.borrowernumber ASC";
    print "$query\n";
    my $sth = C4::Context->dbh->prepare($query);
    $sth->execute();
    return $sth->fetchall_arrayref({});
}
