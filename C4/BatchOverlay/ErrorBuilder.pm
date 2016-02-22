package C4::BatchOverlay::ErrorBuilder;

use Modern::Perl;
use Scalar::Util qw(blessed);
use Try::Tiny;

use C4::Context;
use C4::BatchOverlay::Report::Error;

use Koha::Exception::BadParameter;
use Koha::Exception::UnknownProgramState;

sub new {
    my ($class) = @_;

    my $self = {};
    $self->{errors} = []; #Collect the error Hashes here.
    bless $self, $class;

    return $self;
}

sub addError {
    my ($self, $e) = @_;
    my $report = $self->_reportizeError($e);
    push(@{$self->{errors}}, $report);

    return $report;
}
sub getErrors {
    return shift->{errors};
}

sub _reportizeError {
    my ($self, $e) = @_;

    my $report = C4::BatchOverlay::Report::Error->new({
        localRecord => $e->{records}->[0],
        operation => ($e->{operation}) ? 'error '.$e->{operation} : 'error',
        timestamp => DateTime->now( time_zone => C4::Context->tz() ),
        diff => $e,
        overlayRule => $e->{overlayRule},
    });

    return $report;
}

1; #Satisfying the compiler, we aim to please!
