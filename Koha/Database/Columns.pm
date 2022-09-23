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
            "cn_source"            => __("Source of classification / shelving scheme"),
            "cn_sort"              => __("Koha normalized classification for sorting"),
            "notforloan"           => __("Not for loan"),
            "itemlost"             => __("Lost status"),
            "itemlost_on"          => __("Lost on"),
            "withdrawn"            => __("Withdrawn status"),
            "withdrawn_on"         => __("Withdrawn on"),
            "itemcallnumber"       => __("Call number"),
            "issues"               => __("Total checkouts"),
            "renewals"             => __("Total renewals"),
            "reserves"             => __("Total holds"),
            "restricted"           => __("Use restrictions"),
            "itemnotes"            => __("Public note"),
            "itemnotes_nonpublic"  => __("Internal note"),
            "holdingbranch"        => __("Current library"),
            "timestamp"            => __("Timestamp"),
            "location"             => __("Shelving location"),
            "permanent_location"   => __("Permanent shelving location"),
            "ccode"                => __("Collection"),
            "itype"                => __("Koha itemtype"),
            "stocknumber"          => __("Inventory number"),
            "damaged"              => __("Damaged status"),
            "damaged_on"           => __("Damaged on"),
            "materials"            => __("Materials specified"),
            "uri"                  => __("Uniform Resource Identifier"),
            "more_subfields_xml"   => __("Additional subfields (XML)"),
            "enumchron"            => __("Serial enumeraton/chronology"),
            "copynumber"           => __("Copy number"),
            "new_status"           => __("New status"),
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
            "frameworkcode" => __("Framework code"),
            "author"        => __("Author"),
            "datecreated"   => __("Creation date"),
            "timestamp"     => __("Modification date"),
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
        suggestions=> {
            "author"          => __("author"),
            "copyrightdate"   => __("copyrightdate"),
            "isbn"            => __("isbn"),
            "publishercode"   => __("publishercode"),
            "collectiontitle" => __("collectiontitle"),
            "place"           => __("place"),
            "quantity"        => __("quantity"),
            "itemtype"        => __("itemtype"),
            "branchcode"      => __("branchcode"),
            "patronreason"    => __("patronreason"),
            "note"            => __("note"),
            "title"           => __("title"),
        }
    };
}

1;
