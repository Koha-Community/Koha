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

=item biblio

=item biblioitems

=item borrowers

=item items

=item statistics

=item subscription

=item suggestion

=back

=cut

sub columns {
    return {
        aqorders => {
            "ordernumber"             => __("Order number"),
            "biblionumber"            => __("Biblionumber (internal)"),
            "entrydate"               => __("Creation date"),
            "quantity"                => __("Quantity"),
            "currency"                => __("Currency"),
            "listprice"               => __("Vendor price"),
            "datereceived"            => __("Date received"),
            "invoiceid"               => __("Invoice ID (internal)"),
            "freight"                 => __("Not used (deprecated)"),
            "unitprice"               => __("Actual cost"),
            "unitprice_tax_excluded"  => __("Actual cost, tax excl."),
            "unitprice_tax_included"  => __("Actual cost, tax incl."),
            "quantityreceived"        => __("Quantity received"),
            "created_by"              => __("Borrower number of creator"),
            "datecancellationprinted" => __("Cancellation date"),
            "cancellationreason"      => __("Cancellation reason"),
            "order_internalnote"      => __("Internal note"),
            "order_vendornote"        => __("Vendor note"),
            "purchaseordernumber"     => __("Not used (deprecated)"),
            "basketno"                => __("Basket ID (inernal)"),
            "timestamp"               => __("Timestamp"),
            "rrp"                     => __("Retail price"),
            "replacementprice"        => __("Replacement price"),
            "rrp_tax_excluded"        => __("Retail price, tax excl."),
            "rrp_tax_included"        => __("Retail price, tax incl."),
            "ecost"                   => __("Budgeted cost"),
            "ecost_tax_excluded"      => __("Budgeted cost, tax excl."),
            "ecost_tax_included"      => __("Budgeted cost, tax incl."),
            "tax_rate_bak"            => __("Tax rate backup (deprecated)"),
            "tax_rate_on_ordering"    => __("Tax rate on order"),
            "tax_rate_on_receiving"   => __("Tax rate on receive"),
            "tax_value_bak"           => __("Tax value backup (deprecated)"),
            "tax_value_on_ordering"   => __("Tax amount on order"),
            "tax_value_on_receiving"  => __("Tax amount on receive"),
            "discount"                => __("Discount"),
            "budget_id"               => __("Fund ID (internal)"),
            "budgetdate"              => __("Not used (deprecated)"),
            "sort1"                   => __("Statistic 1"),
            "sort2"                   => __("Statistic 2"),
            "sort1_authcat"           => __("Not used"),
            "sort2_authcat"           => __("Not used"),
            "uncertainprice"          => __("Uncertain price"),
            "subscriptionid"          => __("Subscription ID (internal)"),
            "parent_ordernumber"      => __("Parent order number (internal)"),
            "orderstatus"             => __("Order status"),
            "line_item_id"            => __("Line item ID (EDIFACT)"),
            "suppliers_reference_number" => __("Vendor reference number (EDIFACT)"),
            "suppliers_reference_qualifier" => __("Vendor reference qualifier (EDIFACT)"),
            "suppliers_report"        => __("Vendor report (EDIFACT)"),
            "estimated_delivery_date" => __("Estimated delivery date"),
        },
        borrowers => {
            "borrowernumber"      => __("Borrower number"),
            "title"               => __("Salutation"),
            "surname"             => __("Surname"),
            "firstname"           => __("First name"),
            "middle_name"         => __("Middle name"),
            "dateofbirth"         => __("Date of birth"),
            "initials"            => __("Initials"),
            "pronouns"            => __("Pronouns"),
            "othernames"          => __("Other name"),
            "sex"                 => __("Gender"),
            "relationship"        => __("Relationship"),
            "streetnumber"        => __("Street number"),
            "streettype"          => __("Street type"),
            "address"             => __("Address"),
            "address2"            => __("Address 2"),
            "city"                => __("City"),
            "state"               => __("State"),
            "zipcode"             => __("ZIP/Postal code"),
            "country"             => __("Country"),
            "phone"               => __("Primary phone"),
            "phonepro"            => __("Secondary phone"),
            "mobile"              => __("Other phone"),
            "email"               => __("Primary email"),
            "emailpro"            => __("Secondary email"),
            "fax"                 => __("Fax"),
            "B_streetnumber"      => __("Alternate address: Street number"),
            "B_streettype"        => __("Alternate address: Street type"),
            "B_address"           => __("Alternate address: Address"),
            "B_address2"          => __("Alternate address: Address 2"),
            "B_city"              => __("Alternate address: City"),
            "B_state"             => __("Alternate address: State"),
            "B_zipcode"           => __("Alternate address: ZIP/Postal code"),
            "B_country"           => __("Alternate address: Country"),
            "B_phone"             => __("Alternate address: Phone"),
            "B_email"             => __("Alternate address: Email"),
            "contactnote"         => __("Alternate contact: Note"),
            "altcontactfirstname" => __("Alternate contact: First name"),
            "altcontactsurname"   => __("Alternate contact: Surname"),
            "altcontactaddress1"  => __("Alternate contact: Address"),
            "altcontactaddress2"  => __("Alternate contact: Address 2"),
            "altcontactaddress3"  => __("Alternate contact: City"),
            "contactname"         => __("Alternate contact: Surname"),
            "contactfirstname"    => __("Alternate contact: First name"),
            "contacttitle"        => __("Alternate contact: Title"),
            "altcontactstate"     => __("Alternate contact: State"),
            "altcontactzipcode"   => __("Alternate contact: ZIP/Postal code"),
            "altcontactcountry"   => __("Alternate contact: Country"),
            "altcontactphone"     => __("Alternate contact: Phone"),
            "cardnumber"          => __("Card number"),
            "branchcode"          => __("Home library"),
            "categorycode"        => __("Patron category"),
            "sort1"               => __("Sort 1"),
            "sort2"               => __("Sort 2"),
            "dateenrolled"        => __("Registration date"),
            "dateexpiry"          => __("Expiry date"),
            "opacnote"            => __("OPAC note"),
            "borrowernotes"       => __("Circulation note"),
            "userid"              => __("Username"),
            "password"            => __("Password"),
            "flags"               => __("System permissions"),
            "gonenoaddress"       => __("Gone no address flag"),
            "lost"                => __("Lost card flag"),
            "debarred"            => __("Restricted [until] flag"),
            "debarredcomment"     => __("Comment"),
            "smsalertnumber"      => __("Mobile phone number"),
            "privacy"             => __("Privacy settings"),
            "autorenew_checkouts" => __("Allow auto-renewals"),
        },
        items => {
            "itemnumber"           => __("Item number (internal)"),
            "biblionumber"         => __("Biblio number (internal)"),
            "biblioitemnumber"     => __("Biblioitem number (internal)"),
            "barcode"              => __("Barcode"),
            "dateaccessioned"      => __("Date acquired"),
            "booksellerid"         => __("Source of acquisition"),
            "homebranch"           => __("Permanent library"),
            "price"                => __("Price"),
            "replacementprice"     => __("Replacement price"),
            "replacementpricedate" => __("Price effective from"),
            "datelastborrowed"     => __("Date last checked out"),
            "datelastseen"         => __("Date last seen"),
            "stack"                => __("Shelving control number"),
            "onloan"               => __("Due date"),
            "cn_source"    => __("Source of classification / shelving scheme"),
            "cn_sort"      => __("Koha normalized classification for sorting"),
            "notforloan"   => __("Not for loan"),
            "itemlost"     => __("Lost status"),
            "itemlost_on"  => __("Lost on"),
            "withdrawn"    => __("Withdrawn status"),
            "withdrawn_on" => __("Withdrawn on"),
            "itemcallnumber"           => __("Call number"),
            "coded_location_qualifier" => __("Coded location qualifier"),
            "issues"                   => __("Total checkouts"),
            "renewals"                 => __("Total renewals"),
            "reserves"                 => __("Total holds"),
            "restricted"               => __("Use restrictions"),
            "itemnotes"                => __("Public note"),
            "itemnotes_nonpublic"      => __("Internal note"),
            "holdingbranch"            => __("Current library"),
            "timestamp"                => __("Timestamp"),
            "deleted_on"               => __("Date of deletion"),
            "location"                 => __("Shelving location"),
            "permanent_location"       => __("Permanent shelving location"),
            "ccode"                    => __("Collection"),
            "itype"                    => __("Koha item type"),
            "stocknumber"              => __("Inventory number"),
            "damaged"                  => __("Damaged status"),
            "damaged_on"               => __("Damaged on"),
            "materials"                => __("Materials specified"),
            "uri"                      => __("Uniform resource identifier"),
            "more_subfields_xml"       => __("Additional subfields (XML)"),
            "enumchron"                => __("Serial enumeraton/chronology"),
            "copynumber"               => __("Copy number"),
            "new_status"               => __("New status"),
            "exclude_from_local_holds_priority" => __("Exclude from local holds priority"),
        },
        statistics => {
            "datetime"       => __("Statistics date and time"),
            "branch"         => __("Library"),
            "value"          => __("Value"),
            "type"           => __("Type"),
            "other"          => __(""),
            "itemnumber"     => __("Item number"),
            "itemtype"       => __("Itemtype"),
            "borrowernumber" => __("Borrower number"),
        },
        biblio => {
			"biblionumber"  => __("Biblio number"),
            "frameworkcode" => __("Framework code"),
            "author"        => __("Author"),
            "title"         => __("Title"),
            "medium"        => __("Medium"),
            "subtitle"      => __("Remainder of title"),
            "part_number"   => __("Number of part/section of a work"),
            "part_name"     => __("Name of part/section of a work"),
            "unititle"      => __("Uniform title"),
            "notes"         => __("Notes"),
            "serial"        => __("Is a serial?"),
            "seriestitle"   => __("Series title"),
            "copyrightdate" => __("Copyright date"),
            "datecreated"   => __("Creation date"),
            "timestamp"     => __("Modification date"),
            "abstract"      => __("Abstract"),
        },
        biblioitems => {
            "biblioitemnumber" => __("Biblioitem number"),
            "biblionumber"     => __("Biblio number"),
            "volume"           => __("Volume number"),
            "number"           => __("Number"),
            "classification"   => __("Classification"),
            "itemtype"         => __("Biblio-level item type"),
            "isbn"             => __("ISBN"),
            "issn"             => __("ISSN"),
            "dewey"            => __("Dewey/classification"),
            "subclass"         => __("Sub classification"),
            "publicationyear"  => __("Publication date"),
            "publishercode"    => __("Publisher"),
            "volumedate"       => __("Volume date"),
            "volumedesc"       => __("Volume information"),
            "timestamp"        => __("Timestamp"),
            "illus"            => __("Illustrations"),
            "pages"            => __("Number of pages"),
            "notes"            => __("Notes"),
            "size"             => __("Size"),
            "place"            => __("Place of publication"),
            "lccn"             => __("LCCN"),
            "agerestriction"   => __("Age restriction"),
            "url"              => __("URL"),
            "title"            => __("Title"),
        },
        subscription => {
            "startdate"   => __("Start date"),
            "enddate"     => __("End date"),
            "periodicity" => __("Periodicity"),
            "callnumber"  => __("Call number"),
            "location"    => __("Location"),
            "branchcode"  => __("Library"),
        },
        suggestions => {
            "author"          => __("Author"),
            "copyrightdate"   => __("Copyright date"),
            "isbn"            => __("ISBN"),
            "publishercode"   => __("Publisher"),
            "collectiontitle" => __("Collection title"),
            "place"           => __("Place of publication"),
            "quantity"        => __("Quantity"),
            "itemtype"        => __("Item type"),
            "branchcode"      => __("Library"),
            "patronreason"    => __("Patron reason"),
            "note"            => __("Note"),
            "title"           => __("Title"),
        }
    };
}

1;
