package Koha::Indexer::RecordWriter;
use Moose;

with 'MooseX::RW::Writer::File';


use Carp;
use MARC::Batch;
use MARC::Record;
use MARC::File::XML;


# Is XML Stream a valid marcxml
# By default no => no <collection> </collection>
has valid => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
);


sub begin {
    my $self = shift;
    if ( $self->valid ) {
        my $fh = $self->fh;
        print $fh '<?xml version="1.0" encoding="UTF-8"?>', "\n", '<collection>', "\n";
    }
}


sub end {
    my $self = shift;
    my $fh = $self->fh;
    if ( $self->valid ) {
        print $fh '</collection>', "\n";
    }
    $fh->flush();
}



#
# Sent record is rather a MARC::Record object or an marcxml string
#
sub write {
    my ($self, $record) = @_;

    $self->count( $self->count + 1 );

    my $fh  = $self->fh;
    my $xml = ref($record) eq 'MARC::Record'
              ? $record->as_xml_record() : $record;
    $xml =~ s/<\?xml version="1.0" encoding="UTF-8"\?>\n//g if $self->valid;
    print $fh $xml;
}

__PACKAGE__->meta->make_immutable;

1;
