package Koha::Plugin::MarcFieldValues;

use Modern::Perl;
use MARC::Field;
use MARC::Record;

use base qw(Koha::Plugins::Base);

our $VERSION = 1.00;
our $metadata = {
    name            => 'MarcFieldValues',
    author          => 'M. de Rooy',
    class           => 'Koha::Plugin::MarcFieldValues',
    description     => 'Convert MARC fields from plain text',
    date_authored   => '2017-08-08',
    date_updated    => '2017-08-08',
    minimum_version => '16.11',
    maximum_version => undef,
    version         => $VERSION,
    input_format    => 'MARC field/value pairs in plain text',
};

=head1 METHODS

=head2 new

    Create new object

=cut

sub new {
    my ( $class, $args ) = @_;
    $args->{'metadata'} = $metadata;
    my $self = $class->SUPER::new($args);
    return $self;
}

=head2 to_marc

    Create string of MARC blobs from plain text lines in the form:
        field [,ind1|,ind2|,subcode] = value
    Example:
        003 = OrgCode
        100,a = Author
        245,ind2 = 0
        245,a = Title

=cut

sub to_marc {
    my ( $self, $args ) = @_;
    # $args->{data} contains text to convert to MARC
    my $retval = '';
    my @records = split /\r?\n\r?\n/, $args->{data};
    foreach my $rec ( @records ) {
        my @lines = split /\r?\n/, $rec;
        my $marc = MARC::Record->new;
        my $inds = {};
        my $fldcount = 0;
        foreach my $line ( @lines ) {
            # each line is of the form field [,ind1|,ind2|,subcode] = value
            my @temp = split /\s*=\s*/, $line, 2;
            next if @temp < 2;
            $temp[0] =~ s/^\s*//;
            $temp[1] =~ s/\s*$//;
            my $value = $temp[1];
            @temp = split /\s*,\s*/, $temp[0];
            if( @temp > 1 && $temp[1] =~ /ind[12]/ ) {
                $inds->{$temp[0]}->{$temp[1]} = substr($value, 0, 1);
                next;
            }
            $fldcount++;
            $marc->append_fields( MARC::Field->new(
                $temp[0],
                $temp[0] < 10
                    ? ()
                    : ( ( $inds->{$temp[0]} ? $inds->{$temp[0]}->{ind1} // '' : '', $inds->{$temp[0]} ? $inds->{$temp[0]}->{ind2} // '' : ''), substr( $temp[1], 0, 1 ) ),
                $value,
            ));
        }
        $retval .= $marc->as_usmarc if $fldcount;
    }
    return $retval;
}

1;
