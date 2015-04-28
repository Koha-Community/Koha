package ConversionTable::BorrowernumberConversionTable;

use Modern::Perl;
use ConversionTable::ConversionTable;
our @ISA = qw(ConversionTable::ConversionTable);

use Carp qw(cluck);

sub readRow {
    my ($self, $textRow) = @_;

    if ( $_ =~ /^([0-9A-Z-]+)\s+(\d+)\s+(.*)$/ ) {
        my $custId       = $1; #Old value
        my $borrowernumber = $2; #new Koha itemnumber
        my $barcode      = $3;

        $self->{table}->{$custId} = $borrowernumber;
        $self->{table}->{$custId.'bc'} = $barcode;
    }
    elsif ($textRow =~ /^id;newid;operation;status/ || $textRow =~ /^file : .*?/ || $textRow =~ /^\d+ MARC records done in / ) {
        #It's ok
    }
    else {
        print "ConversionTable::BorrowernumberConversionTable->readRow(): Couldn't parse borrowernumber row: $_\n";
    }
}
sub writeRow {
    my ($self, $itemnumber, $newItemnumber, $barcode) = @_;

    my $fh = $self->{FILE};
    print $fh "$itemnumber $newItemnumber $barcode\n";
}

sub fetchBarcode {
    my ($self, $key) = @_;
    return $self->{table}->{$key.'bc'};
}
1;
