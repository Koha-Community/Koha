package Koha::Exceptions::Calendar;

use Modern::Perl;

use Koha::Exception;

use Exception::Class (
    'Koha::Exceptions::Calendar' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::Calendar::NoOpenDays' => {
        isa         => 'Koha::Exceptions::Calendar',
        description => 'Library has no open days',
    },
);

=head1 NAME

Koha::Exceptions::Calendar - Base class for calendar exceptions

=head1 Exceptions

=head2 Koha::Exceptions::Calendar

Generic calendar exception

=head2 Koha::Exceptions::Calendar::NoOpenDays

Exceptions to be used when no open days have been found

=cut

1;
