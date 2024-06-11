# RELEASE NOTES FOR KOHA 23.11.06
11 Jun 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 23.11.06 can be downloaded from:

- [Download](http://download.koha-community.org/koha-23.11.06.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.11.06 is a bugfix/maintenance release.

It includes 36 enhancements, 162 bugfixes with 4 security.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [36520](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36520) SQL Injection in opac-sendbasket.pl (CVE-2024-36058)
- [36575](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36575) Wrong patron can be returned for API validation route
- [36818](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36818) Remote-Code-Execution (RCE) in upload-cover-image.pl (CVE-2024-36057)
- [36875](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36875) SQL injection in additional content pages

## Bugfixes

### Acquisitions

#### Other bugs fixed

- [30598](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30598) Replacement cost is not copied from retail price when ordering from file
- [34963](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34963) Unable to delete fields in suggestions
- [35927](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35927) Selecting MARC framework again doesn't work when adding to basket from an external source
- [36030](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36030) Do not show "Place hold" for deleted biblio record on basket page
- [36122](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36122) NEW_SUGGESTION is sent for every modification to the suggestion
- [36173](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36173) Cancelling order confirmation view does not show basket's info
  >This fixes the breadcrumb links on the confirmation page when cancelling an order (from the receiving screen).
- [36620](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36620) Broken order management for suggestions with quantity

  **Sponsored by** *Ignatianum University in Cracow*
- [36856](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36856) New order from existing bibliographic record does not show MARC subfield name

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [36665](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36665) Auto location and IP recognition
  >This patch adds a new system preference "StaffLoginLibraryBasedOnIP" which, when enabled, will set the logged in library to the library with an IP setting matching the current users IP. This preference will be overridden if "AutoLocation" is enabled, as that preference will enforce the user selecting a library that matches their current IP or signing into their home library from the correct IP.
- [36790](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36790) 230600052.pl is failing
- [36943](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36943) Update .mailmap for 24.05.x release

#### Other bugs fixed

- [26176](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26176) AutoLocation is badly named
- [30068](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30068) Wrong reference to table_borrowers in circulation.tt
- [34360](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34360) [WARN] DBIx::Class::ResultSetColumn::new(): Attempting to retrieve non-unique column 'biblionumber' on a resultset containing one-to-many joins will return duplicate results
- [35610](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35610) Missing FK on old_reserves.branchcode
  >Add a foreign key on the old_reserves.branchcode database column. This link was missing and the column may contain incorrect data/branchcode.
  >Note that the values will now be set to NULL when the branchcode is incorrect.
- [35979](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35979) Possible RealTimeHoldsQueue check missing in modrequest.pl for BatchUpdateBiblioHoldsQueue background job
- [36307](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36307) SMS::Send driver errors are not captured and stored
- [36378](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36378) Cannot stay logged in if AutoLocation is enabled but library's IP address is not set correctly
- [36386](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36386) Prevent Net::Server warn about User Not Defined from SIPServer
- [36395](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36395) Useless fetch of AV categories in admin/marc_subfields_structure.pl

  **Sponsored by** *The Research University in the Helmholtz Association (KIT)*
- [36432](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36432) Remove circular dependency from Koha::Object
- [36438](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36438) MARCdetail: Can't call method "metadata" on an undefined value
- [36463](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36463) We should compress our JSON responses (gzip deflate mod_deflate application/json)
- [36473](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36473) updatetotalissues.pl should not die on a bad record
  >This fixes the misc/cronjobs/update_totalissues.pl script so that it skips records with invalid data, instead of just stopping. (This also means that the 'Most-circulated items' report now shows the correct data - if the script stopped because of invalid records, the report may have not picked up circulated items.)
- [36526](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36526) Remove circular dependency from Koha::Objects
- [36531](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36531) Koha should serve text/javascript compressed, like application/javascript is
- [36774](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36774) Flatpickr clear() adds unintentional clear button
- [36793](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36793) Local preferences should not stay in the cache when they are deleted
- [36858](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36858) Crash on wrong page number in opac-shelves
- [36914](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36914) DBIx::Class warning from shelves.pl

### Authentication

#### Other bugs fixed

- [36908](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36908) Clarify and standardize the behavior of AutoLocation/ StaffLoginBranchBasedOnIP system preferences

### Cataloging

#### Other bugs fixed

- [24424](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24424) Advanced editor - interface hangs as "Loading" when given an invalid bib number

  **Sponsored by** *Ignatianum University in Cracow*
- [27363](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27363) Restore temporary selection of Z39.50 targets throughout multiple searches
- [36461](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36461) Advanced editor should disable RequireJS timeout with waitSeconds: 0
- [36552](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36552) Update record 'date entered on file' when duplicating a record
- [36589](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36589) Advanced cataloging - restore the correct height of the clipboard
- [36794](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36794) Illegitimate modification of biblionumber subfield content (999 $c)

  **Sponsored by** *Ignatianum University in Cracow*

### Circulation

#### Critical bugs fixed

- [36313](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36313) Check out/check in leads to error 500 in staff interface

  **Sponsored by** *Koha-Suomi Oy*
- [36708](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36708) Problems editing circ rules when 'Holds allowed (total)' value is greater than or equal to 0

#### Other bugs fixed

- [8461](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8461) Block returns of withdrawn items show as 'not checked out'
- [18885](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18885) When 'on-site checkout' was used, the 'Specify due date' should be emptied for next checkout unless OnSiteCheckoutAutoCheck
- [30324](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30324) Parent and child itemtype checkout limits not enforced as expected
- [34263](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34263) Suspending holds consecutively populates previously used date falsely
- [35149](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35149) Add "do nothing" option to CircAutoPrintQuickSlip system preference
- [36347](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36347) Return claims table is loaded twice
- [36393](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36393) Renewal with a specific date does not take the new date due that we pick
- [36494](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36494) Flatpickr error on checkout page if the patron is blocked from checking out
- [36614](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36614) Reinstate phone column in patron search
- [36619](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36619) Cannot show/hide columns on the patron search table when placing a hold

### Command-line Utilities

#### Critical bugs fixed

- [36508](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36508) Patron userid field can be overwritten by update_patron_categories when limiting by fines

#### Other bugs fixed

- [36517](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36517) Fix output from install_plugins.pl
- [36787](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36787) staticfines.pl missing use Koha::DateUtils::output_pref

### Database

#### Other bugs fixed

- [36033](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36033) Table pseudonymized_transactions needs more indexes
- [36687](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36687) itemtypes.notforloan should be tinyint and NOT NULL

### ERM

#### Other bugs fixed

- [35392](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35392) HTML in translatable string
- [36093](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36093) Fix missing array reference in provider rollup reports
- [36392](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36392) Only 20 vendors in ERM dropdown
  >This fixes the listing of vendors when adding a new agreement in the electronic resources (ERM) module. Previously only the first 20 vendors were displayed, now all vendors are displayed.
- [36623](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36623) Remove localhost reference from counter logs page
- [36827](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36827) Tabs in the ERM module have a gap above the tab content
- [36828](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36828) Remove unnecessary code from UsageStatisticsReportsHome.vue

### Hold requests

#### Critical bugs fixed

- [34972](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34972) Canceling a waiting hold from the holds over tab can make the next hold unfillable

#### Other bugs fixed

- [32565](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32565) Holds placed when all libraries are closed do not get added to holds queue if HoldsQueueSkipClosed and RealTimeHoldsQueue are enabled
  >This patch set adds a new option "--unallocated" to the build_holds_queue.pl cronjob.
  >
  >This option prevents deletion of the existing queue, and looks for new unassigned holds that may be mapped to available items.
  >
  >There are two intended uses for the option, depending on whether the 'RealTimeHoldsQueue' (RTHQ) system preference is enabled or not.
  >
  >Without RTHQ libraries who want a more static holds queue during the day can run an hourly 'unallocated' cronjob. This will add new holds to the queue as they come in, but allow libraries longer to fill the holds in their existing queue before they move on. The recommendation would then be a nightly full run to rebuild the queue entirely.
  >
  >With RTHQ, libraries could run a nightly 'unallocated' cron to select holds for libraries that were not open on the previous day, and to select holds that have been unsuspended by another cronjob.
  >
  >Current setups will continue to function as before with no change, but libraries may wish to review their options after this upgrade.
- [34823](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34823) Do not show item group drop-down if there are no item groups
- [35394](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35394) Correct the message displayed when attempting to checkout an item during it's booking period
  >This fixes the logic and message displayed if you try to check out an item where there is a booking. Now you cannot check out an item where there is a booking, and the message displayed is: "The item is booked for another patron".
- [35559](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35559) Can't change the pickup date of holds on the last day of expiration
- [35573](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35573) Koha is not correctly warning of overridden items when placing a hold if AllowHoldPolicyOverride
- [35977](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35977) Display current date in hold starts on when placing a hold in the OPAC
- [36137](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36137) update_totalissues.pl should always skip_holds_queue
- [36227](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36227) No warning if placing hold on item group with no items
- [36439](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36439) Column settings are missing on holds-to-pull table
- [36797](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36797) Record with 1000+ holds and unique priorities causes a 500 error

### I18N/L10N

#### Other bugs fixed

- [35531](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35531) Add context for translation of gender option "Other"
- [36516](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36516) translation script could output useless warning
- [36837](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36837) XSLT CSS classes offered for translations
- [36845](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36845) Exclude meta tag from the translations
- [36872](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36872) Untranslatable "Please make sure all selected titles have a pickup location set"

### ILL

#### Critical bugs fixed

- [36904](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36904) ILL error when searching from table search input

#### Other bugs fixed

- [35685](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35685) ILL - OPAC request creation error if submitted empty while ILLModuleDisclaimerByType is in use

### Installation and upgrade (command-line installer)

#### Critical bugs fixed

- [36986](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36986) (Bug 26176 follow-up) Fix rename StaffLoginBranchBasedOnIP in DBRev

### MARC Authority data support

#### Critical bugs fixed

- [36832](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36832) Adding authority records is broken

#### Other bugs fixed

- [36388](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36388) Mouse operation does not work in draggable fields in authority editor (with Firefox)
- [36791](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36791) Koha explodes when trying to edit an authority record with an invalid authid

  **Sponsored by** *Ignatianum University in Cracow*
- [36799](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36799) Illegitimate modification of MARC authid field content (001)

  **Sponsored by** *Ignatianum University in Cracow*

### MARC Bibliographic data support

#### Other bugs fixed

- [34663](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34663) Errors in UNIMARC default framework

### Notices

#### Other bugs fixed

- [23296](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23296) Auto Renewal Notice does not use Library specific notices
- [35285](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35285) Centralise notice content wrapping for HTML output
- [36652](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36652) Cannot copy notice from one library to another

### OPAC

#### Other bugs fixed

- [16567](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16567) RSS feeds show issues in W3C validator and can't be read by some aggregators (Chimpfeedr, feedbucket)
- [35929](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35929) Don't submit 'empty' changes to personal details in OPAC
- [35969](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35969) Improve error message, remove some logging when sending a cart from the OPAC
- [36142](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36142) Usermenu "Recalls history" not active when confirming recall
- [36341](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36341) "Hold starts on date" should be limited to future dates
- [36390](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36390) Two minor OPAC CSS fixes
- [36772](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36772) OPAC self checkout accepts wrong or partial barcodes
- [36785](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36785) Tagging: Resolve warning about unrecognized biblionumber

### Patrons

#### Critical bugs fixed

- [33832](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33832) Can't change a patron's username without entering passwords

#### Other bugs fixed

- [30318](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30318) Cannot override default patron messaging preferences when creating a patron in staff interface
- [30987](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30987) Adding relationship to PatronQuickAddFields causes it to be added 2x
- [33849](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33849) Duplicate patron warning resets patron's library if different than logged in user's library

  **Sponsored by** *Koha-Suomi Oy*
- [35599](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35599) Pronouns and HidePersonalPatronDetailOnCirculation
  >Bug 10950 adds a pronouns text field to the patron record.
  >It was hidden by the system preference 'HidePersonalPatronDetailOnCirculation', not anymore.
- [36321](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36321) Problem when dateexpiry in BorrowerUnwantedField
- [36353](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36353) Ensure consistent empty selection style for guarantor relationship drop-downs
- [36371](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36371) Patron attributes will not show in brief info if value is 0
- [36376](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36376) Display library limitations alert in patron's messages
- [36452](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36452) Patron message does not respect multiple line display
- [36529](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36529) manage_additional_fields permission for more than acquisitions and serials
- [36816](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36816) OPAC - Patron 'submit update request' does not work for clearing patron attribute types
- [36825](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36825) Cannot hide "Protected" field via BorrowerUnwantedField system preference

  **Sponsored by** *Koha-Suomi Oy*

### Preservation

#### Other bugs fixed

- [35714](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35714) Clicking Print slips when no letter template selected causes error
- [36649](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36649) Adding recently added items to processing from waiting list does not work if processing includes information from database columns

### REST API

#### Critical bugs fixed

- [36612](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36612) The public tickets endpoint needs public fields list

#### Other bugs fixed

- [35129](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35129) REST API: _per_page=0 crashes on Illegal division by zero
- [36420](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36420) REST API Basic Auth does not support cardnumbers, only userid
- [36421](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36421) Better logging of 500 errors in V1/Auth.pm
- [36483](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36483) Calling $object->to_api directly should be avoided
- [36493](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36493) Test for GET /api/v1/cash_registers/:cash_register_id/cashups is fragile

### Reports

#### Other bugs fixed

- [35943](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35943) SQL reports groups/subgroups whose name contains regexp special characters break table filtering
- [36534](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36534) Batch operations when using limit in report
- [36796](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36796) Fix mistake in database column descriptions for statistics table

### SIP2

#### Other bugs fixed

- [36676](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36676) SIP2 drops connection when using unknown patron id in fee paid message

### Searching

#### Critical bugs fixed

- [36563](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36563) Item search does not search for multiple values

#### Other bugs fixed

- [32695](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32695) Search string for various 7xx linking fields is incorrectly formed
  >This fixes the search links for the MARC21 linking fields 775, 780, 785, 787 to search for $a and $t in separate indexes instead of searching for both in the title index.

### Searching - Elasticsearch

#### Other bugs fixed

- [32707](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32707) Elasticsearch should not auto truncate (even if  QueryAutoTruncate = 1) for identifiers (and some other fields)
- [33099](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33099) Add missing MARC21 match authority mappings so "Search all headings" search works
- [33205](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33205) (Bug 28268 follow-up) Method call $row->authid inside quotes - produces meaningless warning
- [36269](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36269) Elasticsearch: publisher-location (pl) index should include 260a/264a (MARC21)
  >This enhancement adds 260$a and 264$a to the publisher-location (pl) Elasticsearch index for MARC21 records. Values in those two fields will be findable using the Publisher location option in the advanced search.
  >
  >Note: for existing installations, the index needs to be rebuilt using -r (reset mappings) in order for this information to be taken into account.

  **Sponsored by** *Steiermärkische Landesbibliothek*
- [36394](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36394) Inconsistent behaviour in footers (mappings admin page)

  **Sponsored by** *The Research University in the Helmholtz Association (KIT)*
- [36554](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36554) Document languages from field 041 should be present in 'ln' search field and Languages facet (MARC 21)
- [36678](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36678) Include fields with non-filing characters removed when indexing

### Searching - Zebra

#### Other bugs fixed

- [27198](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27198) Sync marc21-retrieval-info-auth-dom.xml with retrieval-info-auth-dom.xml
  >This fixes the syntax in marc21-retrieval-info-auth-dom.xml, so that one can use the Zebra special retrieval elements documented at https://software.indexdata.com/zebra/doc/special-retrieval.html
  >
  >These are very useful when troubleshooting issues with authority records in Zebra.

### Self checkout

#### Other bugs fixed

- [23102](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23102) 404 errors on page causes SCI user to be logged out

### Serials

#### Other bugs fixed

- [36804](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36804) Serials claims 'Clear filter' doesn't work

### Staff interface

#### Other bugs fixed

- [35868](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35868) Warning sign for using a patron category that is limited to another library has moved to other side of page
- [35961](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35961) Modal include missing for catalog concerns
- [36462](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36462) Home button breadcrumb appears twice when viewing/editing the authority MARC subfield structure
  >Previously, the 'Home' breadcrumb button would appear twice in succession when viewing or editing the authority MARC subfield structure for a particular field. Following a trivial template fix, the 'Home' breadcrumb button will now appear only once.
- [36673](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36673) Limit search for used categories and item types to current library
- [36834](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36834) (Bug 29697 follow-up) Koha explodes when trying to open in Labeled MARC view a bibliographic record with an invalid biblionumber

### System Administration

#### Other bugs fixed

- [35457](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35457) Move SerialsDefaultEMailAddress and SerialsDefaultReplyTo to serials preferences
- [35708](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35708) System parameter AutoRenewalNotices defaults to deprecated option
  >NEW INSTALLATIONS ONLY. This sets the default value for the AutoRenewalNotices system preference to "according to patron messaging preferences". (The previous default value was deprecated - "(Deprecated) according to --send-notices cron switch".)
- [35973](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35973) System preference RedirectGuaranteeEmail has incorrect values
- [36409](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36409) System preference name consistency - change EMail to Email for SerialsDefaultEMailAddress and AcquisitionsDefaultEMailAddress

### Templates

#### Other bugs fixed

- [35857](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35857) Update display of Clear and Cancel links in the authority search pop-up window
- [36282](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36282) OPAC - Remove trailing and leading blank space from translated strings
- [36295](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36295) Space out content blocks in batch record deletion
- [36528](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36528) Incorrect path to enquire.js on self checkout slip print page
- [36892](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36892) Wrong label on filter-orders include

### Test Suite

#### Other bugs fixed

- [36160](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36160) Use $builder->build_object when creating patrons in Circulation.t
- [36268](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36268) Letters.t assumes an empty ReplyToDefault
- [36567](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36567) Datetime warning in t/db_dependent/Circulation.t and t/db_dependent/Circulation/dateexpiry.t

  **Sponsored by** *Koha-Suomi Oy*
- [36916](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36916) TestBuilder generates incorrect JS and CSS for libraries
- [36923](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36923) Holds/LocalHoldsPriority.t generates warnings
- [36924](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36924) t/db_dependent/Search.t generates warnings
- [36939](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36939) Serials.t generates a warning

### Tools

#### Other bugs fixed

- [34621](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34621) Patron import option to 'Renew existing patrons' 'from the current membership expiry date' not implemented
  >This fixes the option when importing patrons so that the expiry date is updated for existing patrons (Tools > Patrons > Import patrons > Preserve existing values > Overwrite the existing one with this > Renew existing patrons - from the current membership expiry date).
- [36082](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36082) OPACResultsSideBar not working with library specific message

### Web services

#### Other bugs fixed

- [36335](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36335) ILS-DI GetRecords bad encoding for UNIMARC

### Z39.50 / SRU / OpenSearch Servers

#### Other bugs fixed

- [34041](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34041) z3950 responder additional options not coming through properly

### translate.koha-community.org

#### Other bugs fixed

- [36730](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36730) (Bug 35428 follow-up) po files (sometimes) fail to update

## Enhancements 

### Architecture, internals, and plumbing

#### Enhancements

- [31345](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31345) Add ability to exit process_message_queue.pl early if any plugin before_send_messages hook fails
- [36792](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36792) Limit POSIX imports

### Cataloging

#### Enhancements

- [30554](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30554) Use XSLT in authority search cataloguing plugin
  >This fixes the authority search cataloguing plugin so that the search results when adding an authority term to a record are customisable when using the AuthorityXSLTResultsDisplay system preference (for both MARC21 and UNIMARC).

  **Sponsored by** *Écoles nationales supérieure d'architecture (ENSA)*
- [35034](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35034) Add link to the bibliographic records when they are selected for merging
- [35768](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35768) Show 'Used in' records link for results in cataloguing authority plugin

  **Sponsored by** *Education Services Australia SCIS*
- [36370](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36370) Add ContentWarningField to UNIMARC XSLT
  >This enhancement enables UNIMARC installations to pick a note field to use to store 'Content warnings' about bibliographic records, using the ContentWarningField system preference (added in Koha 23.05 by bug 31123, but only for MARC21 installations).
  >
  >To use this feature, add a tag and subfields to your bibliographic framework(s), and update the ContentWarningField system preference with the tag to use. A 'Content warning:' label will then be displayed in the OPAC and staff interface, on both the detail and results pages.  If a $u subfield for a URL is added, the $a subfield will use this as to create a clickable link. Other subfields will be displayed after the $a subfield.

### Circulation

#### Enhancements

- [36074](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36074) Make materials specified note easier to customize, part 2

### Command-line Utilities

#### Enhancements

- [31286](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31286) Embed see-from headings into bibliographic records export
  >This adds a new option `--embed_see_from_headings` to the CLI script `export_records.pl`. It allows to include the see-also headings from the linked authority records in the exported bibliographic records.
- [35954](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35954) Add --status to koha-plack
- [35996](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35996) Add clarification to POD in writeoff_debts.pl

### Hold requests

#### Enhancements

- [31981](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31981) Add classes to each NEEDSCONFIRM message for easier styling in circ/circulation.tt
  >This patch adds a unique class to each "needs confirmation" message shown in circulation. Previously the only selector for any circulation message needing confirmation was #circ_needsconfirmation, so CSS or jQuery targeting only a single specific message was not easy to do.
  >With this patch you can directly target the new unique class selector for the specific message found behind the class element .needsconfirm.

### MARC Authority data support

#### Enhancements

- [35903](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35903) In cataloguing authority plugin using autocomplete should set operator exact after selecting an entry

### OPAC

#### Enhancements

- [35689](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35689) Add id and classes to each MARC note in OPAC bibliographic details
  >This enhancement adds id and class attributes to each MARC note in the description tab for the OPAC bibliographic detail page.
  >
  >It adds a unique id for each note (for unique styling of each repeated tag), and a general and unique class for each tag (for consistent styling across the same tag number). An example of the HTML output: 
  >```
  ><p id="marcnote-500-2" class="marcnote marcnote-500">...</p>
  >```
  >Styles can be defined for notes and individual tags in the `OPACUserCSS` system preference - see the test plan for an example.
- [36138](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36138) Add cancellation reason to the status column on the OPAC hold history page

### Patrons

#### Enhancements

- [34574](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34574) Datatables column dropdown select filter does not have a CSS class
- [34575](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34575) Patron search results: Add a CSS class to patron email to ease customization

### REST API

#### Enhancements

- [22613](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22613) Add /patrons/patron_id/checkouts endpoints
- [26297](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26297) Add a route to list patron categories
- [35353](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35353) Add API endpoint to fetch patron's previous holds
- [35967](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35967) Add /api/v1/patrons/{patron_id}/recalls endpoint to list a patron's recalls

  **Sponsored by** *Auckland University of Technology*
- [36480](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36480) Add GET /libraries/:library_id/desks
  >This enhancement adds an API endpoint for requesting a list of desks for a library. For example: http://127.0.0.1:8080/api/v1/libraries/cpl/desks
- [36481](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36481) Add GET /libraries/:library_id/cash_registers
  >This enhancement adds an API endpoint for requesting a list of cash registers for a library. For example: http://127.0.0.1:8080/api/v1/libraries/cpl/cash_registers
- [36482](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36482) Make it possible to embed desks and cash_registers on /libraries

### Reports

#### Enhancements

- [36380](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36380) Filter matches not included in borrowers statistics reports

### SIP2

#### Enhancements

- [36605](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36605) TrackLastPatronActivity for SIP should track both patron status and patron information requests

### Searching - Elasticsearch

#### Enhancements

- [35345](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35345) Pass custom SQL to rebuild_elasticsearch.pl to determine which records to index
  >This adds a `--where` parameter to the `rebuild_elasticsearch.pl` script that allows to flexibly select the records for reindexing with SQL. Examples would be the authority type or ranges and lists of biblionumbers and authids.

  **Sponsored by** *HKS3 / koha-support.eu* and *Steiermärkische Landesbibliothek*
- [36574](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36574) Canceled/invalid ISBN not indexed for MARC21
  >This adds a new search index `isbn-all` to the default Elasticsearch search mappings that includes the valid, canceled and invalid ISBNs.
- [36723](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36723) Add musical presentation to Elasticsearch index mappings

  **Sponsored by** *Education Services Australia SCIS*

### Searching - Zebra

#### Enhancements

- [35621](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35621) Map ÿ to y for searching (Non-ICU)

### Staff interface

#### Enhancements

- [35444](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35444) Add easy way to retrieve a logged in user's categorycode
  >This adds a hidden span to the HTML source code of the staff interface that includes the patron category code of the currently logged in staff user.
- [35582](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35582) Advanced search languages should be listed with selected UI language descriptions shown first if available
- [35810](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35810) Add back to top button to the staff interface
  >This adds a 'back to the top' button to the staff interface, similar to the one in the OPAC, that appears in the bottom right corner when scrolling down on pages.
- [36265](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36265) Bigger font-size for headers in staff interface

### Templates

#### Enhancements

- [35558](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35558) Do not fetch local image if none exists
- [36472](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36472) Add search box at the top of the authorities editor page
  >This adds the search header to the authorities editor page. With the recent staff interface redesign, this takes up very little space.

### Test Suite

#### Enhancements

- [36486](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36486) Add tests for Koha::DateTime::Format::SQL

## New system preferences

- AcquisitionsDefaultEmailAddress
- ESPreventAutoTruncate
- SerialsDefaultEmailAddress
- StaffLoginLibraryBasedOnIP
- StaffLoginRestrictLibraryByIP

## Deleted system preferences

- AcquisitionsDefaultEMailAddress
- AutoLocation
- SerialsDefaultEMailAddress

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/23.11//html/) (74%)
- [English](https://koha-community.org/manual/23.11//html/) (100%)
- [English (USA)](https://koha-community.org/manual/23.11/en/html/)
- [French](https://koha-community.org/manual/23.11/fr/html/) (44%)
- [German](https://koha-community.org/manual/23.11/de/html/) (40%)
- [Hindi](https://koha-community.org/manual/23.11/hi/html/) (80%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (99%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Traditional) (91%)
- Czech (69%)
- Dutch (77%)
- English (100%)
- English (New Zealand) (64%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (96%)
- German (99%)
- German (Switzerland) (52%)
- Greek (52%)
- Hindi (99%)
- Italian (84%)
- Norwegian Bokmål (76%)
- Persian (fa_ARAB) (92%)
- Polish (99%)
- Portuguese (Brazil) (92%)
- Portuguese (Portugal) (88%)
- Russian (92%)
- Slovak (62%)
- Spanish (100%)
- Swedish (87%)
- Telugu (70%)
- Turkish (81%)
- Ukrainian (74%)
- hyw_ARMN (generated) (hyw_ARMN) (65%)
</div>

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 23.11.06 is


- Release Manager: Katrin Fischer

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Martin Renvoize
  - Jonathan Druart

- QA Manager: Marcel de Rooy

- QA Team:
  - Marcel de Rooy
  - Julian Maurice
  - Lucas Gass
  - Victor Grousset
  - Kyle M Hall
  - Nick Clemens
  - Martin Renvoize
  - Tomás Cohen Arazi
  - Aleisha Amohia
  - Emily Lamancusa
  - David Cook
  - Jonathan Druart
  - Pedor Amorim

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - REST API -- Tomás Cohen Arazi
  - ERM -- Matt Blenkinsop
  - ILL -- Pedro Amorim
  - SIP2 -- Matthias Meusburger
  - CAS -- Matthias Meusburger

- Bug Wranglers:
  - Aleisha Amohia
  - Indranil Das Gupta

- Packaging Managers:
  - Mason James
  - Indranil Das Gupta
  - Tomás Cohen Arazi

- Documentation Manager: Aude Charillon

- Documentation Team:
  - Caroline Cyr La Rose
  - Kelly McElligott
  - Philip Orr
  - Marie-Luce Laflamme
  - Lucy Vaux-Harvey

- Translation Manager: Jonathan Druart


- Wiki curators: 
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 23.11 -- Fridolin Somers
  - 23.05 -- Lucas Gass
  - 22.11 -- Frédéric Demians
  - 22.05 -- Danyon Sewell

- Release Maintainer assistants:
  - 22.05 -- Wainui Witika-Park

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 23.11.06
<div style="column-count: 2;">

- Auckland University of Technology
- Education Services Australia SCIS
- HKS3 / koha-support.eu
- Ignatianum University in Cracow
- [Koha-Suomi Oy](https://koha-suomi.fi)
- Steiermärkische Landesbibliothek
- The Research University in the Helmholtz Association (KIT)
- Écoles nationales supérieure d'architecture (ENSA)
</div>

We thank the following individuals who contributed patches to Koha 23.11.06
<div style="column-count: 2;">

- Aleisha Amohia (2)
- Pedro Amorim (19)
- Tomás Cohen Arazi (19)
- Alex Arnaud (1)
- Stefan Berndtsson (1)
- Matt Blenkinsop (9)
- Jérémy Breuillard (1)
- Phan Tung Bui (2)
- Nick Clemens (48)
- David Cook (1)
- Chris Cormack (2)
- Jonathan Druart (35)
- Magnus Enger (2)
- Laura Escamilla (3)
- Katrin Fischer (16)
- Matthias Le Gac (3)
- Lucas Gass (16)
- Victor Grousset (2)
- Thibaud Guillot (5)
- David Gustafsson (2)
- Kyle M Hall (7)
- Andreas Jonsson (1)
- Janusz Kaczmarek (17)
- Jan Kissig (2)
- Thomas Klausner (2)
- Emily Lamancusa (9)
- Brendan Lawlor (4)
- Owen Leonard (9)
- Julian Maurice (7)
- David Nind (1)
- Philip Orr (1)
- Katariina Pohto (2)
- Liz Rea (1)
- Martin Renvoize (30)
- Phil Ringnalda (4)
- Marcel de Rooy (22)
- Caroline Cyr La Rose (3)
- Andreas Roussos (1)
- Danyon Sewell (1)
- Fridolin Somers (15)
- Lari Strand (1)
- Emmi Takkinen (4)
- Hammat Wele (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.11.06
<div style="column-count: 2;">

- Athens County Public Libraries (9)
- BibLibre (29)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (16)
- BigBallOfWax (2)
- ByWater-Solutions (75)
- Catalyst (1)
- Catalyst Open Source Academy (2)
- Chetco Community Public Library (4)
- clamsnet.org (4)
- Dataly Tech (1)
- David Nind (1)
- Göteborgs Universitet (2)
- Independant Individuals (21)
- Koha Community Developers (37)
- Koha-Suomi (6)
- Kreablo AB (1)
- Libriotech (2)
- lmscloud.de (1)
- montgomerycountymd.gov (9)
- Prosentient Systems (1)
- PTFS-Europe (58)
- Rijksmuseum (22)
- Solutions inLibro inc (9)
- th-wildau.de (2)
- Theke Solutions (19)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Michael Adamyk (1)
- Hebah Amin-Headley (1)
- Pedro Amorim (26)
- Tomás Cohen Arazi (12)
- BabaJaga (1)
- Donna Bachowski (1)
- Baptiste Bayche (1)
- Matt Blenkinsop (9)
- Christopher Brannon (1)
- Nick Clemens (56)
- Chris Cormack (2)
- Ray Delahunty (1)
- Frédéric Demians (3)
- Paul Derscheid (2)
- Roman Dolny (12)
- Jonathan Druart (17)
- Laura Escamilla (6)
- Jonathan Field (1)
- Katrin Fischer (295)
- Andrew Fuerste-Henry (9)
- Matthias Le Gac (1)
- Lucas Gass (22)
- Victor Grousset (27)
- Amit Gupta (2)
- Kyle M Hall (20)
- Sally Healey (2)
- Barbara Johnson (1)
- Janusz Kaczmarek (1)
- Sabrina Kiehl (1)
- Kristi Krueger (1)
- Emily Lamancusa (17)
- Brendan Lawlor (4)
- Owen Leonard (17)
- Esther Melander (3)
- David Nind (70)
- Martin Renvoize (58)
- Phil Ringnalda (2)
- Marcel de Rooy (51)
- Caroline Cyr La Rose (12)
- Fridolin Somers (317)
- Tadeusz Sośnierz (2)
- Michelle Spinney (2)
- Myka Kennedy Stephens (1)
- Anneli Österman (2)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 23.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 11 Jun 2024 07:02:05.
