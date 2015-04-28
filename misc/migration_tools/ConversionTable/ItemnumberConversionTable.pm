package ConversionTable::ItemnumberConversionTable;

use Modern::Perl;
use ConversionTable::ConversionTable;
our @ISA = qw(ConversionTable::ConversionTable);

use Carp qw(cluck);

sub readRow {
    my ($self, $textRow) = @_;

    if ( $_ =~ /^([0-9A-Z-]+):(\d*):(.*)/ ) {
        my $copyId       = $1; #Old value
        my $itemnumber   = $2; #new Koha itemnumber
        my $barcode      = $3;

        $self->{table}->{$copyId} = $itemnumber;
        $self->{table}->{$copyId.'bc'} = $barcode;
    }
    elsif ($textRow =~ /^id;newid;operation;status/ || $textRow =~ /^file : .*?/ || $textRow =~ /^\d+ MARC records done in / ) {
        #It's ok
    }
    else {
        print "ConversionTable::ItemnumberConversionTable->readRow(): Couldn't parse itemnumber row: $_\n";
    }
}
sub writeRow {
    my ($self, $itemnumber, $newItemnumber, $barcode) = @_;

    $itemnumber = '' unless $itemnumber;
    $newItemnumber = '' unless $newItemnumber;
    $barcode = '' unless $barcode;

    my $fh = $self->{FILE};
    print $fh "$itemnumber:$newItemnumber:$barcode\n";
}

sub fetchBarcode {
    my ($self, $key) = @_;
    return $self->{table}->{$key.'bc'};
}
1;
