package ConversionTable::ConversionTable;

use Modern::Perl;
use Carp qw(cluck);

sub new {
    my ($class, $filename, $readOrWrite) = @_;

    my $self = { filename => $filename };
    bless($self, $class);

    if ($readOrWrite eq 'read') {
        $self->_readTable();
    }
    elsif ($readOrWrite eq 'write') {
        $self->_writeTable();
    }
    else {
        cluck "Unknown operation '$readOrWrite'. Supported values 'read' or 'write'";
    }

    return $self;
}

sub _writeTable {
    my ($self) = @_;

    $self->{operation} = 'write';

    $self->{table} = {};
    my $table = $self->{table};

    open( $self->{FILE}, ">>:encoding(utf8)", $self->{filename} ) or die "Writing to file '".$self->{filename}."' failed: ".$!;
}

sub _readTable {
    my ($self) = @_;

    $self->{operation} = 'read';

    $self->{table} = {};
    my $table = $self->{table};

    open( my $in, "<:encoding(utf8)", $self->{filename} ) or die "Reading from file '".$self->{filename}."' failed: ".$!;;
    while (<$in>) {
        $self->readRow($_); #Call the child class' handler method.
    }
    close($in);
}
sub readRow {
    my ($self, $textRow) = @_;

    print "\nreadRow() must be overwritten in the subclass!\n";
}
sub writeRow {
    my ($self, $textRow) = @_;

    my $fh = $self->{FILE};
    print $fh "\nwriteRow() must be overwritten in the subclass!\n";
    print "\nwriteRow() must be overwritten in the subclass!\n";
}
sub fetch {
    my ($self, $key) = @_;
    return $self->{table}->{$key};
}
sub lowestKey {
    my ($self) = @_;
    my @keys = sort {$a <=> $b} keys %{$self->{table}};
    return shift @keys;
}
1;
