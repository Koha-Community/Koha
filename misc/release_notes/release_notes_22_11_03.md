# RELEASE NOTES FOR KOHA 22.11.03
23 Feb 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.11.03 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.11.03.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.11.03 is a bugfix/maintenance release.

It includes 40 enhancements, 87 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha [here](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).




## Enhancements

### Acquisitions

- [[32377]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32377) GetBudgetHierarchy slows down acqui/histsearch.pl

  **Sponsored by** *Koha-Suomi Oy*

### Architecture, internals, and plumbing

- [[28672]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28672) Improve EDI debug logging
- [[30310]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30310) Replace Moment.js with Day.js
- [[30642]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30642) We should record the renewal type (automatic/manual)
- [[31095]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31095) Remove Koha::Patron::Debarment::GetDebarments and use $patron->restrictions in preference

### I18N/L10N

- [[30993]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30993) Translation: Unbreak sentence in upload.tt
- [[31957]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31957) Translation: Ability to change the sentence structure on library administration page

### ILL

- [[32546]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32546) Move ILL system preferences to their own tab in administration

### Notices

- [[24616]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24616) Cannot copy notice to another library if it already exists

  **Sponsored by** *Koha-Suomi Oy*
- [[29100]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29100) Add checkouts data loop to predue/due notices script (advance_notices.pl)

### OPAC

- [[26765]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26765) Make author span a clickable link on OPAC results list
- [[31699]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31699) Add a generic way to redirect back to the page you were on at login for modal logins

  >This enhancement adds the ability to redirect users back to where they were when using the modal type logins in place of an action that requires login on the OPAC.
  >
  >Example: On the OPAC detail page you can add comments if logged in. Prior to this patch, clicking the link to add a comment prior to being logged in would expose the login modal and then re-direct you to your OPAC user page, and thus lose the context of your action.  With this enhancement, you are redirected back to the record you were looking at and can then post your comment.
- [[32125]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32125) Implement contextual return on OPAC comments

  >This enhancement ensures patrons are returned to the correct biblio detail page after a login that is prompted when attempting to comment on a bilio.

### REST API

- [[30962]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30962) REST API: Add endpoint /auth/password/validation
- [[32409]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32409) Cannot search cashups using non-latin-1 scripts

  >This fixes the cashup history table so that filters can use non latin-1 characters (Point of sale > Cash summary for <library> > select register). Before this fix, the table was not filtered or refreshed if you entered non latin-1 characters.

### SIP2

- [[32408]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32408) If a fine can be overridden on checkout in Koha, what should the SIP client do?

### Searching

- [[14911]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14911) Item search: Display additional 245 subfields in search results
- [[31326]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31326) Koha::Biblio->get_components_query fetches too many component parts

  **Sponsored by** *Koha-Suomi Oy*
- [[31338]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31338) Show in advanced search when IncludeSeeFromInSearches is used

### Staff interface

- [[32239]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32239) Report options for adding groups/sub groups are misaligned
- [[32644]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32644) Terminology: staff/intranet and biblio in plugins home page

  >This patch replaces some incorrect terminology in the plugins home page regarding enhanced content plugins.
- [[32718]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32718) Capitalization: Display Order
- [[32733]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32733) Add more page-sections to basket summary page

### Templates

- [[31407]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31407) Set focus for cursor to Currency when adding a new currency
- [[31932]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31932) The basket summary page template needs a cleanup
- [[32482]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32482) Reindent holds awaiting pickup template

  >This tidies up the template used to display the holds awaiting pickup page (Circulation > Holds > Holds awaiting pickup). It also fixes the page so that the circulation sidebar is now shown.
- [[32562]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32562) Reindent the about page template
- [[32571]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32571) Use template wrapper to build tabbed components
- [[32586]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32586) Reindent items with no checkouts reports template
- [[32587]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32587) Add page-section to items with no checkouts report
- [[32649]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32649) Use template wrapper for library transfer limits tabs
- [[32660]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32660) Use template wrapper for basket groups tabs
- [[32661]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32661) Use template wrapper for invoices page tabs
- [[32662]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32662) Use template wrapper for item circulation alerts page
- [[32688]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32688) Convert recalls awaiting pickup tabs to Bootstrap
- [[32690]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32690) Reindent the serial collection template
- [[32698]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32698) Use template wrapper for serials pages tabs
- [[32743]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32743) Reindent the invoice details page
- [[32769]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32769) Standardize structure around action fieldsets in administration

### Tools

- [[32600]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32600) Housebound module needs page-section treatment


## Critical bugs fixed

### Acquisitions

- [[32401]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32401) x-koha-query cannot contain non-ISO-8859-1 values

### Architecture, internals, and plumbing

- [[32393]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32393) background job worker explodes if JSON is incorrect
- [[32561]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32561) background job worker is still running with all the modules in RAM
- [[32612]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32612) Koha background worker should log to worker-error/output.log
- [[32656]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32656) Script delete_records_via_leader.pl no longer deletes items

### ERM

- [[32779]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32779) Import from list is broken

### Fines and fees

- [[30254]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30254) New overdue fine applied to incorrectly when using "Refund lost item charge and charge new overdue fine" option in circ rules

### I18N/L10N

- [[32356]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32356) xx-XX installer dir /kohadevbox/koha/installer/data/mysql/xx-XX already exists.

### Notices

- [[32442]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32442) Invalid Template Toolkit in notices can cause errors

### OPAC

- [[32712]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32712) OPACShowCheckoutName makes OPAC explode

### Plugin architecture

- [[32539]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32539) UI hooks can break the UI

### SIP2

- [[32515]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32515) SIP2 no block flag on checkin calls routine that does not exist

### Serials

- [[32555]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32555) Error when viewing serial in OPAC

### Staff interface

- [[32772]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32772) Patron autocomplete should not use contains on all fields

### Tools

- [[32631]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32631) Error when previewing record during batch record modification

  >This patch corrects an error in the script which outputs MARC data for preview during batch record modification.


## Other bugs fixed

### Acquisitions

- [[20473]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20473) "Item information" tab should not appear if item is not created upon placing an order
- [[32382]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32382) Fund input misaligned on invoice summary page
- [[32406]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32406) Cannot search pending orders using non-latin-1 scripts
- [[32603]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32603) Suggester category in Suggestions management
- [[32694]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32694) Keep current option for budgets in receiving broken

### Architecture, internals, and plumbing

- [[18247]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18247) Remove SQL queries from branch_transfer_limit.pl administrative script

  **Sponsored by** *Catalyst*
- [[31893]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31893) Some pages load about.tt template to check authentication rather than using checkauth
- [[32573]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32573) background_jobs_worker.pl should ACK a message before it forks and runs the job
- [[32580]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32580) Background job cancel button broken, leads to background_jobs.pl with a kc
- [[32583]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32583) Restore display of only one item in catalogue/moredetails

### Cataloging

- [[15869]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15869) Change framework on overlay

  >This change fixes a long-standing bug where the framework specified during import only applied to new records and not overlaid matches.
- [[29173]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29173) Button "replace authority record via Z39/50/SRU" doesn't pre-fill

  >This fixes the behaviour of the replace an authority record via Z39.50/SRU buttons when editing an authority record. Both ways of doing this (Edit > Edit record > Replace record via Z39.50/SRU search and Edit > Replace record via Z39.50/SRU search) now pre-fill the search form with available data.
- [[32204]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32204) in-page anchor to edititem on additem.pl not working
- [[32321]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32321) 006 field not correctly prepopulated in Advanced cataloging editor
- [[32567]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32567) Update plugin unimarc_field_110.pl 'Script of title' and 'Transliteration code'
- [[32692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32692) Terminology: MARC framework tag subfield editor uses intranet instead of staff interface

### Circulation

- [[29021]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29021) Automatic renewal due to RenewAccruingItemWhenPaid should not be considered Seen

### Command-line Utilities

- [[32793]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32793) import_patrons.pl typo in usage

### Database

- [[28674]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28674) old_reserves.item_level_hold and reserves.item_level_hold comments have typo "hpld" not "hold"

### Hold requests

- [[32455]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32455) Don't send hold notices from the library's inbound email address

### I18N/L10N

- [[32292]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32292) Update and add database column descriptions used in guided reports

  >This completes and adds column descriptions that show up when creating a new guided report for following tables:
  >* items
  >* borrowers
  >* biblio
  >* aqorders
  >* suggestions
- [[32588]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32588) Filters on top of 'Items with no checkouts' report are untranslatable

### ILL

- [[22693]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22693) ILL "Price paid" column does not appear in column configuration

  >This adds the "Price paid" column to the inter-library loan requests table.  This column is also configurable using the Columns button and in the table settings (Administration > Additional parameters > Table settings > Interlibrary loans > ill-requests).

### MARC Bibliographic data support

- [[31860]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31860) Standardize capitalization for item subfield descriptions (UNIMARC 995/MARC21 952)
- [[32689]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32689) Host item entry (773) missing a space between label and content when $i is used

### Notices

- [[32221]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32221) Password entry should be removed from placeholder list in notices editor

### OPAC

- [[16522]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16522) Add 773 (Host item entry) to the cart and list displays and e-mails

  **Sponsored by** *Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)*

  >This adds information from host item entry (MARC21 773) and if applicable a link to the host record in the following places:
  >* Staff interface: list, list email, cart, cart email, and search results
  >* OPAC: list, list email, cart, cart email, and search results
- [[32251]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32251) opac-page.pl: Add a fallback for when language cookie was removed

### Patrons

- [[32570]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32570) City is duplicated in patron search if the patron has both city and state
- [[32655]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32655) Variables showing in patron messaging preferences

### Reports

- [[32589]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32589) Improve headings on result tables for 'checkouts with no items' report

### SIP2

- [[32537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32537) Add 'no_block' option to sip_cli_emulator

  >This enhanced adds the no-block option to the SIP emulator for optional use in checkout/checkin/renew messages.
- [[32624]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32624) Patrons fines are not accurate in SIP2 when NoIssuesChargeGuarantorsWithGuarantees or NoIssuesChargeGuarantees are enabled

### Searching - Zebra

- [[32416]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32416) arp - Accelerated reader point searches fail due to conflicting attribute

  >This fixes
- [[32741]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32741) Attribute codes should not be repeated in bib1.att

### Self checkout

- [[19188]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19188) Self checkout: Fine blocking checkout is missing currency symbol

### Staff interface

- [[28314]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28314) Spinning icon is not always going away for local covers in staff
- [[31768]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31768) Tags is a 'Tool' but doesn't include the tools nav sidebar
- [[31962]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31962) Add tooltip to 'configure' on datatable controls
- [[32027]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32027) Terminology: change "librarian interface" to "staff interface" in additional contents tool
- [[32504]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32504) Empty column name, misaligning visibility, and export for basket/orders in table settings
- [[32520]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32520) Patron autocomplete should respect DefaultPatronSearchFields
- [[32523]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32523) Shortcuts / Links to missing fields in MARC-Editor don't work as expected

  >This fixes the standard MARC editor so that the links for any errors go to the correct tab. Currently, the links only work if you are the correct tab.
- [[32797]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32797) Cannot save OAI set mapping rule for subfield 0
- [[32881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32881) System preferences sub menu text is hard to read
- [[32908]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32908) Item type icons broken in the bibliographic record details page
- [[32909]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32909) Item type icons broken when placing an item-level hold

### System Administration

- [[32544]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32544) borrowers.flags should not be an option in any BorrowerMandatory or BorrowerUnwanted system preferences
- [[32761]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32761) Typos in description of CircControlReturnsBranch system preference
- [[32786]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32786) Curbside pickup admin page has cities search bar
- [[32787]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32787) Patron restrictions admin page has patron categories search bar
- [[32788]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32788) Curbside pickups - Order curbside pickup slots chronologically

### Templates

- [[32023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32023) Remove horizontal line from OPAC navigation for CMS pages
- [[32222]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32222) Capitalization: id
- [[32226]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32226) Capitalization: Edit html content
- [[32229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32229) Typo: Items missing from bundle at checkin for %s
- [[32230]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32230) Capitalization: Manage Domains
- [[32264]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32264) Capitalization/Terminology: Show in Staff client?
- [[32289]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32289) Punctuation: Delete desk "...?"
- [[32290]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32290) ILL requests uses some wrong terminology
- [[32294]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32294) Capitalization: Enter your User ID...
- [[32295]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32295) Punctuation: Filters :
- [[32605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32605) Restore some form styling from before the redesign
- [[32606]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32606) Revert Flatpickr style changes made in Bug 31943
- [[32618]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32618) Add 'page-section' to various administration pages
- [[32633]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32633) Add 'page-section' to cataloging and authority pages
- [[32672]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32672) Incorrect CSS path to jquery-ui
- [[32738]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32738) Correct upload local cover image title tag
- [[32785]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32785) Typo: Maximum number of simultaneus pickups per interval (curbside pickups)

### Test Suite

- [[32376]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32376) selenium/authentication_2fa.t produces artefact
- [[32673]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32673) Remove misc/load_testing/ scripts

### Tools

- [[26628]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26628) Clubs permissions should grant access to Tools page



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)



The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (72.8%)
- Armenian (100%)
- Bulgarian (92.1%)
- Chinese (Taiwan) (83.1%)
- Czech (59.6%)
- English (New Zealand) (69%)
- English (USA)
- Finnish (95.4%)
- French (97%)
- French (Canada) (95.9%)
- German (100%)
- German (Switzerland) (50.6%)
- Greek (50.4%)
- Hindi (98.9%)
- Italian (93.5%)
- Nederlands-Nederland (Dutch-The Netherlands) (77.1%)
- Norwegian Bokmål (52.8%)
- Persian (58.4%)
- Polish (92.7%)
- Portuguese (74.1%)
- Portuguese (Brazil) (78.3%)
- Russian (90.7%)
- Slovak (59.7%)
- Spanish (99%)
- Swedish (76.3%)
- Telugu (78.8%)
- Turkish (88.2%)
- Ukrainian (78.3%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 22.11.03 is


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
  - 22.11 -- PTFS Europe (Martin Renvoize, Matt Blenkinsop, Jacob O'Mara)
  - 22.05 -- Lucas Gass
  - 21.11 -- Arthur Suzuki
  - 21.05 -- Wainui Witika-Park

## Credits
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 22.11.03

- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- [Koha-Suomi Oy](https://koha-suomi.fi)

We thank the following individuals who contributed patches to Koha 22.11.03

- Aleisha Amohia (3)
- Pedro Amorim (2)
- Tomás Cohen Arazi (23)
- Matt Blenkinsop (3)
- Alex Buckley (1)
- Nick Clemens (23)
- David Cook (5)
- Frédéric Demians (1)
- Jonathan Druart (22)
- Katrin Fischer (41)
- Andrew Fuerste-Henry (1)
- Lucas Gass (7)
- Thibaud Guillot (2)
- Michael Hafen (1)
- Kyle M Hall (14)
- Jan Kissig (1)
- Owen Leonard (34)
- Matthias Meusburger (1)
- David Nind (1)
- Jacob O'Mara (2)
- Johanna Raisa (1)
- Martin Renvoize (33)
- Marcel de Rooy (5)
- Caroline Cyr La Rose (4)
- Andreas Roussos (1)
- Slava Shishkin (2)
- Fridolin Somers (2)
- Emmi Takkinen (3)
- Koha translators (1)
- George Veranis (1)
- Jenny Way (1)
- Hammat Wele (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.11.03

- Athens County Public Libraries (34)
- BibLibre (5)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (41)
- ByWater-Solutions (44)
- Catalyst (1)
- Catalyst Open Source Academy (3)
- Dataly Tech (2)
- David Nind (1)
- dubcolib.org (1)
- Independant Individuals (5)
- Koha Community Developers (22)
- Koha-Suomi (3)
- Prosentient Systems (5)
- PTFS-Europe (40)
- Rijksmuseum (5)
- Solutions inLibro inc (5)
- Tamil (1)
- th-wildau.de (1)
- Theke Solutions (23)

We also especially thank the following individuals who tested patches
for Koha

- Pedro Amorim (22)
- Tomás Cohen Arazi (221)
- Matt Blenkinsop (76)
- Philippe Blouin (1)
- Felicity Brown (2)
- Nick Clemens (24)
- David Cook (1)
- Frédéric Demians (6)
- Jonathan Druart (24)
- Laura Escamilla (2)
- Katrin Fischer (65)
- Andrew Fuerste-Henry (10)
- Lucas Gass (19)
- Amaury GAU (2)
- Kyle M Hall (30)
- Heather Hernandez (7)
- Barbara Johnson (4)
- Owen Leonard (15)
- ml-inlibro (1)
- David Nind (73)
- Jacob O'Mara (143)
- Jacob Omara (1)
- Pascal (1)
- Martin Renvoize (69)
- Marcel de Rooy (20)
- Caroline Cyr La Rose (9)
- George Veranis (1)



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

Autogenerated release notes updated last on 23 Feb 2023 17:38:14.
