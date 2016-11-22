# RELEASE NOTES FOR KOHA 16.11.00
22 Nov 2016

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 16.11.00 can be downloaded from:

- [Download](http://download.koha-community.org/koha-16.11.00.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 16.11.00 is a major release, that comes with many new features.

It includes 6 new features, 246 enhancements, 410 bugfixes.

## Deprecation notice

Support for Debian 7 ( Wheezy ) is officially deprecated. It is highly recommended that Debian 8 ( Jessie ) be used for upgrades and new installations.

## New features

### Holds
- [[14695]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14695) Add ability to place multiple item holds on a given record per patron
> Koha now supports the ability for a patron to place multiple holds on a single bibliographic record, with the type and limits configurable as circulation rules.
> This new functionality is especially useful for records with heterogeneous items, where a patron may need to request multiple specific items.

- [[5260]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5260) Add option to send an order by e-mail to the acquisition module
> It will be possible to send order information to the vendor by e-mail. For now this feature can be triggered manually with a button before closing the basket.
The order e-mail is based on the acquisition claim feature, but uses a new notice template: ACQORDER.

### Cataloging

- [[14793]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14793) New cataloguing plugin unimarc_field_225a_bis

### Circulation

- [[14610]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14610) Add ability to place article requests in Koha

### Patrons
- [[3534]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3534) Patron quick add form
> This patch adds a new system preference: PatronQuickAddFields When either this pref or BorrowerMandatoryField is populated this will add a new dropdown to the bew patron toolbar.
> When a category is chosen from this dropdown the fields in PatronQuickAddFields and BorrowerMandatoryField will be displayed.
> There will be a button allowing a user to switch from the quickadd to the full form and fields will be copied between the forms when toggling.
> The Quick add will only be displayed on add of a new patron, future edits should display the full form.

- [[5670]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5670) Housebound Readers Module
> The Housebound module is an addition to Koha to allow the library to link together housebound patrons, volunteers, delivers and book choosers.
> Ability to create housebound profiles & scheduled visits for patrons.
> Ability to record users as Deliverers or Choosers (or both), using extended patron attributes.
> Ability to link choosers and deliverers to individual delivery runs.
> 'Delivery Frequencies' are customizable through authorised values ('HSBND_FREQ').

## Enhancements

### Acquisitions

- [[7039]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7039) Link to existing record from result list in acquisition search
- [[9896]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9896) Show vendor in subscription search when creating an order for a subscription
- [[13321]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13321) Fix tax and prices calculation
- [[13323]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13323) Change the tax rate on receiving
- [[14752]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14752) Add multiple copies to a basket at once
- [[15128]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15128) Add ability to limit the number of open purchase suggestions a patron can make
- [[15164]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15164) Allow editing of the invoice number after initial saving
- [[16123]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16123) Display budget hierarchy in the budget dropdown menu used when placing a new order
- [[16511]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16511) Make contracts actions buttons
- [[16525]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16525) Add cancel button when adding a new acq budget
- [[16738]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16738) Improve EDIFACT messages template
- [[16841]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16841) Help for Library EANs
- [[16842]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16842) Help for EDI accounts
- [[16843]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16843) Help for EDIFACT messages
- [[16981]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16981) Add EDI admin links to acq menu
- [[17414]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17414) Add GIR codes added to Edifact since 1.2

### Architecture, internals, and plumbing

- [[11921]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11921) Move memcached configuration back to koha-conf.xml
- [[15407]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15407) Move the patron categories related code to Koha::Patron::Categories - part 2
- [[15451]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15451) Move the CSV related code to Koha::CsvProfile[s]
- [[15758]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15758) Move the C4::Branch related code to Koha::Libraries - part 4
- [[15801]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15801) Move the framework related code to Koha::BiblioFramework[s] - part 2
- [[15803]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15803) Koha::AuthorisedValues - Remove GetAuthorisedValueCategories
- [[15839]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15839) Move the reviews related code to Koha::Reviews
- [[15895]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15895) Add Koha::Account module, use Koha::Account::pay internally for recordpayment
- [[15899]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15899) Remove the use of recordpayment
- [[15900]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15900) Remove use of recordpayment in ProcessOfflinePayment
- [[15901]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15901) Remove use of recordpayment in C4::SIP::ILS::Transaction::FeePayment
- [[15902]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15902) Remove use of recordpayment in process_koc.pl
- [[15903]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15903) Remove use of recordpayment in paycollect.pl
- [[16166]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16166) Improve L1 cache performance and safety
- [[16365]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16365) Selectively introduce GetMarcStructure() "unsafe" variant for better performance
- [[16436]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16436) Allow action logs to be logged to the koha log file
- [[16519]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16519) Do not use global variables in [opac-]addbybiblionumbers.pl
- [[16586]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16586) Koha Plugins: Limit results of GetPlugins by metadata
- [[16672]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16672) Add ability to remove expired holidays from special_holidays
- [[16685]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16685) Use eval instead of do for .perl atomicupdates
- [[16693]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16693) reserve/renewscript.pl is not used and should be removed
- [[16715]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16715) Koha::Cache - Use Sereal for serialization
- [[16769]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16769) Koha::Cache->set_in_cache calls need to be standardised
- [[16770]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16770) Remove wrong uses of Memoize::Memcached
- [[16819]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16819) C4::Members::DelMember should use Koha::Holds to delete holds
- [[16847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16847) Remove C4::Members::GetTitles
- [[16849]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16849) Move IsDebarred to Koha::Patron->is_debarred
- [[16850]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16850) Move IsMemberBlocked to Koha::Patron
- [[16851]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16851) Move HasOverdues to Koha::Patron->has_overdues
- [[16852]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16852) Remove C4::Members::GetBorrowerCategorycode
- [[16853]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16853) Move changepassword to Koha::Patron->update_password
- [[16891]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16891) Move MoveMemberToDeleted to Koha::Patron->move_to_deleted
- [[16907]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16907) Move DelMember and HandleDelBorrower to Koha::Patron
- [[16908]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16908) Koha::Patrons - Remove GetSortDetails
- [[16909]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16909) Koha::Patrons - Remove checkuniquemember
- [[16911]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16911) Koha::Patrons - Move ExtendMemberSubscriptionTo to ->renew_account
- [[16912]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16912) Koha::Patrons - Move AddEnrolmentFeeIfNeeded to add_enrolment_fee_if_needed
- [[16913]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16913) C4::Members::GetBorrowersNamesAndLatest is not used
- [[16961]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16961) Add the Koha::Objects->update method
- [[16965]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16965) Add the Koha::Objects->search_related method
- [[17080]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17080) Koha::Object->new should handle default values for NOT NULL columns
- [[17089]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17089) Move the star ratings related code to Koha::Ratings
- [[17091]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17091) Add AUTOLOAD to Koha::Objects
- [[17094]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17094) Methods of Koha::Object[s]-based classed should not return DBIx::Class objects
- [[17099]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17099) GetSupportName and GetSupportList from C4/Koha.pm are no longer used
- [[17110]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17110) Lower CSRF expiry in Koha::Token
- [[17189]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17189) Add the ability to define several memcached namespaces
- [[17193]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17193) C4::Search::SearchAcquisitions is not used
- [[17197]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17197) misc/batchupdateISBNs.pl is certainly no longer in use
- [[17216]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17216) Add a new table to store authorized value categories
- [[17226]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17226) Improve AUTOLOAD of Koha::Object
- [[17248]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17248) Koha::AuthorisedValues - Remove GetKohaAuthorisedValueLib
- [[17249]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17249) Koha::AuthorisedValues - Remove GetKohaAuthorisedValuesFromField
- [[17250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17250) Koha::AuthorisedValues - Remove GetAuthValCode
- [[17251]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17251) Koha::AuthorisedValues - Remove GetKohaAuthorisedValuesMapping
- [[17252]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17252) Koha::AuthorisedValues - Remove GetAuthorisedValueByCode
- [[17253]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17253) Koha::AuthorisedValues - Remove GetKohaAuthorisedValues
- [[17274]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17274) Add info about which memcached config is used to about.pl
- [[17302]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17302) Add Koha::Util::Normalize for normalization functions
- [[17356]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17356) Add atomic update .perl skeleton file
- [[17425]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17425) Koha::Object should raise exceptions
- [[17555]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17555) Add Koha::Patron->category
- [[17579]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17579) Add the Koha::Patron->is_expired method
- [[17594]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17594) Make Koha::Object->discard_changes available
- [[17599]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17599) Move C4::Circulation::GetIssuingRule to Koha::IssuingRules->get_effective_issuing_rule
- [[17604]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17604) Add the Koha::Patron::Category->effective_BlockExpiredPatronOpacActions method
- [[17651]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17651) t/db_dependent/api/v1/patrons.t is failing

### Cataloging

- [[6499]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6499) MARC21 035 -- Other-control-number --  Indexing & Matching
- [[7741]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7741) Clear search terms in Z3950 search page
- [[9259]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9259) Delete marc batches from staged marc management
- [[13501]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13501) Allow autocompletion on drop-down lists
- [[14629]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14629) Add aggressive ISSN matching feature equivalent to the aggressive ISBN matcher

### Circulation

- [[3669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3669) Create a template for circ/add_message.pl
- [[6906]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6906) Show 'Borrower has previously issued $ITEM' alert on checkout
- [[9543]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9543) Show patrons messaging subscription on holds notification
- [[11360]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11360) Disable barcode field and submit button when a hold is found
- [[13134]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13134) Add patron category to returns confirmation dialogs
- [[14048]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14048) Change RefundLostItemFeeOnReturn to be branch specific
- [[14668]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14668) Show serial enumeration in the patron's opac checkout summary
- [[15172]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15172) Serial enumchron/sequence not visible when returning/checking in Items
- [[15581]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15581) Add a circ rule to not allow auto-renewals after defined loan period
- [[16272]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16272) Transform checkout from on-site checkout to regular checkout
- [[16531]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16531) Circ overdues report is showing an empty table if no overdues
- [[16566]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16566) 'Print slip' button formatting inconsistent
- [[17331]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17331) Show holding branch in holds awaiting pickup report
- [[17397]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17397) Show name of librarian who created circulation message

### Command-line Utilities

- [[10337]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10337) Add a script to insert all sample data automatically
- [[14504]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14504) Add command-line script to batch delete items based on data in items table
- [[17444]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17444) Export by date and time in export_record.pl
- [[17459]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17459) Add a script to create a superlibrarian user

### Course reserves

- [[15853]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15853) Add author and link columns to opac course reserves table
- [[16651]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16651) Notes field blank for 952$z in opac-course-details.pl

### Hold requests

- [[8030]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8030) Change pickup location of a hold from patron record
- [[14642]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14642) Add logging of hold modifications
- [[16336]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16336) UX of holds patron search with long lists of results

### I18N/L10N

- [[16687]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16687) Translatability: Fix issues with sentence splitting in Administration preferences
- [[16952]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16952) Add sorting rules for Czech language to Zebra
- [[17543]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17543) Update German web installer sample files for 16.11

### Installation and upgrade (command-line installer)

- [[17567]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17567) populate_db.pl should initialize ES mappings

### Lists

- [[15485]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15485) Allow choosing different XSLTs for lists

### MARC Bibliographic data support

- [[16472]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16472) Update MARC21 de-DE frameworks to Update 22 (April 2016)
- [[16601]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16601) Update MARC21 it-IT frameworks to Update 22 (April 2016)
- [[17318]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17318) Make 'Normalization rule' configurable on matchpoint definition

### MARC Bibliographic record staging/import

- [[10407]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10407) Allow MARCXML records to be imported with Tools/Stage MARC records for import

### Notices

- [[14757]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14757) Allow the use of Template Toolkit syntax for slips and notices

### OPAC

- [[5456]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5456) Create a link to opac-ics.pl
- [[10848]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10848) Allow configuration of mandatory/required fields on the suggestion form in OPAC
- [[15388]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15388) Show Syndetics covers by UPC in search results
- [[16507]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16507) Show play media tab first
- [[16551]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16551) Display the name of lists to the search results at the OPAC
- [[16552]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16552) Add the ability to change the default holdings sort
- [[16641]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16641) Update Novelist in opac to use updated call to fetch content
- [[16875]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16875) OPAC:  Removing link to records if authority is not used by any records
- [[16876]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16876) Remove Full heading column in OPAC Authority search
- [[17109]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17109) sendbasket: Remove second authentication, add CSRF token
- [[17191]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17191) Confirm message on deleting tag in OPAC
- [[17220]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17220) Improve clarity when placing a hold by changing button text from "Place hold" to "Confirm hold"

### Packaging

- [[16647]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16647) Update debian/control for 16.*
- [[17013]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17013) build-git-snapshot: add basetgz parameter and update master version number
- [[17019]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17019) debian/changelog update
- [[17030]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17030) Configure the REST api on packages install

### Patrons

- [[10760]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10760) Use Street Number and Street type in Alternate Address section
- [[12402]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12402) Show more on pending patron modification requests
- [[14874]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14874) Add ability to search for patrons by date of birth from checkout and patron quick searches
- [[16273]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16273) Prevent selfregistration from printing the borrower password and filling the logging form
- [[16274]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16274) Make the selfregistration branchcode selection configurable
- [[16275]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16275) Prevent patron self registration if the email already filled in borrowers.email
- [[16276]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16276) When automatically deleting expired borrowers, make sure they didn't log in recently
- [[16729]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16729) Use member-display-address-style*-includes when printing user summary
- [[16730]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16730) Use member-display-address-style*-includes in moremember-brief.tt
- [[17154]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17154) Note column is missing on account lines receipt
- [[17443]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17443) Make possible to renew patron by later of expiry and current date

### Reports

- [[6934]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6934) New report Cash Register Statistics
- [[7679]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7679) Add new filters to circulation statistics wizard
- [[14435]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14435) Recover feature to store and access results of a report
- [[16388]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16388) Move option to download report into reports toolbar
- [[16978]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16978) Add delete reports user permission
- [[17341]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17341) Enhance the report action button on guided_reports.pl

### SIP2

- [[13807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13807) SIPServer Input loop not checking for closed connections reliably

### Searching

- [[13949]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13949) Add holding library to item search
- [[14899]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14899) Mapping configuration page for Elastic search
- [[14902]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14902) Add qualifier menu to staff side "Search the Catalog"

> The main OPAC search has a qualifier menu available (the Search: Library Catalog/Title/Author/Subject/ISBN/Series/Call Number menu). Now the staff side had this option available, too. Show/Not show with syspref 'IntranetCatalogSearchPulldown'.


- [[16524]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16524) Use floating toolbar on item search

### Self checkout

- [[15131]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15131) Give SCO separate control for AllowItemsOnHoldCheckout
- [[16732]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16732) Add audio alerts (custom sound notifications) to web based self checkout
- [[17386]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17386) Add opac notes for patron to self checkout screen

### Serials

- [[7677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7677) Subscriptions: Ability to define default itemtype and automatically change itemtype of older issues on receive of next issue
- [[16289]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16289) Abbreviated formatting for numbering patterns
- [[16745]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16745) Add edit catalog and edit items links to serials toolbar
- [[16874]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16874) Making serials collections actions buttons
- [[16950]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16950) Serials subscriptions advanced search shows '0 found' pre-search
- [[17165]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17165) Improve heading on vendor search when searching for all vendors in Serials
- [[17402]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17402) Enhance the actions button on serials-search.pl

### Staff Client

- [[14790]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14790) Link to OPAC view from within subscriptions, search and item editor
- [[16324]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16324) Move item search into header

### System Administration

- [[16165]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16165) Include link to ILS-DI documentation page in ILS-DI system preference
- [[16768]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16768) Add official number format for Switzerland: 1'234'567.89
- [[16945]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16945) Syspref PatronSelfRegistration: Add note about setting PatronSelfRegistrationDefaultCategory
- [[17162]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17162) Moving MARC tags structure actions into a drop down menu
- [[17163]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17163) Making MARC subfields structure actions buttons
- [[17173]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17173) Quick edit a subfield in frameworks
- [[17187]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17187) Lower the timeout preference from 139 days to 1 day
- [[17261]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17261) Add memcached configuration info to about.pl

### Templates

- [[11606]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11606) Novelist Select in Staff Client
- [[15975]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15975) Add Home Library Column to Checkouts
- [[16005]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16005) Standardize use of icons for delete and cancel operations
- [[16127]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16127) Add discharge menu item to patron toolbar
- [[16148]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16148) Revised layout and behavior of marc modification template management
- [[16310]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16310) Remove the use of "onclick" from audio alerts template
- [[16400]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16400) Proposal to uniform the placement of submit buttons
- [[16437]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16437) Automatic item modifications by age needs prettying
- [[16450]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16450) Remove the use of "onclick" from guarantor search template
- [[16456]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16456) Add Font Awesome icons to some buttons in Tools module, section Patrons and circulation
- [[16468]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16468) Remove last "onclick" from the stage MARC records template
- [[16469]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16469) Remove the use of "onclick" from some catalog pages
- [[16477]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16477) Improve staff client cart JavaScript and template
- [[16490]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16490) Add an "add to cart" link for each search results in the staff client
- [[16494]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16494) Remove the use of "onclick" from some patron pages
- [[16538]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16538) Improve the style of progress bars
- [[16541]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16541) Make edit and delete links styled buttons in cities administration
- [[16543]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16543) Make edit and delete links styled buttons in patron attribute types administration
- [[16549]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16549) Remove the use of "onclick" from header search forms
- [[16557]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16557) Remove the use of "onclick" from several include files
- [[16576]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16576) Remove the use of "onclick" from label templates
- [[16592]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16592) Use Bootstrap modal for MARC and Card preview on acquisitions receipt summary page
- [[16602]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16602) Remove the use of "onclick" from several templates
- [[16677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16677) Use abbr for authorities linked headings
- [[16752]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16752) Remove the use of event attributes from some acquisitions templates
- [[16772]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16772) Change label from 'For:' to 'Library:' to ease translation
- [[16778]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16778) Use Bootstrap modal for card printing on patron lists page
- [[16801]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16801) Include Font Awesome Icons to check/unchek all in Administration > Library transfer limits
- [[16906]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16906) Add DataTables pagination and filter to top of saved SQL reports table
- [[16937]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16937) Remove the use of "onclick" from the manage staged MARC records template
- [[16938]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16938) Remove the use of "onclick" from batch patrons modification template
- [[16946]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16946) Remove the use of "onclick" from several serials templates
- [[16963]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16963) Remove the use of "onclick" from subscription add template
- [[16967]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16967) Remove the use of "onclick" from serial frequency and numbering management
- [[16968]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16968) Remove the use of "onclick" from serial patron and vendor search templates
- [[16995]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16995) Remove event attributes from two include files
- [[17011]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17011) Remove "onblur" event attribute from some templates
- [[17012]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17012) Remove more event attributes from administration templates
- [[17056]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17056) Remove event attributes from various templates
- [[17083]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17083) Remove more event attributes from tools templates
- [[17112]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17112) Action buttons for course reserves detail page
- [[17210]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17210) Remove use of onclick from biblio detail sidebar in OPAC
- [[17211]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17211) Remove use of onclick from OPAC fines page
- [[17222]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17222) Remove use of onclick from OPAC member entry page

### Test Suite

- [[13691]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13691) Add some selenium scripts
- [[16866]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16866) Catch warning t/db_dependent/Languages.t
- [[17304]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17304) C4::Matcher::_get_match_keys is not tested
- [[17539]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17539) t/db_dependent/Reserves.t is failing

### Tools

- [[15023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15023) Allow patron anonymize/bulk delete tool to be limited by branch
- [[15213]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15213) Fix tools sidebar to highlight Patron lists when in that module
- [[16513]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16513) Improvements and fixes for quote upload process
- [[16681]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16681) Allow update of opacnote via batch patron modification tool
- [[17147]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17147) Streamline messages following batch record modification
- [[17161]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17161) Making 'preview MARC' links show as buttons in batch record mod
- [[17183]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17183) Koha News 'delete selected' function doesn't check if anything has been selected
- [[17301]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17301) Add callnumber to label-edit-batch.pl

### Transaction logs

- [[16829]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16829) action_logs should have an 'interface' column

### Web services

- [[14868]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14868) REST API: Swagger2-driven permission checking
- [[16212]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16212) Swagger specification separation and minification
- [[16271]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16271) Allow more filters on /api/v1/holds
- [[16699]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16699) Swagger: Split parameters and paths, and specify required permissions for resource
- [[17032]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17032) REST API tests: Make sure Swagger object definition is up-to-date with database
- [[17428]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17428) REST API: CRUD endpoint for cities
- [[17431]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17431) Fix failing test t/db_dependent/api/v1/holds.t
- [[17432]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17432) Remove requirement to minify swagger.json
- [[17445]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17445) REST API: Generic handling of malformed query parameters

### Z39.50 / SRU / OpenSearch Servers

- [[17174]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17174) Making z39.50 authority search actions buttons


## Critical bugs fixed

(this list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### About

- [[17177]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17177) Can't locate Koha/Config/SysPrefs.pm in @INC on intranet about page

### Acquisitions

- [[16493]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16493) acq matching on title and author

### Architecture, internals, and plumbing

- [[16443]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16443) C4::Members::Statistics is not plack safe
- [[16518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16518) opac-addbybiblionumber is not plack safe
- [[16556]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16556) KohaToMarcMapped columns sharing same field with biblio(item)number are removed.
- [[16716]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16716) Invalid SQL GROUP BY clauses in GetborCatFromCatType and GetAuthorisedValues
- [[17048]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17048) Authority search result list page scrolling not working properly
- [[17050]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17050) Accessing the REST API through Plack kicks the session out
- [[17332]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17332) Memcached configuration missing in koha-conf* files
- [[17494]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17494) Koha generating duplicate self registration tokens
- [[17548]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17548) Step 1 of memberentry explodes
- [[17558]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17558) Fix t/db_dependent/Koha/Patron/Messages.t
- [[17642]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17642) Authorised values code is broken because of the refactoring
- [[17644]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17644) t/db_dependent/Exporter/Record.t fails
- [[17659]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17659) sample_notices.sql is broken for fr-QA

### Authentication

- [[17481]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17481) Cas Logout: bug 11048 has been incorrectly merged

### Cataloging

- [[10148]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10148) 007 not filling in with existing values
- [[14844]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14844) Corrupted storable string. When adding/editing an Item, cookie LastCreatedItem might be corrupted.
- [[15974]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15974) Rancor - 942c is always displaying first in the list.
- [[17023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17023) z3950_search.pl are vulnerable to XSS attacks
- [[17072]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17072) 006 not filling in with existing values
- [[17285]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17285) Rancor - Advanced editor fails or broken
- [[17477]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17477) Duplicating a subfield yields an empty subfield tag

### Circulation

- [[14390]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14390) Fine not updated from 'FU' to 'F' on renewal
- [[14598]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14598) itemtype is not set on statistics by C4::Circulation::AddReturn
- [[16527]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16527) Sticky due date calendar unexpected behaviour
- [[16534]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16534) Error when checking out already checked out item (depending on AllowReturnToBranch)
- [[16570]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16570) All checked-in items are said to be part of a rotating collection
- [[17036]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17036) circulation.pl is vulnerable to XSS attacks
- [[17135]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17135) Fine for the previous overdue may get overwritten by the next one
- [[17524]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17524) Datepicker on checkout fails when dateformat = iso

### Command-line Utilities

- [[11144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11144) Fix sequence of cronjobs: automatic renewal - fines - overdue notices
- [[17376]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17376) rebuild_zebra.pl in daemon mode no database access kills the process

### Hold requests

- [[16942]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16942) Confirm hold results in ugly error
- [[16988]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16988) Suspending a hold with AutoResumeSuspendedHolds disabled results in error
- [[17010]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17010) Canceling a hold awaiting pickup no longer alerts librarian about next hold
- [[17028]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17028) request.pl is vulnerable to XSS attacks
- [[17327]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17327) Item level holds no longer enforced

### Installation and upgrade (command-line installer)

- [[17292]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17292) Use of DBIx in updatedatabase.pl broke upgrade (from bug 12375)

### Installation and upgrade (web-based installer)

- [[16554]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16554) Web installer fails to load i18n sample data on MySQL 5.6+
- [[16573]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16573) Web installer fails to load structure and sample data on MySQL 5.7
- [[16619]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16619) Installer stuck in infinite loop
- [[16678]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16678) updatedatabase.pl 3.23.00.006 DB upgrade crashes if subscription_numberpatterns.numberingmethod contains parentheses
- [[16920]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16920) sysprefs.sql - missing comma for MaxOpenSuggestions
- [[17324]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17324) branchcode is NULL in letter triggers red upgrade message
- [[17345]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17345) Typo in sysprefs.sql prevents all systempreferences from being installed
- [[17576]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17576) Add HSBND_FREQ authorised value to translated installer sample files

### Label/patron card printing

- [[16747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16747) Fix regression in patron card creator (patron image)

### OPAC

- [[7441]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7441) Search results showing wrong branch
- [[11592]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11592) opac detail scripts do not respect MARC tag visibility
- [[16593]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16593) Access Control - Malicious user can delete the search history of another user
- [[16680]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16680) Library name are not displayed for holds in transit
- [[16686]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16686) Fix "Item in transit from since" in Holds tab
- [[16707]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16707) Software Error in OPAC password recovery when leaving form fields empty
- [[16918]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16918) opac-main.pl is not running under plack
- [[16958]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16958) opac-imageviewer.pl is vulnerable to XSS
- [[16996]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16996) Template process failed: undef error - Can't call method "description"
- [[17392]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17392) opac/svc/overdrive_proxy is not plack safe
- [[17393]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17393) selfreg - Patron's info are not correctly inserted if contain non-Latin characters
- [[17484]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17484) Searching with date range limit (lower and upper) does not work
- [[17522]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17522) opac-user.pl gives error of OpacRenewalAllowed is enabled

### Packaging

- [[16617]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16617) debian/control is broken

### Patrons

- [[11217]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11217) The # in accountlines descriptions makes them un-writeoffable
- [[16504]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16504) All borrower attribute values for a given code deleted if that attribute has branch limits
- [[16941]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16941) Can not add new patron in staff client
- [[16960]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16960) Patron::Modifications should be fixed
- [[17069]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17069) Can't create new patron category on the intranet
- [[17384]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17384) Categories do not display in patron editing form if they have only one category assigned
- [[17403]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17403) Internal Server Error while deleting patron

### Reports

- [[13914]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13914) The holds statistics report returns random data
- [[17495]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17495) reports/issues_stats.pl is broken

### SIP2

- [[16492]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16492) Checkouts ( and possibly checkins and other actions ) will use the patron home branch as the logged in library
- [[16610]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16610) Regression in SIP2 user password handling

### Searching

- [[16838]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16838) Elasticsearch - mapping tables are not populated on new installs
- [[17029]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17029) *detail.pl are vulnerable to XSS attacks
- [[17038]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17038) search.pl is vulnerable to XSS attacks
- [[17323]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17323) MySQL 5.7 - Column search_history.time cannot be null
- [[17377]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17377) ES - control fields are not taken into account

### Serials

- [[17026]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17026) checkexpiration.pl is vulnerable to XSS attacks
- [[17295]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17295) Missed variable removal in subscription-add.pl from Bug 15758

### Staff Client

- [[16947]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16947) Can not modify patron messaging preferences
- [[16955]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16955) Internal Server Error while populating new framework
- [[17022]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17022) branchtransfers.pl is vulnerable to XSS attacks

### System Administration

- [[17308]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17308) 'New patron attribute type' button does not work
- [[17389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17389) Exporting framework always export the default framework
- [[17582]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17582) Cannot edit an authority framework

### Tools

- [[16917]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16917) Error when importing patrons, Column 'checkprevcheckout' cannot be null
- [[17024]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17024) viewlog.pl is vulnerable to XSS attacks
- [[17420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17420) record export fails when itemtype on biblio

### Web services

- [[17336]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17336) api_secret_passphrase missing in packages setup

### About

- [[7143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7143) Bug for tracking changes to the about page
- [[13405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13405) System information has misleading information about indexing mode

### Acquisitions

- [[13324]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13324) [DEPENDS_ON_13321] The fund values must be based on tax included values
- [[16736]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16736) Keep library filter when changing suggestion
- [[16737]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16737) Error when deleting EDIFACT message
- [[16934]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16934) Cannot add notes to canceled and deleted order line
- [[16953]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16953) Acquisitions home: Remove trailing &rsaquo; from breadcrumbs
- [[17081]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17081) Incorrect comparison operator used in edifactmsgs.pl
- [[17141]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17141) Incorrect method called in edi_cron to get logdir

### Architecture, internals, and plumbing

- [[10455]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10455) remove redundant 'biblioitems.marc' field
- [[12633]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12633) SQLHelper replacement - C4::Members
- [[13074]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13074) C4::Items::_build_default_values_for_mod_marc should use Koha::Cache
- [[14060]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14060) Remove readonly on date inputs
- [[14707]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14707) Change UsageStatsCountry from free text to a dropdown list
- [[15690]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15690) Unconstrained CardnumberLength preference conflicts with table column limit of 16
- [[16088]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16088) Excessive CGI->new() calls hurting cache performace under plack
- [[16428]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16428) The framework is not checked to know if a field is mapped
- [[16431]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16431) Marc subfield structure should be cached using Koha::Cache
- [[16441]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16441) C4::Letters::getletter is not plack safe
- [[16442]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16442) C4::Ris is not plack safe
- [[16444]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16444) C4::Tags is not plack safe
- [[16449]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16449) unimarc_field_4XX raises a warning
- [[16455]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16455) TagsExternalDictionary does not work under Plack
- [[16502]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16502) Table koha_plugin_com_bywatersolutions_kitchensink_mytable not always dropped after running Plugin.t
- [[16520]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16520) Per-virtualhost SetEnvs don't work with Plack
- [[16565]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16565) additional_fields and additional_field_values are not dropped in kohastructure.sql
- [[16578]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16578) Wide character warning in opac-export.pl when utf8 chosen
- [[16644]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16644) Plack: Use to_app to remove warning about Plack::App::CGIBin instance
- [[16667]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16667) Unused variable and function call in circulation.pl
- [[16670]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16670) CGI->param used in list context
- [[16671]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16671) Wrong itemtype picked in HoldsQueue.t
- [[16708]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16708) ElasticSearch - Fix authority reindexing
- [[16720]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16720) DBIx ActionLogs.pm should be removed
- [[16724]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16724) Link from online help to manual broken (as of version 16.05)
- [[16731]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16731) Use INSERT IGNORE when inserting a syspref
- [[16741]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16741) Remove dead code "sub itemissues" from C4/Circulation.pm
- [[16742]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16742) Remove unused template subject.tt
- [[16751]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16751) Fix sitemaper typo
- [[16844]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16844) 1 occurrence of GetMemberRelatives has not been removed
- [[16848]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16848) Wrong warning "Invalid date ... passed to output_pref" can be carped
- [[16857]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16857) patron-attr-types.tt: Get rid of warnings "Argument "" isn't numeric"
- [[16889]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16889) Move the ::columns subroutines to Koha::Objects->columns
- [[16929]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16929) Prevent opac-memberentry waiting for random chars
- [[16971]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16971) Missing dependency for HTML::Entities
- [[16975]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16975) DSA-3628-1 perl -- security update
- [[17020]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17020) findborrower is not used in circulation.tt
- [[17087]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17087) Set Test::WWW::Mechanize version to 1.42
- [[17124]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17124) DecreaseLoanHighHolds.t does not pass
- [[17128]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17128) summary-print.pl is not plack safe
- [[17157]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17157) Middle click on dropdown menu in header may cause software error
- [[17223]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17223) Add Cache::Memcached to PerlDependencies
- [[17231]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17231) HTML5MediaYouTube should recognize youtu.be links from youtube as well at the full links
- [[17294]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17294) reserves_stats.pl is not plack safe
- [[17368]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17368) plugins tests are broken - KitchenSinkPlugin
- [[17372]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17372) Elasticsearch paths need to be standardized
- [[17396]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17396) t/DataTables/Members.t is unnecessary
- [[17411]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17411) Change exit 1 to exit 0 in acqui/basket.pl to prevent Internal Server Error
- [[17426]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17426) AutoCommit should not be set in tests
- [[17446]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17446) Remove some seleted typos
- [[17513]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17513) koha-create does not set GRANTS correctly
- [[17537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17537) xt/author/valid-templates.t is broken
- [[17538]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17538) t/db_dependent/Upload.t is broken
- [[17540]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17540) auth_values_input_www.t is broken
- [[17544]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17544) populate_db.pl should not require t::lib::Mocks
- [[17552]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17552) Koha::Objects->reset does no longer allow chaining
- [[17562]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17562) Acquisition.t is broken
- [[17563]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17563) Acquisition/CancelReceipt.t is broken
- [[17564]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17564) Acquisition/OrderUsers.t is broken
- [[17589]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17589) Improper method type in Koha::ItemType(s)
- [[17633]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17633) Tests should not call set_preference
- [[17634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17634) Unit test t/db_dependent/ArticleRequests.t is failing
- [[17637]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17637) Auth_with_ldap.t is failing
- [[17638]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17638) t/db_dependent/Search.t is failing
- [[17640]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17640) t/db_dependent/Template/Plugin/Categories.t is failing
- [[17641]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17641) t/Biblio/Isbd.t is failing
- [[17654]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17654) Add tests to enforce swagger definition files integrity

### Authentication

- [[16818]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16818) CAS redirect broken under Plack
- [[16845]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16845) C4::Members::ModPrivacy is not used

### Cataloging

- [[7045]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7045) Default-value substitution inconsistent
- [[12629]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12629) Software error when trying to merge records from different frameworks
- [[14897]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14897) Header name mismatch in ./modules/catalogue/detail.tt
- [[16245]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16245) RIS export file type incorrect
- [[16358]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16358) Rancor - Deleting records when Rancor is enabled just opens them
- [[16613]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16613) MARC 09X Field Help Links are Broken
- [[16807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16807) Frameworks unordered  in dropdown when adding/editing a biblio
- [[17152]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17152) Duplicating a subfield should not copy the data
- [[17194]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17194) When edit record, Button "Z39.50/SRU search" not work
- [[17201]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17201) Remaining calls to C4::Context->marcfromkohafield
- [[17204]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17204) Rancor Z39.50 search fails under plack
- [[17206]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17206) Can't switch to default framework
- [[17405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17405) Edit record uses Default framework
- [[17545]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17545) Make "Add biblio" not hidden by language chooser
- [[17660]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17660) Any $t subfields not editable in any framework

### Circulation

- [[10768]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10768) Improve the interface related to itemBarcodeFallbackSearch
- [[14736]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14736) AllowRenewalIfOtherItemsAvailable slows circulation down in case of a record with many items and many holds
- [[16200]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16200) 'Hold waiting too long' fee has a translation problem
- [[16462]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16462) Change default sorting of circulation patron search results to patron name
- [[16569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16569) Message box for "too many checked out" is empty if AllowTooManyOverride is not enabled
- [[16596]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16596) branchcode and categorycode are displayed instead of their description on patron search result
- [[16780]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16780) Specify due date always sets time as AM when using 12 hour time format
- [[16854]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16854) request.tt: Logic to display messages broken
- [[17001]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17001) filtering overdue report by due date can fail if TimeFormat is 12hr
- [[17055]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17055) Add classes to different note types to allow for styling on checkins page
- [[17095]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17095) Regression: Error when checking out to non-existent patron
- [[17310]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17310) Broken URLs in 'Item renewed' / 'Cannot renew' messages
- [[17352]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17352) Patron search type is hard coded to 'contain' in circ/circulation.pl
- [[17394]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17394) exporting checkouts with items selects without items in combo-box

### Command-line Utilities

- [[2389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=2389) overdue_notices.pl needs a test mode
- [[16822]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16822) koha-common init.d script should run koha-plack without quiet
- [[16830]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16830) koha-indexer still uses the deprecated -x option switch
- [[16935]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16935) launch export_records.pl with deleted_barcodes param fails
- [[16974]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16974) koha-plack should check and fix log files permissions
- [[17088]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17088) Bad MARC XML can halt export_records.pl

### Database

- [[10459]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10459) borrowers should have a timestamp

### Developer documentation

- [[17626]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17626) INSTALL files are outdated

### Documentation

- [[16537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16537) Overdue and Status triggers grammar

### Hold requests

- [[14514]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14514) LocalHoldsPriority and the HoldsQueue conflict with each other
- [[14968]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14968) found shouldn't be set to null when cancelling holds

### I18N/L10N

- [[12509]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12509) Untranslatable "Restriction added by overdues process"
- [[15676]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15676) Actions in pending offline circulation actions are not translatable
- [[16540]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16540) Translatability in opac-auth.tt (tag-splitted sentences)
- [[16560]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16560) Translatability: Issues in opac-memberentry.tt
- [[16562]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16562) Translatability: Issue in opac-user.tt (separated word 'item')
- [[16563]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16563) Translatability: Issues in opac-account.tt (sentence splitting)
- [[16585]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16585) Update Italian installer sample files for 16.05

> With this patch all sample/defintions .sql files are translated into Italian (if you select italian during web installation).

- [[16620]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16620) Translatability: Fix problem with isolated word "please" in auth.tt
- [[16621]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16621) Translatability: Issues in opac-user.tt (sentence splitting)

> Fix translatability issues due to sentence splitting in koha-tmpl/opac-tmpl/bootstrap/en/modules/opac-user.tt


- [[16633]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16633) Translatability: Issues in tags/review.tt (sentence splitting)
- [[16634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16634) Translatability: Fix issue in memberentrygen.tt
- [[16697]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16697) Translatability: Fix problem with isolated "'s"in request.tt
- [[16701]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16701) Translatability: Fix problem with isolated ' in currency.tt
- [[16718]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16718) Translatability: Fix problems with sentence splitting by use of strong tag in about.tt
- [[16776]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16776) If language is set by external link language switcher does not work
- [[16861]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16861) Translatability: Fix separated "below" in circulation.tt
- [[16871]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16871) Translatability: Avoid [%%-problem and fix related sentence splitting in catalogue/detail.tt
- [[17040]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17040) Context menu when editing items is not translated
- [[17064]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17064) Delete backup marc21_framework_DEFAULT.sql~ file
- [[17082]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17082) Translatability: Fix sentence splitting in member.tt
- [[17245]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17245) Untranslatable abbreviated names of seasons
- [[17322]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17322) Translation breaks opac-ics.tt
- [[17518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17518) Displayed language name for Czech is wrong

### Installation and upgrade (command-line installer)

- [[17044]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17044) Wrong destination for 'api' directory

### Installation and upgrade (web-based installer)

- [[17357]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17357) WTHDRAWN is still used in installer files
- [[17358]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17358) Authorised values: COU>COUNTRY | LAN>LANG
- [[17391]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17391) ReturnpathDefault and ReplyToDefault missing from syspref.sql
- [[17504]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17504) Installer shows PostgreSQL info when wrong DB permissions

### Label/patron card printing

- [[14138]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14138) Patroncard: Warn user if PDF creation fails
- [[16459]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16459) Adding patrons to a patron card label batch requires 'routing' permission
- [[17175]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17175) Typo in patron card images error message

### Lists

- [[16897]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16897) Re-focus on "Add item" in Lists
- [[17185]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17185) Staff client shows "Lists that include this title:" even if item is not in a list
- [[17315]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17315) Can't add entry to lists using link in result list
- [[17316]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17316) Possible to see name of lists you don't own

### MARC Authority data support

- [[17118]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17118) Regression: Bug 15381 triggers error when trying to clear a linked authority

### MARC Bibliographic data support

- [[17281]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17281) Warning when saving subfield structure

### MARC Bibliographic record staging/import

- [[6852]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6852) Staged import reports wrong success for items with false branchcode

### Notices

- [[16624]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16624) Times are formatted incorrectly in slips ( AM PM ) due to double processing

### OPAC

- [[2735]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=2735) Authority search in OPAC stops at 15 pages
- [[14434]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14434) OPAC should indicate to patrons that auto renewal will not work because hold has been placed
- [[15636]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15636) DataTables Warning: Requested unknown parameter from opac-detail.tt
- [[16311]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16311) Advanced search language limit typo for Romanian
- [[16464]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16464) If a patron has been discharged, show a message in the OPAC
- [[16465]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16465) OPAC discharge page has no title tag
- [[16597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16597) Reflected XSS in [opac-]shelves and [opac-]shareshelf
- [[16599]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16599) XSS found in opac-shareshelf.pl
- [[16615]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16615) OpenLibrary: always use SSL when referencing external resources
- [[16805]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16805) Log in with database admin user breaks OPAC
- [[16806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16806) "Too soon" renewal error generates no alert for user
- [[17068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17068) empty list item in opac-reserves.tt
- [[17078]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17078) Format fines on opac-account.pl
- [[17103]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17103) Google API Loader jsapi called over http
- [[17117]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17117) Patron personal details not displayed unless branch update request is enabled
- [[17142]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17142) Don't show library group selection in advanced search if groups are not defined
- [[17296]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17296) Failed to correctly configure AnonymousPatron with AnonSuggestions should display a warning in about
- [[17367]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17367) Showing all items must keep show holdings tab in OPAC details
- [[17435]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17435) Gives ability to display stocknumber in the search results

### Packaging

- [[4880]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=4880) koha-remove sometimes fails because user is logged in
- [[16695]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16695) Exception::Class 1.39 is not packaged for Jessie
- [[16823]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16823) Comment out koha-rebuild-zebra in debian/koha-common.cron.d
- [[16885]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16885) koha-stop-zebra should be more sure of stopping zebrasrv
- [[17043]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17043) debian/list-deps fixes, master edition
- [[17062]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17062) debian/control.in update: change maintainer & add libhtml-parser-perl
- [[17065]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17065) Rename C4/Auth_cas_servers.yaml.orig
- [[17084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17084) Automatic debian/control updates (master)
- [[17085]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17085) Specify libmojolicious-perl min version
- [[17228]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17228) Make two versions of SIPconfig.xml identical
- [[17266]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17266) Update man page for koha-remove with -p
- [[17267]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17267) Document koha-create --adminuser

### Patrons

- [[10227]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10227) GetMessagingPreferences does not return correct Digest preferences
- [[14605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14605) The description on pay/write off individual fine is wrong
- [[15397]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15397) Pay selected does not works as expected
- [[16458]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16458) Setting to guarantor: JavaScript error form.branchcode is undefined
- [[16508]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16508) User permission "parameters_remaining_permissions Remaining system parameters permissions" does not allow saving systempreferences.
- [[16612]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16612) Cannot set "Until date" for "Enrollment period" for Patron Categories
- [[16779]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16779) Move road type after address in US style address formatting (main address)
- [[16795]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16795) Patron categories: Accept integers only for enrolment period and age limits
- [[16810]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16810) Fines note not showing on checkout
- [[16894]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16894) re-show email on patron search results
- [[17052]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17052) Patron category description not displayed in the sidebar of paycollect
- [[17076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17076) Format fines in patron search results table (staff client)
- [[17100]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17100) On summary print, "Account fines and payments" is displayed even if there is nothing to pay
- [[17106]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17106) DataTables patron search defaulting to 'starts_with' - doc
- [[17213]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17213) Self registration cardnumber is not editable if errors found when form submitted
- [[17284]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17284) Patron details page ( moremember.pl ) show logged in library as patron's home library
- [[17307]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17307) Some edit buttons/links for patrons do not work
- [[17404]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17404) Patron deletion page: Fix title and breadcrumb
- [[17419]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17419) Fix more confusion between smsalertnumber and mobile
- [[17423]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17423) patronimage.pl permission is too restrictive
- [[17434]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17434) Moremember displaying primary and secondary phone number twice
- [[17521]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17521) Step 3 of patron modification editor not checking age limits
- [[17559]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17559) Invalid ID of element B_streetnumber in member edit form

### Reports

- [[16760]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16760) Circulation Statistics wizard not populating itemtype correctly
- [[16816]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16816) Duplicate button on report results copies parameters used
- [[17053]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17053) Clearing search term in Reports
- [[17535]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17535) Regression: Search for reports by keywords
- [[17590]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17590) Exporting reports as CSV with 'delimiter' SysPref set to 'tabulation' creates files with 't' as separator

### SIP2

- [[15006]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15006) Need to distinguish client timeout from login timeout

### Searching

- [[16777]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16777) Correct intranet search alias
- [[17074]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17074) Fix links in result list of 'scan indexes' search and keep search term
- [[17107]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17107) Add ident and Identifier-standard to known indexes
- [[17132]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17132) Availability search broken when using Elastic

### Self checkout

- [[17299]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17299) Date due shows incorrect time on SCO.

### Serials

- [[12178]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12178) Serial claims: exporting late issues with the CSV profile doesn't set the issue claimed
- [[12748]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12748) Serials - two issues with status of "Expected"
- [[16692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16692) Error "No method update!" when creating new serial issue
- [[16705]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16705) Status missing in Opac, serials subscription history
- [[17300]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17300) Serials search does not return any results

### Staff Client

- [[16809]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16809) Silence CGI param warnings from C4::Biblio::TransformHtmlToMarc
- [[16989]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16989) Advanced search form does not display translated itemtype
- [[17144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17144) Fix variable scope issue in edi_accounts.pl (Internal server error with plack)
- [[17149]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17149) EDI accounts: Add missing '>' to breadcrumb
- [[17375]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17375) Prevent internal software error when searching patron with invalid birth date

### System Administration

- [[11019]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11019) Require some fields when adding authorized value category
- [[15641]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15641) Typo in explanation for MembershipExpiryDaysNotice
- [[15929]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15929) typo in explanation for MaxSearchResultsItemsPerRecordStatusCheck
- [[16035]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16035) MARC framework Export misbehaving
- [[16532]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16532) Libraries and groups showing empty tables if nothing defined
- [[16762]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16762) Record matching rules: Remove match check link removes too much
- [[16813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16813) OPACBaseURL cannot be emptied
- [[17009]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17009) Duplicating frameworks is unnecessary slow
- [[17657]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17657) Item type's images could not be displayed correctly on the item types admin page

### Templates

- [[12359]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12359) hidepatronname doesn't hide on the holds queue
- [[13921]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13921) XSLT Literary Formats Not Showing
- [[16001]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16001) Use standard message dialog when there are no cities to list
- [[16529]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16529) Clean up and improve upload template
- [[16594]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16594) Orders by fund report has wrong link to css and other issues
- [[16600]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16600) Remove some obsolete references to Greybox in some templates
- [[16608]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16608) Missing entity nbsp in some XML files
- [[16642]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16642) Fix capitalisation for upload patron image
- [[16774]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16774) Format date on 'Transfers to receive' page to dateformat system preference
- [[16781]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16781) Add Font Awesome Icons to "Select/Clear all" links to modborrows.tt and result.tt
- [[16792]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16792) Add Font Awesome Icon and mini button to Keyword to MARC mapping section
- [[16793]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16793) Use Font Awesome for arrows instead of images in audio_alerts.tt
- [[16794]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16794) Revise layout for Admistration > Patron categories
- [[16803]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16803) Add Font Awesome Icons to "Select/Clear all" links to shelves.tt
- [[16812]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16812) Revise JS script for z3950_search.tts and remove onclick events
- [[16888]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16888) Add Font Awesome Icons to Members
- [[16893]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16893) Missing closing tag disrupts patron detail page style
- [[16900]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16900) Hold suspend button incorrectly styled in patron holds list
- [[16903]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16903) Multiple class attributes on catalog search tab
- [[16944]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16944) Add "email" and "url" classes when edit or create a vendor
- [[16964]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16964) Fix capitalization for "Report Plugins" in reports-home.tt
- [[16990]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16990) Show branch name instead of branch code when managing patron modification requests
- [[16991]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16991) Add subtitle to holds to pull report
- [[17200]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17200) Badly formatted "hold for" patron name on catalog detail page
- [[17289]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17289) Holds awaiting pickup shows date unformatted
- [[17312]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17312) Typo in members-toolbar.inc / moremember-brief.tt / moremember.tt
- [[17417]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17417) Correct invalid markup around news on the staff client home page
- [[17601]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17601) Regression: Incomplete CSS update introduced by Bug 14610
- [[17616]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17616) Select tag on elasticsearch mappings page is not closed properly
- [[17635]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17635) (Bug 6934 followup) Templates missing body id
- [[17645]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17645) Remove obsolete interface customization images

### Test Suite

- [[15200]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15200) t/Creators.t fails when using build-git-snapshot
- [[16500]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16500) Catch two warns in TestBuilder.t with warning_like
- [[16582]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16582) t/Price.t test should pass if Test::DBIx::Class is not available
- [[16607]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16607) Remove CPL/MPL from two unit tests
- [[16609]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16609) Catch warning from Koha::Hold in Hold.t
- [[16618]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16618) 00-load.t prematurely stops all testing
- [[16622]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16622) some tests triggered by prove t fail for unset KOHA_CONF
- [[16635]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16635) t/00-load.t warning from C4/Barcodes/hbyymmincr.pm
- [[16636]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16636) t/00-load.t warning from C4/External/BakerTaylor.pm
- [[16637]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16637) Dependency for C4::Tags not listed
- [[16649]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16649) OpenLibrarySearch.t fails when building packages
- [[16668]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16668) Fix t/Ris.t (follow-up for 16442)
- [[16675]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16675) fix breakage of t/Languages.t
- [[16717]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16717) Remove hardcoded category from Holds.t
- [[16860]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16860) Catch warning t/db_dependent/ClassSource.t
- [[16864]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16864) Silence warnings in t/db_dependent/ILSDI_Services.t
- [[16868]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16868) Silence error t/db_dependent/Linker_FirstMatch.t
- [[16869]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16869) Silence and catch warnings in t/db_dependent/SuggestionEngine_ExplodedTerms.t
- [[16890]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16890) TestBuilder always generate datetime for dates
- [[17430]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17430) MarkIssueReturned.t should create its own data
- [[17441]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17441) t/db_dependent/Letters.t fails on Jenkins
- [[17476]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17476) Failed test 'Create DateTime with dt_from_string() for 2100-01-01 with TZ in less than 2s'
- [[17572]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17572) Remove issue.t warnings
- [[17573]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17573) Remove DecreaseLoanHighHolds.t warnings
- [[17574]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17574) Remove LocalholdsPriority.t warnings
- [[17575]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17575) Remove Circulation.t warnings
- [[17587]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17587) Remove itemtype-related IsItemIssued.t warnings
- [[17592]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17592) Remove itemtype-related maxsuspensiondays.t warnings
- [[17603]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17603) Remove itemtype-related Borrower_Discharge.t warnings
- [[17636]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17636) Remove itemtype-related GetIssues.t warnings
- [[17646]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17646) Remove itemtype-related IssueSlip.t warnings
- [[17647]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17647) Remove itemtype-related CancelReceipt.t warnings
- [[17653]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17653) Remove itemtype-related t/db_dependent/Circulation* warnings

### Tools

- [[11490]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11490) MaxItemsForBatch should be split into two new prefs
- [[14612]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14612) Overdue notice triggers should show branchname instead of branchcode
- [[16548]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16548) All libraries selected on Tools -> Export Data screen
- [[16589]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16589) Quote of the day: Fix upload with csv files associated to LibreOffice Calc
- [[16682]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16682) Fix display if Batch patron modification tool does not get any patrons
- [[16727]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16727) Upload tool needs better warning
- [[16855]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16855) Poor performance due to high overhead of SQL call in export.pl
- [[16859]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16859) Fix wrong item field name in export.pl
- [[16886]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16886) 'Upload patron images' tool is not plack safe
- [[16949]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16949) Batch record deletion says success when no records have been passed in
- [[17663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17663) Forgotten userpermissions from bug 14686

### Web services

- [[17041]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17041) Fix missing properties in Swagger definition for Patron
- [[17042]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17042) Fix missing properties in Swagger definition for Hold
- [[17086]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17086) REST API: Reword borrowers to patrons in Swagger tags for holds
- [[17607]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17607) Fix patron definition in Swagger

## New sysprefs

- AggressiveMatchOnISSN
- AllowItemsOnHoldCheckoutSCO
- ArticleRequests
- ArticleRequestsMandatoryFields
- ArticleRequestsMandatoryFieldsItemsOnly
- ArticleRequestsMandatoryFieldsRecordOnly
- CheckPrevCheckout
- DefaultPatronSearchFields
- HoldsLog
- HouseboundModule
- IntranetCatalogSearchPulldown
- MaxItemsToDisplayForBatchDel
- MaxItemsToProcessForBatchMod
- MaxOpenSuggestions
- NovelistSelectStaffEnabled
- NovelistSelectStaffView
- OPACHoldingsDefaultSortField
- OPACResultsLibrary
- OPACXSLTListsDisplay
- PatronQuickAddFields
- PatronSelfRegistrationEmailMustBeUnique
- PatronSelfRegistrationLibraryList
- PatronSelfRegistrationPrefillForm
- RefundLostOnReturnControl
- ReplyToDefault
- ReturnpathDefault
- SwitchOnSiteCheckouts
- TrackLastPatronActivity
- XSLTListsDisplay
- makePreviousSerialAvailable

## System requirements

Important notes:
- Debian 8 ( Jessie ) or later is required
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

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 16.11.00 is

- Release Manager:
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Kyle M Hall](mailto:kyle@bywatersolutions.com)
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
  - [Brooke](mailto:)
  - [Thomas Dukleth](mailto:kohadevel@agogme.com)
- Release Maintainers:
  - 16.05 -- [Frédéric Demians](mailto:f.demians@tamil.fr)
  - 3.22 -- [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - 3.20 -- [Chris Cormack](mailto:chrisc@catalyst.net.nz)

## Credits

We thank the following libraries who are known to have sponsored
new features in Koha 16.11.00:

- BULAC - http://www.bulac.fr/
- ByWater Solutions
- California College of the Arts
- Carnegie Stout Library
- Catalyst IT
- DoverNet
- FIT
- Hochschule für Gesundheit (hsg), Germany
- NEKLS
- South-East Kansas Library System
- SWITCH Library Consortium
- Tulong Aklatan
- Universidad de El Salvador
- Universidad Empresarial Siglo 21
- University of the Arts London
- VOKAL

We thank the following individuals who contributed patches to Koha 16.11.00.

- Marc (11)
- Aleisha (19)
- kohamaster (1)
- Liz (1)
- NguyenDuyTinh (1)
- radiuscz (1)
- Blou (2)
- genevieve (2)
- phette23 (3)
- remi (6)
- Jacek Ablewicz (14)
- Brendan A Gallagher (1)
- Morgane Alonso (1)
- Aleisha Amohia (12)
- Dimitris Antonakis (1)
- Alex Arnaud (5)
- Oliver Bock (1)
- Nightly Build Bot (1)
- Colin Campbell (8)
- Hector Castro (24)
- Galen Charlton (4)
- Barton Chittenden (10)
- Nick Clemens (53)
- Tomás Cohen Arazi (111)
- Chris Cormack (11)
- Indranil Das Gupta (L2C2 Technologies) (1)
- Frédéric Demians (2)
- Marcel de Rooy (86)
- Simith D'Oliveira (1)
- Rocio Dressler (1)
- Jonathan Druart (491)
- Nicole Engard (2)
- Magnus Enger (6)
- Charles Farmer (1)
- Bouzid Fergani (7)
- Julian FIOL (1)
- Katrin Fischer (26)
- Brendan Gallagher (6)
- Bernardo González Kriegel (13)
- Claire Gravely (3)
- Karl Holten (1)
- Koha instance kohadev-koha (1)
- Mason James (1)
- Lee Jamison (1)
- Srdjan Jankovic (1)
- Olli-Antti Kivilahti (5)
- Rafal Kopaczka (1)
- Owen Leonard (65)
- Florent Mara (1)
- Jesse Maseto (1)
- Julian Maurice (24)
- Holger Meißner (1)
- Matthias Meusburger (5)
- Sophie Meynieux (3)
- Kyle M Hall (181)
- Josef Moravec (13)
- Aliki Pavlidou (1)
- Liz Rea (2)
- Martin Renvoize (3)
- Andreas Roussos (9)
- Rodrigo Santellan (1)
- A. Sassmannshausen (1)
- Alex Sassmannshausen (21)
- Robin Sheat (1)
- Radek Šiman (1)
- Fridolin Somers (14)
- Zeno Tajoli (3)
- Lari Taskula (23)
- Lyon3 Team (1)
- Koha Team Lyon 3 (1)
- Mirko Tietgen (14)
- Mark Tompsett (30)
- Marc Véron (47)
- Jesse Weaver (9)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 16.11.00

- abunchofthings.net (15)
- ACPL (65)
- aei.mpg.de (1)
- arts.ac.uk (3)
- BibLibre (72)
- biblos.pk.edu.pl (14)
- BigBallOfWax (3)
- BSZ BW (26)
- bugs.koha-community.org (473)
- bwstest.bywatersolutions.com (1)
- ByWater-Solutions (263)
- Catalyst (12)
- centrum.cz (1)
- Cineca (3)
- Hochschule für Gesundheit (hsg), Germany (1)
- inLibro.com (6)
- jns.fi (11)
- kallisti.net.nz (1)
- KohaAloha (1)
- kohadevbox (1)
- kohaVM (1)
- l2c2.co.in (1)
- Libriotech (6)
- Marc Véron AG (58)
- marywood.edu (1)
- poczta.onet.pl (1)
- PTFS-Europe (33)
- rbit.cz (1)
- Rijksmuseum (86)
- Solutions inLibro inc (13)
- student.uef.fi (17)
- switchinc.org (1)
- Tamil (2)
- Theke Solutions (108)
- unidentified (118)
- Universidad Nacional de Córdoba (16)
- Université Jean Moulin Lyon 3 (2)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha (5)
- Aleisha Amohia (30)
- Alexis Rodegerdts (3)
- Andreas Roussos (4)
- Andrew Brenza (1)
- Arslan Farooq (1)
- Barbara Fondren (1)
- barbara johnson (2)
- Barbara.Johnson@bedfordtx.gov (1)
- Barbara Walters (5)
- Barton Chittenden (3)
- Benjamin Rokseth (41)
- Bob Birchall (2)
- Brendan (1)
- Brendan Gallagher (163)
- Brendon Ford (2)
- Broust (2)
- Chad Roseburg (2)
- Chris (1)
- Chris Cormack (76)
- Chris Kirby (4)
- Christopher Brannon (2)
- Claire Gravely (64)
- Colin Campbell (1)
- Dani Elder (2)
- David Cook (1)
- Deb Stephenson (2)
- Dwayne Nance (3)
- Filippos Kolovos (1)
- FILIPPOS KOLOVOS (1)
- Florent Mara (1)
- Francois Charbonnier (9)
- Frédéric Demians (16)
- Galen Charlton (6)
- George (2)
- Heather Braum (2)
- Hector Castro (75)
- Irma Birchall (1)
- Jacek Ablewicz (15)
- Jan Kissig (1)
- Jason Robb (12)
- Jennifer Schmidt (15)
- Jesse Maseto (6)
- Jesse Weaver (22)
- JM Broust (1)
- Johanna Raisa (8)
- Jonathan Druart (457)
- Jonathan Field (4)
- Josef Moravec (59)
- Joy Nelson (4)
- Juliette (1)
- Katrin Fischer (118)
- Lari Taskula (2)
- Laurence Rault (12)
- Lisette Scheer (1)
- Liz Rea (14)
- Lucio Moraes (4)
- Magnus Enger (2)
- Marc (33)
- Marc Veron (13)
- Marc Véron (101)
- Margaret Thrasher (10)
- Mark Tompsett (51)
- Martin Renvoize (43)
- Mason James (9)
- Matthias Meusburger (1)
- Megan Wianecki (1)
- mehdi (1)
- Michael Kuhn (1)
- Mirko Tietgen (18)
- Nick Clemens (147)
- Nicolas Legrand (17)
- Nicole (1)
- Oliver Bock (1)
- Olli-Antti Kivilahti (10)
- Owen Leonard (123)
- radiuscz (4)
- rainer (1)
- remy (1)
- Robin Sheat (1)
- Rocio Dressler (3)
- Sabine Liebmann (1)
- Sean McGarvey (4)
- Sean Minkel (1)
- Sinziana (1)
- Sofia (1)
- sonia bouis (1)
- sonia BOUIS (2)
- Sonia Bouis (26)
- Srdjan (37)
- Trent Roby (1)
- Katrin Fischer  (169)
- Nikos Chatzakis, Afrodite Malliari (1)
- Tomas Cohen Arazi (185)
- Alain et Aurélie (2)
- Barton Chittenden barton@bywatersolutions.com (1)
- Jason M. Burds (14)
- Nicole C Engard (10)
- Kyle M Hall (1324)
- Bernardo Gonzalez Kriegel (33)
- Marcel de Rooy (245)
- Eivin Giske Skaaren (1)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

### Thanks
- For Chelsea, who keeps my world from falling down around my ears.
- For Daria, whose insatiable curiosity always inpsires me.
- For Kylie, whose smile lights up my world; just breathe.

### Special thanks from the Release Manager
I'd like to thank everyone who has contributed time and effort to this release. Many hands make light work!

A special thanks goes out to Jonathan and Tomás who have gone above and beyond taking care of many unglamorous
tasks that are good and necessary for the future of Koha.

More thanks go to Katrin and the Koha 16.11 QA team, whose dedication and hard work make using Koha a joy.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is v16.11.x

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 Nov 2016 11:45:49.
