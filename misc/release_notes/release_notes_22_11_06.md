# RELEASE NOTES FOR KOHA 22.11.06
23 May 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.11.06 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.11.06.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.11.06 is a bugfix/maintenance release.

It includes 8 enhancements, 161 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).




## Security


- [33702](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33702) Patrons should only see their own ILLs in the OPAC

## Bugfixes



### Acquisitions



#### Critical bugs fixed


- [33262](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33262) When an ordered record is deleted, we lose all information on what was ordered
- [33653](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33653) Search for late orders can show received order lines


#### Other bugs fixed


- [32484](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32484) Enable framework plugins when UseACQFrameworkForBiblioRecords is set
  >This bugfix enables the use of framework plugins when: 
  >- `UseACQFrameworkForBiblioRecords` is enabled, and
  >- entering catalog details when adding items to a basket from a new (empty) record. 
  >This requires plugins to be enabled for fields in the `ACQ` framework.




### Architecture, internals, and plumbing





#### Other bugs fixed


- [32990](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32990) Possible deadlock in C4::ImportBatch::_update_batch_record_counts
- [32992](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32992) Move background worker script to misc/workers
- [33053](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33053) Tables item_groups and recalls have a biblio_id column with a default of 0
- [33167](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33167) Cleanup staff interface catalog details page
- [33447](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33447) Add caching to Biblio->pickup_locations
- [33488](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33488) Library transfer limits should have an index on fromBranch
- [33489](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33489) The borrowers table should have indexes on default patron search fields
- [33710](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33710) Ignore howto files




### Cataloging



#### Critical bugs fixed


- [28328](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28328) Editing a record can cause an ISE if data too long for column
- [33445](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33445) Regression - Replacing authority via Z39.50 will not search for anything but the value from the existing authority
- [33591](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33591) Cannot merge bibliographic records


#### Other bugs fixed


- [32253](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32253) Advanced cataloging editor doesn't load every line initially
- [32817](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32817) Clean up cataloguing/value_builder/dateaccessioned.pl
- [32818](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32818) Clean up cataloguing/value_builder/marc21_field_005.pl
- [32865](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32865) Clean up cataloguing/value_builder/unimarc_field_146a.pl
- [32866](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32866) Clean up cataloguing/value_builder/unimarc_field_146h.pl
- [32867](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32867) Clean up cataloguing/value_builder/unimarc_field_146i.pl
- [32868](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32868) Fix cataloguing/value_builder/unimarc_field_210c_bis.pl
- [32869](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32869) Fix cataloguing/value_builder/unimarc_field_210c.pl
- [32870](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32870) Fix cataloguing/value_builder/unimarc_field_225a_bis.pl
- [32871](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32871) Fix cataloguing/value_builder/unimarc_field_225a.pl
- [32872](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32872) Fix cataloguing/value_builder/unimarc_field_4XX.pl
- [32873](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32873) Fix cataloguing/value_builder/unimarc_field_686a.pl
- [32874](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32874) Fix cataloguing/value_builder/unimarc_field_700-4.pl
- [32875](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32875) Fix cataloguing/value_builder/unimarc_leader_authorities.pl
- [32876](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32876) Fix cataloguing/value_builder/unimarc_leader.pl
- [33655](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33655) z39.50 search no longer shows search in progress




### Circulation



#### Critical bugs fixed


- [33300](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33300) Wrong system preference name AutomaticWrongTransfer


#### Other bugs fixed


- [18398](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18398) CHECKIN/CHECKOUT/RENEWAL don't use AutoEmailPrimaryAddress but first valid e-mail
  >This enhancement applies the EmailFieldPrimary (formerly AutoEmailPrimaryAddress) system preference choice to the CHECKIN, CHECKOUT, RENEWAL and various RECALL notices.
- [26967](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26967) Patron autocomplete does not correctly format addresses
- [32121](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32121) Show an alert when adding a checked out item to an item bundle
- [32129](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32129) Use patron categorycode of most relevant recall when checking if item can be a waiting recall

  **Sponsored by** *Auckland University of Technology*
  >This patch uses the patron category of the patron who requested the most relevant recall to check for more specific circulation rules relating to recalls. This ensures that patrons who are allowed to place recalls are able to fill their recalls, especially when recalls are not  generally available for all patron categories.
- [33021](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33021) Show an alert when adding an item on hold to an item bundle
  >When adding an item that is currently on hold to an item bundle, a warning will display, but you can still choose to add the item to the bundle.
- [33577](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33577) Buttons on reserve/request.pl are misaligned
- [33613](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33613) Claim return doesn't charge when "Ask if a lost fee should be charged" is selected and marked to charge




### Command-line Utilities



#### Critical bugs fixed


- [33108](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33108) We need a way to launch the ES indexer automatically
- [33603](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33603) misc/maintenance/search_for_data_inconsistencies.pl fails if biblio.biblionumber on control field


#### Other bugs fixed


- [33626](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33626) compare_es_to_db.pl does not work with Search::Elasticsearch 7.0
- [33645](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33645) koha-foreach always returns 1 if --chdir not specified
- [33677](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33677) Remove --verbose from koha-worker manpage




### Database





#### Other bugs fixed


- [32357](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32357) Set borrower_message_preferences.days_in_advance default to NULL
  >This fixes the default value in the database for the 'Days in advance' field for patron messaging preferences so that it defaults to NULL instead of 0 (borrower_message_preferences table and the days_in_advance field).




### ERM



#### Critical bugs fixed


- [32782](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32782) Add UNIMARC support to the ERM module
- [33482](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33482) Errors from EBSCO's ws are not reported to the UI
- [33483](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33483) Cannot link EBSCO's package with local agreement
- [33623](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33623) getAll not encoding URL params


#### Other bugs fixed


- [33354](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33354) Error 400 Bad Request when submitting form in ERM
- [33355](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33355) ERM UI and markup has some issues
- [33408](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33408) Fetch sysprefs from svc/config/systempreferences

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*
- [33490](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33490) Agreements - Filter by expired results in error
- [33491](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33491) EBSCO Packages - Add new agreement UI has some issues
- [33648](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33648) Errors when enabling ERM in 22.11




### Hold requests



#### Critical bugs fixed


- [30687](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30687) Unable to override hold policy if no pickup locations are available
- [33611](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33611) Holds being placed in the future if DefaultHoldExpirationdate is set


#### Other bugs fixed


- [32627](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32627) Reprinting holds slips should not reset the expiration date
- [32993](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32993) Holds priority changed incorrectly with dropdown selector
- [33210](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33210) (Bug 31963 follow-up) No hold fee message on OPAC should be displayed when there is no fee
- [33302](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33302) Placing item level holds in OPAC allows to pick forbidden pick-up locations, but then places no hold
- [33672](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33672) Item group features shows when placing holds if EnableItemGroupHolds is disabled




### I18N/L10N



#### Critical bugs fixed


- [30352](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30352) "Not for loan" in result list doesn't translate in OPAC


#### Other bugs fixed


- [26403](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26403) Move debit and credit types to YAML files and fix other related translation issues
  >With this patch the descriptions of system internal credit and debit types will be translated into the selected language at installation time. This will only affect new installations and SQL reporting. If you are building your own SQL reports, you'll be able to pull the descriptions from the tables.
  >
  >It also makes sure, that all system internal debit and credit types appear translated in the GUI. This now also includes the administration pages for managing credit and debit types. Some descriptions for discount, payout, purchase, and void were missing. These have now also been added.
- [32931](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32931) ERM - (is perpetual) Yes / No options untranslatable
- [33533](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33533) Translatability: Do not separate "Patron" or "Organization" and "identity" in memberentrygen.tt




### ILL





#### Other bugs fixed


- [22440](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22440) Improve ILL page performance by moving to server side filtering




### Installation and upgrade (command-line installer)



#### Critical bugs fixed


- [28267](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28267) Older databases fail to upgrade due to having a row format other than "DYNAMIC"






### Installation and upgrade (web-based installer)





#### Other bugs fixed


- [33671](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33671) Database update  22.06.00.048  breaks update process




### MARC Authority data support



#### Critical bugs fixed


- [32250](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32250) link_bibs_to_authorities generates too many background jobs
- [33277](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33277) Correctly handle linking subfields with no defined thesaurus
- [33557](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33557) Add a system preference to disable/enable thesaurus checking during authority linking






### MARC Bibliographic data support





#### Other bugs fixed


- [31432](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31432) MARC21: Make 245 n and p subfields visible in frameworks by default
- [32766](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32766) Update plugin unimarc_field_116.pl fields
  >This updates the labels for some values so that they match with the definitions in UNIMARC Bibliographic (3rd ed.) Updates, and to help with translation:
  >
  >- Specific material designation: 
  >  i- print (no change in display)
  >  m- master -> m- mould
  >
  >- Techniques (drawings, paintings) 1, 2, and 3:
  >  crayon -> charcoal
  >
  >- Technique (prints) 1,2, and 3:
  >  Label for dropdown list changed to Techniques (print) 1, 2, and 3
  >  camaiu -> cameo
  >  computer graphics -> infography
  >
  >- Functional designation
  >  ab- item cover -> ab- resource cover
  >  ag- chart -> ag- diagram
- [33419](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33419) Make home library and holding library in items mandatory by default
  >This will make the home library and holding library on the item form manatory for new installations. It's recommended to also manually make these changes for existing installations as Koha won't function properly if any of these fields are missing.




### Notices





#### Other bugs fixed


- [32917](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32917) Change patron.firstname and patron.surname in password change sample notice
- [33622](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33622) Notice content does not show on default tab if TranslateNotices enabled
- [33649](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33649) Fix use of cronlogaction




### OPAC



#### Critical bugs fixed


- [33069](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33069) File download from list in OPAC gives error


#### Other bugs fixed


- [32412](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32412) OPACShelfBrowser controls add extra Coce images to biblio-cover-slider
- [32701](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32701) Self checkout help page lacks required I18N JavaScript
- [32995](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32995) Koha agent string not sent for OverDrive fulfillment requests
- [33102](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33102) Cart in OPAC and staff interface does no longer display infos from biblioitems table
- [33233](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33233) OPAC advanced search inputs stay disabled when using browser's back button




### Packaging



#### Critical bugs fixed


- [33629](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33629) allow pbuilder to use network via build-git-snapshot






### Patrons



#### Critical bugs fixed


- [19249](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19249) Date picker broken in "Quick add new patron" form


#### Other bugs fixed


- [25379](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25379) HTML in circulation notes doesn't show correctly on checkin
- [32232](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32232) Koha crashes if dateofbirth is 1947-04-27, 1948-04-25, or 1949-04-24
- [33684](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33684) Able to save patron with empty mandatory date fields




### Plugin architecture





#### Other bugs fixed


- [30367](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30367) Plugins: Search explodes in error when searching for specific keywords




### REST API





#### Other bugs fixed


- [33328](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33328) x-marc-schema should be renamed x-record-schema
- [33329](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33329) GET /biblios encoding wrong when UNIMARC
- [33470](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33470) Don't calculate overridden values when placing a hold via the REST API




### Reports





#### Other bugs fixed


- [33513](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33513) Batch update from report module - no patrons loaded into view




### SIP2



#### Critical bugs fixed


- [33216](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33216) SIP fee paid messages explode if payment registers are enabled and the SIP account has no register


#### Other bugs fixed


- [33580](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33580) Bring back ability to mark item as seen via SIP2 item information request




### Searching





#### Other bugs fixed


- [33093](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33093) (Bug 27546 follow-up) With ES searching within results does not work for 'Keyword' and 'Keyword as phrase'
- [33506](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33506) Series has wrong index name on scan index page and search option selection is not retained
- [33569](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33569) Order by relevance may not be visible




### Searching - Elasticsearch



#### Critical bugs fixed


- [32594](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32594) Add a dedicated ES indexing background worker


#### Other bugs fixed


- [33206](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33206) Bad title__sort made of multisubfield 245
- [33486](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33486) Remove Koha::BackgroundJob::UpdateElasticIndex->process routine




### Searching - Zebra





#### Other bugs fixed


- [32937](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32937) Zebra: Ignore copyright symbol when searching




### Self checkout





#### Other bugs fixed


- [32921](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32921) SelfCheckTimeout doesn't logout if SelfCheckReceiptPrompt modal is open




### Serials





#### Other bugs fixed


- [33037](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33037) [Bugs 32555  and 31313 follow-up] Koha does not display difference between enumchron and serialseq in record detail view (OPAC and intranet)
- [33512](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33512) Labels/buttons are confusing on serials-edit page
- [33560](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33560) Batch edit link broken if subscriptions are selected using "select all" link




### Staff interface





#### Other bugs fixed


- [28315](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28315) PopupMARCFieldDoc is defined twice in addbiblio.tt
- [33253](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33253) 2FA - Form not excluded from autofill
- [33505](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33505) Improve styling of scan index page
- [33588](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33588) Inventory item list is missing page-section class
- [33590](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33590) WRAPPER tab_panel breaks JS on some pages (Select all/Clear all, post-Ajax updates)
- [33596](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33596) Merge result page is missing page-section
- [33615](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33615) Date picker icon not visible
- [33621](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33621) Javascript error when claiming return via circulation.pl
- [33631](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33631) results_summary label and content are slightly misaligned in staff interface
- [33642](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33642) Typo: No log found .
- [33643](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33643) Add page-section to 'scan index' page




### System Administration





#### Other bugs fixed


- [32745](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32745) Jobs view breaks when there are jobs with context IS NULL
- [33196](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33196) Terminology: rephrase Pseudonymization system preference to be more general
- [33197](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33197) Terminology: rename GDPR_Policy system preference
- [33335](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33335) MARC overlay rules broken because of "categorycode.categorycode " which contains "-"
- [33549](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33549) Patron restriction types - Style missing for dialog messages
- [33586](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33586) Library and category are switched in table configuration for patron search results table settings
- [33634](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33634) Sidebar navigation links in system preferences not taking user to the clicked section




### Templates





#### Other bugs fixed


- [22375](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22375) Due dates should be formatted consistently
- [31405](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31405) Set focus for cursor to setSpec input when adding a new OAI set
- [31410](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31410) Set focus for cursor to Server name when adding a new Z39.50 or SRU server
- [32642](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32642) Loading spinner always visible when cover image is short (OPAC)
- [33320](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33320) Patron modification requests: options are squashed
- [33336](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33336) Use a dedicated column for plugin status in plugins table
- [33388](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33388) Use template wrapper for breadcrumbs: Patrons part 4
- [33437](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33437) Use template wrapper for breadcrumbs: Reports part 2
- [33438](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33438) Use template wrapper for breadcrumbs: Reports part 3
- [33439](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33439) Use template wrapper for breadcrumbs: Reports part 4
- [33551](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33551) Rogue span in patron restriction types admin page title
- [33555](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33555) Use template wrapper for breadcrumbs: Rotating collections
- [33558](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33558) Use template wrapper for breadcrumbs: Serials part 1
- [33559](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33559) Use template wrapper for breadcrumbs: Serials part 2
- [33564](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33564) Use template wrapper for breadcrumbs: Serials part 3
- [33565](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33565) Use template wrapper for breadcrumbs: Tags
- [33566](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33566) Use template wrapper for breadcrumbs: Tools, part 1
- [33571](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33571) Use template wrapper for breadcrumbs: Tools, part 2
- [33572](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33572) Use template wrapper for breadcrumbs: Tools, part 3
- [33579](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33579) Typo: record record
- [33582](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33582) Use template wrapper for breadcrumbs: Tools, part 4
- [33597](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33597) Get rid of few SameSite warnings
- [33598](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33598) Use template wrapper for breadcrumbs: Tools, part 5
- [33600](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33600) Use template wrapper for breadcrumbs: Tools, part 7
- [33601](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33601) Use template wrapper for breadcrumbs: Tools, part 8
- [33696](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33696) Doubled up home icon in budgets page
- [33699](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33699) Typo in identity_provider_domains.tt (presedence)




### Test Suite



#### Critical bugs fixed


- [33416](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33416) Agreements.ts is failing


#### Other bugs fixed


- [33402](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33402) ERM Cypress tests needs to be moved to their own directory
- [33403](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33403) Letters.t: Foreign key exception if you do not have a numberpattern with id=1




### Tools



#### Critical bugs fixed


- [33156](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33156) Batch patron modification tool is missing search bar and other attributes
- [33412](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33412) (bug 15869 follow-up) Overlay record framework is always setting records to original framework
- [33576](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33576) Records are not indexed when imported if using Elasticsearch


#### Other bugs fixed


- [32041](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32041) OPAC and staff client results page do not honor SyndeticsCoverImageSize
- [33637](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33637) Batch patron modification broken




### Web services



#### Critical bugs fixed


- [33504](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33504) ILS-DI does not record renewer_id for renewals creating issue with renewal history view
















## Enhancements 

### Architecture, internals, and plumbing



#### Enhancements


- [33066](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33066) We need a KohaTable Vue component





























### ERM



#### Enhancements


- [32924](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32924) Filter agreements by logged in librarian
- [33064](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33064) Add a search option for licenses to top search bar

  **Sponsored by** *PTFS Europe*
- [33466](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33466) Link vendor name in list of licenses





























### Installation and upgrade (web-based installer)



#### Enhancements


- [33128](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33128) Add Polish translations for language descriptions











































































































### Templates



#### Enhancements


- [33127](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33127) Use template wrapper for breadcrumbs: Administration part 5
- [33310](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33310) Use template wrapper for tabs: Suggestions











### Tools



#### Enhancements


- [32164](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32164) Add link to MARC modification templates from batch record modification page











## New system preferences
- AutomaticConfirmTransfer
- LinkerConsiderThesaurus
- PrivacyPolicyConsent


## Deleted system preferences
- AutomaticWrongTransfer
- GDPR_Policy


## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)



The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (72.2%)
- Armenian (100%)
- Armenian (Classical) (64.9%)
- Bulgarian (90.8%)
- Chinese (Taiwan) (81.7%)
- Czech (59.9%)
- English (New Zealand) (68.4%)
- English (USA)
- English (United Kingdom) (100%)
- Finnish (95.6%)
- French (99.3%)
- French (Canada) (95.9%)
- German (100%)
- German (Switzerland) (50.4%)
- Greek (50.4%)
- Hindi (100%)
- Italian (92.2%)
- Nederlands-Nederland (Dutch-The Netherlands) (85%)
- Norwegian Bokmål (64.9%)
- Persian (70.4%)
- Polish (93.9%)
- Portuguese (89.6%)
- Portuguese (Brazil) (100%)
- Russian (93.8%)
- Slovak (62%)
- Spanish (100%)
- Swedish (76%)
- Telugu (77.4%)
- Turkish (87.4%)
- Ukrainian (78.2%)
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

The release team for Koha 22.11.06 is


- Release Manager: Tomás Cohen Arazi

- Release Manager assistants:
  - Jonathan Druart
  - Martin Renvoize

- QA Manager: Katrin Fischer

- QA Team:
  - Aleisha Amohia
  - Nick Clemens
  - David Cook
  - Jonathan Druart
  - Lucas Gass
  - Victor Grousset
  - Kyle M Hall
  - Martin Renvoize
  - Marcel de Rooy
  - Fridolin Somers

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - REST API -- Martin Renvoize

- Bug Wranglers:
  - Aleisha Amohia
  - Indranil Das Gupta

- Packaging Manager: Mason James


- Documentation Manager: Caroline Cyr La Rose


- Documentation Team:
  - Aude Charillon
  - David Nind
  - Lucy Vaux-Harvey

- Translation Manager: Bernardo González Kriegel


- Wiki curators: 
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 22.11 -- PTFS Europe (Martin Renvoize, Matt Blenkinsop, Jacob O'Mara, Pedro Amorim)
  - 22.05 -- Lucas Gass
  - 21.11 -- Arthur Suzuki
  - 21.05 -- Wainui Witika-Park

## Credits
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 22.11.06
<div style="column-count: 2;">

- Auckland University of Technology
- [Bibliothèque Universitaire des Langues et Civilisations (BULAC)](http://www.bulac.fr)
</div>

We thank the following individuals who contributed patches to Koha 22.11.06
<div style="column-count: 2;">

- Aleisha Amohia (2)
- Pedro Amorim (23)
- Tomás Cohen Arazi (39)
- Matt Blenkinsop (2)
- Nick Clemens (41)
- David Cook (3)
- Frédéric Demians (1)
- Jonathan Druart (70)
- emlam (1)
- Magnus Enger (3)
- Laura Escamilla (1)
- Katrin Fischer (31)
- Lucas Gass (12)
- Didier Gautheron (1)
- Thibaud Guillot (2)
- Kyle M Hall (5)
- Mason James (2)
- Janusz Kaczmarek (6)
- Owen Leonard (24)
- Marius Mandrescu (1)
- Julian Maurice (17)
- Josef Moravec (1)
- Jacob O'Mara (3)
- Philip Orr (1)
- Martin Renvoize (13)
- Marcel de Rooy (17)
- Caroline Cyr La Rose (3)
- Slava Shishkin (4)
- Fridolin Somers (4)
- Lari Taskula (1)
- Koha translators (1)
- Hammat Wele (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.11.06
<div style="column-count: 2;">

- Athens County Public Libraries (24)
- BibLibre (24)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (31)
- ByWater-Solutions (59)
- Catalyst Open Source Academy (2)
- Hypernova Oy (1)
- Independant Individuals (14)
- Koha Community Developers (70)
- KohaAloha (2)
- Libriotech (3)
- lmscloud.de (1)
- montgomerycountymd.gov (1)
- Prosentient Systems (3)
- PTFS-Europe (38)
- Rijksmuseum (17)
- Solutions inLibro inc (5)
- Tamil (1)
- Theke Solutions (39)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (6)
- Pedro Amorim (39)
- Tomás Cohen Arazi (284)
- Andrew Auld (10)
- Bob Bennhoff (1)
- Matt Blenkinsop (100)
- Nick Clemens (44)
- Paul Derscheid (1)
- Jonathan Druart (55)
- emlam (2)
- Magnus Enger (8)
- Laura Escamilla (2)
- Katrin Fischer (70)
- Lucas Gass (16)
- Nicolas Giraud (1)
- Victor Grousset (4)
- Kyle M Hall (7)
- Frank Hansen (6)
- Sally Healey (3)
- Barbara Johnson (10)
- Emily Lamancusa (2)
- Owen Leonard (6)
- Marius Mandrescu (2)
- Julian Maurice (1)
- Agustín Moyano (26)
- David Nind (76)
- Jacob O'Mara (54)
- Laurence Rault (2)
- Martin Renvoize (216)
- Phil Ringnalda (3)
- Marcel de Rooy (32)
- Caroline Cyr La Rose (6)
- Lisette Scheer (1)
- Michaela Sieber (2)
- Emmi Takkinen (3)
- Hinemoea Viault (5)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 22.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 May 2023 08:14:41.
