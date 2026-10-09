package Koha::Exceptions::Report;

use Modern::Perl;

use Koha::Exception;

use Exception::Class (
    'Koha::Exceptions::Report' => {
        isa         => 'Koha::Exception',
        description => 'A report operation failed',
    },
    'Koha::Exceptions::Report::DuplicateRunning' => {
        isa         => 'Koha::Exceptions::Report',
        description => "The configured per-user limit on simultaneous runs of this report has been reached",
        fields      => [ 'report_id', 'user_id', 'limit' ],
    },
    'Koha::Exceptions::Report::TotalRunning' => {
        isa         => 'Koha::Exceptions::Report',
        description => "The configured per-user limit on total simultaneous report runs has been reached",
        fields      => [ 'user_id', 'limit' ],
    },
    'Koha::Exceptions::Report::InstanceTotalRunning' => {
        isa         => 'Koha::Exceptions::Report',
        description => "The configured instance-wide limit on total simultaneous report runs has been reached",
        fields      => ['limit'],
    },
    'Koha::Exceptions::Report::EditPermission' => {
        isa         => 'Koha::Exceptions::Report',
        description => 'You do not have permission to edit this report',
        fields      => ['report_id'],
    },
    'Koha::Exceptions::Report::UnauthorizedBranchParameter' => {
        isa         => 'Koha::Exceptions::Report',
        description => 'The selected library is not allowed for this report',
        fields      => [ 'report_id', 'branchcode' ],
    },
);

=head1 NAME

Koha::Exceptions::Report - Base class for report exceptions

=head1 Exceptions

=head2 Koha::Exceptions::Report

Generic report exception.

=head2 Koha::Exceptions::Report::DuplicateRunning

The configured per-user limit on simultaneous runs of this report has been reached.

=head2 Koha::Exceptions::Report::TotalRunning

The configured per-user limit on total simultaneous report runs has been reached.

=head2 Koha::Exceptions::Report::EditPermission

Exception raised when the logged-in user may not edit a report.

=head2 Koha::Exceptions::Report::UnauthorizedBranchParameter

Exception raised when a Library runtime parameter value is outside the
branchcodes the report's library limits allow under LimitReportsBy.

=head1 Class methods

=head2 description

Returns the description of the exception.

=cut

1;
