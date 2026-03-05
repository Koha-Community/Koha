use Modern::Perl;

return {
    bug_number  => "41297",
    description => "Add system preferences for blocking duplicate EDI invoices",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Master preference to enable duplicate blocking
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type)
            VALUES (
                'EdiBlockDuplicateInvoice',
                '0',
                NULL,
                'Block processing of EDIFACT invoices when a duplicate invoice number is detected for the same supplier. When enabled, duplicate invoices will be rejected and logged as errors.',
                'YesNo'
            )
        }
        );
        say $out "Added system preference 'EdiBlockDuplicateInvoice'";

        # Email notification toggle
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type)
            VALUES (
                'EdiBlockDuplicateInvoiceEmailNotice',
                '0',
                NULL,
                'Send email notification when duplicate EDIFACT invoices are detected. Requires EdiBlockDuplicateInvoice to be enabled.',
                'YesNo'
            )
        }
        );
        say $out "Added system preference 'EdiBlockDuplicateInvoiceEmailNotice'";

        # Email recipient list
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type)
            VALUES (
                'EdiBlockDuplicateInvoiceEmailAddresses',
                '',
                NULL,
                'Comma-separated list of email addresses to notify when duplicate EDIFACT invoices are detected (e.g., "purchasing@library.org,edi_support@library.org"). Requires EdiBlockDuplicateInvoiceEmailNotice to be enabled.',
                'Textarea'
            )
        }
        );
        say $out "Added system preference 'EdiBlockDuplicateInvoiceEmailAddresses'";

        # Add database index for performance
        my $index_exists = $dbh->selectrow_array(
            q{
            SELECT COUNT(*)
            FROM information_schema.statistics
            WHERE table_schema = DATABASE()
            AND table_name = 'aqinvoices'
            AND index_name = 'idx_invoicenumber_booksellerid'
        }
        );

        unless ($index_exists) {
            $dbh->do(
                q{
                CREATE INDEX idx_invoicenumber_booksellerid
                ON aqinvoices (invoicenumber(100), booksellerid)
            }
            );
            say $out "Added index idx_invoicenumber_booksellerid to aqinvoices table";
        }

        # Add edi_error_notification column to aqcontacts
        unless ( column_exists( 'aqcontacts', 'edi_error_notification' ) ) {
            $dbh->do(
                q{
                ALTER TABLE aqcontacts
                ADD COLUMN edi_error_notification TINYINT(1) NOT NULL DEFAULT 0
                AFTER serialsprimary
            }
            );
            say $out "Added edi_error_notification column to aqcontacts table";
        }

        # Delete any truncated templates first
        $dbh->do(q{DELETE FROM letter WHERE code = 'EDI_DUPLICATE_INVOIC' AND module = 'acquisition'});

        # Add notice templates for duplicate invoice notifications
        $dbh->do(
            q{
            INSERT IGNORE INTO letter (module, code, branchcode, name, is_html, title, content, message_transport_type, lang)
            VALUES (
                'acquisition',
                'EDI_DUP_INV_LIBRARY',
                '',
                'EDIFACT duplicate invoice detected - library notification',
                0,
                'EDIFACT Duplicate Invoice Blocked - [% invoicenumber | html %]',
                'Duplicate EDIFACT Invoice Detected and Blocked

Invoice Number: [% invoicenumber | html %]
Vendor: [% aqbooksellers.name | html %] (ID: [% vendor_id | html %])
EDI Message File: [% filename | html %]
Original Invoice ID: [% original_invoiceid | html %]
Original Invoice Date: [% original_shipmentdate | html %]

Status: Processing has been blocked. The invoice was NOT created in Koha.

Action Required:
The supplier must resend this invoice with a unique invoice number.

View EDI Message: [% OPACBaseURL | uri %]/cgi-bin/koha/acqui/edimsg.pl?id=[% message_id | uri %]
View Original Invoice: [% OPACBaseURL | uri %]/cgi-bin/koha/acqui/invoice.pl?invoiceid=[% original_invoiceid | uri %]

This is an automated notification from your Koha system.',
                'email',
                'default'
            )
        }
        );
        say $out "Added letter template 'EDI_DUP_INV_LIBRARY'";

        $dbh->do(
            q{
            INSERT IGNORE INTO letter (module, code, branchcode, name, is_html, title, content, message_transport_type, lang)
            VALUES (
                'acquisition',
                'EDI_DUP_INV_VENDOR',
                '',
                'EDIFACT duplicate invoice detected - vendor notification',
                0,
                'Duplicate Invoice Number - Action Required - [% invoicenumber | html %]',
                'Dear Supplier,

We have received an EDIFACT invoice message from your system with a duplicate invoice number.

Invoice Number: [% invoicenumber | html %]
Your Reference (SAN): [% vendor_san | html %]
EDI Message File: [% filename | html %]
Received Date: [% received_date | html %]

Issue:
This invoice number has already been processed in our system (original invoice ID: [% original_invoiceid | html %], date: [% original_shipmentdate | html %]).

Action Required:
Please resend this invoice using a UNIQUE invoice number. Duplicate invoice numbers cannot be processed by our system.

If you believe this is in error, please contact our acquisitions department.

Library: [% aqbooksellers.name | html %]

This is an automated notification. Please do not reply to this email.',
                'email',
                'default'
            )
        }
        );
        say $out "Added letter template 'EDI_DUP_INV_VENDOR'";
    },
};
