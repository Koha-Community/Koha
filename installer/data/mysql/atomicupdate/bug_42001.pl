use Modern::Perl;

return {
    bug_number  => "42001",
    description => "Add email notifications for duplicate EDI purchase orders",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Email notification toggle
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type)
            VALUES (
                'EdiDuplicateOrderEmailNotice',
                '0',
                NULL,
                'Send email notification when a duplicate EDIFACT purchase order number is detected for the same supplier.',
                'YesNo'
            )
        }
        );
        say $out "Added system preference 'EdiDuplicateOrderEmailNotice'";

        # Email recipient list
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type)
            VALUES (
                'EdiDuplicateOrderEmailAddresses',
                '',
                NULL,
                'Comma-separated list of email addresses to notify when duplicate EDIFACT purchase order numbers are detected (e.g., "purchasing@library.org,edi_support@library.org"). Requires EdiDuplicateOrderEmailNotice to be enabled.',
                'Textarea'
            )
        }
        );
        say $out "Added system preference 'EdiDuplicateOrderEmailAddresses'";

        # Add notice template - library staff notification
        $dbh->do(
            q{
            INSERT IGNORE INTO letter (module, code, branchcode, name, is_html, title, content, message_transport_type, lang)
            VALUES (
                'acquisition',
                'EDI_DUP_ORD_LIBRARY',
                '',
                'EDIFACT duplicate order detected - library notification',
                0,
                'EDIFACT Duplicate Purchase Order Blocked - [% po_number | html %]',
                'Duplicate EDIFACT Purchase Order Detected and Blocked

Purchase Order Number: [% po_number | html %]
Vendor: [% aqbooksellers.name | html %] (ID: [% vendor_id | html %])
Basket No: [% basketno | html %]
Existing Basket No: [% existing_basketno | html %]

Status: The EDI order was NOT sent. The basket remains open.

This purchase order number already exists for this vendor (basket [% existing_basketno | html %]).
A basket name/PO number must be unique per vendor when the vendor EDI account has "Use basket name as PO number" enabled.

Action Required:
Rename the basket to use a unique purchase order number, then resend the EDI order.

View Basket: [% OPACBaseURL | uri %]/cgi-bin/koha/acqui/basket.pl?basketno=[% basketno | uri %]
View Existing Basket: [% OPACBaseURL | uri %]/cgi-bin/koha/acqui/basket.pl?basketno=[% existing_basketno | uri %]

This is an automated notification from your Koha system.',
                'email',
                'default'
            )
        }
        );
        say $out "Added letter template 'EDI_DUP_ORD_LIBRARY'";

        # Add notice template - vendor notification
        $dbh->do(
            q{
            INSERT IGNORE INTO letter (module, code, branchcode, name, is_html, title, content, message_transport_type, lang)
            VALUES (
                'acquisition',
                'EDI_DUP_ORD_VENDOR',
                '',
                'EDIFACT duplicate order detected - vendor notification',
                0,
                'Duplicate Purchase Order Number Received - [% po_number | html %]',
                'Dear Supplier,

We have attempted to send an EDIFACT order to your system but the purchase order number is a duplicate.

Purchase Order Number: [% po_number | html %]
Your Reference (SAN): [% vendor_san | html %]

Issue:
This purchase order number has already been used in a previous order with your organisation. We were unable to send the order.

No action is required from you at this stage. Our acquisitions team has been notified and will resubmit the order with a corrected purchase order number.

If you have any questions, please contact our acquisitions department.

Library: [% aqbooksellers.name | html %]

This is an automated notification. Please do not reply to this email.',
                'email',
                'default'
            )
        }
        );
        say $out "Added letter template 'EDI_DUP_ORD_VENDOR'";
    },
};
