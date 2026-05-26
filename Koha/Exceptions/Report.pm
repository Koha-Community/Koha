package Koha::Exceptions::Report;

use Modern::Perl;

use Koha::Exception;

use Exception::Class (
    'Koha::Exceptions::Report' => {
        isa         => 'Koha::Exception',
        description => 'A report operation failed',
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
    'Koha::Exceptions::Report::RunTypeNotAllowed' => {
        isa         => 'Koha::Exceptions::Report',
        description => "The report's run_type is set to a value that does not match the allowed one",
        fields      => [ 'report_id', 'requested', 'allowed' ],
    },
);

=head1 NAME

Koha::Exceptions::Report - Base class for report exceptions

=head1 Exceptions

=head2 Koha::Exceptions::Report

Generic report exception.

=head2 Koha::Exceptions::Report::EditPermission

Exception raised when the logged-in user may not edit a report.

=head2 Koha::Exceptions::Report::UnauthorizedBranchParameter

Exception raised when a Library runtime parameter value is outside the
branchcodes the report's library limits allow under LimitReportsBy.

=head1 Class methods

=head2 description

Returns the description of the exception.

=head2 Koha::Exceptions::Report::RunTypeNotAllowed

Exception raised when the requested run_type does not match the run_type
the report is set to.

=cut

1;
