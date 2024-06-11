# RELEASE NOTES FOR KOHA 23.05.12
11 Jun 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 23.05.12 can be downloaded from:

- [Download](http://download.koha-community.org/koha-23.05.12.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.05.12 is a bugfix/maintenance release.

It includes 3 security fixes, 12 enhancements, and 113 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).

#### Security bugs

- [36520](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36520) SQL Injection in opac-sendbasket.pl (CVE-2024-36058)
- [36575](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36575) Wrong patron can be returned for API validation route
- [36818](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36818) Remote-Code-Execution (RCE) in upload-cover-image.pl (CVE-2024-36057)

## Bugfixes

### Acquisitions

#### Critical bugs fixed

- [36035](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36035) Form is broken in addorderiso2709.pl
- [36053](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36053) Replacement prices not populating when supplied from MarcItemFieldsToOrder

#### Other bugs fixed

- [30598](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30598) Replacement cost is not copied from retail price when ordering from file
- [34963](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34963) Unable to delete fields in suggestions
- [35927](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35927) Selecting MARC framework again doesn't work when adding to basket from an external source
- [36036](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36036) Fix location field when ordering from staged files
- [36122](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36122) NEW_SUGGESTION is sent for every modification to the suggestion
- [36856](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36856) New order from existing bibliographic record does not show MARC subfield name

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [36665](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36665) Auto location and IP recognition
  >This patch adds a new system preference "StaffLoginLibraryBasedOnIP" which, when enabled, will set the logged in library to the library with an IP setting matching the current users IP. This preference will be overridden if "AutoLocation" is enabled, as that preference will enforce the user selecting a library that matches their current IP or signing into their home library from the correct IP.
- [36943](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36943) Update .mailmap for 24.05.x release

#### Other bugs fixed

- [34360](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34360) [WARN] DBIx::Class::ResultSetColumn::new(): Attempting to retrieve non-unique column 'biblionumber' on a resultset containing one-to-many joins will return duplicate results
- [35921](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35921) Improve performance of acquisitions start page when there are many budgets
- [35979](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35979) Possible RealTimeHoldsQueue check missing in modrequest.pl for BatchUpdateBiblioHoldsQueue background job
- [36378](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36378) Cannot stay logged in if AutoLocation is enabled but library's IP address is not set correctly
- [36386](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36386) Prevent Net::Server warn about User Not Defined from SIPServer
- [36395](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36395) Useless fetch of AV categories in admin/marc_subfields_structure.pl

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*
- [36432](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36432) Remove circular dependency from Koha::Object
- [36438](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36438) MARCdetail: Can't call method "metadata" on an undefined value
- [36463](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36463) We should compress our JSON responses (gzip deflate mod_deflate application/json)
- [36473](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36473) updatetotalissues.pl should not die on a bad record
  >This fixes the misc/cronjobs/update_totalissues.pl script so that it skips records with invalid data, instead of just stopping. (This also means that the 'Most-circulated items' report now shows the correct data - if the script stopped because of invalid records, the report may have not picked up circulated items.)
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
- [36331](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36331) Items that cannot be held are prevented renewal when there are holds on the record
- [36708](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36708) Problems editing circ rules when 'Holds allowed (total)' value is greater than or equal to 0

#### Other bugs fixed

- [34263](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34263) Suspending holds consecutively populates previously used date falsely
- [36347](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36347) Return claims table is loaded twice
- [36393](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36393) Renewal with a specific date does not take the new date due that we pick
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

### ERM

#### Other bugs fixed

- [36392](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36392) Only 20 vendors in ERM dropdown
  >This fixes the listing of vendors when adding a new agreement in the electronic resources (ERM) module. Previously only the first 20 vendors were displayed, now all vendors are displayed.

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
- [35573](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35573) Koha is not correctly warning of overridden items when placing a hold if AllowHoldPolicyOverride
- [35977](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35977) Display current date in hold starts on when placing a hold in the OPAC
- [36137](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36137) update_totalissues.pl should always skip_holds_queue
- [36227](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36227) No warning if placing hold on item group with no items

### I18N/L10N

#### Other bugs fixed

- [35531](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35531) Add context for translation of gender option "Other"
- [36516](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36516) translation script could output useless warning
- [36837](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36837) XSLT CSS classes offered for translations
- [36845](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36845) Exclude meta tag from the translations
- [36872](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36872) Untranslatable "Please make sure all selected titles have a pickup location set"

### MARC Authority data support

#### Critical bugs fixed

- [36832](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36832) Adding authority records is broken

#### Other bugs fixed

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

### OPAC

#### Critical bugs fixed

- [34886](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34886) Regression in when hold button appears

#### Other bugs fixed

- [16567](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16567) RSS feeds show issues in W3C validator and can't be read by some aggregators (Chimpfeedr, feedbucket)
- [35929](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35929) Don't submit 'empty' changes to personal details in OPAC
- [35969](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35969) Improve error message, remove some logging when sending a cart from the OPAC
- [36142](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36142) Usermenu "Recalls history" not active when confirming recall
- [36341](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36341) "Hold starts on date" should be limited to future dates
- [36390](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36390) Two minor OPAC CSS fixes

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

### REST API

#### Critical bugs fixed

- [36612](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36612) The public tickets endpoint needs public fields list

#### Other bugs fixed

- [35129](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35129) REST API: _per_page=0 crashes on Illegal division by zero
- [36329](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36329) Transfer limits should respect `BranchTransferLimitsType`
- [36420](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36420) REST API Basic Auth does not support cardnumbers, only userid
- [36421](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36421) Better logging of 500 errors in V1/Auth.pm
- [36493](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36493) Test for GET /api/v1/cash_registers/:cash_register_id/cashups is fragile

### Reports

#### Other bugs fixed

- [35943](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35943) SQL reports groups/subgroups whose name contains regexp special characters break table filtering
- [36534](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36534) Batch operations when using limit in report

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

- [33099](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33099) Add missing MARC21 match authority mappings so "Search all headings" search works
- [33205](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33205) (Bug 28268 follow-up) Method call $row->authid inside quotes - produces meaningless warning
- [36269](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36269) Elasticsearch: publisher-location (pl) index should include 260a/264a (MARC21)
  >This enhancement adds 260$a and 264$a to the publisher-location (pl) Elasticsearch index for MARC21 records. Values in those two fields will be findable using the Publisher location option in the advanced search.
  >
  >Note: for existing installations, the index needs to be rebuilt using -r (reset mappings) in order for this information to be taken into account.

  **Sponsored by** *Steiermärkische Landesbibliothek*
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
- [36834](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36834) (Bug 29697 follow-up) Koha explodes when trying to open in Labeled MARC view a bibliographic record with an invalid biblionumber

### Templates

#### Other bugs fixed

- [36282](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36282) OPAC - Remove trailing and leading blank space from translated strings
- [36295](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36295) Space out content blocks in batch record deletion
- [36892](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36892) Wrong label on filter-orders include

### Test Suite

#### Critical bugs fixed

- [36356](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36356) FrameworkPlugin.t does not rollback properly

#### Other bugs fixed

- [36567](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36567) Datetime warning in t/db_dependent/Circulation.t and t/db_dependent/Circulation/dateexpiry.t

  **Sponsored by** *Koha-Suomi Oy*
- [36923](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36923) Holds/LocalHoldsPriority.t generates warnings
- [36924](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36924) t/db_dependent/Search.t generates warnings
- [36939](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36939) Serials.t generates a warning

### Tools

#### Other bugs fixed

- [34621](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34621) Patron import option to 'Renew existing patrons' 'from the current membership expiry date' not implemented
  >This fixes the option when importing patrons so that the expiry date is updated for existing patrons (Tools > Patrons > Import patrons > Preserve existing values > Overwrite the existing one with this > Renew existing patrons - from the current membership expiry date).

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
- [35388](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35388) Add comment to circ/transfers_to_send.pl about limited use in stock rotation context
- [36792](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36792) Limit POSIX imports

### Cataloging

#### Enhancements

- [30554](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30554) Use XSLT in authority search cataloguing plugin
  >This fixes the authority search cataloguing plugin so that the search results when adding an authority term to a record are customisable when using the AuthorityXSLTResultsDisplay system preference (for both MARC21 and UNIMARC).

  **Sponsored by** *Écoles nationales supérieure d'architecture (ENSA)*
- [35034](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35034) Add link to the bibliographic records when they are selected for merging
- [35768](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35768) Show 'Used in' records link for results in cataloguing authority plugin

  **Sponsored by** *Education Services Australia SCIS*

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

### SIP2

#### Enhancements

- [36605](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36605) TrackLastPatronActivity for SIP should track both patron status and patron information requests

### Searching - Elasticsearch

#### Enhancements

- [36574](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36574) Canceled/invalid ISBN not indexed for MARC21
  >This adds a new search index `isbn-all` to the default Elasticsearch search mappings that includes the valid, canceled and invalid ISBNs.
- [36723](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36723) Add musical presentation to Elasticsearch index mappings

  **Sponsored by** *Education Services Australia SCIS*

### Searching - Zebra

#### Enhancements

- [35621](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35621) Map ÿ to y for searching (Non-ICU)

### Staff interface

#### Enhancements

- [35582](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35582) Advanced search languages should be listed with selected UI language descriptions shown first if available

## New system preferences

- StaffLoginBranchBasedOnIP

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/23.05/zh_Hant/html/) (74%)
- [English](https://koha-community.org/manual/23.05//html/) (100%)
- [English (USA)](https://koha-community.org/manual/23.05/en/html/)
- [French](https://koha-community.org/manual/23.05/fr/html/) (44%)
- [German](https://koha-community.org/manual/23.05/de/html/) (40%)
- [Hindi](https://koha-community.org/manual/23.05/hi/html/) (80%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (87%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Traditional) (99%)
- Czech (70%)
- Dutch (83%)
- English (100%)
- English (New Zealand) (68%)
- English (USA)
- Finnish (99%)
- French (100%)
- French (Canada) (99%)
- German (100%)
- German (Switzerland) (55%)
- Greek (55%)
- Hindi (100%)
- Italian (91%)
- Norwegian Bokmål (78%)
- Persian (fa_ARAB) (99%)
- Polish (100%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (98%)
- Slovak (66%)
- Spanish (100%)
- Swedish (88%)
- Telugu (76%)
- Turkish (87%)
- Ukrainian (80%)
- hyw_ARMN (generated) (hyw_ARMN) (69%)
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

The release team for Koha 23.05.12 is


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
  - Pedro Amorim

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
new features in Koha 23.05.12
<div style="column-count: 2;">

- Education Services Australia SCIS
- Ignatianum University in Cracow
- Karlsruhe Institute of Technology (KIT)
- [Koha-Suomi Oy](https://koha-suomi.fi)
- Steiermärkische Landesbibliothek
- Écoles nationales supérieure d'architecture (ENSA)
</div>

We thank the following individuals who contributed patches to Koha 23.05.12
<div style="column-count: 2;">

- Aleisha Amohia (1)
- Pedro Amorim (10)
- Tomás Cohen Arazi (14)
- Matt Blenkinsop (1)
- Jérémy Breuillard (1)
- Phan Tung Bui (2)
- Nick Clemens (40)
- David Cook (1)
- Chris Cormack (2)
- Jonathan Druart (18)
- Magnus Enger (1)
- Laura Escamilla (3)
- Katrin Fischer (3)
- Matthias Le Gac (3)
- Lucas Gass (14)
- Thibaud Guillot (2)
- Kyle M Hall (6)
- Janusz Kaczmarek (11)
- Jan Kissig (1)
- Thomas Klausner (1)
- Emily Lamancusa (4)
- Brendan Lawlor (3)
- Owen Leonard (6)
- Julian Maurice (5)
- Philip Orr (1)
- Katariina Pohto (2)
- Liz Rea (1)
- Martin Renvoize (13)
- Phil Ringnalda (4)
- Marcel de Rooy (16)
- Caroline Cyr La Rose (2)
- Andreas Roussos (1)
- Danyon Sewell (1)
- Fridolin Somers (10)
- Lari Strand (1)
- Emmi Takkinen (3)
- Hammat Wele (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.05.12
<div style="column-count: 2;">

- Athens County Public Libraries (6)
- [BibLibre](https://www.biblibre.com) (18)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (3)
- BigBallOfWax (2)
- [ByWater Solutions](https://bywatersolutions.com) (64)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (3)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (1)
- Catalyst Open Source Academy (1)
- Chetco Community Public Library (4)
- [Dataly Tech](https://dataly.gr) (1)
- Independant Individuals (13)
- Koha Community Developers (18)
- [Koha-Suomi Oy](https://koha-suomi.fi) (5)
- [Libriotech](https://libriotech.no) (1)
- [LMSCloud](lmscloud.de) (1)
- [Montgomery County Public Libraries](montgomerycountymd.gov) (4)
- [Prosentient Systems](https://www.prosentient.com.au) (1)
- [PTFS Europe](https://ptfs-europe.com) (24)
- Rijksmuseum, Netherlands (16)
- [Solutions inLibro inc](https://inlibro.com) (8)
- [Theke Solutions](https://theke.io) (14)
- Wildau University of Technology (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Hebah Amin-Headley (1)
- Pedro Amorim (13)
- Tomás Cohen Arazi (11)
- BabaJaga (1)
- Baptiste Bayche (1)
- Matt Blenkinsop (5)
- Nick Clemens (34)
- Chris Cormack (1)
- Ray Delahunty (1)
- Frédéric Demians (2)
- Roman Dolny (10)
- Jonathan Druart (11)
- Laura Escamilla (4)
- Katrin Fischer (187)
- Andrew Fuerste-Henry (7)
- Matthias Le Gac (1)
- Lucas Gass (207)
- Victor Grousset (10)
- Amit Gupta (2)
- Kyle M Hall (14)
- Barbara Johnson (2)
- Janusz Kaczmarek (1)
- Sabrina Kiehl (1)
- Kristi Krueger (1)
- Emily Lamancusa (10)
- Brendan Lawlor (4)
- Owen Leonard (13)
- Esther Melander (2)
- David Nind (45)
- Martin Renvoize (40)
- Phil Ringnalda (2)
- Marcel de Rooy (41)
- Caroline Cyr La Rose (9)
- Fridolin Somers (179)
- Myka Kennedy Stephens (1)
- Anneli Österman (1)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 23.05.x-security.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 11 Jun 2024 14:26:28.
