package Koha::Exceptions::File;

use Modern::Perl;

use File::Basename;

use Koha::File;

use Koha::Exceptions;

use Exception::Class (

    'Koha::Exceptions::File' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'Problem with a file',
        fields => ['path', 'stat'],
    },
);

=head2 throw
@OVERLOADS

Adds diagnostic information regarding the file with issues

=cut

sub throw {
    my ($self, %args) = @_;
    my @pwuid = getpwuid($<);
    my $realUser = $pwuid[0];
    @pwuid = getpwuid($>);
    my $effectiveUser = $pwuid[0];

    my $stat = 'File permissions:> ';
    if (-e $args{path}) {
        $stat .= Koha::File::getDiagnosticsString($args{path});
    }
    else {
        $stat .= "FILE NOT EXISTS.";
        my $parentDir = File::Basename::dirname($args{path});
        $stat .= " Parent directory '$parentDir' permissions:> ".(Koha::File::getDiagnosticsString(  $parentDir  ) || 'DIR NOT EXISTS');
    }

    $stat .= ", Real user:> $realUser, Effective user:> $effectiveUser";
    $args{stat} = $stat;

    $args{error} .= '. '.$stat;
    $self->SUPER::throw(%args);
}

1;
