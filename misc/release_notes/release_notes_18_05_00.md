# RELEASE NOTES FOR KOHA 18.05.00
17 May 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 18.05.00 can be downloaded from:

- [Download](http://download.koha-community.org/koha-18.05-latest.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 18.05.00 is a major release, that comes with many new features.

It includes 12 new features, 257 enhancements, 354 bugfixes.



## New features

### Acquisitions

- [[19289]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19289) Allow configuration of the fields on the 'Catalog details' form in the acquisition baskets

> When creating a new order on an acquisition basket, bibliographic fields displayed on 'Catalog details' can now be customized. The system preference 'UseACQFrameworkForBiblioRecords' must be enabled. Fields are set on the 'ACQ' MARC framework.



### Architecture, internals, and plumbing

- [[15707]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15707) Add ability to define hierarchical groups of libraries

> Koha now supports grouping libraries into hierarchies. The previous grouping allowed only a single level of groups. The new hierarchical grouping allows for trees of unlimited depth to be created. This will allow for grouping of libraries based on physical location, political affiliation, or any other type of grouping! The new system is currently used for search groups, and patron visibility limits. Expect to see more features using hierarchical groups in the future!


- [[20123]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20123) Allow multiple instances of Koha to have different timezones on the same server

> Koha now has the ability to set times zones in Koha on a per-instance basis. That means that a single Koha server can support instances in several time zones simultaneously!  
Each instance's timezone can be set in its' koha-conf.xml  
See https://wiki.koha-community.org/wiki/Time_Zone_Configuration for more details.



### Authentication

- [[19160]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19160) CAS Single Logout

> This adds support for the CAS Single Logout feature. Single logout means that the user gets logged out not only from the CAS Server, but also from all visited CAS client applications when logging out in one of them or after reaching a timeout. The CAS server has to be set up for single logout for this to take effect, otherwise behaviour will remain unchanged.


- [[20568]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20568) Add API key management interface for patrons

> Adds the ability to handle patron-level API keys to be used for authenticating the REST API.



### Hold requests

- [[19287]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19287) Add ability to mark an item 'Lost' from 'Holds to pull' list

### Patrons

- [[9302]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9302) Add ability to merge patron records

> Koha now has the ability to merge patron accounts!  
To merge patrons, perform a patron search, select two or more patrons then click the 'Merge' button.  
Next, choose which patron you want to keep.  
Circulation data (checkouts, holds, fines, etc.) will be transferred to the remaining patron record.


- [[18403]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18403) Hide patron information if not part of the logged in user library group

### REST api

- [[16330]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16330) Add routes to add, update and delete patrons

> REST API route for managing patrons in database. Adds CRUD implementation for creating, reading, updating and deleting patrons, as well as listing with optional sorting.  
Follows new guidelines from REST API RFC and Koha Object Exceptions regarding validation and error handling. Patrons can modify and delete their own object, or anyone with borrower modification permissions.


- [[20402]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20402) OAuth2 client credentials grant for REST API

> This development adds the OAuth2 client credentials grant support to Koha. This way securing the REST API for using it from other systems gets easier as it follows current standards.



### Searching

- [[19290]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19290) Browse selected biblios - Staff

### Self checkout

- [[15492]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15492) Stand alone self check-in tool

## Enhancements

### About

- [[18674]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18674) Show timezone for Perl and MySQL on the About Koha page
- [[19542]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19542) Koha should display Elasticsearch information in the about page
- [[19904]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19904) Release team 18.05

### Acquisitions

- [[10032]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10032) Uncertain prices hide 'close basket' without explanation
- [[17182]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17182) Allow Keyword to MARC mapping for acquisitions searches (subtitle)
- [[17457]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17457) Use SearchWithISBNVariations in acquisition advanced search (histsearch.pl)
- [[19479]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19479) Price display on a basketgroup

### Architecture, internals, and plumbing

- [[10021]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10021) Remove dead code related to notifys
- [[10306]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10306) Koha to MARC mappings (Part 1): Allow multiple mappings per kohafield (for say 260/RDA 264)

> This patchset adds the ability to map several MARC fields to a single Koha field. The first existing mapped field will be saved into the database. This allows for flexibility in a system using RDA and AACR2 records where some store the publication data in the 260 fields and others in the 264.


- [[12001]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12001) GetMemberAccountRecords slows down display of patron details and checkout pages
- [[12904]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12904) Force browser to load new JavaScript and CSS files after upgrade

> For non-package installations, the following rewrite rules will need to be added to the apache config file:  
RewriteRule ^(.*)_[0-9][0-9]\.[0-9][0-9][0-9][0-9][0-9][0-9][0-9].js$ $1.js [L]  
RewriteRule ^(.*)_[0-9][0-9]\.[0-9][0-9][0-9][0-9][0-9][0-9][0-9].css$ $1.css [L]


- [[16735]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16735) Replace existing library search groups functionality with the new hierarchical groups system
- [[17553]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17553) Move GetOverduesForPatron to Koha::Patron
- [[17672]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17672) Items table should have a damaged_on column
- [[17833]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17833) _initilize_memcached() warns if errors
- [[18255]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18255) Koha::Biblio - Remove GetBiblioItemByBiblioNumber
- [[18336]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18336) Add support for Unicode supplementary characters

> Koha now supports Unicode supplementary characters like emojis or supplementary japanese, chinese and others.  
The DB structure definition is changed to make use of the utf8mb4 encoding, instead of utf8.


- [[18789]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18789) Send a Koha::Patron object to the templates
- [[18913]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18913) Allow symbolic link in /etc/koha/sites
- [[19096]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19096) Koha to MARC mappings (Part 2): Make Default authoritative
- [[19280]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19280) CanBookBeIssued must take a Koha::Patron in parameter
- [[19299]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19299) Replace C4::Reserves::GetReservesForBranch with Koha::Holds->waiting
- [[19300]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19300) Move C4::Reserves::OPACItemHoldsAllowed to the Koha namespace
- [[19301]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19301) Move C4::Reserves::OnShelfHoldsAllowed to the Koha namespace
- [[19303]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19303) Move C4::Members::GetFirstValidEmailAddress to Koha::Patron->first_valid_email_address
- [[19304]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19304) Move C4::Members::GetNoticeEmailAddress to Koha::Patron->notice_email_address
- [[19802]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19802) Move Selenium code to its own module
- [[19826]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19826) Introduce Koha::Acquisition::Budget(s) and Koha::Acquisition::Fund(s)
- [[19828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19828) Koha::Object->store should catch DBIC exceptions and raise Koha::Exceptions
- [[19830]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19830) Add the Koha::Patron->old_checkout method
- [[19841]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19841) AddMember should raise an exception if categorycode is invalid
- [[19855]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19855) Move the "alert" code to Koha::Subscription
- [[19926]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19926) Add the Koha::Object->unblessed_all_relateds method
- [[19929]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19929) Add Koha Objects for class_source and class_sort_rules
- [[19933]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19933) Move C4::Members::patronflags to the Koha namespace - part 1
- [[19935]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19935) Move C4::Members::GetPendingIssues to the Koha namespace
- [[19936]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19936) Move Check_userid and Generate_Userid to Koha::Patron
- [[19940]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19940) Koha::Biblio - Remove GetBiblioItemInfosOf
- [[19943]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19943) Koha::Biblio - Remove GetBiblioItemData
- [[19992]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19992) use Modern::Perl in Admin perl scripts
- [[19993]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19993) use Modern::Perl in Acquisition perl scripts
- [[19995]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19995) use Modern::Perl in Catalogue perl scripts
- [[19996]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19996) use Modern::Perl in cataloguing perl scripts
- [[19997]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19997) use Modern::Perl in Circulation perl scripts
- [[19998]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19998) use Modern::Perl in error perl scripts
- [[19999]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19999) use Modern::Perl in Labels perl scripts
- [[20009]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20009) use Modern::Perl in Members perl scripts
- [[20010]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20010) use Modern::Perl in Patroncards perl scripts
- [[20011]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20011) use Modern::Perl in plugins perl scripts
- [[20012]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20012) use Modern::Perl in Reports perl scripts
- [[20013]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20013) use Modern::Perl in Reserves perl scripts
- [[20015]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20015) use Modern::Perl in Serials perl scripts
- [[20016]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20016) use Modern::Perl in svc scripts
- [[20017]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20017) use Modern::Perl in Tools perl scripts
- [[20018]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20018) use Modern::Perl in offline circulation perl scripts
- [[20019]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20019) use Modern::Perl in miscellaneous perl scripts
- [[20020]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20020) use Modern::Perl in XT scripts
- [[20047]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20047) Add Z3950Server Object and use it for getting server count
- [[20052]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20052) Add Reports object class
- [[20157]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20157) Use group 'features' to decide which groups to use for group searching functionality
- [[20264]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20264) Syspref checkdigit is no longer in used
- [[20267]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20267) Add basic .gitignore
- [[20275]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20275) Add comment to let users know they can define multiple plugindirs
- [[20444]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20444) Remove C4::Members::Attributes::GetAttributes
- [[20538]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20538) Remove the need of writing [% KOHA_VERSION %] everywhere
- [[20599]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20599) Add the Koha::Subscription->vendor method
- [[20622]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20622) Add some color to bootstrap modal headers and footers

### Authentication

- [[12227]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12227) Remove demo user functionality
- [[20489]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20489) Prevent DB user login

> It is no longer possible to use the database user (defined in koha-conf.xml) to login into Koha.  
You should first create a superlibrarian patron and use it for logging in.  
See the script misc/devel/create_superlibrarian.pl


- [[20612]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20612) Make OAuth2 use patron's client_id/secret pairs

### Browser compatibility

- [[20062]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20062) Remove support for Internet Explorer 7 in the staff client

> Internet Explorer 7, released in 2006, is no longer supported by Koha.



### Cataloging

- [[9701]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9701) Configure default indicators

> This adds default indicators to bibliographic frameworks. The table marc_tag_structure is adjusted. In order to make effective use of this enhancement, you may want to add values in your MARC frameworks administration.


- [[11046]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11046) Better handling of uncertain years for publicationyear/copyrightdate
- [[18417]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18417) Advanced Editor - Rancor - add shortcuts for copyright symbols (C) (P)
- [[18878]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18878) Improve item form display / labels too far from input fields
- [[18904]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18904) Advanced editor - Rancor - Add authority support

> This patchset adds the ability to search for and link authorities in the advanced cataloging editor. When  editing a record staff can press 'Shift+Ctrl+L' to launch the authorities search. Choosing a record will update the field and add a subfield 9 for linking.


- [[19267]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19267) Advanced Editor - Rancor - Add warning before leaving page if there are unsaved modifications
- [[19538]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19538) Advanced editor - Rancor - Move syspref from labs to cataloging and remove experimental note

### Circulation

- [[11210]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11210) Allow partial writeoff
- [[15752]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15752) Automatically switch from circulation to new patron when a cardnumber is scanned during circulation

> The new system preference AutoSwitchPatron allows to automatically switch to another patron record on scanning the cardnumber during circulation. This will allow to streamline processes at the circulation desk a bit more. Note: Use only if there is no overlap in your cardnumber and barcode ranges.


- [[18786]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18786) Add ability to create custom payment types
- [[18790]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18790) Add ability to void payments
- [[18816]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18816) Make CataloguingLog work in production by preventing circulation from spamming the log
- [[19494]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19494) Add reservedate to Holds awaiting pickup
- [[19752]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19752) Improve authentication response in offline_circ/service.pl
- [[19804]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19804) Suspension calculation doesn't honor 'Suspension charging interval'
- [[19831]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19831) Turn on EnhancedMessagingPreferences by default for new installations
- [[20322]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20322) Circulation page layout and design update

> These patches give a facelift to the circulation homepage. All functionality remains the same, however, things have been moved to make the interface little friendlier and more responsive on different screens.


- [[20343]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20343) Show number of checkouts by itemtype in circulation.pl

### Command-line Utilities

- [[12598]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12598) New misc/import_borrowers.pl command line tool

> Koha now has a command line tool for importing patron CSV files of the same format the web-based tool uses. This tool allows a user to specify a matchpoint, set default values for non-existing fields, decide if a match should be overwritten, and if extended attributes should be preserved!  
For more details, run "misc/import_patrons.pl -h"


- [[17467]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17467) Introduce a single koha-zebra script to handle Zebra daemons for instances

> To ease multi-tenant sites maintenance, several handy scripts were introduced. For handling Zebra, 4 scripts were introduced: koha-start-zebra, koha-stop-zebra, koha-restart-zebra and koha-rebuild-zebra.  
This patch introduces a new script, koha-zebra, that unifies those actions regarding Zebra daemons on a per instance base, through the use of option switches.


- [[17468]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17468) Remove koha-*-zebra scripts in favor of koha-zebra

> The new koha-zebra maintenance script replaces the old koha-start-zebra, koha-stop-zebra and koha-restart-zebra scripts. This patch removes them, while keeping backwards compatibility (i.e. you can still run them until you get used to the new syntax).


- [[18964]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18964) Add a --debugger flag to koha-plack

> Remote debugging capabilities are added to the koha-plack script. This is very important for developers.


- [[19451]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19451) Let borrowers-force-messaging-defaults.pl optionally add preferences only when not already present

> This report adds the command-line option 'no-overwrite' so that you can add preferences only when they are not yet  
present (in other words: skip patrons that already set their prefs).


- [[19454]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19454) Add the ability to filter on patron category for borrowers-force-messaging-defaults.pl
- [[19955]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19955) Add ability to process only one 'type' of message ( sms, email, etc ) for a given run of process_message_queue.pl
- [[20525]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20525) Add --timezone switch to koha-create

### Course reserves

- [[15378]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15378) Remove 'lost' items from course reserves

### Hold requests

- [[18382]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18382) action_logs entry for module HOLDS, action SUSPEND is spammy
- [[19769]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19769) 'Pickup library is different' message does not display library branch name when placing hold

### I18N/L10N

- [[11674]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11674) Configuration for MARC field doc URLs
- [[20295]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20295) Allow translating link title in ILL module
- [[20296]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20296) Untranslatable "All" in patrons table filter

### Installation and upgrade (web-based installer)

- [[18819]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18819) Correct "whereas UNIMARC tends to be used in Europe." in web installer files

### Lists

- [[19658]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19658) Style fix for staff client lists page

### MARC Authority data support

- [[14769]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14769) Authorities merge: Set correct indicators in biblio field

> This report adds pref AuthorityControlledIndicators. It controls how the indicators of linked authority records affect the corresponding biblio indicators. Currently, the default pref value is finetuned for MARC21, and copies the authority indicators for UNIMARC.  
An example to illustrate: A MARC21 field 100 in a biblio record should pick its first indicator from the linked authority record. The second indicator is not controlled by the authority. This report supports such MARC conventions.


- [[18071]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18071) Add new script update_authorities.pl

> This patch adds a script to perform various authority related maintenance tasks.  
This version supports deleting an authority record and updating all linked biblio records.  
Furthermore it supports merging authority records with one reference record, and updating all linked biblio records.  
It also allows you to force a renumber, i.e. save the authid into field 001.



### MARC Bibliographic data support

- [[16427]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16427) Direct link to authority records missing in staff detail view (MARC21 6xx)
- [[18198]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18198) MARC21: Further improve handling of 5XX$u in GetMarcNotes

### Notices

- [[17981]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17981) Add the ability to preview generated notice templates
- [[18007]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18007) Interface updates to notices and notice previews

### OPAC

- [[11976]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11976) Add column settings + new column "Publication date" to the subscription table

> This patchset adds a new column to the subscriptions tab on the opac details page, 'publication date' so a user can see the date of issue rather than the date of receipt.  
Additionally, the patch brings the table under column settings in the administration side so that staff can determine which columns should be shown by default


- [[15794]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15794) Add emoji picker to tag entry in OPAC
- [[18083]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18083) Don't show 'library' selection on popular titles page for single-branch libraries
- [[18313]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18313) Remove Delicious icon from OPAC social network links
- [[19573]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19573) Link to make a new list in masthead in OPAC only appears / works if no other list already exists
- [[19708]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19708) Printing code improvements in opac-basket.tt
- [[19989]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19989) opac-memberentry.pl has a FIXME that can be fixed
- [[20155]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20155) Improve readability of OPAC header language menu
- [[20181]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20181) Allow plugins to add CSS and Javascript to OPAC
- [[20400]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20400) Add routing list tab to the patron account in OPAC

> Adds a routing list tab to the patron account in the OPAC that will be visible if RoutingSerials is turned on and the user is at least on one routing list.


- [[20432]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20432) Add black version of small Koha logo for use in the OPAC
- [[20497]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20497) LibraryThing: always use https instead of http

### Packaging

- [[17951]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17951) koha-create should create the template cache dir and configure it in koha-conf.xml

### Patrons

- [[18626]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18626) Add ability to track cardnumber changes for patrons
- [[19471]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19471) Show creation date in patron restrictions list
- [[19801]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19801) Display messages on user details page as well as on check out page
- [[19988]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19988) Change 'sex' to 'gender'
- [[20100]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20100) A non-superlibrarian should not be able to add superlibrarian privileges

> This report adds pref ProtectSuperlibrarianPrivileges in order to block users without superlibrarian privileges to modify the superlibrarian flag for themselves or other users, if the pref is enabled. For existing installs the pref will not be set, so behavior does not change. For new installs the pref will be enabled.


- [[20516]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20516) Show patron's library in pending discharges table
- [[20524]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20524) Make columns of pending discharges table sortable
- [[20526]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20526) Show and sort by date of request in pending discharges table

### REST api

- [[16213]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16213) Allow to select hold's itemtype when using API
- [[18330]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18330) REST API: Date-time handling
- [[19234]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19234) Add query parameters handling helpers
- [[19278]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19278) Add a configurable default page size for endpoints
- [[19369]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19369) Add a helper function for translating pagination params into SQL::Abstract
- [[19370]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19370) Add a helper function for translating order_by params into SQL::Abstract
- [[19410]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19410) Add a helper function for generating object searches for the API
- [[19686]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19686) Add to_model and to_api params to objects.search helper
- [[19784]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19784) Adapt /v1/patrons to new naming guidelines
- [[20004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20004) Adapt /v1/cities to new naming guidelines

### Reports

- [[9573]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9573) Ability to download items lost report
- [[9634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9634) Allow for parameters re-use on SQL reports

> This new feature allows parameters to be re-used in reports. When a report asks for two variables using the same name and type/authorised value they will be combined into a single input field on the form. i.e.  
SELECT *  
FROM items   
WHERE homebranch=<<Branchcode|branches>> AND holdingbranch=<<Branchcode|branches>> AND itype=<<Item type|itemtypes>>  
Will ask for only 2 parameters when run, Branchcode and Item type.


- [[11317]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11317) Add a way to access files from the intranet

> This feature allows to access files on the server from the staff interface. The directories where the files are stored need to be defined in the koha-conf.xml file. In order to be able to access the tool the staff patron requires either the superlibrarian or the new access_files permission.


- [[13445]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13445) Clean up options for scheduled reports, remove URL, add HTML and Text/TSV
- [[16782]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16782) Display JSON report URL in staff client report interface
- [[19233]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19233) Add ability to send itemnumbers in report results to batch modification
- [[19664]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19664) Reports sidebar menu should match list of reports on reports home page
- [[19716]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19716) Add option to send header line for CSV output with runreport.pl
- [[19856]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19856) Improve styling of reports sidebar to match tools sidebar
- [[19957]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19957) Allow continued editing after saving a report
- [[20345]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20345) Put saved report keyword search form on reports home
- [[20350]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20350) Add column configuration to table of saved reports

### SIP2

- [[17826]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17826) Allow extended patron attributes to be sent in arbitrary SIP2 fields
- [[18625]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18625) Update borrower last seen from SIP

### Searching

- [[13660]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13660) rebuild_zebra_sliced.sh - Exclude export phase and use existing exported MARCXML.

### Searching - Elasticsearch

- [[18825]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18825) Elasticsearch - Update default authority mappings
- [[19582]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19582) Elasticsearch: Auth-finder.pl must use search_auth_compat
- [[20073]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20073) Move Elasticsearch settings to configuration files
- [[20386]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20386) Improve warning and error messages for Search Engine Configuration

### Serials

- [[7910]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7910) Batch renewal of subscriptions
- [[18327]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18327) Add the ability to set the received date to today on multi receiving serials
- [[18426]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18426) Subscriptions batch editing

### Staff Client

- [[19488]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19488) Add borrowernumber to brief info on patron details pages in staff client
- [[19806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19806) Add class to items.itemnotes_nonpublic
- [[19953]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19953) Add column for invoice in acquisition details tab
- [[20291]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20291) Add a StaffLoginInstructions system preference to add text to the staff client login box
- [[20404]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20404) Extended patron attributes should always be on

### System Administration

- [[13287]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13287) Add a system preference to define the number of days used in purge_suggestions.pl

> Apart from introducing the new preference PurgeSuggestionsOlderThan, this report also adds a -confirm flag to the cron job purge_suggestions.pl. Please adjust existing cron tab files and add this flag in order to have the expected results.


- [[16764]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16764) Update printers administration page
- [[19292]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19292) Add MARC code column on libraries list
- [[20133]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20133) "Hide patron information" feature should not affect all library groups

### Templates

- [[4078]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=4078) Add the ability to customize and display the symbol for a currency
- [[15922]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15922) Show authorized value description in staff client search results for lost, withdrawn, and damaged

> Show the library's description for variations of "Lost," "Damaged," and "Withdrawn" statuses which have been defined in Koha's authorized values.


- [[18791]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18791) Add the ability for librarians to easily copy, download or print DataTables based tables in Koha
- [[19592]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19592) Move admin templates JavaScript to the footer: Acquisitions
- [[19594]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19594) Move admin templates JavaScript to the footer: MARC-related
- [[19600]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19600) Move admin templates JavaScript to the footer: Other catalog pages
- [[19601]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19601) Move admin templates JavaScript to the footer: Additional parameters
- [[19603]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19603) Move admin templates JavaScript to the footer: Patrons and circulation
- [[19607]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19607) Move admin templates JavaScript to the footer: Basic parameters
- [[19608]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19608) Move admin templates JavaScript to the footer: The rest
- [[19623]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19623) Move template JavaScript to the footer: Cataloging
- [[19627]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19627) Move patron clubs templates JS to the footer
- [[19628]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19628) Move course reserves templates JS to the footer
- [[19641]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19641) Move patron templates JavaScript to the footer
- [[19647]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19647) Move patron lists templates JS to the footer
- [[19653]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19653) Move tools templates JavaScript to the footer: Additional tools
- [[19654]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19654) Move tools templates JavaScript to the footer: Batch MARC tools
- [[19656]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19656) Move rotating collections templates JS to the footer
- [[19657]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19657) Move lists templates JS to the footer
- [[19659]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19659) Move JS to the footer: Suggestions and tags
- [[19663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19663) Move JS to the footer: Reports
- [[19672]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19672) Move tools templates JavaScript to the footer: More MARC tools
- [[19679]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19679) Move templates JavaScript to the footer: More tools templates
- [[19680]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19680) Move JS to the footer: Patron and circulation tools
- [[19682]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19682) Move JS to the footer: Two patron-related tools
- [[19697]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19697) Move template JavaScript to the footer: Search results
- [[19700]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19700) Move template JavaScript to the footer: Some circulation pages
- [[19710]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19710) Move plugins templates javascript to the footer
- [[19726]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19726) Move admin templates JavaScript to the footer: Preferences
- [[19744]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19744) Move template JavaScript to the footer: Offline circulation
- [[19751]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19751) Holds awaiting pickup report should not be fixed-width
- [[19753]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19753) Move template JavaScript to the footer: Acquisitions
- [[19754]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19754) Move template JavaScript to the footer: Acquisitions, part 2
- [[19755]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19755) Move template JavaScript to the footer: Acquisitions, part 3
- [[19758]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19758) Move template JavaScript to the footer: Serials, part 1
- [[19761]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19761) Move template JavaScript to the footer: Serials, part 2
- [[19777]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19777) Move template JavaScript to the footer: Serials, part 3
- [[19778]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19778) Move template JavaScript to the footer: Serials, part 4
- [[19785]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19785) Move template JavaScript to the footer: Authorities, part 1
- [[19786]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19786) Move template JavaScript to the footer: Authorities, part 2
- [[19805]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19805) Add DataTables to Koha to MARC mapping page
- [[19823]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19823) Move template JavaScript to the footer: MARC21 editor plugins
- [[19860]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19860) Make staff client home page responsive
- [[19866]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19866) Move template JavaScript to the footer: UNIMARC editor plugins, part 1
- [[19868]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19868) Move template JavaScript to the footer: UNIMARC editor plugins, part 2
- [[19869]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19869) Move template JavaScript to the footer: UNIMARC editor plugins, part 3
- [[19872]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19872) Move template JavaScript to the footer: UNIMARC editor plugins, part 4
- [[19874]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19874) Move template JavaScript to the footer: UNIMARC editor plugins, part 5
- [[19877]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19877) Move template JavaScript to the footer: UNIMARC editor plugins, part 6
- [[19878]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19878) Move template JavaScript to the footer: UNIMARC editor plugins, part 7
- [[19882]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19882) Add Novelist Select staff client profile

> This patch adds a new Staff Client profile for Novelist information. Previously we used the same value as the opac, this caused malformed links on the staff side. With this patch Novelist features will be disabled on the staff client until a correct profile is obtained from Novelist and entered into the system preference


- [[19892]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19892) Replace numbersphr variable with Koha.Preference('OPACNumbersPreferPhrase') in OPAC
- [[19932]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19932) Update popup window templates to use Bootstrap grid: Cataloging Z39.50 search
- [[19939]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19939) Move cataloging Z39.50 results actions into menu
- [[19946]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19946) Update popup window templates to use Bootstrap grid: Authority Z39.50 search
- [[19947]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19947) Update popup window templates to use Bootstrap grid: Acquisitions transfer order
- [[19949]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19949) Update popup window templates to use Bootstrap grid: Cataloging authority search
- [[19950]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19950) Update popup window templates to use Bootstrap grid: Serials
- [[19952]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19952) Update popup window templates to use Bootstrap grid: UNIMARC cataloging plugins
- [[19954]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19954) Update popup window templates to use Bootstrap grid: Patrons
- [[19960]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19960) Update popup window templates to use Bootstrap grid: Add to list
- [[19961]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19961) Move template JavaScript to the footer: Patron card creator
- [[19981]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19981) Switch single-column templates to Bootstrap grid: Course reserves
- [[19982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19982) Switch single-column templates to Bootstrap grid: Patrons
- [[19983]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19983) Switch single-column templates to Bootstrap grid: Authorities
- [[20032]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20032) Switch single-column templates to Bootstrap grid: Tools
- [[20033]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20033) Switch single-column templates to Bootstrap grid: Catalog
- [[20034]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20034) Switch single-column templates to Bootstrap grid: Circulation
- [[20035]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20035) Switch single-column templates to Bootstrap grid: Patron clubs
- [[20036]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20036) Switch single-column templates to Bootstrap grid: Offline circulation
- [[20037]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20037) Switch single-column templates to Bootstrap grid: Serials
- [[20038]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20038) Switch single-column templates to Bootstrap grid: Acquisitions
- [[20045]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20045) Switch single-column templates to Bootstrap grid: Various
- [[20518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20518) Don't show "Messages" header and link on patron details if there are no messages

### Test Suite

- [[18055]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18055) Speed up '00-strict.t' test
- [[18797]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18797) t/db_dependent/rollingloans.t is skipping
- [[19181]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19181) Intranet and OPAC authentication selenium test
- [[19243]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19243) Selenium test for testing the administration module functionality - part 1
- [[19483]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19483) t/db_dependent/www/* crashes test harness due to misconfigured test plan

### Tools

- [[19554]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19554) The inventory table should jump to detail instead of MARCdetail
- [[19584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19584) Inventory: Trivial interface improvements
- [[19585]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19585) Inventory: Allow additional separators in a barcode file
- [[19837]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19837) Add multiple patrons to a list by cardnumber
- [[20081]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20081) Enable uploaded pdfs to be viewed inline


## Critical bugs fixed

(This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### Acquisitions

- [[18593]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18593) Suggestions aren't updated when one biblio is merged with another
- [[19030]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19030) Link order <-> subscription is lost when an order is edited
- [[19694]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19694) Edited shipping cost in invoice doesn't save
- [[20303]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20303) Receive order fails if no "authorised_by" value
- [[20426]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20426) Can't import all titles from a stage file with default values
- [[20446]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20446) QUOTES processing broken by run time error

### Architecture, internals, and plumbing

- [[15770]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15770) Number::Format issues with large numbers
- [[19319]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19319) Reflected XSS Vulnerability in opac-MARCdetail.pl
- [[19439]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19439) Some error responses from opac/unapi get lost in eval
- [[19568]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19568) Wrong html filter used in opac-opensearch.tt url
- [[19569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19569) X-Frame-Options=SAMEORIGIN is not set from opac-showmarc.pl
- [[19570]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19570) autocomplete="off" no set for login forms at the OPAC
- [[19599]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19599) anonymise_issue_history can be very slow on large systems
- [[19611]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19611) XSS Flaws in supplier.pl
- [[19612]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19612) Fix XSS in /cgi-bin/koha/members/memberentry.pl
- [[19614]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19614) Fix XSS in /cgi-bin/koha/members/pay.pl
- [[19766]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19766) Preview routing slip is broken
- [[19847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19847) tracklinks.pl accepts any url from a parameter for proxying
- [[19881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19881) authorities-list.pl can be executed by anybody
- [[20126]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20126) Saving a biblio does no longer update MARC field lengths
- [[20145]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20145) borrowers.datexpiry eq '0000-00-00' means expired?
- [[20229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20229) Remove problematic SQL modes
- [[20299]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20299) Koha is a gift
- [[20323]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20323) Batch patron modification tool broken
- [[20325]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20325) C4::Accounts::purge_zero_balance_fees does not check account_offsets
- [[20428]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20428) MARC import fails on Debian Stretch

### Cataloging

- [[19646]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19646) value_builder marc21_linking_section template is broken
- [[19706]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19706) Item search: Unsupported format html
- [[19968]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19968) Undefined subroutine &Date::Calc::Today
- [[19974]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19974) Marking an item as 'lost' will not actually modify the current item (cataloguing/additem.pl)

> The behaviour for marking a checked out item as 'Lost' is different, depending on the path you use: sometimes the item is checked in, sometimes not.  
The system preference 'MarkLostItemsAsReturned' now allows libraries to choose if the item is checked for each of the 4 ways an item can be marked as 'Lost': from the edit item form, from the 'Items' tab of the catalog module, from the batch item modification and with the longoverdue cronjob.


- [[20063]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20063) $9 is lost when cataloguing authority records

### Circulation

- [[2696]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=2696) Fine payments should show what was paid for

> This adds a details view for every fine and payment in a patron account that will show detailed information about the payments made forward a fine and how a payment has been split up to pay towards several fines.


- [[4319]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=4319) waiting and in transit items cannot be reserved
- [[19204]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19204) Fines in days restriction calculation is not taking calendar into account
- [[19444]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19444) Automatic renewal script should not auto-renew if a patron's record has expired
- [[19771]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19771) Pending offline circulation actions page will crash on unknown barcode or on payment action
- [[19798]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19798) Returns.pl doesn't define itemnumber for transfer-slip.
- [[19899]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19899) The float items feature is broken - cannot checkin
- [[20499]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20499) Checkout of bad barcode: Internal Server Error

### Command-line Utilities

- [[12812]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12812) Longoverdue.pl --mark-returned doesn't return items
- [[17717]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17717) Fix broken cronjobs due to permissions of the current directory
- [[19730]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19730) misc/export_records.pl should use biblio_metadata.timestamp

### Documentation

- [[20706]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20706) Fix links to help files for changed file structure (removed numbering on files)

### Fines and fees

- [[20562]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20562) issue_id is not stored in accountlines for rental fees

### Hold requests

- [[18474]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18474) Placing multiple holds from results breaks when patron is searched for
- [[20167]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20167) Item hold is set to bibliographic hold when changing pickup location
- [[20724]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20724) ReservesNeedReturns syspref breaks "Holds awaiting pickup"

### ILL

- [[20001]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20001) ILL: Adding a 'new request' from OPAC is not possible
- [[20284]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20284) ILL: Adding a 'new request' from OPAC fails with template error if text exists in ILLModuleCopyrightClearance
- [[20556]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20556) Marking ILL request as complete results in "Internal server error"

### Installation and upgrade (web-based installer)

- [[19514]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19514) No Password restrictions in onboarding tool patron creation
- [[20745]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20745) indexing/searching not active at end of installation

### Lists

- [[20687]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20687) Multiple invitations to share lists prevents some users from accepting

### MARC Authority data support

- [[20074]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20074) Auth_subfield_structure changes hidden attribute

### Notices

- [[18477]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18477) AR_PENDING notice does not populate values from article_requests table
- [[18725]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18725) process_message_queue.pl sends duplicate emails if message_queue is not writable

### OPAC

- [[18915]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18915) Creating a checkout note (patron note) sends an incomplete email message
- [[18975]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18975) Wrong CSRF token when emailing cart contents
- [[19496]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19496) Patron notes about item does not get emailed as indicated
- [[19808]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19808) Reviews from deleted patrons make few scripts to explode
- [[19843]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19843) reviews.datereviewed is not set
- [[19911]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19911) Passwords displayed to user during self-registration are not HTML-encoded
- [[19913]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19913) Embedded HTML5 videos are broken
- [[19975]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19975) Tag cloud searching does not working
- [[19978]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19978) Fix ITEMTYPECAT feature for grouping item types for search
- [[20218]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20218) Tracklinks fails when URL has special characters
- [[20286]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20286) Subscribing to a search via rss goes to an empty page
- [[20363]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20363) Privacy management shows misleading "No reading history to delete"
- [[20479]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20479) Superlibrarians cannot log into opac

### Packaging

- [[20061]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20061) koha-common is not pulling libsearch-elasticsearch-perl
- [[20437]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20437) Force requirement for HTTP::OAI 3.27
- [[20693]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20693) Plack fails, because 'libcgi-emulate-psgi-perl' package is not installed

### Patrons

- [[19466]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19466) Cardnumber auto calc is broken because field is required
- [[19908]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19908) Password should not be mandatory
- [[19921]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19921) Error when updating child to adult patron on system with only one adult patron category
- [[20214]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20214) Patron search is broken

### REST api

- [[19546]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19546) Make koha-plack run Starman from the instance's directory

### SIP2

- [[20251]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20251) Regression - SIP checkout broken

### Searching - Elasticsearch

- [[19563]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19563) Generation of sort_fields uses incorrect condition
- [[20261]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20261) No result in some page in authority search opac and pro (ES)
- [[20385]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20385) ElasticSearch authority search raises Software error

### Staff Client

- [[19223]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19223) Avoid encoding issues in plugins by providing helper methods to output headers correctly

> The current plugin writing practice is to craft the response header in the controller methods. This patchset adds new helper methods for plugin authors to use when dealing with output on their plugins. This way the end-user experience is better, and the plugin author's tasks easier.


- [[20625]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20625) Cannot add new patron category without currency

### System Administration

- [[20216]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20216) Editing itemtypes does not pull existing values correctly

### Templates

- [[20135]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20135) Staff client language choose pop-up can appear off-screen
- [[20498]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20498) Patron advanced search form missing from patron entry page

### Web services

- [[19725]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19725) OAI-PMH ListRecords and ListIdentifiers should use biblio_metadata.timestamp
- [[20665]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20665) OAI-PMH Provider should reset MySQL connection time zone


## Other bugs fixed

(This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### About

- [[7143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7143) Bug for tracking changes to the about page

### Acquisitions

- [[3841]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3841) Add a Default ACQ framework
- [[18183]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18183) jQuery append error related to script tags in cloneItemBlock
- [[19200]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19200) Warns when exporting a basket
- [[19401]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19401) No confirm message when deleting an invoice from invoice detail page
- [[19429]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19429) No confirm message when deleting an invoice from invoice search
- [[19792]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19792) Reduce number of SQL calls in GetBudgetHierarchy
- [[19812]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19812) Holds count in "Already received" table has confusing and unexpected values
- [[19813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19813) MarcItemFieldsToOrder cannot handle a tag not existing
- [[19916]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19916) Can't search keyword or standard ID from Acquisitions external source / z3950
- [[19928]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19928) Acquisitions' CSV exports should honor syspref "delimiter"
- [[20110]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20110) Don't allow adding same user multiple times to same budget fund
- [[20148]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20148) Don't allow adding same user multiple times to a basket or an order
- [[20201]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20201) Silence warnings in admin/aqplan.pl
- [[20318]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20318) Merge invoices can lead to an merged invoice without Invoice number
- [[20623]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20623) PDF export of a basket group fails when an item has an itemtype that is not in the itemtype table

### Architecture, internals, and plumbing

- [[18342]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18342) Set memcached as 'enabled' by default

> Memcached is now required and enabled by default.


- [[19713]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19713) 2 occurrences of OpacShowLibrariesPulldownMobile have not been removed
- [[19714]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19714) 2 occurrences of memberofinstitution have not been removed
- [[19738]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19738) XSS in serials module
- [[19739]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19739) Add default ES configuration to koha-conf.xml
- [[19746]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19746) Debug statements are left in returns.pl
- [[19756]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19756) Encoding issues when update DB is run from the interface
- [[19760]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19760) Die instead of warn if koha-conf is not accessible
- [[19827]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19827) checkuniquemember is exported from C4::Members but has been removed
- [[19839]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19839) invoice.pl warns about bad variable scope
- [[19985]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19985) TestBuilder.t fails if default circ rule exists
- [[20031]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20031) CGI param in list context warn in guided_reports.pl
- [[20056]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20056) Uninitialized warn in cmp_sysprefs.pl
- [[20060]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20060) Uninitialized warn from Koha::Template::Plugin::Branches
- [[20088]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20088) Use of uninitialized value in array element in svc/holds
- [[20097]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20097) marc2dcxml croaks on format dc
- [[20185]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20185) Some scripts don't pass perl -wc
- [[20187]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20187) New rewrite rules can break custom css
- [[20189]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20189) No style on authentication and installer pages
- [[20190]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20190) TinyMCE is broken and not displayed
- [[20219]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20219) t/smolder_smoke_signal is no longer used
- [[20225]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20225) Remove unused script reports/stats.print.pl
- [[20304]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20304) Warnings in cataloguing scripts need to be removed
- [[20305]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20305) Warnings in tools scripts need to be removed
- [[20321]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20321) C4:XISBN->get_biblionumber_from_isbn is not used
- [[20494]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20494) Remove unused code in neworderempty.pl and addbiblio.pl
- [[20510]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20510) Remove unused sub TotalPaid from C4::Stats
- [[20530]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20530) trailing ':' in columns_settings.yml
- [[20539]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20539) Warnings in catalogue/search.pl need to be removed
- [[20580]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20580) create_superlibrarian.pl should accept parameters
- [[20590]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20590) Koha::Exceptions does not stringify the exceptions
- [[20603]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20603) Remove unused subs from C4::Accounts
- [[20620]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20620) Warning in moredetail.pl need to be removed
- [[20659]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20659) Blocking errors are not longer displayed
- [[20734]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20734) Add warning to the about page if RESTOAuth2ClientCredentials and not Net::OAuth2::AuthorizationServer

### Authentication

- [[20083]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20083) Information disclosure when (mis)using the MARC Preview feature
- [[20480]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20480) Fix styling issues on bad SCI/SCO module logins
- [[20624]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20624) Disable the OAuth2 client credentials grant by default

### Cataloging

- [[18833]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18833) plugin unimarc_field_210c pagination error
- [[19595]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19595) Clicking plugin link does not fill item's date acquired field
- [[20067]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20067) Wrong display of authorised value for items.materials on staff detail page
- [[20341]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20341) Show authorized value description for withdrawn like damaged and lost
- [[20477]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20477) Silence warnings Fast Cataloguing
- [[20540]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20540) TransformHtmlToXml can duplicate the datafield close tag

### Circulation

- [[16603]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16603) Hide option to apply directly when processing uploaded offline circulation file
- [[19530]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19530) Prevent multiple transfers from existing for one item
- [[19825]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19825) List of pending offline operations does not links to biblio
- [[19840]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19840) Patron note is not displayed on checkin
- [[20003]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20003) Result summary of remaining checkouts items not displaying.
- [[20536]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20536) ILL: authnotrequired not explicitly unset
- [[20546]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20546) Shelving location not displayed on checkin

### Command-line Utilities

- [[11936]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11936) Consistent log message for item insert
- [[19452]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19452) The -truncate option in borrowers-force-messaging-defaults.pl should not remove category preferences
- [[19712]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19712) Fix command line options of delete_records_via_leader.pl
- [[20234]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20234) Make maintenance scripts use koha-zebra instead of koha-*-zebra

### Course reserves

- [[19230]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19230) Warn when deleting a course in course reserves
- [[19678]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19678) Clicking Cancel when adding New Course to course reserves shows message Invalid Course!
- [[20282]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20282) Wrong attribute in template calls to match holding branch when adding/editing a course reserve item

### Database

- [[19547]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19547) Maria DB doesn't have a debian.cnf
- [[19724]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19724) Add timestamp to biblio_metadata and deletedbiblio_metadata

### Fines and fees

- [[19750]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19750) Overdues without a fine rule add warnings to log

### Hold requests

- [[11512]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11512) Only allow to override maximum number of holds from staff as other overrides would never be filled
- [[19533]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19533) Hold pulldown for itemtype is empty if hold placement needs override
- [[19972]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19972) Holds to pull should honor syspref "item-level_itypes"
- [[20637]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20637) Holds to pull: filter shows two itypes on the same line if a biblio has two items of a different type
- [[20707]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20707) Permissions for circ/ysearch.pl override specific page level permissions and delete sessions improperly

### I18N/L10N

- [[11827]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11827) Untranslatable "Cancel Rating" in jQuery rating plugin
- [[12020]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12020) Allow translating label-edit-batch hardcoded strings
- [[19522]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19522) Label creator - some strings are not translatable
- [[20082]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20082) Vietnamese language display name is incorrect
- [[20085]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20085) Better translatability of smart-rules.tt
- [[20109]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20109) Allow translating "Remove" in Add Fund
- [[20111]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20111) Patron card creator - some strings are not translatable
- [[20115]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20115) Languages appear in a different order in the footer

> The languages displayed in the footer are now displayed in the same order as they are in the system preferences languages and opaclanguages (they can be reordered by drag and drop).


- [[20124]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20124) Allow translating did you mean config save message
- [[20139]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20139) Improve MARC mapping translatable strings
- [[20140]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20140) Allow translating more of OAI sets
- [[20141]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20141) Untranslatable string in Transport cost matrix
- [[20142]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20142) Allow translating offline circ message
- [[20147]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20147) Allow translating prompt in label edit batch
- [[20166]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20166) Untranslatable course reserves delete prompt
- [[20195]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20195) Untranslatable Show/Hide title attr replacement in opac detail
- [[20301]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20301) Allow translating "View" in manage MARC import
- [[20302]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20302) Allow translating Delete button in Patron batch mod tool
- [[20330]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20330) Allow translating more of quote upload

### ILL

- [[20041]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20041) ILL module missing from more menu in staff when activated
- [[20515]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20515) "ILL Request" menu options displayed when user has no ILL permissions

### Installation and upgrade (web-based installer)

- [[12932]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12932) Web installer's Perl version check will not raise errors if all modules are installed
- [[19790]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19790) Remove additionalauthors.author from installer files
- [[19862]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19862) RoutingListAddReserves must be disabled by default
- [[19973]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19973) SQL syntax error in uk-UA/mandatory/sample_notices.sql
- [[20075]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20075) Change authority hidden attribute in sql installer files
- [[20103]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20103) Readonly::XS version not detected
- [[20746]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20746) Improve behaviour of onboarding tool for Italian by standardizing file structure of it-IT installer

### Label/patron card printing

- [[10222]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10222) Error when saving Demco label templates
- [[19681]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19681) label-item-search.pl result count formatting error when there is only one page
- [[20193]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20193) Path to Greybox CSS broken after Bug 12904

### Lists

- [[11943]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11943) Koha::Virtualshelfshare duplicates rows for the same list

### MARC Authority data support

- [[18458]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18458) Merging authority record incorrectly orders subfields
- [[20430]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20430) Z39.50 button display depends on wrong server count

### MARC Bibliographic data support

- [[20245]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20245) Wrong language code for Slovak
- [[20482]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20482) language_rfc4646_to_iso639 uses some Terminology instead of Bibliographic codes

### Notices

- [[12123]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12123) HTML notices can break the notice viewer
- [[18570]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18570) Password recovery e-mail only sent after message queue is processed
- [[18990]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18990) Overdue Notices are not sending through SMS correctly
- [[19578]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19578) TT syntax for notices - There is no way to pre-process DB fields
- [[20298]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20298) Notices template uses same html id for each language
- [[20685]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20685) Modify letter template does not render incorrectly

### OPAC

- [[12497]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12497) Make OPAC search history feature accessible when it should
- [[17682]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17682) Change URL for Google Scholar in OPACSearchForTitleIn
- [[18856]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18856) Cancel Waiting Hold in OPAC does not give useful message
- [[19171]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19171) Confusing message "no items available" when placing a hold in OPAC
- [[19338]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19338) Dates sorting incorrectly in opac-account.tt
- [[19450]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19450) OverDrive integration failing on missing method
- [[19579]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19579) PatronSelfRegistrationEmailMustBeUnique does not prevent duplicates when using PatronSelfRegistrationVerifyByEmail
- [[19640]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19640) IdRef webservice display is broken
- [[19702]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19702) Basket not displaying correctly on home page
- [[19845]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19845) Patron password is ignored during self-registration if PatronSelfRegistrationVerifyByEmail is enabled
- [[20054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20054) Remove attribute "text/css" for the style tags used in the OPAC templates

> Prevents warnings about type attribute being generated for the style tags when testing the OPAC pages using W3C Validator for HTML5.


- [[20068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20068) Warn on OPAC homepage if not logged in due to OPAC dashboard
- [[20122]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20122) Empty and close link on cart page not working
- [[20163]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20163) Position of NoLoginInstructions text is inconsistent
- [[20420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20420) Remove unnecessary [% KOHA_VERSION %] from OPAC third-party sources
- [[20459]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20459) Correct message for cancelling an article request
- [[20686]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20686) OPAC shows 'Login to OverDrive account' with 'OverDriveCirculation' syspref disabled
- [[20737]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20737) Use https for Baker and Taylor cover images

### Packaging

- [[17084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17084) Automatic debian/control updates (master)
- [[18696]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18696) Change debian/source/format to quilt
- [[18907]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18907) Warning "dpkg-source: warning: relation < is deprecated: use << or <="
- [[18908]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18908) Warning "Compatibility levels before 9 are deprecated"
- [[18993]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18993) Bump libtest-simple-perl to 1.302073
- [[19610]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19610) Make koha-common.logrotate use copytruncate
- [[20072]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20072) Fix build-git-snapshot for Debian source format quilt

### Patrons

- [[19510]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19510) edi_manage permission has no description
- [[19621]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19621) Routing lists tab not present when viewing 'Holds history' tab for a patron
- [[19673]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19673) Patron batch modification tool cannot use authorised value "0"
- [[19907]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19907) Email validation on patron add/edit not working
- [[20008]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20008) Restrictions added from memberentry.pl have expiration date ignored if TimeFormat is 12hr
- [[20205]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20205) Add IDs to buttons in patron-toolbar.inc
- [[20367]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20367) userid resets to firstname.surname when BorrowerUnwantedField contains userid
- [[20455]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20455) Can't sort patron search on date expired
- [[20666]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20666) Wrong Permissions prevent non-plack pages to load
- [[20719]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20719) Home library not displayed on all patron account tabs

### REST api

- [[20134]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20134) Remove /api/v1/app.pl from the generated URLs

### Reports

- [[18497]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18497) Downloading a report passes the constructed SQL as a parameter
- [[19467]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19467) Display location and itemtype description on lost items report
- [[19551]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19551) Cash register report has bad erroneous results from wrong order of operations
- [[19583]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19583) Report updater triggers on auth_header.marcxml
- [[19638]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19638) False positives for 'Update SQL' button
- [[19669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19669) Remove deprecated checkouts by patron category report
- [[19671]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19671) Circulation wizard / issues_stats.pl does not populate itemtype descriptions correctly
- [[19910]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19910) Download report as 'Comma separated' is misleading
- [[20663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20663) Dead report code for "Create Compound Report" since prior to 3.0.x

### SIP2

- [[20348]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20348) SIP2 patron identification fails to use userid

### Searching

- [[18799]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18799) XSLTresultsdisplay hides the icons
- [[19807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19807) IntranetCatalogSearchPulldown doesn't honor IntranetNumbersPreferPhrase
- [[19873]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19873) Make it possible to search on value 0
- [[19971]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19971) typo in the comments of parseQuery routine
- [[20369]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20369) Analytics search is broken with QueryAutoTruncate set to 'only if * is added'
- [[20722]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20722) Searching only for an ITEMTYPECAT itemtype is impossible

### Searching - Elasticsearch

- [[17373]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17373) Elasticsearch - Authority mappings for UNIMARC
- [[19564]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19564) Fix extraction of sort order from sort condition name
- [[19580]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19580) Elasticsearch: QueryAutoTruncate exclude period as splitting character in autotruncation
- [[19581]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19581) Elasticsearch - Catmandu split option adds extra null fields to indexes

### Serials

- [[19315]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19315) Routing preview may use wrong biblionumber
- [[19767]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19767) serial-issues.pl is unused and should be removed
- [[19794]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19794) Rename RLIST - Routing list notice template as it's not related to routing lists
- [[20461]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20461) New subscription form: "Item type" and "item type for older issues" fields are ignored
- [[20614]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20614) Firefox prevents parent page reload when renewing subscriptions
- [[20616]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20616) Using "Edit serials" with no issues selected gives an ugly error

### Staff Client

- [[19221]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19221) Onboarding tool says user needs to be made superlibrarian
- [[19456]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19456) Some pages title tag contains html
- [[19636]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19636) Hold priority changes incorrectly via dropdown select
- [[19857]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19857) Optionally hide SMS provider field in patron modification screen
- [[20227]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20227) admin/smart-rules.pl should pass categorycode instead of branchcode
- [[20268]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20268) CSS regression: white gap on the top of the staff pages
- [[20329]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20329) Text input fields are wider than the fieldset class they are inside of
- [[20347]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20347) Add missing classes to search results elements

### System Administration

- [[13676]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13676) OpacSuppression description says 'items' but means 'records'
- [[19560]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19560) Unable to delete library when branchcode contains special characters
- [[19788]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19788) Case sensitivity is not preserved when creating local system preferences
- [[19977]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19977) Local Use tab in systempreferences tries to open text editor's temporary files, and die
- [[19987]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19987) If no z39.50/SRU servers, the z39.50/SRU buttons should not show
- [[20091]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20091) FailedLoginAttempts is not part of NorwegianPatronDatabase pref group
- [[20383]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20383) Hide link to plugin management if plugins are not enabled

### Templates

- [[18820]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18820) The different parts in the main don't automatically adjust with the available space
- [[19602]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19602) Add usage statistics link to administration sidebar menu
- [[19677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19677) Angle brackets in enumchron do not display in opac or staff side
- [[19692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19692) Unclosed div in opac-shelves.tt
- [[19851]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19851) Improve responsive layout handling of staff client menu bar
- [[19918]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19918) span tag not closed in opac-registration-confirmation.tt
- [[20051]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20051) Invalid markup in staff client's header.inc
- [[20156]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20156) Staff client header language menu doesn't show check mark for current language
- [[20173]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20173) Clean up koha-tmpl directory
- [[20221]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20221) Fix for JavaScript error during checkout patron search
- [[20239]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20239) Fix spelling on authority linker plugin
- [[20240]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20240) Remove space before : when searching for a vendor in serials (Vendor name :)
- [[20249]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20249) "Patron has no outstanding fines" now appears alongside fines
- [[20290]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20290) Fix capitalization: Routing List
- [[20372]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20372) Correct toolbar markup on some pages
- [[20382]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20382) Missing space between patron and cardnumber on check out screen
- [[20422]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20422) Fix warn on URI/Escape.pm line 184 from opac-detail
- [[20433]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20433) Remove unused Mozilla Persona image file
- [[20552]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20552) Fix HTML tag for search facets
- [[20617]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20617) Add 'Search Engine configuration' link to administration menu
- [[20619]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20619) Remove last occurrences of long gone syspref (opacsmallimage)

### Test Suite

- [[17770]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17770) t/db_dependent/Sitemapper.t fails when date changes during test run
- [[18979]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18979) Speed up 'valid-templates.t' tests
- [[19705]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19705) DecreaseLoanHighHolds.t is still failing randomly
- [[19759]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19759) TestBuilder generates too many decimals for float
- [[19775]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19775) Search/History.t is failing randomly
- [[19776]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19776) Test failing randomly - fix categorycode vs category_type
- [[19783]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19783) Move check_kohastructure.t to db_dependent
- [[19867]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19867) HouseboundRoles.t is failing randomly
- [[19914]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19914) Cannot locate the "Delete" in the library list table
- [[19937]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19937) Silence warnings t/db_dependent/www/batch.t
- [[19979]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19979) Search.t fails on facet info with one branch
- [[20042]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20042) 00-load.t fails when Elasticsearch is not installed
- [[20144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20144) Test suite is failing with new default SQL modes
- [[20175]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20175) Set a correct default value for club_enrollments.date_created
- [[20176]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20176) Set biblio.datecreated to NOW if not defined
- [[20179]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20179) Remove GROUP BY in get_shelves_containing_record
- [[20180]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20180) Remove GROUP BY clause in manage-marc-import.pl
- [[20182]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20182) Remove group by clause in search_patrons_to_anonymise
- [[20191]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20191) OAI/Server.t still fails on slow servers
- [[20199]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20199) Letters.t does not pass with new SQL modes
- [[20204]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20204) FrameworkPlugin.t should not depend on CPL branch
- [[20250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20250) NoIssuesChargeGuarantees.t is still failing randomly
- [[20311]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20311) get_age tests can fail on February 28th
- [[20466]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20466) Incorrect fixtures for active currency in t/Prices.t
- [[20474]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20474) Passwordrecovery.t should mock Mail::Sendmail::sendmail
- [[20490]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20490) Correct wrong bug number in comment in Circulation.t
- [[20503]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20503) Borrower_PrevCheckout.t  is failing randomly
- [[20531]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20531) IssueSlip is failing randomly
- [[20557]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20557) Koha/Acquisition/Order.t is failing randomly
- [[20584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20584) Koha/Patron/Categories.t is on slow servers
- [[20721]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20721) Circulation.t keeps failing randomly
- [[20764]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20764) t/Koha_Template_Plugin_KohaPlugins.t is DB dependent

### Tools

- [[18201]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18201) Export data -Fix "Remove non-local items" option and add "Removes non-local records" option for existing functionality
- [[19643]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19643) Pagination buttons on staged marc management are stacking instead of inline
- [[19674]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19674) Broken indicators of changed fields in manage staged MARC records template
- [[19683]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19683) Export.pl does not populate the Authority Types dropdown correctly
- [[20098]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20098) Inventory: CSV export: itemlost column is always empty
- [[20222]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20222) Make bread crumb for cleanborrowers.pl match the link text in tools-home.pl
- [[20376]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20376) "Select all" button no longer selects disabled checkboxes in Batch Record Deletion Tool
- [[20438]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20438) Allow uninstalling plugins not implementing the 'uninstall' method
- [[20462]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20462) Duplicate barcodes in batch item deletion cause software error if deleting biblio records
- [[20695]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20695) Upload does not show all results when uploading multiple files

### Web services

- [[13990]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13990) ILS-DI LookupPatron Requries ID Type

### Z39.50 / SRU / OpenSearch Servers

- [[19986]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19986) 'Server name' doesn't appear as required when creating new z39.50/sru server

## New system preferences

- AuthorityControlledIndicators
- AutoSwitchPatron
- BrowseResultSelection
- CanMarkHoldsToPullAsLost
- MarcFieldDocURL
- NovelistSelectStaffProfile
- ProtectSuperlibrarianPrivileges
- PurgeSuggestionsOlderThan
- RESTOAuth2ClientCredentials
- RESTdefaultPageSize
- SelfCheckInMainUserBlock
- SelfCheckInModule
- SelfCheckInTimeout
- SelfCheckInUserCSS
- SelfCheckInUserJS
- StaffLoginInstructions
- UpdateItemWhenLostFromHoldList
- UseACQFrameworkForBiblioRecords

## Renamed system preferences
- NoLoginInstructions => OpacLoginInstructions

## Deleted system preferences
- checkdigit

## New Authorized value categories
- PAYMENT_TYPE

## New notices
- CANCEL_HOLD_ON_LOST

## Renamed notices
- RLIST => SERIAL_ALERT

## System requirements

Important notes:
    
- Perl 5.10 is required
- Zebra is required

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/18.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](http://git.koha-community.org/gitweb/?p=kohadocs.git;a=summary)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (96.8%)
- Armenian (99.2%)
- Basque (73.6%)
- Chinese (China) (78%)
- Chinese (Taiwan) (100%)
- Czech (91.5%)
- Danish (64.5%)
- English (New Zealand) (97%)
- English (USA)
- Finnish (93.1%)
- French (99.6%)
- French (Canada) (89.7%)
- German (100%)
- German (Switzerland) (96.7%)
- Greek (78.7%)
- Hindi (100%)
- Italian (97%)
- Norwegian Bokmål (53%)
- Occitan (post 1500) (71.3%)
- Persian (53.6%)
- Polish (95%)
- Portuguese (99.9%)
- Portuguese (Brazil) (78.7%)
- Slovak (93.8%)
- Spanish (99.5%)
- Swedish (95.1%)
- Turkish (99.2%)
- Vietnamese (66%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 18.05.00 is

- Release Manager: [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
- Release Manager assistant: [Nick Clemens](mailto:nick@bywatersolutions.com)

- QA Team:
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Alex Arnaud](mailto:alex.arnaud@biblibre.com)
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - Josef Moravec
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
- Bug Wranglers:
  - Claire Gravely
  - Jon Knight
  - [Marc Véron](mailto:veron@veron.ch)
  - Alex Buckley
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Team:
  - Lee Jamison
  - David Nind
  - Caroline Cyr La Rose
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Release Maintainers:
  - 17.11 -- [Nick Clemens](mailto:nick@bywatersolutions.com)
  - 17.05 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)
  - 16.11 -- [Chris Cormack](mailto:chrisc@catalyst.net.nz)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 18.05.00:

- BULAC - http://www.bulac.fr/
- ByWater Solutions
- Camden County
- Catalyst IT
- Goethe-Institut
- Hotchkiss School
- Orex Digital

We thank the following individuals who contributed patches to Koha 18.05.00.

- Aleisha Amohia (9)
- Alex Arnaud (8)
- Philippe Audet-Fortin (1)
- Zoe Bennett (8)
- Chad Billman (1)
- David Bourgault (10)
- Alex Buckley (4)
- Pongtawat C (1)
- Colin Campbell (2)
- Nick Clemens (74)
- Tomás Cohen Arazi (130)
- David Cook (2)
- Charlotte Cordwell (8)
- Chris Cormack (1)
- Bonnie Crawford (1)
- Christophe Croullebois (1)
- Olivier Crouzet (1)
- Roch D'Amour (3)
- Indranil Das Gupta (L2C2 Technologies) (1)
- Frédéric Demians (1)
- Marcel de Rooy (108)
- Jonathan Druart (568)
- Magnus Enger (3)
- Charles Farmer (4)
- Katrin Fischer (24)
- Jessica Freeman (1)
- Joachim Ganseman (1)
- Claire Gravely (5)
- Victor Grousset (22)
- Isabel Grubi (1)
- Amit Gupta (4)
- David Gustafsson (3)
- Andrew Isherwood (6)
- Mason James (4)
- Lee Jamison (1)
- Srdjan Jankovic (1)
- Janusz Kaczmarek (2)
- Pasi Kallinen (20)
- Olli-Antti Kivilahti (4)
- Ulrich Kleiber (1)
- Jon Knight (3)
- Owen Leonard (127)
- Ere Maijala (3)
- Sherryn Mak (1)
- Jose Martin (1)
- Jesse Maseto (1)
- Julian Maurice (36)
- Remi Mayrand-Provencher (1)
- Kyle M Hall (103)
- Josef Moravec (53)
- Chris Nighswonger (1)
- Priya Patel (1)
- Eric Phetteplace (1)
- Simon Pouchol (1)
- Te Rauhina Jackson (6)
- Liz Rea (6)
- Martin Renvoize (1)
- Benjamin Rokseth (1)
- Andreas Roussos (1)
- Maksim Sen (1)
- Radek Šiman (1)
- Grace Smyth (6)
- Fridolin Somers (7)
- Lari Taskula (7)
- Mirko Tietgen (13)
- Mark Tompsett (50)
- Jenny Way (6)
- Jesse Weaver (2)
- Chris Weeks (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 18.05.00

- abunchofthings.net (13)
- ACPL (127)
- BibLibre (74)
- BSZ BW (30)
- bugs.koha-community.org (568)
- ByWater-Solutions (179)
- Catalyst (17)
- Foundations (1)
- Göteborgs universitet (3)
- helsinki.fi (3)
- informaticsglobal.com (4)
- inLibro.com (2)
- jns.fi (11)
- joensuu.fi (20)
- KohaAloha (4)
- l2c2.co.in (1)
- Libriotech (3)
- Loughborough University (3)
- Marywood University (1)
- Oslo Public Library (1)
- pennmanor.net (1)
- Prosentient Systems (2)
- PTFS-Europe (9)
- punsarn.asia (1)
- rbit.cz (1)
- Rijksmuseum (108)
- Solutions inLibro inc (17)
- student.ua.ac.be (1)
- Tamil (1)
- Theke Solutions (130)
- unidentified (155)
- Université Jean Moulin Lyon 3 (1)

We also especially thank the following individuals who tested patches
for Koha.

- Arturo (3)
- claude (3)
- delaye (6)
- Joel (1)
- Brendan A Gallagher (1)
- Hugo Agud (7)
- Aleisha Amohia (1)
- Alex Arnaud (10)
- Marjorie Barry-Vila (2)
- Zoe Bennett (8)
- Anne-Claire Bernaudin (2)
- Sonia Bouis (1)
- David Bourgalt (1)
- David Bourgault (29)
- claude brayer (1)
- Jean-Manuel Broust (1)
- JM Broust (5)
- Alex Buckley (11)
- Colin Campbell (9)
- Barry Cannon (1)
- Marci Chen (1)
- Barton Chittenden (1)
- Axelle Clarisse (1)
- Nick Clemens (113)
- Tomas Cohen Arazi (171)
- Koha-us conference (1)
- Charlotte Cordwell (5)
- Chris Cormack (2)
- Roch D'Amour (26)
- Marcel de Rooy (250)
- Jonathan Druart (1491)
- Charles Farmer (16)
- Bouzid Fergani (1)
- Katrin Fischer (373)
- Brendan Gallagher (14)
- Lucie Gay (2)
- Bernardo Gonzalez Kriegel (1)
- Claire Gravely (79)
- Victor Grousset (11)
- Amit Gupta (1)
- Mohd Hafiz Yusoff (1)
- Sebastian Hierl (2)
- Mason James (2)
- Lee Jamison (3)
- Dilan Johnpullé (18)
- Eugene Jose Espinoza (1)
- Pasi Kallinen (20)
- Nancy Keener (1)
- Scott Kehoe (2)
- Olli-Antti Kivilahti (1)
- Jon Knight (37)
- Nicolas Legrand (14)
- Owen Leonard (52)
- Ere Maijala (1)
- Jesse Maseto (11)
- Daniel Mauchley (1)
- Julian Maurice (135)
- Jon McGowan (26)
- Kyle M Hall (219)
- Josef Moravec (351)
- Björn Nylén (2)
- Eric Phetteplace (1)
- Dominic Pichette (8)
- Simon Pouchol (23)
- Séverine QUEUNE (33)
- Te Rauhina Jackson (3)
- Liz Rea (2)
- Benjamin Rokseth (29)
- BWS Sandboxes (3)
- Maksim Sen (12)
- Grace Smyth (3)
- Fridolin Somers (2)
- Lari Taskula (17)
- Mirko Tietgen (9)
- Mark Tompsett (119)
- Ed Veal (2)
- Marc Véron (7)
- Marjorie Vila (5)
- Jenny Way (1)
- George Williams (3)

And people who contributed to the Koha manual during the release cycle of Koha 18.05.00.

  * Chris Cormack (37)
  * Caroline Cyr La Rose (27)
  * Jonathan Druart (9)
  * Magnus Enger (2)
  * Katrin Fischer (7)
  * Lee Jamison (7)
  * Hugh Rundle (2)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

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

Autogenerated release notes updated last on 17 May 2018 15:46:36.
