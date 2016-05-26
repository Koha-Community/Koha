# RELEASE NOTES FOR KOHA 16.05.00
26 May 2016

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.05.00 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.05.00.tar.gz)

Installation instructions can be found at:

Please note - Ubuntu 16.04 support is still WIP and isn't supported at the moment, due to stricter MySQL version 5.7.  All installs and updates should be done on versions previous to MySQL 5.7.  Thanks

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.05.00 is a major release, that comes with many new features.

It includes 7 new features, 340 enhancements, 472 bugfixes.

## New features

### Acquisitions

- [[7736]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7736) Edifact QUOTE and ORDER functionality

### Authentication

- [[10988]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10988) Allow login via Google OAuth2 (OpenID Connect)

### Cataloging

- [[11023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11023) Automatic item modification by age (Was "Toggle new status for items")

### Circulation

- [[9129]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9129) Add the ability to set the maximum fine for an item to its replacement price

### Notices

- [[9021]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9021) Add SMS via email as an alternative to SMS services via SMS::Send drivers

### OPAC

- [[8753]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8753) Add forgot password link to OPAC
- [[11622]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11622) Add ability to pay fees and fines from OPAC via PayPal

## Enhancements

### About

- [[15465]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15465) README for github

### Acquisitions

- [[12333]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12333) Add floating toolbar to acquisition basket summary page
- [[13238]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13238) Improve heading on vendor search when searching for all vendors
- [[15004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15004) Allow to change amounts of duplicated budgets
- [[15049]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15049) Add warning about "No active currency" to Acquisitions start page
- [[15519]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15519) Warns when creating a basket
- [[15531]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15531) Add support for standing orders
- [[15630]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15630) Make Edifact module pluggable
- [[16036]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16036) Making basket actions buttons
- [[16037]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16037) Rename 'Print' to 'Export as PDF' for basket groups
- [[16142]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16142) Making 'order' a button for new order suggestions
- [[16262]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16262) Remove the use of "onclick" from acquisitions basket template
- [[16351]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16351) Error when trying to receive a new shipment without specifying invoice number

### Architecture, internals, and plumbing

- [[5404]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5404) C4::Koha::subfield_is_koha_internal_p no longer serves a purpose
- [[11625]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11625) Default to logged in library for circ rules and notices & slips
- [[11747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11747) Default to logged in library for Overdue notice/status triggers
- [[14751]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14751) Allow C4::Context->interface to be set to 'sip' or 'commandline'
- [[14828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14828) Move the item types related code to Koha::ItemTypes
- [[14889]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14889) Move the framework related code to Koha::BiblioFramework[s]
- [[15084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15084) Move the currency related code to Koha::Acquisition::Currenc[y|ies]
- [[15288]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15288) Error pages: Code duplication removal and better translatability
- [[15294]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15294) Move the C4::Branch related code to Koha::Libraries - part 1
- [[15295]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15295) Move the C4::Branch related code to Koha::Libraries - part 2
- [[15380]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15380) Move the authority types related code to Koha::Authority::Type[s] - part 1
- [[15381]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15381) Move the authority types related code to Koha::Authority::Type[s] - part 2
- [[15481]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15481) Remove dead code in datatables.js
- [[15548]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15548) New patron related code should have been put to Patron instead of Borrower
- [[15628]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15628) Remove get_branchinfos_of vestiges
- [[15629]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15629) Move the C4::Branch related code to Koha::Libraries - part 3
- [[15631]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15631) Move the cities related code to Koha::Cities - part 2
- [[15632]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15632) Move the messages related code to Koha::Patron::Messages
- [[15635]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15635) Move the patron images related code to Koha::Patron::Images
- [[15653]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15653) Updating a guarantor has never updated its guarantees
- [[15656]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15656) Move the guarantor/guarantees code to Koha::Patron
- [[15731]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15731) C4::Reports::Guided::build_authorised_value_list is not used
- [[15769]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15769) C4::Koha::slashifyDate is outdated
- [[15783]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15783) C4::Koha::AddAuthorisedValue can be replaced with Koha::AuthorisedValue->new->store
- [[15796]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15796) C4::Koha - get_itemtypeinfos_of is not used anymore
- [[15797]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15797) C4::Koha::GetKohaImageurlFromAuthorisedValues is no longer in use
- [[15798]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15798) C4::Koha::displayServers is no longer in use
- [[15800]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15800) Koha::AuthorisedValues - Remove C4::Koha::IsAuthorisedValueCategory
- [[15870]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15870) Add Filter for MARC to respect visibility settings
- [[16011]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16011) Remove $VERSION from our modules
- [[16044]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16044) Define a L1 cache for all objects set in cache
- [[16070]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16070) Empty (undef) system preferences may cause some issues in combination with memcache
- [[16086]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16086) Add Koha::Issue objects.
- [[16087]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16087) Add Koha::OldIssues Objects
- [[16103]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16103) Remove FK constraint for sms_provider_id in deletedborrowers
- [[16157]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16157) C4::Koha::GetAuthorisedValues should not handle the selected option
- [[16158]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16158) GetAuthorisedValues should not be called inside a loop
- [[16167]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16167) Remove prefs to drive authorised value images
- [[16168]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16168) Eliminate unneeded C4::Context->dbh calls in C4/Biblio.pm
- [[16169]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16169) TransformMarcToKoha should not take $dbh in parameters
- [[16199]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16199) C4::Ris::charconv is one of the less useful subroutines ever written
- [[16221]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16221) Use Storable::dclone() instead of Clone::clone() for L1 cache deep-copying mode
- [[16238]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16238) Upgrade jQuery in staff client: use .prop() instead of .attr()

### Authentication

- [[11807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11807) Add categorycode conversions to LDAP authentication.

### Cataloging

- [[11084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11084) Delete biblios on Leader 05 =d
- [[12670]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12670) Show materials label instead of code
- [[14168]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14168) enhance streaming cataloging to include youtube
- [[14199]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14199) Unify all organization code plugins
- [[15225]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15225) Make HTML5Media work with file upload feature
- [[15859]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15859) Move some basic MARC editor controls into settings menu
- [[15952]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15952) Moving cataloging search actions into a drop-down menu
- [[16205]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16205) MARC editor settings menu should use a Font Awesome icon

### Circulation

- [[1983]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=1983) Add option to create hold request when checking out an item already on loan
- [[11565]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11565) decreaseLoanHighHolds needs Override
- [[13592]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13592) Hold fee not being applied on placing a hold
- [[14395]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14395) Two different ways to calculate 'No renewal before' (days or hours)
- [[14577]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14577) Allow restriction of checkouts based on fines of guarantor/guarantee
- [[14753]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14753) Show accession date on checkin
- [[14945]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14945) Add the ability to store the last patron to return an item
- [[15129]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15129) Koha::object for issuing rules
- [[15471]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15471) Add column settings and filters to Holds queue table
- [[15564]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15564) Display "print slip" option when returning an item which is in a rotating collection
- [[15571]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15571) reserveforothers permission does not remove Search to hold button from patron account
- [[15675]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15675) Add issue_id column to accountlines and use it for updating fines
- [[15793]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15793) UX of circulation patron search with long lists of returned borrowers
- [[15821]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15821) Use Font Awesome icons in confirmation dialogs - Circulation
- [[16141]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16141) Making 'Transfers to receive' action a button

### Command-line Utilities

- [[12289]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12289) stage_file.pl does not allow control of nomatch options
- [[13143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13143) Add a tool to show a Koha's password
- [[14292]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14292) Add --category and --skip-category options to longoverdue.pl to include or exclude borrower categories.
- [[14532]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14532) koha-dump should provide a way to exclude Zebra indexes
- [[16039]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16039) Quiet flag support for share_usage_with_koha_community.pl

### Database

- [[13624]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13624) Remove columns branchcode, categorytype from table overduerules_transport_types

### Documentation

- [[13136]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13136) Add documentation for Home > Tools > Labels home > Manage label Layouts

### Hold requests

- [[12803]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12803) Add ability to skip closed libraries when generating the holds queue
- [[13517]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13517) Show waiting date on reserve/request.pl
- [[14134]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14134) Make "Holds over" show holds expiring tomorrow if ExpireReservesMaxPickUpDelay is set
- [[14310]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14310) Add ability to suspend and resume individual holds from the patron holds table
- [[14694]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14694) Make decreaseloanHighHolds more flexible
- [[15443]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15443) Re-code RESERVESLIP as HOLD_SLIP
- [[15532]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15532) Add ability to allow only items whose home/holding branch matches the hold's pickup branch to fill a given hold
- [[15533]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15533) Allow patrons and librarians to select itemtype when placing hold
- [[15534]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15534) Add the ability to prevent a patron from placing a hold on a record with available items

### I18N/L10N

- [[15231]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15231) Import patrons: Remove string splitting by html tags to avoid weird translations
- [[15274]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15274) Better translatability for circulation.pl / circulation.tt
- [[15301]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15301) Translatability: branchtransfers.tt: Remove ambiguous "To" and fix splitted sentence.
- [[16382]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16382) Update German web installer sample files for 16.05

### Installation and upgrade (web-based installer)

- [[14622]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14622) Add fr-CA data folder in the web installer

### Label/patron card printing

- [[14131]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14131) Patroncard: Add possibility to print from patron lists
- [[15211]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15211) Label/patron card creators need to have Tools sidebar
- [[15662]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15662) String and translatability fix to Label Creator
- [[16152]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16152) Rename label management table column to Actions
- [[16153]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16153) Adding "actions" class to Label Creator table actions so the buttons dont wrap

### Lists

- [[15403]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15403) Confirm messages in intranet lists interface strangely worded
- [[15583]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15583) List of lists in the staff client should have a default sort
- [[16110]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16110) Making lists actions buttons
- [[16338]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16338) Remove the use of "onclick" from the lists template

### MARC Authority data support

- [[15931]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15931) If Authority is not used by any records, remove link to cataloguing search
- [[15932]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15932) Moving Authorities actions into a drop-down menu

### MARC Bibliographic data support

- [[14306]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14306) Show URL from MARC21 field 555$u in basket and detail
- [[15162]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15162) Add for Unimarc transformation to new metadata formats
- [[16460]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16460) Update MARC21 frameworks to Update No. 22 (April 2016)
- [[16470]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16470) Update MARC21 es-ES frameworks to Update 22 (April 2016)

### MARC Bibliographic record staging/import

- [[2324]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=2324) Undo Import should have a confirm dialog
- [[16052]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16052) Styling buttons after MARC records have been staged
- [[16057]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16057) Use font awesome button for cleaning a batch of staged MARC records

### Notices

- [[9004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9004) Talking Tech doesn't account for holidays when calculating a holds last pickup date
- [[10076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10076) Add Bcc syspref for claimacquisition and clamissues
- [[12426]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12426) Allow resending of emails from the notices tab in the patron account
- [[12923]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12923) Improve error logging for advance_notices.pl; Show borrowernumber when no letter of type is found and force utf8 output.
- [[14515]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14515) Add biblioitems table to notices in C4/Reserves.pm
- [[16048]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16048) Making notices actions buttons

### OPAC

- [[5979]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5979) Add separate OPACISBD system preference
- [[6624]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6624) Allow Koha to use the new read API from OpenLibrary
- [[7594]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7594) Google Cover Javascript contains hardcoded CSS style
- [[13642]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13642) Adding new features for Dublin Core metadata
- [[13774]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13774) Add the unique anchors of news as links in the RSS for news in Opac
- [[13918]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13918) Add waiting expiration date to opac list of holds for user
- [[14305]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14305) Public way to look at the Opac of different branches
- [[14523]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14523) Google jackets being blocked when OPAC using HTTPS
- [[14571]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14571) using_https check for ssl connections doesn't work in some situations
- [[14582]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14582) OPAC detail shows an unuseful link to "add tag" when user is not logged in
- [[14658]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14658) Split PatronSelfRegistrationBorrowerUnwantedField into two preferences for creating and editing
- [[14659]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14659) Allow patrons to enter card number and patron category on OPAC registration page
- [[15044]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15044) add suggestion's date on Your purchase suggestions tab in OPAC
- [[15311]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15311) Let libraries set text to display when OpacMaintenance = on
- [[15574]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15574) Better wording for error message when adding tags
- [[15813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15813) Fix list-context call to ...->guarantor in opac-memberentry.pl
- [[16283]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16283) Make OPAC registration captcha case insensitive

### Packaging

- [[4940]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=4940) Koha should include sample rc.d script(s) for *BSD
- [[15303]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15303) Letsencrypt option for Debian package installations
- [[15714]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15714) Remove zebra.log from debian scripts and add optional log levels
- [[16016]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16016) Integrate sitemap.pl into the packages
- [[16190]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16190) Enable the indexer daemon by default

### Patrons

- [[9303]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9303) relative's checkouts in the opac
- [[10468]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10468) Add pending holds to summary print
- [[11088]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11088) Patron entry page should use floating toolbar like cataloging interface
- [[12528]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12528) Enable staff to deny message setting access to patrons on the OPAC
- [[13931]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13931) Date of birth in patron search result and in autocomplete
- [[14406]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14406) When adding messages in patron account, only first name is shown in pull down
- [[14497]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14497) Add warning to patron details page if patron's fines exceed noissuescharge
- [[14763]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14763) show patron's age
- [[14834]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14834) Make membership_expiry cronjob more flexible
- [[14948]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14948) Display amounts right aligned in tables on patron pages
- [[15096]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15096) Export today's checked in barcodes: Display warning if reading history is set to "never"
- [[15196]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15196) Order patrons on patron lists by name
- [[15206]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15206) Show patron's age when filling date of birth in memberentry.pl
- [[15343]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15343) Allow patrons to choose their own password on self registration.
- [[15543]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15543) Use another notice in membership_expiry.pl
- [[16100]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16100) Buttons in patron toolbar are styled differently
- [[16120]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16120) Making action on patron search a button
- [[16182]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16182) Make phone number clickable to call
- [[16183]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16183) Add confirm message for deleting patron messages
- [[16234]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16234) Borrower account has an unnecessary link to 'View item'
- [[16235]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16235) Making borrower account actions buttons
- [[16316]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16316) Make it possible to limit patron search to surname

### Reports

- [[7683]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7683) statistic wizard: cataloging
- [[10154]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10154) Add collection, location, and callnumber filters to report for most circulated items
- [[11371]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11371) Add a new report : Orders by budget
- [[12544]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12544) Send scheduled reports as an attachment
- [[15321]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15321) Add delete report option to Show, Edit and Run screens
- [[15863]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15863) When creating a dictionary for date column, date range selection should be hidden if all dates is selected
- [[16161]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16161) Add confirm message when deleting dictionary definition
- [[16162]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16162) Making dictionary 'Delete' a font awesome button
- [[16163]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16163) Show message if there are no dictionary definitions
- [[16281]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16281) Remove the use of "onclick" from Reports module
- [[16359]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16359) Filter search box covers other elements on saved reports page
- [[16389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16389) Reports row limit should change upon option selection

### SIP2

- [[14512]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14512) Add support for AV field to Koha's SIP2 Server

### Searching

- [[12478]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12478) Elasticsearch support for Koha
- [[14277]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14277) Search index 'lex' does not honor MARC indicator "ind1"
- [[14332]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14332) Skip title articles on Opac using ind2 of tag 245 (MARC21 only)
- [[14899]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14899) Mapping configuration page for Elastic search
- [[15263]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15263) XSLT display fetches sysprefs for every result processed
- [[15555]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15555) Index 024$a into Identifier-other:u url register when source $2 is uri
- [[16363]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16363) Use floating toolbar on advanced search

### Serials

- [[12375]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12375) Store serials enumeration data in separate fields
- [[16074]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16074) Making frequencies actions buttons
- [[16075]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16075) Making numbering patterns actions buttons
- [[16097]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16097) Making messages for subscription fields more user friendly
- [[16098]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16098) Making subscription fields actions buttons
- [[16099]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16099) Make name required field when creating subscription field
- [[16164]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16164) Making check expiration actions buttons

### Staff Client

- [[4941]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=4941) Remove singleBranchMode system preference

> The singleBranchMode system preference has been removed. Koha instance with multiple libraries will not longer be able to use single branch mode. Single branch mode will be automatically enabled for Koha instances with only one library configured.


- [[11280]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11280) Change Withdrawn toggle to drop down selection of authorized values
- [[12342]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12342) Patron registration datepicker dropdown shows only 10 years
- [[15008]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15008) Add custom HTML areas to circulation and reports home pages
- [[15413]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15413) Adding colons where they should appear in forms etc to be consistent
- [[15638]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15638) spelling mistake in ~/Koha/reserve/placerequest.pl:4: writen  ==> written
- [[15640]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15640) Accessibility - ensure there are no titles on hover over the links (circ home page)
- [[16028]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16028) Remove redundant hold links
- [[16130]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16130) Show the item non-public note on the detail view

### System Administration

- [[15552]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15552) Better wording of intranetreadinghistory syspref
- [[15617]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15617) Be able to close "Click to edit" text boxes after opening them
- [[15665]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15665) Better wording of error messages when importing MARC frameworks
- [[15965]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15965) Koha to MARC mapping - table changes with selection of drop down menu
- [[15966]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15966) Move MARC frameworks actions into a drop down menu
- [[15988]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15988) Moving authority types actions into a drop-down menu
- [[15989]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15989) Making classification sources actions buttons
- [[15990]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15990) Making record matching rules actions buttons
- [[15991]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15991) Moving OAI sets actions into a drop-down menu
- [[15992]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15992) Renaming 'Operations' column heading to 'Actions'
- [[15993]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15993) Making currency actions buttons
- [[15994]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15994) Adding font awesome icons to Funds actions
- [[15995]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15995) Making libraries actions buttons
- [[16081]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16081) Making Koha to MARC mapping actions buttons
- [[16096]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16096) Change 'Modify' to 'Edit' for OAI sets config
- [[16132]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16132) Remove branch select button in Library Transfer Limits
- [[16236]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16236) Making authorised values actions buttons
- [[16263]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16263) Making authority tags and subfields actions buttons
- [[16265]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16265) Making item types actions buttons
- [[16267]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16267) Making circ and fines rules actions buttons
- [[16268]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16268) Add confirm message when deleting circ and fines rules
- [[16286]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16286) Use validation plugin when adding or editing patron category
- [[16297]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16297) Remove the use of "onclick" from OAI sets configuration template
- [[16298]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16298) Standardize on "Patron categories" when referring to patron category administration
- [[16299]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16299) Use validation plugin when creating a patron attribute type
- [[16301]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16301) Remove the use of "onclick" from SMS cellular providers template
- [[16305]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16305) Remove the use of "onclick" from transport cost matrix
- [[16308]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16308) Remove the use of "onclick" from Z39.50/SRU servers template
- [[16383]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16383) Making Local Use sysprefs actions buttons

### Templates

- [[10171]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10171) Add a header in Advanced Search (staff interface)
- [[10347]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10347) Deactivate "Add item" button when "Add multiple copies" was activated
- [[12051]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12051) add renew tab to top on staff client
- [[13302]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13302) Use CSS3 ellipsis for email address in staff client patron sidebar
- [[13464]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13464) Standardize the pagination class
- [[13778]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13778) Putting patron lists buttons into a dropdown menu
- [[14304]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14304) RDA: Display link in XSLT for 264 field to reflect Zebra indexing
- [[14377]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14377) Indicate that a record is suppressed in staff client
- [[15285]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15285) Upgrade DataTables to 1.10.10 or later
- [[15309]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15309) Use Bootstrap modal for cataloging search MARC and Card preview
- [[15313]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15313) Use Bootstrap modal for z39.50 search MARC and Card preview
- [[15314]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15314) Use Bootstrap modal for cataloging merge MARC preview
- [[15316]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15316) Use Bootstrap modal for authority Z39.50 search results preview
- [[15317]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15317) Use Bootstrap modal for MARC and Card preview when ordering from staged files
- [[15318]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15318) Use Bootstrap modal for MARC and Card preview when ordering an external source
- [[15319]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15319) Use Bootstrap modal for MARC preview when performing batch record modifications
- [[15320]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15320) Use Bootstrap modal for MARC preview when ordering from an existing record
- [[15669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15669) alphabetize marc modification pulldowns
- [[15671]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15671) Show branch name instead of branch code in checkout history
- [[15672]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15672) Show descriptions instead of codes on the hold ratios report
- [[15692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15692) Move some patron entry form JavaScript into members.js
- [[15785]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15785) Use Font Awesome icons in confirmation dialogs
- [[15825]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15825) Patron lists does not show tools menu sidebar
- [[15826]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15826) Use Font Awesome icons in confirmation dialogs - Tools
- [[15843]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15843) Move MARC subfields structure JavaScript into separate file
- [[15846]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15846) Move MARC Framework JavaScript into separate file
- [[15858]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15858) Use Font Awesome icons in dialog alert for addorder.tt
- [[15867]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15867) Move MARC modification templates JavaScript into separate file
- [[15883]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15883) Upgrade jQuery from v1.7.2 in the staff client
- [[15886]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15886) Revise layout and behavior of audio alerts management
- [[15887]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15887) Revise layout and behavior of item search fields management
- [[15910]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15910) Move header search keep text JavaScript into staff-global.js
- [[15918]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15918) Obsolete file datatables-strings.inc can be removed
- [[15936]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15936) Revise layout and behavior of SMS cellular providers management
- [[15938]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15938) Use validation plugin when adding or editing classification sources and filing rules
- [[15950]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15950) Use Font Awesome icons for acquisitions basket close confirmation
- [[15951]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15951) Use Font Awesome icons for acquisitions order cancellation confirmation
- [[15959]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15959) Use Font Awesome icons for attach item confirmations
- [[15960]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15960) Use Font Awesome icons for classification filing rule deletion error
- [[15961]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15961) Use Font Awesome icons for confirmation of currency deletion
- [[15963]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15963) Use Font Awesome icons for confirmation after deleting MARC tag
- [[15978]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15978) Use Font Awesome icons for guided reports error dialog
- [[15979]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15979) Use Font Awesome icons subscription deletion confirmation dialog
- [[15980]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15980) Use Font Awesome icons in subscription frequency deletion confirmation dialog
- [[15983]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15983) Use Font Awesome icons in serial numbering pattern deletion confirmation dialog
- [[16019]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16019) Remove unused blue.css
- [[16020]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16020) Remove unused CSS and images following label creator UX changes
- [[16021]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16021) Use Font Awesome icons on automatic item modifications by age page
- [[16032]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16032) Use Font Awesome icon in "note" styled divs
- [[16043]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16043) Use Font Awesome icon in hold confirmation dialog
- [[16045]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16045) Use Font Awesome icons in OAI sets administration
- [[16046]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16046) Use Font Awesome icons on patron edit pages
- [[16059]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16059) Use Font Awesome icons in standard cataloging duplicate warning dialog
- [[16060]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16060) Add Font Awesome icon to Z39.50 search button when no results are found
- [[16061]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16061) Use Font Awesome icons in reports when filter returns no results
- [[16062]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16062) Remove CSS and images related to old "approve" and "deny" button styles
- [[16064]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16064) Remove use of image to indicate approval in tags moderation
- [[16065]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16065) Use Font Awesome icons in dialog when duplicate patron is suspected
- [[16071]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16071) Use Font Awesome icons in authority record duplicate warning dialog
- [[16078]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16078) Remove unused YUI CSS
- [[16080]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16080) Remove unused images from the staff client
- [[16092]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16092) Fix error dialog and use Font Awesome Icons when deleting branch group
- [[16228]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16228) Move some patron entry form JavaScript into members.js again
- [[16241]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16241) Move staff client CSS out of language directory
- [[16242]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16242) Move staff client JavaScript out of language directory
- [[16341]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16341) Revise the way table controls look on the title detail page
- [[16366]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16366) Remove obsolete "border" attribute from <img> tags
- [[16368]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16368) Remove obsolete attributes from table tags
- [[16372]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16372) Replace the use of "onclick" for deletion confirmation in some templates
- [[16386]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16386) Replace the use of "onclick" from patron card creator templates
- [[16438]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16438) Use Font Awesome icons in batch templates

### Test Suite

- [[12787]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12787) Unit test files should be better organized
- [[15258]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15258) Prevent unused declared variables
- [[15756]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15756) Some tests for haspermission in C4::Auth
- [[15956]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15956) Rearranging some SIP unit tests (testable without SIP server)
- [[16155]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16155) Composite keys in TestBuilder and more
- [[16173]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16173) db_structure.t shouldn't have a fixed number of tests
- [[16320]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16320) Refactor ILSDI_Services.t so it uses TestBuilder

### Tools

- [[10612]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10612) Add ability to delete patrons with batch patron deletion tool
- [[14686]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14686) New menu option and permission for file uploading
- [[15213]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15213) Fix tools sidebar to highlight Patron lists when in that module
- [[15414]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15414) Noisy warns when creating new layout for patron card creator
- [[15573]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15573) String and translatability fix to Patron Card Creator
- [[15824]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15824) 'Done' button is unclear on batch item modification and deletion
- [[15827]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15827) Unfriendly message when saving overdue notice/status triggers
- [[15828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15828) Upload patron images is hard to read
- [[15829]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15829) Rotating Collections is under Patrons on Tools Home - Should be Catalog
- [[15830]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15830) Move Rotating Collections actions into a drop-down list
- [[16058]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16058) Add a button to delete an individual news item
- [[16077]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16077) Remove unused script and template card-print
- [[16139]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16139) Renaming 'Unseen since' column in Inventory/Stocktaking
- [[16193]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16193) Typo in Automatic item modifications by age
- [[16337]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16337) Remove the use of "onclick" from the stage MARC records template
- [[16360]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16360) Buttons wrap in Actions column for reviewing tags

### Web services

- [[13903]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13903) Add API routes to list, create, update, delete holds
- [[14257]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14257) Add show_extended_attributes to ILS-DI call GetPatronInfo
- [[14939]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14939) OAI Server classes must be modularized
- [[15126]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15126) REST API: Use newer version of Swagger2
- [[15527]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15527) OAI-PMH should have a stylesheet to aid usability

### translate.koha-community.org

- [[15080]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15080) ./translate-tool should tell if xgettext-executable is missing


## Critical bugs fixed

(this list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### Acquisitions

- [[16010]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16010) merge_authorities migration script is broken
- [[16089]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16089) Acquisitions -> Invoice broken by Bug 15084
- [[16227]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16227) The currencies of vendor and order do not display correctly
- [[16237]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16237) Adding new EDI account results in Perl error when plugins are not activated
- [[16256]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16256) Can't edit library EAN if you leave EAN empty

### Architecture, internals, and plumbing

- [[11998]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11998) Syspref caching issues
- [[15344]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15344) GetMemberDetails called unecessary
- [[15429]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15429) sub _parseletter should not change referenced values
- [[15446]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15446) Koha::Object[s]->type should be renamed to _type to avoid conflict with column name
- [[15447]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15447) log4perl.conf does not have __LOG_DIR__ replaced when installing
- [[15473]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15473) Koha::Objects->find should find if the key is an empty string
- [[15478]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15478) Checksum mismatch when regenerating schema
- [[15578]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15578) Authority tests skip and hide a bug
- [[15585]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15585) Move C4::Passwordrecovery to Koha::Patron::Password::Reset
- [[15680]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15680) Fresh install of Koha cannot find any dependencies
- [[15687]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15687) Syntax errors in misc/translator/xgettext.pl
- [[15891]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15891) Late night for Brendan :) updatedatabase
- [[16007]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16007) Correction of 'Remove columns branchcode, categorytype from table overduerules_transport_types'
- [[16068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16068) System preference override feature (OVERRIDE_SYSPREF_* = ) is not reliable for some cache systems
- [[16084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16084) log4perl.conf not properly set on packages
- [[16138]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16138) Restart plack when rotating logfiles
- [[16229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16229) Koha::Cache should be on the safe side
- [[16288]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16288) Edifact sysprefs EDIfactEAN and EDIInvoicesShippingBudget problems
- [[16418]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16418) EnhancedMessagingPreferencesOPAC appears twice in sysprefs.sql
- [[16505]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16505) rebuild_zebra.pl skips updates if -x is passed
- [[16539]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16539) Koha::Cache is incorrectly caching single holidays

### Authentication

- [[15889]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15889) Login with LDAP deletes extended attributes

### Cataloging

- [[15256]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15256) Items table on detail page can be broken
- [[15358]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15358) merge.pl does not populate values to merge
- [[15572]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15572) Authority creation fails when authid is linked to 001 field
- [[15579]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15579) records_batchmod permission doesn't allow access to batch modification
- [[16373]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16373) merge.pl reports success but files are not merged

### Circulation

- [[12045]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12045) Transfer impossible if barcode includes spaces
- [[13024]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13024) Nonpublic note not appearing in the staff client
- [[15442]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15442) Checkouts table will not display due to javascript error
- [[15462]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15462) Unable to renew books via circ/renew.pl
- [[15560]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15560) Multiple holding branchs and locations not displaying in pending holds report
- [[15570]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15570) circ/renew.pl is broken
- [[15736]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15736) Add a preference to control whether all items should be shown in checked-in items list
- [[15757]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15757) Hard coded due loan/renewal period of 21 days if no circ rule found in C4::Circulation::GetLoanLength
- [[16009]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16009) crash displaying pending offline circulations
- [[16073]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16073) Circulation is completely broken
- [[16082]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16082) Empty patron detail page is displayed if the patron does not exist - circulation.pl
- [[16186]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16186) t/db_dependent/Circulation_Issuingrule.t is failing
- [[16215]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16215) Missing closing quote in checkout template
- [[16240]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16240) Regression: Bug 16082 causes message to be displayed even when no borrowernumber is passed
- [[16378]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16378) Overdues.pm: Can't call method "store" without a package or object reference
- [[16496]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16496) accountlines.issue_id not set when new overdue is processed

### Command-line Utilities

- [[15923]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15923) Export records by id list impossible in export_records.pl

### Course reserves

- [[15530]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15530) Editing a course item via a disabled course disables it even if it is on other enabled courses

### Database

- [[15840]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15840) Import borrowers tool explodes if userid already exists

### Hold requests

- [[15645]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15645) In transit holds do not show as in transit on request.pl
- [[16151]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16151) can't place holds from lists

### Installation and upgrade (command-line installer)

- [[16361]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16361) Installer syntax error

### Installation and upgrade (web-based installer)

- [[13669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13669) Web installer fails to load sample data on MySQL 5.6+
- [[16402]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16402) DB structure cannot be loaded in MySQL 5.7

### Lists

- [[15453]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15453) Cannot download a list in the staff interface
- [[15810]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15810) Can't create private lists if OpacAllowPublicListCreation is set to 'not allow'
- [[16517]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16517) A server error is raised when creating a new list with an existing name

### MARC Authority data support

- [[15188]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15188) remove_unused_authorities.pl will delete all authorities if zebra is not running
- [[16056]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16056) Error when deleting MARC authority

### Notices

- [[12752]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12752) OVERDUE notice mis-labeled as "Hold Available for Pickup"
- [[15967]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15967) Print notices are not generated if the patron cannot be notified

### OPAC

- [[13534]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13534) Deleting staff patron will delete tags approved by this patron
- [[14614]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14614) Multiple URLs (856) in cart/list email are broken
- [[15550]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15550) Authority type pull down in OPAC authority search is empty
- [[16198]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16198) Opac suggestions are broken if user is not logged in
- [[16210]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16210) Bug 15111 breaks the OPAC if JavaScript is disabled
- [[16317]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16317) Attempt to share private list results in error

### Packaging

- [[14633]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14633) apache2-mpm-itk depencency makes Koha uninstallable on Debian Stretch
- [[15713]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15713) Restart zebra when rotating logfiles

### Patrons

- [[15163]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15163) Patron attributes with branch limiits are not saved when invisible
- [[15289]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15289) "borrowers" permission doesn't allow to see current loans
- [[15367]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15367) Batch patron modification: Data loss with multiple repeatable patron attributes

### Reports

- [[15250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15250) Software error: Can't locate object method "field" via package "aqorders.datereceived" in reports/acquisitions_stats.pl
- [[15290]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15290) SQL reports encoding problem

### Searching

- [[15818]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15818) OPAC search with utf-8 characters and without results generates encoding error

### Serials

- [[15501]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15501) Planned Irregularities are deleted when modifying subscription
- [[15643]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15643) Every datepicker on serials expected date column updates top issue

### Staff Client

- [[15816]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15816) Timeout login redirects to home page

### System Administration

- [[16015]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16015) Cannot delete a group of libraries
- [[16114]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16114) Regression: Bug 14828 broke display of localized item type descriptions
- [[16397]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16397) Unable to delete audio alerts

### Templates

- [[14632]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14632) Incorrect alert while deleting single item in batch
- [[15916]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15916) Regression: Many tables' sorting broken by JavaScript error
- [[16095]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16095) Security issue with the use of target="_blank" or window.open()
- [[16553]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16553) Incorrect path to jQueryUI file in help template

### Test Suite

- [[16160]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16160) t/db_dependent/www/search_utf8.t fails due to layout change
- [[16561]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16561) Regression caused by 15877 - t/db_dependent/Barcodes.t deletes all items from a DB

### Tools

- [[14893]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14893) Separate temporary storage per instance in Upload.pm

> Note: All temporary uploaded files will be deleted during upgrade.


- [[15240]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15240) Performance issue running overdue_notices.pl
- [[15332]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15332) ModMember not interpreting dates (Batch patron modification)
- [[15493]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15493) Export records using a CSV profile does not work
- [[15607]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15607) Batch patron modification: Data loss of 'dateenrolled' and 'expirydate' fields
- [[15684]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15684) Fix encoding issues with quote upload
- [[15842]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15842) Cannot import patrons if the csv file does not contain privacy_guarantor_checkouts
- [[16040]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16040) Quote deletion never ending processing
- [[16426]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16426) Import borrowers tool warns for blank and/or existing userids

### Web services

- [[16222]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16222) Add REST API folder to Makefile.PL


## Other bugs fixed

(this list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### About

- [[7143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7143) Bug for tracking changes to the about page
- [[15721]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15721) About page does not display Apache version

### Acquisitions

- [[9184]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9184) Ordering from staged file in acq should not offer authority records
- [[11203]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11203) Datatables in acqusitions do not ignore "stopwords" in titles
- [[13041]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13041) Can't add user as manager of basket if name includes a single quote
- [[14853]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14853) Change "Fund" to "Shipping fund" where appropriate
- [[15202]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15202) Fix date display when transferring an order
- [[15624]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15624) Spelling mistake in suggestion.pl
- [[15962]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15962) Currency deletion doesn't correctly identify currencies in use
- [[16053]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16053) Edit the active currency removes its 'active' flag
- [[16055]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16055) Deleting a basket group containing baskets fails silently
- [[16154]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16154) Replace CGI->param with CGI->multi_param in list context
- [[16206]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16206) Corrections to templates related new EDI feature
- [[16208]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16208) Can't delete a library EAN if the EAN value is empty
- [[16253]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16253) Acq: Change "Delete order" to "Cancel order line" on basket summary and receive page
- [[16257]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16257) EDIfact messages link on tools page results error
- [[16321]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16321) 'Show all details' checkbox triggers JS error after jQuery upgrade
- [[16325]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16325) Suggestions: Tab "Status unknown" contains all suggestions
- [[16384]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16384) When canceling 'edit basket', return to basket summary if you came from there
- [[16385]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16385) Fix breadcrumbs when ordering from subscription
- [[16414]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16414) aqorders.budgetgroup_id has never been used and can be removed

### Architecture, internals, and plumbing

- [[6679]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6679) Fixing code so it passes basic Perl::Critic tests
- [[12920]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12920) Remove AllowRenewalLimitOverride from pl scripts, use Koha.Preference instead
- [[15086]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15086) Creators layout and template sql has warnings
- [[15099]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15099) Fix file name: categorie.pl should be either category.pl or categories.pl
- [[15135]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15135) Remove Warning Subroutine HasOverdues redefined
- [[15193]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15193) Perl scripts missing exec permission
- [[15230]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15230) Remove unused file circ/stats.pl from system
- [[15333]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15333) Use Koha::Cache for caching all holidays
- [[15432]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15432) t/db_dependent/Letters.t depends on external data/configuration
- [[15466]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15466) Suggestions.t is failing
- [[15467]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15467) AuthoritiesMarc.t is failing
- [[15517]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15517) Tables borrowers and deletedborrowers differ again
- [[15601]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15601) TestBuilder tests are failing
- [[15626]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15626) koha-remove does not remove log4perl.conf
- [[15735]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15735) Audio Alerts editor broken by use of of single quotes in editor
- [[15742]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15742) Unnecessary loop in j2a cronjob
- [[15743]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15743) Allow plugins to embed Perl modules
- [[15777]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15777) Refactor loop in which Record::Processor does not initialize parameters
- [[15809]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15809) versions of CGI < 4.08 do not have multi_param
- [[15871]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15871) Improve perl critic of t/RecordProcessor.t
- [[15877]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15877) C4::Barcodes  does not correctly calculate db_max for 'annual' barcodes
- [[15878]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15878) C4::Barcodes::hbyymmincr inccorectly calculates max and should warn when no branchcode present
- [[15930]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15930) DataTables patron search defaulting to 'starts_with' and not getting correct parameters to parse multiple word searches
- [[15939]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15939) modification logs view now silently defaults to only current day's actions
- [[15968]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15968) Unnecessary loop in C4::Templates
- [[16054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16054) Plack - variable scope error in paycollect.pl
- [[16104]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16104) Warnings "used only once: possible typo" should be removed
- [[16105]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16105) Cache::Memory is loaded even if memcache is used
- [[16136]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16136) Koha::Patron contains 'return undef' and fails critic tests
- [[16248]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16248) ModZebra doesn't update zebraqueue if ES is enabled
- [[16259]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16259) More: Replace CGI->param with CGI->multi_param in list context
- [[16354]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16354) Fix FK constraints for edifact_messages table
- [[16412]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16412) Cache undef in L1 only
- [[16419]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16419) Tests of t/db_dependent/Acquisition.t do not pass
- [[16429]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16429) Going to circulation from notice triggers may change logged in branch
- [[16445]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16445) Bug 12478 has added an unnecessary line to Koha/Database.pm
- [[16448]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16448) Perlcritic errors introduced by 12478
- [[16452]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16452) PatronLists.t raises a warning
- [[16489]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16489) ES code incorrectly refers to Moose
- [[16499]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16499) circulation.pl logs warnings about Use of uninitialized value
- [[16506]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16506) rebuild_zebra.pl still using USMARC as default
- [[16550]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16550) Can't set opac news expiration date to NULL, it reverts to today

### Authentication

- [[14034]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14034) User logged out on refresh after Shibboleth authentication
- [[14507]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14507) SIP Authentication broken when LDAP Auth Enabled
- [[15553]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15553) cgisess_ files polluting the /tmp directory
- [[15747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15747) Auth.pm flooding error log with "CGI::param called in list context"

### Cataloging

- [[15337]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15337) Koha Item Type sorted by Codes instead of Descriptions
- [[15411]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15411) "Non fiction" is incorrect
- [[15512]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15512) Minor regression caused by Bug 7369 - warn on deleting item not triggered
- [[15514]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15514) New professional cataloguing editor does not handle repeatable fields correctly
- [[15682]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15682) Merging records from cataloguing search only allows to merge 2 records
- [[15872]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15872) Rancor: Ctrl-Shift-X has incorrect description in "Keyboard shortcuts"
- [[15955]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15955) Tuning function 'New child record' for Unimarc
- [[16171]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16171) Show many media (856) in html5media tab

### Circulation

- [[13838]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13838) Redirect to 'expired holds' tab after cancelling a hold
- [[14015]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14015) Checkout: Fix software error if barcode '0' is given
- [[14244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14244) viewing a bib item's circ history requires circulation permissions
- [[14846]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14846) Items with no holdingbranch causes user's holds display to freeze
- [[14930]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14930) Leaving OpacFineNoRenewals blank blocks renewals, but should disable feature
- [[15244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15244) t/db_dependent/Reserves.t depends on external data/configuration
- [[15324]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15324) Checkout page: Hide title "Waiting holds:" for patrons without waiting holds
- [[15472]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15472) Do not display links to circulation.pl if remaining_permissions is not set
- [[15569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15569) Automatic renewal should not be displayed if the patron cannot checkout
- [[15706]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15706) Templates require circulate permissions to show circ related tabs when they should only require circulate_remaining_permissions
- [[15730]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15730) 500 error on returns.pl if barcode doesn't exist
- [[15741]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15741) Incorrect rounding in total fines calculations
- [[15832]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15832) Pending reserves: duplicates branches in datatable filter
- [[15833]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15833) Bad variable value in renewal template confirmation dialog
- [[15841]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15841) Final truth value in C4:Circulation has become displaced
- [[15845]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15845) Renewal date in circulation.pl is not always correct and not even used
- [[15919]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15919) Batch checkout should show due date in list of checked-out items
- [[16042]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16042) Missing closing quote in checkin template
- [[16125]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16125) Regression: Can't add messages at checkout if no other messages are present
- [[16145]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16145) Regression: Bug 15632 broke display of library name on circulation messages

### Command-line Utilities

- [[14624]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14624) <<items.content>> for advance_notices.pl wrongly documented
- [[15113]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15113) koha-rebuild-zebra should check USE_INDEXER_DAEMON and skip if enabled
- [[15325]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15325) rebuild_zebra.pl table option (-t) doesn't work
- [[16031]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16031) sitemap.pl shouldn't append protocol to OPACBaseURL

### Course reserves

- [[15699]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15699) Opac: Course reserves instructors should be in form "Surname, Firstname" for sorting purposes

### Database

- [[15526]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15526) Drop nozebra database table
- [[16170]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16170) Pseudo foreign key in Items

### Developer documentation

- [[14397]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14397) Typo 'foriegn' in table comments
- [[14538]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14538) POD for CalcFine is incomplete
- [[16106]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16106) minor spelling correction to comment

### Documentation

- [[13177]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13177) Add help pages for Rotating collections
- [[14638]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14638) Update serials help files
- [[15220]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15220) typo in circ rules help
- [[15926]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15926) Item search fields admin missing help file

### Hold requests

- [[15357]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15357) Deleting all items on a record with title level holds creates orphaned/ghost holds
- [[15652]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15652) Allow current date in datepicker on opac-reserve
- [[15997]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15997) Hold Ratios for ordered items doesn't count orders where AcqCreateItem is set to 'receiving'

### I18N/L10N

- [[13474]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13474) Untranslatable log actions
- [[15232]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15232) Advanced Cataloging Editor: Fix translation issues
- [[15233]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15233) Cataloging subfield editors: Clean up html and streamline text for better translatability
- [[15236]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15236) Better translatibility in "Connect biblio.biblionumber to a MARC subfield"
- [[15237]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15237) Quote of the day: Better translatibility for editor and help
- [[15238]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15238) Better translatability for Installer Step 1
- [[15300]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15300) Translatability: Replace ambiguous 'From' and 'To' in members-update.tt
- [[15304]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15304) Norwegian patron database: translatable strings added to all po files
- [[15340]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15340) Translatability: fix issue with 'or choose' splitted by <strong tag
- [[15345]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15345) Translatability: fix issue in facets (Availability')
- [[15346]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15346) Translatability: fix sentence splitting issue in memberentrygen.tt
- [[15355]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15355) Translatability: Fix issues on check in page
- [[15361]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15361) Translatability: Fix issue on Administration Columns settings
- [[15362]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15362) Translatability: Fix issue on Administration 'Did you mean?'
- [[15363]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15363) Translatability: Fix issue with ambiguous 'all' on Administration > Set library checkin and transfer policy
- [[15365]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15365) Translatability: Fix issue on Administration > Circulation and fine rules
- [[15375]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15375) Translatability: Fix issues on OPAC page 'Placing a hold'
- [[15383]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15383) Opac: Authority details: Fix translation issues with tags
- [[15487]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15487) Encoding problem with item type translations
- [[15674]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15674) 'Show/hide columns' is not translatable
- [[15861]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15861) No chance to correctly translate an isolated word "The"
- [[16133]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16133) Translatability of database administrator account warning
- [[16194]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16194) Do not consider xslt as valid theme dir in LangInstaller.pm
- [[16322]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16322) Translatability: "Unknown" in suggestion/suggestion.pl not translatable
- [[16471]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16471) Translatability: Fix issues in opac-password-recovery.tt

### Installation and upgrade (command-line installer)

- [[12549]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12549) Hard coded font Paths (  DejaVu ) cause problems for non-Debian systems
- [[15405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15405) XML paths to zebra libraries is wrong for 64-bit installs on non-Debian linux

### Installation and upgrade (web-based installer)

- [[15719]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15719) Silence warning in C4/Language.pm during web install

### Label/patron card printing

- [[15224]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15224) Typo: Leave empty to add via item search (itemnunber).
- [[15663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15663) Can't delete label from checkbox

### Lists

- [[4912]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=4912) After editing private list, user should be redirect to private lists
- [[6322]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6322) It's possible to view lists/virtualshelves even when virtualshelves is off
- [[15476]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15476) Listname not always displayed in shelves.pl
- [[15811]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15811) Redirect after adding a new list in OPAC broken
- [[16484]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16484) Virtualshelves: Using no XSLTResultsDisplay breaks content display in intranet (titles not showing in lists)

### MARC Authority data support

- [[14050]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14050) Default framework for authorities should not be deletable

### MARC Bibliographic data support

- [[15170]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15170) Add 264 field to MARC21*DC.xsl
- [[15209]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15209) C4::Koha routines  expecting a MARC::Record object should check it is defined
- [[15444]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15444) MARC21: Repeated 508 not correctly formatted (missing separator)

### MARC Bibliographic record staging/import

- [[15745]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15745) C4::Matcher gets CCL parsing error if term contains ? (question mark)

### Notices

- [[1859]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=1859) Notice fields: can't select multiple fields at once
- [[8085]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8085) Rename 'Reserve slip' to 'Hold slip'
- [[14133]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14133) Print notices generated in special case do not use print template
- [[16217]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16217) Notice' names may have diverged

### OPAC

- [[11602]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11602) Fix localcover display

> Adds a CSS class of thumbnail to local covers. Don't show the 1px "No image found" image (since we'll usually try another image provider).


- [[14076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14076) Noisy warns in opac-authorities-home.pl
- [[14441]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14441) TrackClicks cuts off/breaks URLs
- [[14555]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14555) Warns in opac-search.pl
- [[14971]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14971) RIS only outputs the first 10 characters for either ISBN10 or ISBN13
- [[15100]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15100) MARC21: Display of $d for 7xx and 1xx fields should be optional
- [[15210]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15210) Novelist js throws an error if no ISBN
- [[15373]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15373) Zip should be ZIP
- [[15382]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15382) 245$a visibility constraints not respected in opac-MARCdetail.pl
- [[15394]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15394) Confirm messages on OPAC lists interface strangely worded
- [[15412]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15412) Dropdowns in suspend holds date selector do not function in Firefox
- [[15511]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15511) Tabbed fines display on OPAC patron summary page broken
- [[15576]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15576) Link in OPAC redirects to the wrong page
- [[15577]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15577) Link in OPAC doesn't redirect anywhere
- [[15589]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15589) OPAC Lists "his" string fix
- [[15697]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15697) Unnecessary comma between title and subtitle on opac-detail.pl
- [[15888]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15888) Syndetics Reviews preference should not enable LibraryThing reviews
- [[16129]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16129) Remove URL::Encode dependency
- [[16143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16143) Wrong icon PATH on virtualshelves
- [[16179]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16179) Clicking Rate me button in OPAC without selecting rating produces error
- [[16220]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16220) The view tabs on opac-detail.pl are not responsive
- [[16233]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16233) Unclosed <strong> tag in the opac-facets.inc breaks some display
- [[16296]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16296) Virtualshelves: Using no OPACXSLTResultsDisplay breaks content display
- [[16315]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16315) OPAC Shelfbrowser doesn't display the full title
- [[16328]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16328) datatables on opac-suggestions.pl broken by js error
- [[16340]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16340) JS variable in opac-bottom.inc is declared two times
- [[16343]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16343) 7XX XSLT subfields displaying out of order
- [[16478]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16478) Translation breaks display of Checkout history in tab Checkouts / On-site-checkouts
- [[16516]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16516) showListsUpdate JS function is not defined at the OPAC

### Packaging

- [[9754]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9754) koha-remove optionally includes var/lib and var/spool
- [[16396]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16396) Update package version for master packages

### Patrons

- [[9393]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9393) Add note to circulation.pl if borrower has pending modifications
- [[12267]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12267) Allow password option in Patron Attribute non functional
- [[12721]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12721) Prevent  software error if incorrect fieldnames given in sypref StatisticsFields
- [[14193]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14193) Accessibility: Searching patrons using the alphabetic index doesn't work
- [[14480]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14480) Warns when modifying patron
- [[14599]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14599) Saved auth login and password are used in patron creation from
- [[15195]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15195) patron details should open in tab
- [[15252]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15252) Patron search on start with does not work with several terms
- [[15353]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15353) patron image disappears when on fines tab
- [[15619]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15619) Spelling mistake in memberentry.pl
- [[15621]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15621) Spelling mistake in printinvoice
- [[15622]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15622) Spelling mistake in printfreercpt.pl
- [[15623]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15623) Spelling mistake in boraccount.pl
- [[15722]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15722) Patron search cannot deal with hidden characters ( tabs ) in fields
- [[15746]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15746) A random library is used to record an individual payment
- [[15795]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15795) C4/Members.pm is floody (Norwegian Patron DB)
- [[15823]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15823) Can still access patron discharge slip without having the syspref on - Permissions breach
- [[15928]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15928) Show unlinked guarantor
- [[16066]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16066) JavaScript error on new patron form when duplicate is suspected
- [[16211]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16211) Missing </th> tag in member.tt line 392
- [[16214]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16214) Surname not displayed in serials patron search results
- [[16285]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16285) write_age() function throws error for patron categories that don't include dateofbirth in form
- [[16447]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16447) "Borrow Permission" should not be used anymore

### Reports

- [[1750]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=1750) Report bor_issues_top erroneous and truncated results
- [[2669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=2669) Radio Buttons where there should be checkboxes on Dictionary
- [[13132]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13132) Adding confirm message for deleting a report from the reports toolbar
- [[15299]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15299) Add delete confirmation for deleting saved reports
- [[15366]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15366) Fix breadcrumbs and html page title in guided reports
- [[15416]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15416) Warns on Guided Reports page
- [[15421]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15421) Show all available actions in reports toolbar
- [[16184]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16184) Report bor_issues_top shows incorrect number of rows
- [[16185]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16185) t/db_dependent/Reports_Guided.t is failing
- [[16481]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16481) Report menu has unexpected issues

### SIP2

- [[13871]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13871) OverDrive message when user authentication fails
- [[15479]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15479) SIPserver rejects renewals for patrons with alphanumeric cardnumbers

### Searching

- [[9819]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9819) stopwords related code should be removed
- [[13022]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13022) Hardcoded limit causes records with more than 20 items to show inaccurate statuses

> If a record has more than 20 items, all the items over 20 will show as available on results even if they are not! This is a hard coded limit in the Search module. This is made configurable with the new system preference MaxSearchResultsItemsPerRecordStatu


- [[14816]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14816) Item search returns no results with multiple values selected for one field
- [[14991]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14991) Reword, clarify and add consistency to authority search
- [[15217]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15217) variables declared twice in in catalogue/search.pl
- [[15468]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15468) Search links on callnumbers with parentheses fails on OPAC results page
- [[15606]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15606) Spelling mistake in MARC21slim2OPACDetail.xsl
- [[15608]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15608) Spelling mistake in MARC21slim2OPACDetail.xsl
- [[15613]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15613) Spelling mistake: paramter vs parameter
- [[15616]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15616) Spelling mistake in opac-account.tt
- [[15694]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15694) Date/time-last-modified not searchable
- [[16041]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16041) StaffAuthorisedValueImages & AuthorisedValueImages preferences - impact on search performance
- [[16398]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16398) Keep expanded view after clearing the search form

### Self checkout

- [[11498]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11498) Prevent bypassing sco timeout with print dialog
- [[12663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12663) SCOUserCSS and SCOUserJS ignored on selfcheck login page

### Serials

- [[12748]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12748) Serials - two issues with status of "Expected"
- [[13877]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13877) seasonal predictions showing wrong in test
- [[14641]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14641) Warns in subscription-add.pl
- [[15605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15605) Accessibility: Can't tab to add link in serials routing list add user popup
- [[15657]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15657) follow-up for bug 15501 : add a missing semi-colon
- [[15838]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15838) syspref SubscriptionDuplicateDroppedInput does not work for all fields
- [[15981]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15981) Serials frequencies can be deleted without warning
- [[15982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15982) Serials numbering patterns can be deleted without warning

### Staff Client

- [[9387]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9387) Feedback message for FAILED check out items are not obvious for visually impaired
- [[11569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11569) Typo in userpermissions.sql
- [[14349]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14349) Checkouts and Fines tabs missing category description on the left
- [[14613]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14613) Send cart window is too small in staff and hides 'send' button
- [[15119]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15119) Hide search header text boxes on render
- [[15386]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15386) Checkout / patron pages: Hide menu items leading to 404 page
- [[15592]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15592) spelling mistake in ~/Koha/koha-tmpl/intranet-tmpl/p./plugins/plugins-upload.tt
- [[15609]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15609) spelling mistake in :692: writen  ==> written
- [[15611]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15611) Spelling mistake: implimented
- [[15614]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15614) Spelling mistake in circ/pendingreserves.tt: Fullfilled
- [[15808]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15808) Remove "Return to where you were before" from sysprefs
- [[16218]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16218) printfeercpt.tt (and others) does not include jQuery
- [[16270]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16270) Typo authentification vs authentication in 404

### System Administration

- [[14153]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14153) Noisy warns in admin/transport-cost-matrix.pl
- [[15009]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15009) Planning dropdown button in aqbudget can have empty line
- [[15101]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15101) Don't display system preference AllowPkiAuth under heading CAS Authentication
- [[15409]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15409) Plugins section missing from Admin menu sidebar
- [[15477]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15477) Error handling  on editing item type translations
- [[15568]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15568) Circ rules are not displayed anymore
- [[15603]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15603) Accessibility: Can't tab to select link in budgets add user popup
- [[15755]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15755) Default item type is not marked as "All" in circulation rules
- [[15773]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15773) Checkboxes do not work correctly when creating a new subfield for an authority framework
- [[15790]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15790) Don't delete a MARC framework if existing records use that framework
- [[15864]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15864) SMS cellular providers link missing from administration sidebar menu
- [[16012]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16012) The default authority type is not editable
- [[16013]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16013) Classification sources are not deletable
- [[16014]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16014) OAI sets can be deleted without warning
- [[16047]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16047) Software error on deleting a group with no category code

### Templates

- [[2016]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=2016) navigation bar in moredetail.pl not the same as in detail.pl
- [[11038]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11038) Enable use of IntranetUserCSS and intranetcolorstylesheet on staff client login page
- [[11937]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11937) opac link doesn't open in new window
- [[12152]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12152) Holds to pull report should show library and itype description instead of their codes
- [[15071]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15071) In OPAC search results, "checked out" status should be more visible
- [[15194]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15194) Drop-down menu 'Actions' has problem in 'Saved reports' page with language bottom bar
- [[15216]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15216) Display Branch names and itemtype descriptions on the returns page
- [[15228]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15228) Patron card batches - Improve translatability
- [[15229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15229) Tiny typo: This patrons is ...
- [[15306]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15306) Don't show translate link for item types if only one language is installed
- [[15327]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15327) Minor tweaks to Bootstrap modal handling on Staged MARC management page
- [[15354]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15354) item types aren't showing in default hold policies
- [[15396]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15396) MARC21 Leader plugin label '1-4 Record size' is wrong
- [[15469]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15469) Authority header search is broken
- [[15542]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15542) Patron's information are not always displayed the same way
- [[15597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15597) Typo in opac-auth-detail.tt
- [[15598]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15598) Typo in subscription-add.tt
- [[15600]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15600) System preferences broken toolbar looks broken
- [[15667]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15667) Messages in patron account display dates wrongly formatted
- [[15670]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15670) Rename "Cancel" to "Cancel hold" when checking in a waiting item
- [[15691]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15691) Show card number minimum and maximum in visible hint when adding a patron
- [[15693]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15693) Unnecessary punctuation mark when check-in an item in a library other than the home branch
- [[15784]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15784) Library deletion warning is incorrectly styled
- [[15804]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15804) Use standard dialog style for confirmation of MARC subfield deletion
- [[15844]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15844) Correct JSHint errors in staff-global.js
- [[15847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15847) Correct JSHint errors in basket.js in the staff client
- [[15880]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15880) Serials new frequency link should be a toolbar button
- [[15881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15881) Serials new numbering pattern link should be a toolbar button
- [[15884]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15884) Vendor contract deletion warning is incorrectly styled
- [[15920]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15920) Clean up and fix errors in batch checkout template
- [[15921]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15921) DataTables JavaScript files included twice on many pages
- [[15925]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15925) Correct some markup issues with patron lists pages
- [[15927]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15927) Remove use of <tr class="highlight"> for alternating row colors.
- [[15940]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15940) Remove unused JavaScript from authorities MARC subfield structure
- [[15941]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15941) The template for cloning circulation and fine rules says "issuing rules"
- [[15984]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15984) Correct templates which use the phrase "issuing rules"
- [[16022]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16022) Use Font Awesome icons on patron lists page
- [[16023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16023) Use Font Awesome icons on audio alerts page
- [[16024]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16024) Use Font Awesome icons on item types administration page
- [[16025]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16025) Use Font Awesome icons on item types localization page
- [[16026]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16026) Use Font Awesome icons on cataloging home page
- [[16027]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16027) Use Font Awesome icons in the professional cataloging interface
- [[16029]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16029) Do not show patron toolbar when showing the "patron does not exist" message
- [[16030]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16030) Automatic item modifications by age missing from admin sidebar
- [[16159]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16159) guarantor section missing ID on patron add form
- [[16225]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16225) Extra closing quote in circulation home page template.
- [[16230]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16230) Show tooltip with menu item when fund cannot be deleted
- [[16369]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16369) Clean up and improve plugins template
- [[16381]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16381) Fix capitalization on tags review page
- [[16415]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16415) Layout problem on staff client detail page if local cover images are enabled
- [[16439]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16439) Allow styling to button for upload local cover images (Font Awesome Icons)
- [[16451]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16451) Fix missing body id in orders_by_budget.tt
- [[16454]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16454) Use "inventory" instead of "inventory/stocktaking"
- [[16473]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16473) Tiny typo: there was _an_ problem ...
- [[16474]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16474) Standardize spelling of EDIFACT
- [[16480]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16480) Unclosed tag <span> in shelves on intranet

### Test Suite

- [[14097]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14097) Add unit tests to C4::UsageStats
- [[14144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14144) Silence warnings t/db_dependent/Auth_with_ldap.t
- [[14158]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14158) t/db_dependent/www/search_utf8.t hangs if error is returned
- [[14362]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14362) PEGI 15 Circulation/AgeRestrictionMarkers test fails
- [[15323]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15323) ./t/Prices.t fails without a valid database
- [[15391]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15391) HoldsQueue.t does not handle for loan itemtypes correctly
- [[15445]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15445) DateUtils.t fails on Jenkins due to server sluggishness
- [[15586]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15586) References to Koha::Branches remain in unit tests
- [[15947]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15947) SIPILS.t should be moved to t/db_dependent
- [[16134]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16134) t::lib::Mocks::mock_preference should be case-insensitive
- [[16172]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16172) OAI Server tests broken by bug 15946
- [[16174]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16174) Problems in icondirectories.t and tt_valid.t due to bug 15527
- [[16176]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16176) t/db_dependent/UsageStats.t is failing
- [[16177]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16177) Tests for ColumnsSettings are failing
- [[16178]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16178) Tests for xt/single_quotes.t are failing
- [[16191]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16191) t/Ris.t is noisy
- [[16216]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16216) Circulation_Branch.t doesn't set itemtype for test data
- [[16224]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16224) Random failure for t/db_dependent/Reports_Guided.t
- [[16249]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16249) Zebra-specific tests should pass with ES disabled
- [[16377]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16377) Fix t/db_dependent/Members/Attributes.t
- [[16390]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16390) Accounts.t does not need MPL
- [[16403]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16403) Fix Holds.t (tests 9 and 39)
- [[16404]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16404) Fix Circulation/Branch.t (tests 8-11)
- [[16405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16405) Fix Circulation/NoIssuesChargeGuarantees.t test 2
- [[16407]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16407) Fix Koha_borrower_modifications.t
- [[16408]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16408) Fix UsageStats.t
- [[16411]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16411) Make Hold.t not depend on two existing branches
- [[16423]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16423) Fix t/db_dependent/www/batch.t so it matches new layout
- [[16453]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16453) Elasticsearch tests should be skipped if configuration entry missing
- [[16501]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16501) Remove some unneeded warns in Upload.t

### Tools

- [[12636]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12636) Batch patron modification should not update with unique patron attributes
- [[14636]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14636) Sorting and searching by publication year in item search doesn't work correctly
- [[14810]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14810) Improve messages in patron anonymizing tool
- [[15398]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15398) Batch patron deletion/anonymization issue page: Restricted dropdown menu
- [[15602]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15602) Accessibility: Can't tab to add link in patron card creator add patrons popup
- [[15658]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15658) Browse system logs: Add more actions to action filter list
- [[15866]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15866) No warning when deleting a rotating collection using the toolbar button
- [[15868]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15868) Ask for confirmation before deleting MARC modification template action
- [[16004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16004) Replace items.new with items.new_status
- [[16033]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16033) Quotes upload preview broken for 973 days

### Web services

- [[15190]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15190) Bad utf8 decode to unapi and fixing code status 200
- [[15764]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15764) KOCT timestamp timezone problem
- [[15946]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15946) Broken link to LoC in MARCXML declaration for OAI-PMH ListMetadataFormats

### Z39.50 / SRU / OpenSearch Servers

- [[15298]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15298) z39.50 admin setup, options column suggested changes

## New sysprefs

- AllowHoldItemTypeSelection
- AllowPatronToSetCheckoutsVisibilityForGuarantor
- AllowStaffToSetCheckoutsVisibilityForGuarantor
- ClaimsBccCopy
- DefaultToLoggedInLibraryCircRules
- DefaultToLoggedInLibraryNoticesSlips
- DefaultToLoggedInLibraryOverdueTriggers
- EnablePayPalOpacPayments
- EnhancedMessagingPreferencesOPAC
- GoogleOAuth2ClientID
- GoogleOAuth2ClientSecret
- GoogleOpenIDConnect
- GoogleOpenIDConnectDomain
- HTML5MediaYouTube
- HoldFeeMode
- HoldsQueueSkipClosed
- IntranetCirculationHomeHTML
- IntranetReportsHomeHTML
- MaxSearchResultsItemsPerRecordStatusCheck
- NoIssuesChargeGuarantees
- OPACISBD
- OpacMaintenanceNotice
- OpacResetPassword
- OpenLibrarySearch
- PatronSelfModificationBorrowerUnwantedField
- PayPalChargeDescription
- PayPalPwd
- PayPalSandboxMode
- PayPalSignature
- PayPalUser
- SearchEngine
- ShowAllCheckins
- StoreLastBorrower
- decreaseLoanHighHoldsControl
- decreaseLoanHighHoldsIgnoreStatuses

## System requirements

Important notes:
    
- Perl 5.10 is required
- Zebra is required

## Documentation

The Koha manual is maintained in DocBook.The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://manual.koha-community.org//en/)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](http://git.koha-community.org/gitweb/?p=kohadocs.git;a=summary)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- English (USA)
- Arabic (96%)
- Armenian (97%)
- Chinese (China) (91%)
- Chinese (Taiwan) (99%)
- Czech (96%)
- Danish (75%)
- English (New Zealand) (100%)
- Finnish (94%)
- French (90%)
- French (Canada) (90%)
- German (100%)
- German (Switzerland) (100%)
- Italian (97%)
- Korean (56%)
- Kurdish (53%)
- Norwegian BokmÃ¥l (62%)
- Persian (62%)
- Polish (100%)
- Portuguese (93%)
- Portuguese (Brazil) (92%)
- Slovak (96%)
- Spanish (100%)
- Swedish (80%)
- Turkish (96%)
- Vietnamese (77%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 16.05.00 is

- Release Manager: [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
- QA Manager: [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
- QA Team:
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Jonathan Druart](mailto:jonathan.druart@biblibre.com)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
  - [Nick Clemens](mailto:nick@bywatersolutions.com)
  - [Jesse Weaver](mailto:jweaver@bywatersolutions.com)
- Bug Wranglers:
  - [Amit Gupta](mailto:amitddng135@gmail.com)
  - [Magnus Enger](mailto:magnus@enger.priv.no)
  - [Mirko Tietgen](mailto:mirko@abunchofthings.net)
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.in)
  - [Zeno Tajoli](mailto:z.tajoli@cineca.it)
  - [Marc Véron](mailto:veron@veron.ch)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Manager: [Nicole C. Engard](mailto:nengard@gmail.com)
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Wiki curators: 
  - [Brook](mailto:)
  - [Thomas Dukleth](mailto:kohadevel@agogme.com)
- Release Maintainers:
  - 16.05 -- [Frédéric Demians](mailto:f.demians@tamil.fr)
  - 3.22 -- [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - 3.20 -- [Chris Cormack](mailto:chrisc@catalyst.net.nz)

## Credits

We thank the following libraries who are known to have sponsored
new features in Koha 16.05.00:

- Alingsås Public Library, Sweden
- American Numismatic Society
- Briar Cliff University
- ByWater Solutions
- Catalyst IT
- Halland county library
- Halland County Library
- Hochschule für Gesundheit (hsg), Germany
- Orex Digital
- Regionbibliotek Halland / County library of Halland
- Universidad de El Salvador
- Universidad Empresarial Siglo 21
- Universidad Nacional de Córdoba
- Vaara-kirjastot

We thank the following individuals who contributed patches to Koha 16.05.00.

- Aleisha (113)
- Chloe (11)
- Gus (12)
- Liz (1)
- mxbeaulieu (1)
- Nick (1)
- Briana (3)
- Blou (5)
- Natasha (8)
- Jacek Ablewicz (3)
- Brendan A Gallagher (18)
- Alex Arnaud (15)
- Maxime Beaulieu (1)
- Gaetan Boisson (1)
- Colin Campbell (13)
- Barry Cannon (2)
- Frédérick Capovilla (1)
- Hector Castro (24)
- Nicole C. Engard (3)
- Francois Charbonnier (1)
- Galen Charlton (3)
- Barton Chittenden (5)
- Nick Clemens (30)
- Tomás Cohen Arazi (60)
- David Cook (2)
- Chris Cormack (11)
- Frédéric Demians (10)
- Marcel de Rooy (69)
- Jonathan Druart (415)
- Nicole Engard (2)
- Magnus Enger (4)
- Charles Farmer (7)
- Arslan Farooq (1)
- Bouzid Fergani (3)
- Julian FIOL (6)
- Katrin Fischer (33)
- Brendan Gallagher (35)
- Eivin Giske Skaaren (1)
- Bernardo González Kriegel (16)
- Mason James (9)
- Srdjan Jankovic (4)
- Olli-Antti Kivilahti (2)
- Joonas Kylmälä (3)
- Henri-Damien Laurent (1)
- Owen Leonard (143)
- Julian Maurice (31)
- Holger Meißner (3)
- Kyle M Hall (247)
- Thomas Misilo (1)
- Josef Moravec (1)
- Dobrica Pavlinusic (1)
- Martin Persson (5)
- Liz Rea (15)
- Martin Renvoize (4)
- Benjamin Rokseth (1)
- Winona Salesky (2)
- Viktor Sarge (1)
- Alex Sassmannshausen (2)
- John Seymour (1)
- Robin Sheat (52)
- Juan Sieira (1)
- Fridolin Somers (5)
- Martin Stenberg (1)
- Zeno Tajoli (4)
- Lari Taskula (2)
- Lyon3 Team (3)
- Mirko Tietgen (12)
- Mark Tompsett (30)
- Nicholas van Oudtshoorn (5)
- Marc Véron (68)
- Jesse Weaver (24)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.05.00.

- abunchofthings.net (12)
- ACPL (143)
- BibLibre (65)
- biblos.pk.edu.pl (3)
- BigBallOfWax (3)
- BSZ BW (33)
- bugs.koha-community.org (403)
- ByWater-Solutions (361)
- bywatersolutins.com (1)
- Catalyst (75)
- catalyst.net.z (4)
- Cineca (4)
- fit.edu (1)
- Hochschule für Gesundheit (hsg), Germany (3)
- interleaf.ie (2)
- jns.fi (2)
- koha-community.org (6)
- KohaAloha (9)
- Libeo (1)
- Libriotech (4)
- Marc Véron AG (68)
- nal.gov.au (1)
- Oslo Public Library (1)
- Prosentient Systems (2)
- PTFS-Europe (19)
- regionhalland.se (1)
- Rijksmuseum (69)
- rot13.org (1)
- Solutions inLibro inc (18)
- stacmail.net (12)
- student.uef.fi (2)
- sysmystic.com (1)
- Tamil (10)
- Theke Solutions (40)
- unidentified (213)
- Universidad Nacional de Córdoba (36)
- Université Jean Moulin Lyon 3 (3)
- Xercode (1)
- xinxidi.net (1)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha (33)
- Alex (1)
- Arslan Farooq (3)
- Barry Cannon (1)
- Barton Chittenden (1)
- Benjamin Rokseth (7)
- Brendan Gallagher (213)
- Briana (4)
- Carol Corrales (1)
- Cathi Wiggin (1)
- Cathi Wiggins (3)
- Chris (10)
- Chris Cormack (50)
- Chris Davis (1)
- Christian Stelzenmüller (1)
- Christopher Brannon (4)
- Chris William (4)
- Dani Elder (1)
- Danielle Aloia (1)
- David Cook (1)
- Galen Charlton (6)
- hbraum@nekls.org (1)
- Heather Braum (3)
- Hector Castro (142)
- Hugo Agud (1)
- Jacek Ablewicz (19)
- Jason Burds (1)
- Jason DeShaw (1)
- Jen DeMuth (1)
- Jesse Maseto (2)
- Jesse Weaver (165)
- JM Broust (2)
- Jonathan Druart (622)
- Joonas Kylmälä (16)
- Josef Moravec (26)
- Julian Maurice (2)
- Julius Fleschner (1)
- jvr (1)
- Karam Qubsi (1)
- Katrin Fischer (355)
- Liz (1)
- Liz Rea (6)
- Lucio Moraes (1)
- Magnus Enger (4)
- Marc Veron (16)
- Marc Véron (230)
- Margaret Holt (2)
- Marjorie (1)
- Mark Tompsett (99)
- Martin Persson (2)
- Martin Renvoize (30)
- Mason James (2)
- Megan Wianecki (3)
- Michael Sauers (2)
- Mirko Tietgen (27)
- Natasha (2)
- Nick Clemens (126)
- Nicole Engard (7)
- Olli-Antti Kivilahti (1)
- Owen Leonard (115)
- Paul Johnson (2)
- Paul Landers (4)
- Paul Poulain (1)
- Philippe Blouin (2)
- Sally Healey (5)
- Srdjan (9)
- Thomas Misilo (1)
- Tom Misilo (2)
- Cindy Murdock Ames (3)
- Tomas Cohen Arazi (183)
- Bob Ewart bob-ewart@bobsown.com (1)
- Brendan Gallagher brendan@bywatersolutions.com (416)
- Nicole C Engard (18)
- Brendan A Gallagher (435)
- Indranil Das Gupta (L2C2 Technologies) (4)
- Kyle M Hall (753)
- Bernardo Gonzalez Kriegel (101)
- Andreas Hedström Mace (3)
- Your Full Name (1)
- juliette et remy (3)
- Marcel de Rooy (127)
- Juan Romay Sieira (1)
- Eivin Giske Skaaren (1)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

### Thanks

- Mom you were an inspiration as a library director and you challenged
us all to create the change that we wanted to see.  May your words help
motivate librarians to be a community and be united in erasing limitations
for disseminating information.

### Special thanks from the Release Manager
I'd like to thank everyone in the community, especially Kyle and JesseW (piano),
for never giving up and helping me through each step of this release!  Hear! Hear!
I'd also like to thank Tomás and Chris for assiting me as a first time RM and
showing me the ropes.  Jonathan and Katrin your endless bug testing and QAing
is wonderful motivation for us all - Thank you so much for all you do!

To my lovely wife Sonja, for putting up with so many late nights
so I could push that last piece of code or test one last thing.  Thank 
you for being patient and volunteering so much of our time so we could 
have an awesome release!!!

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is master.


## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 26 May 2016 03:30:36.
