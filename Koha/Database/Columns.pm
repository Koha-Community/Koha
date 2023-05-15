package Koha::Database::Columns;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Koha::I18N qw( __ );

=head1 NAME

Koha::Database::Columns

=head1 SYNOPSIS

  use Koha::Database::Columns;
  my $columns = Koha::Database::Columns->columns;

=head1 API

=head2 Methods

=head3 columns

Static method that returns a hashref with mappings from column names
to descriptions, for several tables. Currently

=over

=item aqorders

=item biblio

=item biblioitems

=item borrowers

=item items

=item statistics

=item subscription

=item suggestions

=back

=cut

sub columns {
    return {
        aqorders => {
            "basketno"                      => __("Basket ID (internal)"),
            "biblionumber"                  => __("Biblionumber (internal)"),
            "budget_id"                     => __("Fund ID (internal)"),
            "budgetdate"                    => __("Not used (deprecated)"),
            "cancellationreason"            => __("Cancellation reason"),
            "created_by"                    => __("Borrower number of creator"),
            "currency"                      => __("Currency"),
            "datecancellationprinted"       => __("Cancellation date"),
            "datereceived"                  => __("Date received"),
            "discount"                      => __("Discount"),
            "ecost_tax_excluded"            => __("Budgeted cost, tax excl."),
            "ecost_tax_included"            => __("Budgeted cost, tax incl."),
            "ecost"                         => __("Budgeted cost"),
            "entrydate"                     => __("Creation date"),
            "estimated_delivery_date"       => __("Estimated delivery date"),
            "freight"                       => __("Not used (deprecated)"),
            "invoiceid"                     => __("Invoice ID (internal)"),
            "line_item_id"                  => __("Line item ID (EDIFACT)"),
            "listprice"                     => __("Vendor price"),
            "order_internalnote"            => __("Internal note"),
            "order_vendornote"              => __("Vendor note"),
            "ordernumber"                   => __("Order number"),
            "orderstatus"                   => __("Order status"),
            "parent_ordernumber"            => __("Parent order number (internal)"),
            "purchaseordernumber"           => __("Not used (deprecated)"),
            "quantity"                      => __("Quantity"),
            "quantityreceived"              => __("Quantity received"),
            "replacementprice"              => __("Replacement price"),
            "rrp_tax_excluded"              => __("Retail price, tax excl."),
            "rrp_tax_included"              => __("Retail price, tax incl."),
            "rrp"                           => __("Retail price"),
            "sort1_authcat"                 => __("Not used"),
            "sort1"                         => __("Statistic 1"),
            "sort2_authcat"                 => __("Not used"),
            "sort2"                         => __("Statistic 2"),
            "subscriptionid"                => __("Subscription ID (internal)"),
            "suppliers_reference_number"    => __("Vendor reference number (EDIFACT)"),
            "suppliers_reference_qualifier" => __("Vendor reference qualifier (EDIFACT)"),
            "suppliers_report"              => __("Vendor report (EDIFACT)"),
            "tax_rate_bak"                  => __("Tax rate backup (deprecated)"),
            "tax_rate_on_ordering"          => __("Tax rate on order"),
            "tax_rate_on_receiving"         => __("Tax rate on receive"),
            "tax_value_bak"                 => __("Tax value backup (deprecated)"),
            "tax_value_on_ordering"         => __("Tax amount on order"),
            "tax_value_on_receiving"        => __("Tax amount on receive"),
            "timestamp"                     => __("Timestamp"),
            "uncertainprice"                => __("Uncertain price"),
            "unitprice_tax_excluded"        => __("Actual cost, tax excl."),
            "unitprice_tax_included"        => __("Actual cost, tax incl."),
            "unitprice"                     => __("Actual cost"),
        },
        borrowers => {
            "address"                     => __("Address"),
            "address2"                    => __("Address 2"),
            "altcontactaddress1"          => __("Alternate contact: Address"),
            "altcontactaddress2"          => __("Alternate contact: Address 2"),
            "altcontactaddress3"          => __("Alternate contact: City"),
            "altcontactcountry"           => __("Alternate contact: Country"),
            "altcontactfirstname"         => __("Alternate contact: First name"),
            "altcontactphone"             => __("Alternate contact: Phone"),
            "altcontactstate"             => __("Alternate contact: State"),
            "altcontactsurname"           => __("Alternate contact: Surname"),
            "altcontactzipcode"           => __("Alternate contact: ZIP/Postal code"),
            "anonymized"                  => __("Data anonymization flag"),
            "auth_method"                 => __("Authentication method"),
            "autorenew_checkouts"         => __("Allow auto-renewals"),
            "B_address"                   => __("Alternate address: Address"),
            "B_address2"                  => __("Alternate address: Address 2"),
            "B_city"                      => __("Alternate address: City"),
            "B_country"                   => __("Alternate address: Country"),
            "B_email"                     => __("Alternate address: Email"),
            "B_phone"                     => __("Alternate address: Phone"),
            "B_state"                     => __("Alternate address: State"),
            "B_streetnumber"              => __("Alternate address: Street number"),
            "B_streettype"                => __("Alternate address: Street type"),
            "B_zipcode"                   => __("Alternate address: ZIP/Postal code"),
            "borrowernotes"               => __("Circulation note"),
            "borrowernumber"              => __("Borrower number"),
            "branchcode"                  => __("Home library"),
            "cardnumber"                  => __("Card number"),
            "categorycode"                => __("Patron category"),
            "checkprevcheckout"           => __("Check for previous checkouts"),
            "city"                        => __("City"),
            "contactfirstname"            => __("Alternate contact: First name"),
            "contactname"                 => __("Alternate contact: Surname"),
            "contactnote"                 => __("Alternate contact: Note"),
            "contacttitle"                => __("Alternate contact: Title"),
            "country"                     => __("Country"),
            "date_renewed"                => __("Account renewal date"),
            "dateenrolled"                => __("Registration date"),
            "dateexpiry"                  => __("Expiry date"),
            "dateofbirth"                 => __("Date of birth"),
            "debarred"                    => __("Restricted [until] flag"),
            "debarredcomment"             => __("Comment"),
            "email"                       => __("Primary email"),
            "emailpro"                    => __("Secondary email"),
            "fax"                         => __("Fax"),
            "firstname"                   => __("First name"),
            "flags"                       => __("System permissions"),
            "gonenoaddress"               => __("Gone no address flag"),
            "initials"                    => __("Initials"),
            "lang"                        => __("Preferred language for notices"),
            "lastseen"                    => __("Last activity date"),
            "login_attempts"              => __("Number of failed login attempts"),
            "lost"                        => __("Lost card flag"),
            "middle_name"                 => __("Middle name"),
            "mobile"                      => __("Other phone"),
            "opacnote"                    => __("OPAC note"),
            "othernames"                  => __("Other name"),
            "overdrive_auth_token"        => __("Overdrive auth token"),
            "password_expiration_date"    => __("Password expiration date"),
            "password"                    => __("Password"),
            "phone"                       => __("Primary phone"),
            "phonepro"                    => __("Secondary phone"),
            "primary_contact_method"      => __("Primary contact method"),
            "privacy_guarantor_checkouts" => __("Show checkouts to guarantor"),
            "privacy_guarantor_fines"     => __("Show fines to guarantor"),
            "privacy"                     => __("Privacy settings"),
            "pronouns"                    => __("Pronouns"),
            "relationship"                => __("Relationship"),
            "secret"                      => __("Secret (2FA)"),
            "sex"                         => __("Gender"),
            "sms_provider_id"             => __("SMS provider ID (internal)"),
            "smsalertnumber"              => __("Mobile phone number"),
            "sort1"                       => __("Sort 1"),
            "sort2"                       => __("Sort 2"),
            "state"                       => __("State"),
            "streetnumber"                => __("Street number"),
            "streettype"                  => __("Street type"),
            "surname"                     => __("Surname"),
            "title"                       => __("Salutation"),
            "updated_on"                  => __("Last update date"),
            "userid"                      => __("Username"),
            "zipcode"                     => __("ZIP/Postal code"),
        },
        items => {
            "barcode"                           => __("Barcode"),
            "biblioitemnumber"                  => __("Biblioitem number (internal)"),
            "biblionumber"                      => __("Biblio number (internal)"),
            "booksellerid"                      => __("Source of acquisition"),
            "ccode"                             => __("Collection"),
            "cn_sort"                           => __("Koha normalized classification for sorting"),
            "cn_source"                         => __("Source of classification / shelving scheme"),
            "coded_location_qualifier"          => __("Coded location qualifier"),
            "copynumber"                        => __("Copy number"),
            "damaged_on"                        => __("Damaged on"),
            "damaged"                           => __("Damaged status"),
            "dateaccessioned"                   => __("Date acquired"),
            "datelastborrowed"                  => __("Date last checked out"),
            "datelastseen"                      => __("Date last seen"),
            "deleted_on"                        => __("Date of deletion"),
            "enumchron"                         => __("Serial enumeraton/chronology"),
            "exclude_from_local_holds_priority" => __("Exclude from local holds priority"),
            "holdingbranch"                     => __("Current library"),
            "homebranch"                        => __("Permanent library"),
            "issues"                            => __("Total checkouts"),
            "itemcallnumber"                    => __("Call number"),
            "itemlost_on"                       => __("Lost on"),
            "itemlost"                          => __("Lost status"),
            "itemnotes_nonpublic"               => __("Internal note"),
            "itemnotes"                         => __("Public note"),
            "itemnumber"                        => __("Item number (internal)"),
            "itype"                             => __("Koha item type"),
            "location"                          => __("Shelving location"),
            "materials"                         => __("Materials specified"),
            "more_subfields_xml"                => __("Additional subfields (XML)"),
            "new_status"                        => __("New status"),
            "notforloan"                        => __("Not for loan"),
            "onloan"                            => __("Due date"),
            "permanent_location"                => __("Permanent shelving location"),
            "price"                             => __("Price"),
            "renewals"                          => __("Total renewals"),
            "replacementprice"                  => __("Replacement price"),
            "replacementpricedate"              => __("Price effective from"),
            "reserves"                          => __("Total holds"),
            "restricted"                        => __("Use restrictions"),
            "stack"                             => __("Shelving control number"),
            "stocknumber"                       => __("Inventory number"),
            "timestamp"                         => __("Timestamp"),
            "uri"                               => __("Uniform resource identifier"),
            "withdrawn_on"                      => __("Withdrawn on"),
            "withdrawn"                         => __("Withdrawn status"),
        },
        biblio => {
            "abstract"      => __("Abstract"),
            "author"        => __("Author"),
            "biblionumber"  => __("Biblio number"),
            "copyrightdate" => __("Copyright date"),
            "datecreated"   => __("Creation date"),
            "frameworkcode" => __("Framework code"),
            "medium"        => __("Medium"),
            "notes"         => __("Notes"),
            "part_name"     => __("Name of part/section of a work"),
            "part_number"   => __("Number of part/section of a work"),
            "serial"        => __("Is a serial?"),
            "seriestitle"   => __("Series title"),
            "subtitle"      => __("Remainder of title"),
            "timestamp"     => __("Modification date"),
            "title"         => __("Title"),
            "unititle"      => __("Uniform title"),
        },
        biblioitems => {
            "agerestriction"   => __("Age restriction"),
            "biblioitemnumber" => __("Biblioitem number"),
            "biblionumber"     => __("Biblio number"),
            "classification"   => __("Classification"),
            "dewey"            => __("Dewey/classification"),
            "illus"            => __("Illustrations"),
            "isbn"             => __("ISBN"),
            "issn"             => __("ISSN"),
            "itemtype"         => __("Biblio-level item type"),
            "lccn"             => __("LCCN"),
            "notes"            => __("Notes"),
            "number"           => __("Number"),
            "pages"            => __("Number of pages"),
            "place"            => __("Place of publication"),
            "publicationyear"  => __("Publication date"),
            "publishercode"    => __("Publisher"),
            "size"             => __("Size"),
            "subclass"         => __("Sub classification"),
            "timestamp"        => __("Timestamp"),
            "title"            => __("Title"),
            "url"              => __("URL"),
            "volume"           => __("Volume number"),
            "volumedate"       => __("Volume date"),
            "volumedesc"       => __("Volume information"),
        },
        statistics => {
            "borrowernumber" => __("Borrower number"),
            "branch"         => __("Library"),
            "datetime"       => __("Statistics date and time"),
            "itemnumber"     => __("Item number"),
            "itemtype"       => __("Itemtype"),
            "other"          => __(""),
            "type"           => __("Type"),
            "value"          => __("Value"),
        },
        subscription => {
            "branchcode"  => __("Library"),
            "callnumber"  => __("Call number"),
            "enddate"     => __("End date"),
            "location"    => __("Location"),
            "periodicity" => __("Periodicity"),
            "startdate"   => __("Start date"),
        },
        suggestions => {
            "author"          => __("Author"),
            "branchcode"      => __("Library"),
            "collectiontitle" => __("Collection title"),
            "copyrightdate"   => __("Copyright date"),
            "isbn"            => __("ISBN"),
            "itemtype"        => __("Item type"),
            "note"            => __("Note"),
            "patronreason"    => __("Patron reason"),
            "place"           => __("Place of publication"),
            "publishercode"   => __("Publisher"),
            "quantity"        => __("Quantity"),
            "title"           => __("Title"),
        }
    };
}

1;
