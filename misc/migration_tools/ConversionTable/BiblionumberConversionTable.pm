package ConversionTable::BiblionumberConversionTable;

use Modern::Perl;
use ConversionTable::ConversionTable;
our @ISA = qw(ConversionTable::ConversionTable);

use Carp qw(cluck);

sub readRow {
    my ($self, $textRow) = @_;

    if ( $_ =~ /^([0-9A-Z-]+);(\d+);/ ) {
        my $legacy_biblionumber = $1;
        my $koha_biblionumber   = $2;

        $self->{table}->{$legacy_biblionumber} = $koha_biblionumber;
    }
    elsif ($textRow =~ /^id;newid;operation;status/ || $textRow =~ /^file : .*?/ || $textRow =~ /^\d+ MARC records done in / ) {
        #It's ok
    }
    else {
        print "ConversionTable::BiblionumberConversionTable->readRow(): Couldn't parse biblionumber row: $_\n";
    }
}
1;
