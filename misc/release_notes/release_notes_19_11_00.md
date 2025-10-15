# RELEASE NOTES FOR KOHA 19.11.00
27 Nov 2019

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.11.00 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.11-latest.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.11.00 is a major release, that comes with many new features.

It includes 7 security fixes, 20 new features, 146 enhancements, 367 bugfixes.

### System requirements

Koha is continiously tested against the following configurations and as such these are the recommendations for 
deployment: 

- Debian Jessie with MySQL 5.5
- Debian Stretch with MariaDB 10.1 (MySQL 8.0 support is experimental)
- Ubuntu Bionic with MariaDB 10.1 (MariaDB 10.3 support is experimental) 

Additional notes:
    
- Perl 5.10 is required
- Zebra or Elasticsearch is required


## Security bugs

### Koha

- [[22543]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22543) Patron might be logged in again using browser back button
- [[23025]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23025) security vulnerability detected in fstream < 1.0.12 defined in yarn.lock
- [[23042]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23042) Local login attempt populates shibboleth url with userid and password in plain text
- [[23058]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23058) Cross-site scripting in OPAC search
- [[23329]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23329) tracklinks.pl accepts any url from a parameter for proxying if not tracking
- [[23451]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23451) Reflected XSS in opac-imageviewer.pl
- [[23836]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23836) tracklinks.pl should not forward if TrackClicks is disabled

## New features

### Cataloging

- [[17179]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17179) Advanced editor: Add keyboard shortcuts to repeat (duplicate) a field, and cut text

  **Sponsored by** *Round Rock Public Library*

  >This patchset introduces an internal clipboard to the advanced editor and provides some new functionality to make use of it; The following default shortcuts are provided but can be edited as per bug 21411.
  >
  >Changed:
  >* `Ctrl-X`: Now cuts a line into the clipboard area
  >* `Shift-Ctrl-X`: Now cuts current subfield into clipboard area
  >
  >Added:
  >* `Ctrl-C`: Copies a line into the clipboard area
  >* `Shift-Ctrl-C`: Copies current subfield into clipboard area
  >* `Ctrl-P`: Pastes the selected item from the clipboard at cursor
  >* `Ctrl-I`: Copies the current line and inserts onto a new line below

- [[22445]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22445) Ability to define a URL for custom cover images

  **Sponsored by** *Orex Digital*

  >This development adds the ability to use alternative cover art providers who provide covers openly via consistent URLs.
  >Three new system preferences are introduced, `CustomCoverImagesURL`,  `CustomCoverImages` and  `OPACCustomCoverImages`.

### Fines and fees

- [[23228]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23228) Add option to automatically display payment receipt for printing after making a payment

  >This enhancement adds the optional ability to automatically popup the receipt print dialogue upon successful payments in the staff client.
  >
  >
  >Note: The new `FinePaymentAutoPopup` must be enabled and popup blocker may require setting to allow popups for your Koha staff client domain.

### Hold requests

- [[19618]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19618) Add 'Club Holds' feature

  **Sponsored by** *South East Kansas Library System*

  >This new feature adds the ability for clubs to place a hold for bibs. When such a hold is placed, in the background a hold will be automatically placed for each member of the group in random order.

### OPAC

- [[22581]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22581) Add support for Plaine & Easie musical incipits rendering in OPAC

  **Sponsored by** *Biblioteca Provincial Fr. Mamerto Esquiú (Provincia Franciscana de la Asunción)*

  >This development adds support for displaying Plaine & Easie musical incipits in the OPAC.  With this feature enabled, when a cataloguer adds incipits codes to the 031 MARC21 fields they will display as musical scores and optionally include a short audio clip.

- [[23214]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23214) Add ability to pay guarantees fines

  >This new feature gives guarantors the option to pay off their guarantees charges using online payments via the OPAC.

### Patrons

- [[14570]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14570) Make it possible to add multiple guarantors to a record

  **Sponsored by** *Northeast Kansas Library System* and *Vermont Organization of Koha Automated Libraries*

  >This development adds the ability for a patron to have an unlimited number of guarantors in any combination of existing Koha patrons and manually added guarantors ( e.g. the guarantor has no patron record in Koha ).
  >
  >This feature retains the existing behaviour for importing guarantors during patron imports; However, guarantors can no longer be viewed, added or updated via the REST API.
  >
  >Reports that utilize `borrowers.guarantorid` will need to be updated.

### Plugin architecture

- [[22706]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22706) Add plugin hooks to allow custom password strength checking modules

  >This new feature allows plugin authors to implement a `check_password` method to enable custom password validation routines.
  >
  >**Warning**: Care should be taken when installing any plugins and only plugins you trust should be used.  The hook introduced here allows plugin authors to potentially steel plain text passwords during patron creations and updates.

- [[22709]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22709) Add hooks to notify plugins of biblio and item changes

  >This new feature allows plugin authors to implement `after_biblio_action` and `after_item_action` methods which may be used to take various actions upon biblio and item creations, modifications and deletions.
  >
  >**Warning**: Care should be taken when installing any plugins and only plugins you trust should be used.

- [[22834]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22834) Add a method for plugins to return the absolute path for bundled files

  >This new feature allows plugin authors to construct absolute paths to resources contained within their plugins using the new `bundle_path` method.
  >
  >This can be used to aid in serving static content.
  >
  >**Warning**: Care should be taken when installing any plugins and only plugins you trust should be used.

- [[22835]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22835) Serve static files from plugins through the API

  **Sponsored by** *Theke Solutions*

  >This new feature allows plugin authors to serve static files through the API without the requirement to tweak the Apache configuration files. Routes to the static files tree are automatically loaded from a specially crafted file the plugin authors need to include in the distributed .kpz files.
  >
  >**Warning**: Care should be taken when installing any plugins and only plugins you trust should be used.a

- [[23050]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23050) Add hook to add a tab in intranet biblio details page

  >This new feature allows plugin authors to add additional tabs to the intranet biblio details page.  The new `intranet_catalog_biblio_tab` method which should return an array of `Koha::Plugins::Tab` objects is introduced.
  >
  >**Warning**: Care should be taken when installing any plugins and only plugins you trust should be used.

- [[23237]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23237) Add support for [% INCLUDE %] in plugin templates

  >The new feature allows plugin authors to use template `[% INCLUDE %]` directives in their templates. It does so by introducing a new variable, `PLUGIN_DIR`, allowing the template engine to locate the includes.
  >
  >**Usage**: `[% INCLUDE "$PLUGIN_DIR/header.tt" %]`
  >
  >**Warning**: Care should be taken when installing any plugins and only plugins you trust should be used.

### REST API

- [[16825]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16825) Add API route for getting an item

  **Sponsored by** *Koha-Suomi Oy*

- [[17003]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17003) Add API route to get checkout's renewability
- [[23517]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23517) Add API route to update a holds priority
- [[23584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23584) Add public API routes to change privacy settings
- [[23677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23677) Add API route to get a bibliographic record

### Staff Client

- [[23321]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23321) Add 'cash registers' to the accounts system

  **Sponsored by** *Cheshire Libraries Shared Services* and *PTFS Europe*

  >This new feature adds the ability to define cash registers in Koha and assign transactions to them. It introduces the new `UseCashRegisters` system preference which when enabled will expose the cash register management screen under the administration area and also require a cash register to be associated with any transaction of the payment type `CASH`.

### Z39.50 / SRU / OpenSearch Servers

- [[13937]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13937) Add an Elasticsearch-compatible Z39.50/SRU daemon

  **Sponsored by** *National Library of Finland*

  >This development allows libraries wishing to run Elasticsearch but also serve as a public SRU/Z39.50 gateway to do so without running Zebra in parallel.

## Enhancements

### Acquisitions

- [[14669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14669) Search orders by managing library
- [[20254]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20254) Forbid the download of duplicate EDI messages
- [[20595]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20595) EDI: Add support for LRP (Library Rotation Plan) for Koha with Stock Rotation enabled

  **Sponsored by** *PTFS Europe*

  >This enhancement allows items to be automatically added to rotas at acquisition time by using the LRP (Library Rotation Plan) field in EDI.a

- [[23522]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23522) Show "Actual price" in basket when available

  **Sponsored by** *Virginia Tech*

### Architecture, internals, and plumbing

- [[18928]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18928) Move `holdallowed`, `hold_fulfillment_policy` and `returnbranch` into the `circulation_rules` table.

  >**Reports note**: This changes the database schema, reports referencing the `default_branch_circ_rules`, `default_circ_rules`, `default_branch_item_rules` or `branch_item_rules` tables will need to be updated

- [[18930]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18930) Move 'refund lost item fee rules' into the `circulation_rules` table

  >**Reports note**: This changes the database schema, reports referencing the `refund_lost_item_fee_rules` table will need to be updated

- [[22563]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22563) Convert lost handling to use 'status' instead of multiple accounttypes

  >**Reports note**: The `accounttype` for lost item fees has been updated from 'L' to 'LOST' and for lost item returned credits it has been updated from 'CR' to 'LOST_RETURNED'. The `status` field is now used to track the reason why an 'OVERDUE' fee has stopped incrementing and it may include 'LOST'

- [[22610]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22610) SIP Payment Types should be moved out of accountype

  >**Reports note**: SIP2 `accounttypes` have been deprecated in favour of using standard accounttypes across transactions in the accountlines. Reports should be updated to use `payment_type` to distinguish between the different SIP2 payment type as required.

- [[22721]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22721) Normalize GetMarcFromKohaField calls
- [[22837]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22837) Koha::Account::Line->apply should not require a 'set' of debits
- [[23068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23068) Add ability for Koha to handle X-Forwarded-For headers so REMOTE_ADDR features work behind a proxy
- [[23152]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23152) koha_object[s]_class methods must be implemented when needed
- [[23230]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23230) Make Koha::Plugins::Base::_version_compare OO
- [[23272]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23272) Koha::AuthorisedValue should use Koha::Object::Limit::Library
- [[23281]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23281) Add Koha::Objects::Limit::Library
- [[23414]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23414) Improve performance of C4/XSLT/buildKohaItemsNamespace
- [[23580]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23580) Add C4::Context->yaml_preference

  >This trivial patch adds a convenient way to retrieve YAML-based  system preferences in the code, avoiding the need to handle the decoding in each place they are used.

- [[23623]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23623) Use the new API and remove /svc scripts for privacy settings
- [[23770]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23770) Add Koha::Object(s)->to_api method

  **Sponsored by** *ByWater Solutions*

- [[23793]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23793) Add an EmbedItems RecordProcessor filter for MARC::Record objects
- [[23807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23807) Add Koha::Item->as_marc_field
- [[23843]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23843) Make existing endpoints use Koha::Object(s)->to_api

### Authentication

- [[23146]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23146) Add support for Basic auth on the OAuth2 token endpoint

  **Sponsored by** *ByWater Solutions*

  >This patchset adds flexibility to the OAuth2 implementation regarding how the parameters are passed on the request. The original implementation of OAuth2 only contemplated the option to pass the client_id and client_secret parameters on the request body. It is very common that clients expect to be able to pass them as a Basic authorization header.

### Cataloging

- [[15497]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15497) Limit item types by library

  **Sponsored by** *Central Kansas Library System*, *Northeast Kansas Library System* and *South East Kansas Library System*

- [[17178]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17178) Add a popup/keyboard shortcuts for diacritics and symbols in the advanced cataloging editor

  **Sponsored by** *Round Rock Public Library*

- [[23602]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23602) Library limitations should display in the item types table

### Circulation

- [[14697]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14697) Extend and enhance "Claims returned" lost status

  **Sponsored by** *Fargo Public Library* and *North Central Regional Library System*

  >This enhancement extends the "Claims returned" lost status and allows staff to track items that patrons claim to have returned. Items are marked as "Claims returned" from the checkout page in the staff side.
  >
  >There are 3 new systems preferences to set for this functionality to work: `ClaimReturnedChargeFee`, `ClaimReturnedLostValue` and `ClaimReturnedWarningThreshold`

- [[17492]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17492) Show warning if patron's age is out of category limits

  >This development adds a warning at checkout if a patron is found to have an age that is outside their categories age range and allows the staff user to immediately update the patrons' category from the warning dialogue.

- [[20194]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20194) Display both biblioitems.itemtype and items.itype in circulation screens
- [[20959]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20959) Style checkin form more like the checkout form, with collapsed settings panel
- [[23328]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23328) Some check-in messages should be dismissable
- [[23507]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23507) Add ability to show and print change given on fee receipt from FinePaymentAutoPopup
- [[23686]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23686) Check onsite checkout when the last checkout was an onsite one

### Command-line Utilities

- [[16219]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16219) Runreport.pl should allow SQL parameters to be passed on the command line
- [[17168]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17168) Add a command line script for updating patron category based on status

  **Sponsored by** *Round Rock Public Library*

  >These patches introduce a new script to replace the `j2a.pl` script with a more flexible set of options.
  >
  >`misc/cronjobs/update_patrons_category.pl` can now be used to update patrons who are older or younger than their patron categories to a category chosen by the user.
  >
  >Additionally, this script allows users to specify a fine total to update patrons, to use any specified borrowers field, and to run by category and/or branch.
  >
  >The intention here is to assist in automating updating patrons for schools or libraries where patrons are regularly changed - patrons with fines can be moved to 'probational statuses' or patrons without fines can be moved to 'privileged statuses'.
  >
  >The flexibility should allow for various workflows to be automated via cronjob.

- [[22509]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22509) Add a script to generate MARC fields containing date formatted strings

  **Sponsored by** *Orex Digital*

- [[23346]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23346) Add without-db-name parameter to koha-dump

  >This enhancement is the first step in allowing a koha database dump file to be restored into another koha instance.
  >
  >One can now pass the `--without-db-name` option to `koha-dump` to attain a zipped sql dump with no longer contains the `CREATE DATABASE` and `USE` statements within the restore file.

### Fines and fees

- [[6759]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6759) Use a different account type for account renewals than for new accounts

  >This enhancement makes account renewal charges distinct from initial account registration charges.
  >
  >**Reports note**: Prior to this patch both account creations and account renewals would result in an accountline with accounttype `A`; After this patch account creations will result in an accountline with accounttype `ACCOUNT` and account renewals will result in ana ccountline with accounttype `ACCOUNT_RENEW`.

- [[22627]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22627) Rephrase 'your fines and charges' tab in OPAC

  **Sponsored by** *Catalyst*

- [[23049]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23049) Replace MANUAL_INV authorised value with a dedicated table

  >This patchset moves the `MANUAL_INV` authorized values into their own table and adds an interface into the administration pages to allow the addition and modification of such account types.
  >
  >This serves as the foundation for enhancing the accounts system and leads to clearer code and more consistent data via database-level constraints.
  >
  >**Reports note**: Reports will need to be updated to look in the new debit_type_code field for accountlines of type 'debit' and use the updated coded values.

- [[23805]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23805) Add a dedicated credit_types table

  >This patchset moves the remaining accounttypes, all of which should be credits after bug 23049, into their own table.
  >
  >This serves as the foundation for enhancing the accounts system and leads to clearer code and more consistent data via database-level constraints.
  >
  >**Reports note**: Reports will need to be updated to look in the new credit_type_code field for accountlines of type 'credit' and use the updated coded values.

### Hold requests

- [[22922]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22922) Allow to modify hold and hold expiration date in staff

### Holidays

- [[15260]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15260) Option for extended loan with useDaysMode

  **Sponsored by** *Cheshire East Council*, *Cheshire West and Chester Council*, *Newcastle City Council* and *Sefton Council*

  >The `useDaysMode` system preference has been enhanced to include an additional option.
  >
  >This allows libraries to dictate that if the library is closed on the usual due date, the loan period should be pushed forward to the next open day which is the same day of the week.
  >
  >For example : If an item should be due back on a Tuesday but that particular Tuesday is closed, then instead of it being due back the Wednesday (usual behaviour when due date is pushed forward to next open day), it would actually be due back the next available open Tuesday.
  >
  >**Note**: This preference setting only works in multiples of 7.

### I18N/L10N

- [[23631]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23631) fr-CA translation of NEW_SUGGESTION notice
- [[23983]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23983) Contextualization of "Order" (verb) vs "Order" (noun)

### Label/patron card printing

- [[23464]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23464) Update the process of quick spine label printing

### MARC Bibliographic data support

- [[18309]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18309) UNIMARC update from IFLA for new Koha installations
- [[20364]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20364) Show languages from MARC21 field 041 in intranet

  >This patch adds language data from the 041 field of bibliographic records to both the search results and details pages of the staff client.

- [[20434]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20434) UNIMARC update from IFLA for existing Koha installations
- [[22884]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22884) Remove ending . from XSLT templates
- [[23731]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23731) Display LC call number in OPAC and staff detail pages

### Notices

- [[21180]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21180) Allow Talking Tech outbound script to limit based on patron home library branchcode
- [[23278]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23278) Reopen last panel upon "Save and continue" in notices

### OPAC

- [[5287]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5287) Add floating toolbar to search results in OPAC
- [[8778]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8778) Add Keyword phrase search to OPAC search
- [[20691]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20691) Add ability for guarantors to view guarantee's fines in OPAC
- [[21701]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21701) Have PayPal optionally return to originating OPAC url rather than OPACBaseURL
- [[23096]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23096) Add floating toolbar to OPAC lists
- [[23299]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23299) Switch address1 and streetnumber for German address format on opac-memberentry
- [[23392]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23392) Support MARC21 indicators for private note fields
- [[23566]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23566) Continue on device - with QR codes
- [[23633]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23633) Filter out historical charges by default on a users 'your charges' page
- [[23694]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23694) Author "By" should have its own class
- [[23720]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23720) Add div wrapper to search results to make moving cover images easier
- [[23791]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23791) Allow granular control of social networks enabled by SocialNetworks syspref
- [[23903]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23903) Replace OPAC icons with Font Awesome

  >This patchset updates the majority of icons in the opac to use Font Awesome icons. It improves the consistency of icons, icon alignment and also gives a minor performance boost in opac display.

- [[23955]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23955) Replace famfamfam icon in OPAC holds template

### Packaging

- [[23400]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23400) Add --status to koha-indexer

### Patrons

- [[23219]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23219) Show a warning about cancelling their holds before a patron is deleted
- [[23697]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23697) Add auto complete for patron search in patron module

  >This enhancement adds an optional auto-complete function to the patron search field when in the patrons module.
  >
  >The `CircAutocompl` system preference is renamed to `PatronAutoComplete` and use for both the circulation and patrons module auto-complete.

### Plugin architecture

- [[21073]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21073) Improve plugin performance

  >Before this patch, whenever a plugin hook was reached in koha code we would iteratively load plugins looking for one that may support the method.  This patch adds database level caching of this data so we do one database call instead of iteratively calling 'load'.

- [[23191]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23191) Administrators should be able to install plugins from the command line

  >This patch adds a new script `misc/devel/install_plugins.pl ` which allows system administrators the option of installing plugins via the command line as opposed to requiring the web side UI.

- [[23213]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23213) Add hook to OPAC payments to allow plugins to set minimum payment threshold

### REST API

- [[17005]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17005) Extend /checkouts route to list circulation history
- [[23667]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23667) Add API route for listing items

### Reports

- [[15422]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15422) Number of items to order on holds ratio report will not fulfill the holds ratio
- [[23206]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23206) Batch patron modification from reports which return cardnumber

  >This enhancement adds `Batch patron modification` to the available options display when a report outputs a list of borrowernumbers or cardnumbers.

- [[23389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23389) Add 'All' option to report value dropdowns

  >This enhancement adds the ability to optionally include an `all` option in report placeholders allowing for an 'All' option to be displayed in filter select lists.
  >
  >**Usage**: `WHERE branchcode LIKE <<Branch|branches:all>>`

- [[23390]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23390) Add placeholder syntax for column names

  >This enhancement allows for renaming columns used to trigger batch modification actions in reports. Before this patch, a column had to be called 'itemnumber' to be sent from reports to batch modification. With this enhancement, you can specify `[[itemnumber| Koha_internal_id]]` to allow for a clearer name for the end-user and to allow translation of terms like 'itemnumber' while preserving the batch modification functionality.

### SIP2

- [[20292]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20292) Filter/censor info sent via SIP

  **Sponsored by** *Duchesne County Library* and *Uintah Library System*

  >This enhancement allows the administrator to set if, and which, fields should not be sent to third-party SIP2 clients for privacy reasons.

- [[20954]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20954) Add ability to set syspref overrides in SIP as we can in Apache

  **Sponsored by** *South East Kansas Library System*

- [[22540]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22540) Add ability to place holds using SIP CLI emulator

### Searching

- [[23386]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23386) Add language of original in advanced search - staff client
- [[23543]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23543) Adding withdrawn to the item search

### Searching - Elasticsearch

- [[17851]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17851) Add Elasticsearch config to koha-conf.xml

  **Sponsored by** *Koha-Suomi Oy*

- [[20334]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20334) Elasticsearch - Option for escaping slashes in search queries
- [[20589]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20589) Add field boosting and use elastic query fields parameter instead of deprecated _all
- [[20607]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20607) Elasticsearch - ability to add a relevancy weight in mappings.yaml file
- [[22592]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22592) Elasticsearch - Support for index scan
- [[22826]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22826) Allow indexing of individual authority records in Elasticsearch

### Serials

- [[21588]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21588) Add "Collapse/Expand" options on subscription-detail page
- [[23435]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23435) Add multiple copies of an item when receiving in serials

  **Sponsored by** *Brimbank City Council*

### Staff Client

- [[18421]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18421) Make Coce cover images available for staff search
- [[21245]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21245) Move 'Last patron' button inside of the 'breadcrumb' bar
- [[23711]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23711) Icons on staff main page should be font icons
- [[23803]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23803) Add Font Awesome icon to cart in staff interface

### System Administration

- [[11529]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11529) Add subtitle, medium and part fields to biblio table

  **Sponsored by** *National Library of Finland*

  >Keywords to MARC mapping functionality has been replaced with additional Koha fields in the bibliographic framework. 
  >
  >The keyword mapping only offered a single field, subtitle, and the information was always retrieved from the MARC record, which made it relatively slow. The subtitle and other relevant fields are now available as normal Koha fields:
  >
  >     biblio.medium - Medium information (MARC 21: 245h, UNIMARC: 200b)
  >     biblio.subtitle - Subtitle (MARC 21: 245b, UNIMARC: 200e)
  >     biblio.part_number - Part number (MARC 21: 245n, UNIMARC: 200h)
  >     biblio.part_name - Part name (MARC 21: 245p, UNIMARC: 200i)
  >
  >The subfields in the default framework are automatically updated to include these new fields unless they are already mapped to another Koha field.
  >
  >**Important note**: misc/batchRebuildBiblioTables.pl should be run, after this enhancement is applied, to populate the fields in the database, and it will take some time for larger databases.

- [[21574]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21574) Local use system preferences page doesn't have the system preferences menu
- [[23179]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23179) Add 'Edit subfields' to framework management tag dropdown and clarify options
- [[23606]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23606) Add columns configuration and export options to item types administration
- [[23611]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23611) Add export option to authorized values administration
- [[23866]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23866) HEA submission preferences should prompt similar to ManaKB

### Templates

- [[7074]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7074) Show subtitle, part and number of a record in list of checkins
- [[17057]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17057) Remove event attributes from holds template
- [[21058]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21058) Missing class for results_summary spans
- [[21824]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21824) Add ability to format dates in various formats in templates

  >This patchset allows end-users to use advanced date formatting options within template toolkit based notices and slips.

- [[21852]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21852) Add more columns and column configuration to overdues report
- [[22209]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22209) Move stock rotation stage and item forms into modals
- [[22897]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22897) Switch two-column templates to Bootstrap grid: ILL requests
- [[22935]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22935) Improve style of Bootstrap pagination
- [[22999]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22999) Switch two-column templates to Bootstrap grid: Circulation
- [[23013]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23013) Upgrade DataTables in the staff client
- [[23094]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23094) Use Bootstrap-style pagination on staged MARC records page
- [[23159]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23159) Reindent addbiblio.tt
- [[23183]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23183) Reindent cataloging.js
- [[23196]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23196) Reindent tools/batch_record_modification.tt
- [[23197]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23197) Add more batch operation options to SQL report results
- [[23221]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23221) Reindent tools/manage-marc-import.tt
- [[23259]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23259) Remove reset-fonts-grids.css
- [[23286]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23286) Improve style of hold confirmation modal
- [[23304]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23304) Reindent cataloguing/z3950_search.tt
- [[23307]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23307) Add columns configuration to cataloguing/z3950_search.tt
- [[23339]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23339) Reindent addbooks.tt
- [[23351]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23351) Clean up localization template
- [[23399]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23399) Reindent returns.tt
- [[23438]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23438) Use Font Awesome icons in intranet search results browser
- [[23444]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23444) Terminology: Use library instead of branch
- [[23448]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23448) Clean up subscription detail template
- [[23458]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23458) Clean up holds template in the staff client
- [[23834]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23834) Add default ESLint configuration
- [[23958]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23958) Use Font Awesome icon to replace "new window" icon image
- [[24034]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24034) Capitalization on suggestion edit form: No Status
- [[24076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24076) Remove inline CSS to center patron home library in search results

### Test Suite

- [[23280]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23280) Warning in t/db_dependent/selenium/patrons_search.t
- [[23284]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23284) Duplicate test in t/db_dependent/Plugins.t
- [[23994]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23994) AdditionalFields.t is failing randomly (U18)

### Tools

- [[13552]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13552) Add debar option to batch patron modification
- [[22272]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22272) Calendar: When entering date ranges grey out dates in the past from the start date
- [[22888]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22888) Use DataTables for Koha news table filtering
- [[22996]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22996) Move barcode separators to a preference

  >Adds preference `BarcodeSeparators`
  >
  >**NOTE**: If you currently depend on a comma, semicolon, pipe character or hyphen as a barcode separator within inventory tool, please ADD them to this new preference. The default behaviour is set back to a carriage return, linefeed or whitespace now.

- [[23279]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23279) In news management interface, sort news by publication date descending
- [[23385]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23385) Hide default value fields by default on patron import
- [[23512]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23512) Reindent notices and slips page (letter.tt)

### Web services

- [[22677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22677) Include hint on OAI-PMH URL for Koha in system preference
- [[23154]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23154) Add pagination to /api/v1/checkouts
- [[23156]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23156) Add pagination to checkouts in ILS-DI GetPatronInfo service


## Critical bugs fixed

(This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### Acquisitions

- [[18743]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18743) Filter suggestion lists correctly for IndependentBranches

  **Sponsored by** *BULAC*

- [[21316]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21316) Adding controlfields to the ACQ framework causes issues when adding to basket
- [[23397]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23397) Order lines can be duplicated in acqui scripts spent.pl and ordered.pl
- [[23854]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23854) Cannot edit a suggestion
- [[23855]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23855) Cannot mark the selected suggestion as "pending"
- [[23863]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23863) Editing a basket clears create_items value
- [[23927]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23927) Duplicate a "Complete" order  link the "New" one to the invoice

### Architecture, internals, and plumbing

- [[22857]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22857) Entries missing in koha-conf.xml
- [[23095]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23095) Circulation rules not displayed (empty vs null)
- [[23316]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23316) GetFine needs updating for bug 22521
- [[23599]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23599) Koha::Objects::Limit::Library fails if no library passed
- [[23655]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23655) Errors when running on Debian Jessie
- [[23723]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23723) Using exit inside eval to stop sending output to the browser doesn't work under Plack
- [[23867]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23867) 18.12.00.051 fails with "Truncated incorrect DOUBLE value"

### Authentication

- [[22585]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22585) Fix remaining double-escaped CAS links
- [[23526]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23526) Shibboleth login url with query has double encoded '?' %3F
- [[23771]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23771) CAS/Shib Authentication can fail when multiple users with no userid/cardnumber defined and one of them is locked

### Cataloging

- [[23045]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23045) Advanced cataloging editor (rancor) throws a JS error on incomplete/blank lines
- [[23252]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23252) Pressing enter should not submit form in item editor
- [[23851]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23851) Auto generate accession number format <branchcode>yymm0001 fails to add branchcode prefix(branchcode) for multiple item addition

### Circulation

- [[13958]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13958) Add a suspensionsCalendar syspref

  **Sponsored by** *Universidad Nacional de Córdoba*

  >Before 18.05, suspension expiry date calculation didn't take the calendar into account. This behaviour changed with bug 19204, and some libraries miss the old behaviour. 
  >
  >These patches decouple overdue days calculation configuration (`finesCalendar`) from how the expiry date is calculated for the suspension through a new system preference: `SuspensionsCalendar`, that has the exact same options but only applies to suspensions. On upgrade, the new preference is populated with the value from `finesCalendar`, thus respecting the current configuration.

- [[20086]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20086) AddRenewal is not executed as a transaction and can results in partial success and doubled fines
- [[22877]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22877) Returning a lost item not marked as returned can generate additional overdue fines
- [[23018]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23018) Refunding a lost item fee may trigger error if any fee has been written off related to that item
- [[23079]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23079) Checkouts page broken because of problems with date calculation (TZAmerica/Sao_Paulo)
- [[23103]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23103) Cannot checkin items lost by deleted patrons with fines attached
- [[23120]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23120) Internal server error when checking in item to transfer and printing slip
- [[23145]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23145) Confirming transfer during checkin clears the table of previously checked-in items
- [[23293]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23293) OPACFineNoRenewals always compares against 'balance' not 'outstanding'

  >The patchset adds a new system preference, `OPACFineNoRenewalsIncludeCredits`, to control whether the `OPACFineNoRenewals` function uses the account balance or account amount outstanding for calculation.

- [[23382]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23382) Issuing rules failing after bug 20912
- [[23404]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23404) Circulation::TooMany error on itemtype when at biblio level
- [[23405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23405) Circulation autocomplete for patron lookup broken if cardnumber is empty
- [[23518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23518) Problem with borrower search  autocomplete
- [[23551]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23551) Problem with renewal period when using the renewal tab
- [[23774]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23774) When placing a hold editing using Inspect Element allows addition to the code of non listed library
- [[23938]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23938) Title missing from Checked out box
- [[23985]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23985) The method Koha::Item-> is not covered by tests!
- [[24013]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24013) Transferring a checked out item gives a software error
- [[24075]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24075) Backdating a return to the exact due date and time results in the fine not being refunded

### Command-line Utilities

- [[22566]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22566) Stock rotation cronjob reporting has issues
- [[23933]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23933) commit_file.pl Can't call method "get_effective_marcorgcode" on an undefined value at /usr/share/koha/lib/C4/AuthoritiesMarc.pm line 578.

### Course reserves

- [[22142]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22142) An item's current location changes to blank when it is removed from Course Reserves
- [[23083]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23083) Course reserve item edit fails if one does not set all values

### Database

- [[23265]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23265) Update to DB revision 16.12.00.032 fails: Unknown column 'me.item_level_hold'
- [[23579]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23579) error during web install: 'changed_fields' can't have a default value
- [[23809]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23809) Update to DB revision 16.12.00.032 fails

### Fines and fees

- [[19919]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19919) Writing off a Lost Item Fee marks as "Paid for by patron"
- [[23826]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23826) Manual Invoice does not use new accounttype and status for fines
- [[24100]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24100) "Pay selected" is broken

### Hold requests

- [[13640]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13640) Holds To Pull List includes items unreserveable items
- [[14549]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14549) Hold not removed when item is checked out to patron who is not next in priority list
- [[23116]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23116) Cannot place overridden holds
- [[23484]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23484) Holds to pull (pendingreserves.pl) uses removed default_branch_item_rules table
- [[23710]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23710) Holds broken on intranet, displays a JSON page with an error
- [[23964]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23964) An item level hold when placed is set to Waiting, if ReservesNeedReturn is set to Automatic

### I18N/L10N

- [[23713]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23713) Subscription add form broken for translations

### ILL

- [[23229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23229) "Get all requests" API call fired when loading any ILL page
- [[23529]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23529) Interlibrary loan javascript is broken

### Installation and upgrade (command-line installer)

- [[23090]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23090) MySQL validate_password plugin breaks koha-create
- [[23168]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23168) Database Updates broken due to conflicts in bug 21073 and bug 22053
- [[23250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23250) koha-create generates broken mysql password
- [[23813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23813) DB error on 18.12.00.020

### Installation and upgrade (web-based installer)

- [[23353]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23353) ACQ framework makes fr-CA web installer explode
- [[23396]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23396) Rancor fails to load: insert_copyright is not defined

### Label/patron card printing

- [[23289]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23289) Label Template - Creation not working (MariaDB >= 10.2.4)
- [[23455]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23455) Patron card printing from Patron lists is broken

### Lists

- [[17526]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17526) OPAC lists sortfield breaks with a `(`

### MARC Authority data support

- [[23053]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23053) Local-Number cannot be used for authority matching due to non-existence of 'phrase' index

### MARC Bibliographic record staging/import

- [[23846]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23846) Handle records with broken MARCXML on the bibliographic detail view

### Mana-kb

- [[22210]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22210) ManaKB should not require firstname and lastname for signup

  >This changes the Mana registration form to make it easier for organizations to register. It now only requires name and email address, rather than first name, last name and email address.

- [[22915]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22915) Cannot subscribe to Mana-KB

  >This fix updates the Mana server URL in etc/koha-conf.xml so that it uses the correct URL - https://mana-kb.koha-community.org.

### Notices

- [[23181]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23181) Unable to use payment library in ACCOUNT_PAYMENT or ACCOUNT_WRITEOFF notices
- [[23765]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23765) After TranslateNotices is set to 'Don't allow', email settings still show multiple languages
- [[24064]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24064) DUEDGST typoed as DUEGST
- [[24072]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24072) Typos in advance_notices.pl causes DUEDGST not to be sent

### OPAC

- [[23150]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23150) GDPR feature breaks patron self modification on OPAC
- [[23151]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23151) Patron self modification sends null dateofbirth
- [[23194]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23194) Public notes items in the OPAC should allow for HTML tags

  >Since 18.11, item.itemnotes content is escaped so any HTML tag would appear broken. It is now allowed again, hyperlinks for example.

- [[23225]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23225) OPAC ISBD view returns 404 when no item attached
- [[23253]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23253) OpacNavRight does not display correctly for opacuserlogin disabled or self registration
- [[23428]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23428) Self registration with a verification by email is broken
- [[23431]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23431) having Date of birth in PatronSelfModificationBorrowerUnwantedField causes DOB to be nullified
- [[23467]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23467) Duplicated screen if error in opac-reserve.pl
- [[23530]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23530) Opac-basket.pl script accidentally displays 'hidden' items
- [[23868]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23868) PayPal payment button is never enabled

### Patrons

- [[17140]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17140) Incorrect rounding in total fines calculations, part 2
- [[23082]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23082) Fatal error editing a restricted patron
- [[23822]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23822) Regression: As of 19.05.04 deletion of patrons with outstanding credits is silently blocked
- [[23905]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23905) Button "Search to add" doesn't work on Quick add new patron
- [[24113]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24113) guarantor info lost when a duplicate is found

### REST API

- [[23597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23597) Holds API is missing reserved parameters on the GET spec

### Reports

- [[23626]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23626) Add a system preference to limit the number of rows of data used when charting or exporting report results

  **Sponsored by** *Fenway Library Organization* and *Higher Education Libraries of Massachusetts*

- [[23730]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23730) Exporting reports is broken
- [[23982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23982) Count/pagination broken for reports with duplicated column names

### SIP2

- [[23057]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23057) If checked_in_ok is set and item is not checked out, alert flag is supressed for *any* reason

### Searching

- [[11677]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11677) Limit to Only items currently available for loan or reference not working
- [[23425]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23425) Search explodes with "invalid data, cannot decode object"

### Searching - Elasticsearch

- [[22997]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22997) Searching gives no results in auth_finder.pl
- [[23004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23004) Missing authtype filter in auth_finder.pl
- [[23089]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23089) Elasticsearch - cannot sort on non-text fields
- [[23322]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23322) Elasticsearch - Record matching fails when multiple keys exist
- [[23630]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23630) Elasticsearch indexing is removing field 999

  >In Koha::SearchEngine::Elasticsearch::Indexer::update_index() first arg record ids is now mandatory

- [[23719]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23719) Record matching for authorities using defined fields is broken under ES
- [[23986]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23986) Batch Record Deletion does not remove records from Elasticsearch search index

### Staff Client

- [[23315]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23315) Some system preferences are no longer editable

### System Administration

- [[23104]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23104) Regression (18925) in circ rules - unlimited vs 0
- [[23309]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23309) Can't add new subfields to bibliographic frameworks in strict mode
- [[23398]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23398) Exporting/Reimporting frameworks in XML format will give incomplete results
- [[23772]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23772) Itemtype icons not showing in table
- [[23804]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23804) Itemtype not checked when editing
- [[24026]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24026) Wrong parameters in Koha/Templates/Plugin/CirculationRules.pm and smart-rules.tt

### Test Suite

- [[21985]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21985) Test t/db_dependent/Circulation.t fails if SearchEngine is set to elasticsearch
- [[23234]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23234) Circulation.t failing when comparing dates that seem identical
- [[24022]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24022) Z3950Responder tests are failing randomly

### Tools

- [[11642]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11642) Improve Batch patron deletion and anonymization GUI to make consequences clearer
- [[15814]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15814) Templates for MARC modification: Edit action does not work when Description contains '
- [[17359]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17359) Patron import results use wrong encoding
- [[18707]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18707) Background jobs post disabled inputs
- [[18710]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18710) Wrong subfield modified in batch item modification
- [[23093]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23093) Error during upgrade of OpacNavRight preference to Koha news
- [[23963]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23963) Visible reduction in image quality

### Web services

- [[22249]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22249) Error when submitting Mana comment


## Other bugs fixed

(This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### About

- [[21662]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21662) Missing developers from history
- [[22862]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22862) It should be possible to paste formatted phone numbers into the SMS messaging number field

  >This bugfix improves the likelihood of pasted patron phone numbers passing validation as we will now attempt to normalise out illegal characters often used to human-friendly formatting.

- [[23037]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23037) Henry Bolshaw is missing from the contributors list

### Acquisitions

- [[5365]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5365) It should be more clear how to reopen a basket in a basket group
- [[20780]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20780) EDI: Add support for 'AcqItemSetSubfieldsWhenReceived'

  >EDIFACT receipting of items should now respect the `AcqItemSetSubfieldsWhenReceived` system preference

- [[21580]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21580) Order creation for EDIFACT vendor fails
- [[22294]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22294) EDI wrongly assumes all ISBN13's have corresponding ISBN10's
- [[22786]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22786) Can create new funds for locked budgets
- [[23101]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23101) Contracts permissions for staff patron
- [[23251]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23251) EDI Order line incorrectly terminated when it ends with a quoted apostrophe
- [[23294]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23294) Restore actual cost input field on order page
- [[23319]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23319) Reloading page when adding to basket from existing order can cause internal server error
- [[23320]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23320) Neworderempty has unused 'close' and 'budget_name' parameters
- [[23338]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23338) Cannot specify replacement price when ordering from file if not using fields to order
- [[23363]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23363) Clicking on shipping cost invoice link from spent.pl causes internal server error
- [[23523]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23523) Unitprice tax column values are not populated if entered upon ordering
- [[23721]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23721) Names of exported basketgroup files should be uniformised

### Architecture, internals, and plumbing

- [[16750]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16750) Redirect from selectbranchprinter.pl to additem.pl causes software error
- [[21801]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21801) paycollect.pl should pass library_id when adding accountlines
- [[23117]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23117) additem.pl crashes on nonexistent biblionumber
- [[23144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23144) Bad POD breaks svc/barcode
- [[23310]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23310) Noisy Koha::Biblio
- [[23413]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23413) Add a holds routine to Koha::Items to fetch related holds
- [[23539]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23539) accountlines.accounttype should match authorised_values.authorised_value in size
- [[23627]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23627) Koha::Biblio->get_coins too noisy if no 245$b
- [[23997]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23997) sample_z3950_servers.sql is failing on MySQL 8

### Authentication

- [[24065]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24065) Shibboleth should fail the login if matchpoint is not unique

### Cataloging

- [[7890]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7890) Required fields in the MARC editor should be highlighted

  >This bugfix modifies the basic MARC editor so that required fields have the standard "Required" label on them instead of a small red asterisk.

- [[21518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21518) Material type "three-dimensional artifact" displays as "visual material"
- [[21887]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21887) 856$u link problem in XSLT result lists and detail page
- [[22830]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22830) correct for loop in value_builder/unimarc_field_4XX.pl value_builder
- [[23436]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23436) Save to 'undefined' showing in Advanced cataloging editor

### Circulation

- [[13094]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13094) It should be easy to hide the 'Cancel all' button on the holds over report
- [[16284]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16284) With CheckPrevCheckout used, check only the item for previous checkout if biblio is serial

  >Prior to this patch the `CheckPrevCheckout` functionality errantly included serial type records.

- [[18344]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18344) Overdue fines 'cap at replacement price' and 'cap by amount' should work together
- [[21027]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21027) Totals in statistics tab change when StatisticsFields is changed
- [[22617]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22617) Checkout notes pending dashboard link - error received even though manage_checkout_notes permission set

  >This fixes an error that occurs when an account with full circulate permissions (but not super librarian permissions) clicks on 'Checkout notes pending' and is then automatically logged out with the message "Error: you do not have permission to view this page. Log in as a different user".

- [[22927]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22927) Item improperly marked returned when changing damaged or withdrawn status
- [[22982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22982) Paying lost fee does not always remove lost item from checkouts
- [[23007]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23007) Make dialogs in returns.pl optionally modal
- [[23039]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23039) Hold found modal on checkin screen ( circulation.pl ) obscures Check in message info
- [[23061]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23061) The column/print/export buttons are missing on the checkout history page
- [[23097]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23097) Circulation Overdues report patron link  goes to patron's holds tab
- [[23098]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23098) KOC upload process has misleading wording
- [[23129]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23129) Items holdingbranch should be set to the originating library when generating a transfer
- [[23140]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23140) Typo in returns.tt prevents printing branchcode in transfer slips
- [[23158]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23158) on-site checkout missing when using itemBarcodeFallbackSearch
- [[23192]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23192) Cancelling holds over returning to wrong tab on waitingreserves.pl
- [[23220]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23220) Cancelling transfer on returns.pl is subject to a race condition
- [[23255]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23255) HomeOrHoldingbranch system preference options are described wrong
- [[23273]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23273) Downloading from overdues.pl doesn't use set filters
- [[23408]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23408) Relatives' checkout table columns are not configured properly
- [[23427]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23427) Better sorting of previous checkouts
- [[23679]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23679) Software error when trying to transfer an unknown barcode
- [[23806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23806) FinePaymentAutoPopup does not trigger pop-up for writeoff by "Write off" button
- [[23841]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23841) Add link to bibliographic details page in item details breadcrumbs
- [[23862]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23862) Add enumchron to holds-table on checkout page
- [[24024]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24024) Holds Awaiting Pickup (Both Active and Expired) Sorts by Firstname

### Command-line Utilities

- [[21181]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21181) Cancel expired holds cronjob does not cancel holds in transit if ExpireReservesMaxPickUpDelay not set

  >This patch corrects a behaviour where an in transit hold would not be cancelled if even the patron specified they did not need the hold after a certain date. In some cases they would receive a notice to pickup a hold they no longer wanted.
  >
  >Now these holds will be cancelled while in transit, and should be routed to their home location when checked in with no notice to the patron.

- [[22128]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22128) koha-remove fails mysql ERROR 1133 (42000) at line 2: Can't find any matching row in the user table
- [[23193]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23193) Make set_password.pl use Koha::Script
- [[23345]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23345) Wrong parameter name in koha-dump usage statement

### Course reserves

- [[23952]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23952) Fix body id on OPAC course details page

### Database

- [[23022]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23022) Koha is not compatible with MySQL >= 8.0.11 because of NO_AUTO_CREATE_USER mode
- [[23932]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23932) Typo on 'aqinvoice_adjustments.encumber_open' description in Koha Schema
- [[23995]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23995) Check constraints are supported differently by MySQL and MariaDB so we should remove them for now.

### Developer documentation

- [[22358]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22358) Add POD to Koha::SharedContent

### Fines and fees

- [[11573]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11573) Fine descriptions related to Rentals are untranslatable
- [[23106]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23106) Totals are unclear when a credit is involved on the 'Pay fines' screen
- [[23115]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23115) Totals are unclear when a credit is involved on the OPAC 'Fines and charges' screen
- [[23483]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23483) When writing off a fine, the title of the patron is shown as description

### Hold requests

- [[9834]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9834) Reverting a waiting hold should lead to the former hold type (item or biblio level)
- [[22021]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22021) Item status not shown accurately on request.pl
- [[22633]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22633) Barcodes in the patrons 'holds' summary should link to the moredetail page
- [[22814]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22814) Holds modal patron name display inconsistency
- [[23048]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23048) Hide non-pickup branches from hold modification select
- [[23502]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23502) Staff client "revert status" buttons should not depend on SuspendHoldsIntranet preference

### I18N/L10N

- [[10492]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10492) Translation problems with TT directives in po files
- [[11514]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11514) "Uncertain" no longer display in acq
- [[13749]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13749) On loading holds in patron account 'processing' is not translatable
- [[22114]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22114) Untranslatable "Patron note:" in checkout.js
- [[22661]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22661) TinyMCE/WYSIWYG editor doesn't translate
- [[22783]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22783) 'Location' not picked up by translation toolchain
- [[23123]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23123) Status AVAILABLE and ORDERED for suggestions are not translated in the templates
- [[23452]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23452) Multiple select options in system preferences are not translatable
- [[24068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24068) Koha::Template::Plugin::I18N->tnpx should call Koha::I18->__npx

### ILL

- [[22099]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22099) "List requests" button displays when listing requests

  **Sponsored by** *Catalyst*

- [[22280]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22280) The ILL module assumes every status needs a next/previous status
- [[23712]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23712) Silence warns from Koha/Illrequest/Logger.pm

### Installation and upgrade (command-line installer)

- [[23949]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23949) koha-common.init missing actions for koha-z3950-responder

### Installation and upgrade (web-based installer)

- [[22770]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22770) Typo in German translation for Greek in language pull down
- [[22966]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22966) Add Norwegian library and patron names for the web-based installer

### Lists

- [[22941]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22941) Giving malformed sortfield to list results in Internal Server Error
- [[23266]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23266) Add to cart fires twice on shelf page

### MARC Authority data support

- [[22919]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22919) Authorities MARC Structure not inserted with SQL strict modes
- [[23437]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23437) When UseAuthoritiesForTracing is 'Use' we should use series authorities

### MARC Bibliographic data support

- [[20986]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20986) MARC21 Supplement and Index Textual Holdings don't display

### MARC Bibliographic record staging/import

- [[23324]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23324) Need an ISBN normalization routine

### Mana-kb

- [[23034]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23034) Warning when in Mana KB settings Auto subscription sharing is unchecked

  **Sponsored by** *The National Library of Finland*

- [[23075]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23075) Incorrect URL should have a meaningful error message

  >This enhancement displays a more meaningful error message if an incorrect Mana KB service URL is used in the koha-conf.xml configuration file (for example, if http is used instead of https), rather than the direct output from the failed json parse.

- [[23130]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23130) Incorrect alternative mana server URL in etc/koha-conf.xml

  >This fix updates the alternative Mana KB server URL in
  >etc/koha-conf.xml to https://mana-test.koha-community.org. If the updated URL is used the account creation request is successful and doesn't cause any error messages.

### Notices

- [[21343]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21343) Automatic renewal cronjob doesn't send notices according to patron language preference

  **Sponsored by** *Lund University Library*

- [[22744]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22744) Remove confusing 'Do not notify' checkboxes from messaging preferences
- [[23256]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23256) fr-CA OPAC_REG_VERIFY has hard-coded http://
- [[23762]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23762) Editing is_html status of email template fails under multi-languages

### OPAC

- [[12537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12537) Editions tab showing on bibs with more than one ISBN
- [[14862]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14862) Upgrade jQuery from 1.7 to 3.4.1 in OPAC
- [[16111]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16111) RSS feed for OPAC search results has wrong content type
- [[18084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18084) Language selector is hidden in user menu on mobile interfaces
- [[22602]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22602) OverDrive circulation integration is broken when user is referred to Koha from another site
- [[22804]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22804) OPAC Overdrive JavaScript contains untranslatable strings
- [[22945]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22945) Markup error in OPAC search results around lists display
- [[22946]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22946) Markup error in OPAC search results around selection links
- [[22948]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22948) Markup error in OPAC bibliographic detail template
- [[22949]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22949) Markup error in OPAC course reserves template
- [[22950]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22950) Markup error in OPAC recent comment template
- [[22951]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22951) Markup error in OPAC holds template
- [[22952]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22952) Markup error in OPAC suggestions template
- [[22953]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22953) Markup warning in OPAC user summary template
- [[22954]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22954) Minor markup error in OPAC messaging template
- [[22955]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22955) Markup error in OPAC lists template
- [[23076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23076) Include OpacUserJS on OPAC maintenance page

  >This fix allows the OPAC maintenance page to use JavaScript included in the OPACUserJS system preference.

- [[23078]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23078) Use Koha.Preference in OPAC global header include
- [[23099]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23099) OPAC Search result sorting "go" button flashes on page load
- [[23122]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23122) When searching callnumber in simple search, search option is not retained
- [[23126]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23126) Multiline entries in subscription history display with <br/> in OPAC
- [[23210]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23210) login4tags should be a link
- [[23248]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23248) opac-ISBDdetail.pl dies on invalid biblionumber
- [[23308]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23308) Contents of "OpacMaintenanceNotice" HTML escaped on display
- [[23492]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23492) OPAC search facet header should not be a link at larger browser widths
- [[23506]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23506) Sound material type displays wrong icon in OPAC/Staff details
- [[23528]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23528) Show 'log in to add tags' link on all search result entries
- [[23537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23537) Overdrive won't show complete results if the Overdrive object doesn't have a primaryCreator
- [[23625]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23625) ArticleRequestsMandatoryFields* only affects field labels, does not make inputs required

  **Sponsored by** *California College of the Arts*

- [[23648]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23648) The logged in link (class "loggedinusername") needs data-patroncategory
- [[23683]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23683) Course reserves public notes on specific items should allow for HTML
- [[23726]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23726) Give class to No Items Available text on OPAC results page
- [[23901]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23901) Fix js error sms_input is null in opac-messaging.tt

  **Sponsored by** *Koha-Suomi Oy*

- [[23968]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23968) OPACMySummaryNote does not work
- [[24084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24084) PlainMARC view broken on OPAC if other $.ajax calls produce errors

### Packaging

- [[17084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17084) Automatic debian/control updates (master)
- [[21000]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21000) debian/build-git-snapshot script ignores -D
- [[23700]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23700) Fix output of koha-plack --restart

### Patrons

- [[21390]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21390) Self registration verification emails should send immediately

  **Sponsored by** *Goethe-Institut*

- [[21939]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21939) Permission for holds history tab is too strict
- [[22741]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22741) Koha::Patron->store must not log updated_on changes (random failure of test BorrowersLog and TrackLastPatronActivity)
- [[22910]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22910) Unique attributes should not be copied when duplicating a patron
- [[22944]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22944) avoid AnonymousPatron in search_patrons_to_anonymise
- [[23077]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23077) Can't import patrons without cardnumber
- [[23109]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23109) Incomplete description for staffacccess permission
- [[23199]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23199) Koha::Patron->store and uppercasesurname syspref
- [[23217]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23217) Batch patron modification shows database errors when no Attribute provided
- [[23218]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23218) Batch patron modification empty attribute causes improper handling of values
- [[23589]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23589) Discharge notice does not show non-latin characters
- [[23688]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23688) System preference uppercasesurnames broken by typo
- [[23788]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23788) Writing off multiple fees allows 'overpayment' of those fees

### Plugin architecture

- [[23222]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23222) Fix DISABLE/ENABLE plugin label in plugins home

### REST API

- [[23607]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23607) Make /patrons/:patron_id/account privileged user only
- [[23858]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23858) Vendors endpoint not setting the Location header
- [[23859]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23859) Cities endpoint not setting the Location header
- [[23860]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23860) Patrons endpoint not setting the Location header

### Reports

- [[23624]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23624) Count rows in report without (potentially) consuming all memory

  **Sponsored by** *Fenway Libraries Online*, *Fenway Library Organization* and *Higher Education Libraries of Massachusetts*

- [[23812]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23812) Download icon is an upload icon

### SIP2

- [[19457]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19457) If CheckPrevCheckout is set to "Do", then checkouts are blocked at the SIPServer
- [[22037]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22037) Regression: guarantor no longer blocked (debarred) if child is over limit, when checking out via SIP
- [[23722]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23722) Document allow_empty_passwords in the example SIP config file

### Searching

- [[14419]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14419) Expanding facets (Show more) performs a new search
- [[14794]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14794) Searching patron by birthday returns no results if format incorrect
- [[15704]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15704) The 264 index should be split by subfield to match how 260 is indexed
- [[23132]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23132) Encoding issues in facets with show more link
- [[23663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23663) Itemtype summary feature in search results is only used in deprecated opac results non-xslt view
- [[23768]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23768) ISBN search in IntranetCatalogPulldown searches nothing if passed an invalid ISBN and using SearchWithISBNVariations
- [[24120]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24120) Search terms in search dropdown must be URI filtered

### Searching - Elasticsearch

- [[21534]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21534) ElasticSearch - Wildcards not being analyzed
- [[22258]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22258) Elasticsearch - full record is not indexed in plain text
- [[22524]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22524) Elasticsearch - Date range in advanced search
- [[22874]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22874) Limit to available items doesn't work with elasticsearch 6.x
- [[23670]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23670) Load Koha::Exceptions::ElasticSearch module in Koha::SearchEngine::Elasticsearch
- [[23671]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23671) Elasticsearch shouldn't throw exception on an uppercase subfield identifier

### Self checkout

- [[22929]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22929) Enabling the GDPR_Policy will affect libraries using the SCO module in Koha

### Serials

- [[8260]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8260) Deleting patrons leaves holes in routing list ranking
- [[10215]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10215) Increase the size of opacnote and librariannote for table subscriptionhistory
- [[11492]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11492) Receiving a serial item causes routing list notes to be lost

  **Sponsored by** *Plant and Food Research Limited*
- [[22667]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22667) Framework cannot override syspref for cn_source when receiving serials
- [[23065]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23065) 'New subscription' button in serials sometimes uses a blank form and sometimes defaults to current serial
- [[23416]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23416) When a note to a specific issue upon receiving a serial, this note will appear in next issue received

### Staff Client

- [[14741]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14741) Selecting all child permissions doesn't select the top level check box
- [[21716]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21716) Item Search hangs when \ exists in MARC fields
- [[22958]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22958) The Help link on SMS providers page should link to the correct chapter in the manual
- [[23525]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23525) ISBD view uses view policy of ACQ framework
- [[23651]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23651) RestrictedPage system preferences should include the address of the page in the description
- [[23680]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23680) Can't open 'Edit items' or 'Add item' links in new tab - tab is closed immediately

  **Sponsored by** *Gothenburg University Library*

  >This fixes a problem where the pop-up window or tab immediately closes when attempting to edit or add a bibliographic item.

- [[23689]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23689) Terminology: Branches limitations should be libraries limitations - Authorised Values
- [[23704]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23704) Typo in itemtypes.tt
- [[23729]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23729) Move CSS from moremember.tt template to staff global CSS

### System Administration

- [[8558]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=8558) Better confirmation message for importing frameworks

  **Sponsored by** *Catalyst*

- [[22867]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22867) UniqueItemFields preference value should be pipe-delimited
- [[22947]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22947) Markup error in OPAC preferences file
- [[23153]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23153) In framework management action subfields goes directly to edition
- [[23445]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23445) Loan period unit in circulation rules is untranslatable causing problems when editing rules
- [[23612]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23612) If no columns in a table can be toggled, don't show columns button
- [[23751]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23751) Description of staffaccess permission should be improved
- [[23847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23847) Custom item search fields don't work if subfield is 0 (e.g. Withdrawn)
- [[23853]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23853) Typo in authorised_values.tt

### Templates

- [[13597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13597) Amazon 'no image' element needs a 'no-image' class, in the staff client
- [[22768]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22768) Global search forms' keyboard navigation broken
- [[22851]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22851) Navigation links in the serials module should be styled the same as other modules
- [[22906]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22906) Minor corrections to plugins home page
- [[22957]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22957) Remove type attribute from script tags: Staff client includes 1/2
- [[22960]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22960) Typo found in circulation.pref in UpdateItemLocationOnCheckin preference
- [[23074]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23074) Holds table sort does not understand dateformat
- [[23226]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23226) Remove type attribute from script tags: Cataloging
- [[23227]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23227) Remove type attribute from script tags: Reports
- [[23434]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23434) Hold confirmation dialog problem if HoldsAutoFill is enabled
- [[23441]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23441) Export should not include the 'actions' column in Z3950 results
- [[23446]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23446) Fix display issue with serials navigation
- [[23447]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23447) Fix capitalization and other minor edits on patron batch edit template
- [[23575]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23575) Template error causes item search to be submitted multiple times
- [[23605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23605) Terminology: Branches limitations should be libraries limitations
- [[23778]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23778) Regression: Guarantor entry section no longer has a unique id
- [[23946]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23946) Remove Noun Project icons from the About page
- [[23954]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23954) Format notes in suggestion management
- [[24058]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24058) Acquisition table displayed even if no order exist (bib detail)
- [[24093]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24093) Sorting indicators broken on list contents view

### Test Suite

- [[23027]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23027) Suggestions.t is failing if no biblio in DB
- [[23038]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23038) Expected warnings displayed by tests should be hidden
- [[23177]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23177) Rollback cleanup in Circulation.t
- [[23211]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23211) SIP/Transaction.t is failing randomly
- [[23821]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23821) Reintroduction of create_helper_biblio
- [[23825]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23825) Object.t is failing - Exception not caught
- [[24002]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24002) Test suite is failing on MySQL 8
- [[24029]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24029) marcrecord2csv.t displays a SQL error "Truncated incorrect DOUBLE value: '01e'"
- [[24030]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24030) GetItemsForInventory failing with "ORDER BY clause is not in SELECT list"
- [[24062]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24062) Circulation tests fail randomly if patron category type is 'X'

### Tools

- [[18757]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18757) Problem when importing only items in MARC records
- [[19012]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19012) Note additional columns that are required during patron import
- [[22571]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22571) MARC modification templates do not handle control fields in conditional
- [[22653]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22653) Preference RotationPreventTransfers is never used
- [[22799]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22799) Batch item modification is case sensitive

  **Sponsored by** *South Taranaki District Council*

- [[23006]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23006) Can't use inventory tool with barcodes that contain regex reserved characters ($,...)
- [[23184]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23184) Export/bibs/holdings settings unclear for exporting bibs without any holdings

### Web services

- [[17247]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17247) ILS-DI HoldTitle and HoldItem should check if patron is restricted
- [[23429]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23429) ilsdi.pl GetRecords documentation does not match output

### Z39.50 / SRU / OpenSearch Servers

- [[23242]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23242) Error when adding new Z39.50/SRU server in DB strict mode
## New sysprefs

- AllowPatronToSetFinesVisibilityForGuarantor
- AllowStaffToSetFinesVisibilityForGuarantor
- BarcodeSeparators
- ClaimReturnedChargeFee
- ClaimReturnedLostValue
- ClaimReturnedWarningThreshold
- CustomCoverImages
- CustomCoverImagesURL
- ElasticsearchMARCFormat
- FinePaymentAutoPopup
- IntranetCoce
- OPACCustomCoverImages
- OPACFineNoRenewalsIncludeCredits
- OPACPlayMusicalInscripts
- OPACShowMusicalInscripts
- OnSiteCheckoutAutoCheck
- OpacCoce
- PatronAutoComplete
- PayPalReturnURL
- PreserveSerialNotes
- QueryRegexEscapeOptions
- RoundFinesAtPayment
- SuspensionsCalendar
- TransfersBlockCirc
- UseCashRegisters

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/19.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (95.1%)
- Armenian (95.1%)
- Basque (57.2%)
- Chinese (China) (57.7%)
- Chinese (Taiwan) (100%)
- Czech (92.3%)
- Danish (50.3%)
- English (New Zealand) (80.3%)
- English (USA)
- Finnish (76.2%)
- French (94.9%)
- French (Canada) (95.6%)
- German (100%)
- German (Switzerland) (82.9%)
- Greek (70.7%)
- Hindi (100%)
- Italian (87.1%)
- Norwegian Bokmål (85.5%)
- Occitan (post 1500) (54.5%)
- Polish (79.7%)
- Portuguese (99.3%)
- Portuguese (Brazil) (90.4%)
- Slovak (81.2%)
- Spanish (98.1%)
- Swedish (84.8%)
- Turkish (93.8%)
- Ukrainian (69.7%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.11.00 is


- Release Manager: Martin Renvoize

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Nick Clemens

- QA Manager: Katrin Fischer

- QA Team:
  - Tomás Cohen Arazi
  - Alex Arnaud
  - Nick Clemens
  - Jonathan Druart
  - Kyle Hall
  - Julian Maurice
  - Josef Moravec
  - Marcel de Rooy

- Topic Experts:
  - REST API -- Tomás Cohen Arazi
  - SIP2 -- Kyle Hall
  - UI Design -- Owen Leonard
  - Elasticsearch -- Alex Arnaud
  - ILS-DI -- Arthur Suzuki
  - Authentication -- Martin Renvoize

- Bug Wranglers:
  - Michal Denár
  - Indranil Das Gupta
  - Jon Knight
  - Lisette Scheer
  - Arthur Suzuki

- Packaging Manager: Mirko Tietgen

- Documentation Manager: David Nind

- Documentation Team:
  - Andy Boze
  - Caroline Cyr La Rose
  - Lucy Vaux-Harvey

- Translation Managers: 
  - Indranil Das Gupta
  - Bernardo González Kriegel

- Release Maintainers:
  - 19.05 -- Fridolin Somers
  - 18.11 -- Lucas Gass
  - 18.05 -- Liz Rea

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 19.11.00:

- [BULAC](http://www.bulac.fr/)
- Biblioteca Provincial Fr. Mamerto Esquiú (Provincia Franciscana de la Asunción)
- Brimbank City Council
- [ByWater Solutions](https://bywatersolutions.com/)
- California College of the Arts
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Central Kansas Library System
- Cheshire East Council
- Cheshire Libraries Shared Services
- Cheshire West and Chester Council
- [Duchesne County Library](http://uintahlibrary.org/)
- Fargo Public Library
- Fenway Libraries Online
- Fenway Library Organization
- Goethe-Institut
- Gothenburg University Library
- Higher Education Libraries of Massachusetts
- Koha-Suomi Oy
- Lund University Library
- National Library of Finland
- Newcastle City Council
- North Central Regional Library System
- [Northeast Kansas Library System](http://www.nekls.org)
- Orex Digital
- [PTFS Europe](https://ptfs-europe.com)
- Plant and Food Research Limited
- [Round Rock Public Library](https://www.roundrocktexas.gov/departments/library/)
- Sefton Council
- [South East Kansas Library System](http://www.sekls.org)
- South Taranaki District Council
- The National Library of Finland
- [Theke Solutions](https://theke.io/)
- [Uintah Library System](http://uintahlibrary.org/)
- Universidad Nacional de Córdoba
- [Vermont Organization of Koha Automated Libraries](http://gmlc.org/index.php/vokal)
- [Virginia Tech](https://lib.vt.edu/)

We thank the following individuals who contributed patches to Koha 19.11.00.

- Aleisha Amohia (5)
- Tomás Cohen Arazi (131)
- Alex Arnaud (9)
- Philippe Blouin (1)
- David Bourgault (2)
- Alex Buckley (2)
- Rudolf Byker (1)
- Colin Campbell (6)
- Nick Clemens (139)
- David Cook (1)
- Chris Cormack (2)
- Christophe Croullebois (1)
- Frédéric Demians (1)
- Jonathan Druart (170)
- Magnus Enger (8)
- Charles Farmer (2)
- Katrin Fischer (49)
- Martha Fuerst (1)
- Lucas Gass (13)
- Claire Gravely (1)
- David Gustafsson (7)
- Kyle Hall (70)
- Paul Hoffman (1)
- Andrew Isherwood (13)
- Mason James (1)
- Pasi Kallinen (4)
- Olli-Antti Kivilahti (3)
- Jon Knight (1)
- Bernardo González Kriegel (2)
- Petter von Krogh (1)
- David Kuhn (1)
- Joonas Kylmälä (2)
- Nicolas Legrand (3)
- Owen Leonard (125)
- Ere Maijala (28)
- Hayley Mapley (2)
- Julian Maurice (67)
- Matthias Meusburger (2)
- Josef Moravec (20)
- Agustín Moyano (29)
- Joy Nelson (1)
- David Nind (1)
- Björn Nylen (1)
- Dobrica Pavlinušić (2)
- Eric Phetteplace (1)
- Séverine Queune (1)
- Liz Rea (9)
- Martin Renvoize (349)
- Justin Rittenhouse (1)
- Marcel de Rooy (29)
- Caroline Cyr La Rose (4)
- Alex Sassmannshausen (1)
- Lisette Scheer (2)
- Maryse Simard (1)
- Fridolin Somers (31)
- Arthur Suzuki (2)
- Emmi Takkinen (3)
- Lari Taskula (5)
- Mirko Tietgen (2)
- Mark Tompsett (19)
- Koha translators (1)
- Jesse Weaver (1)
- Bin Wen (1)
- Nazlı Çetin (2)
- Radek Šiman (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.11.00

- abunchofthings.net (2)
- ACPL (125)
- BibLibre (111)
- BSZ BW (50)
- Bulac (4)
- ByWater-Solutions (223)
- Catalyst (6)
- davidnind.com (1)
- Devinim (2)
- flo.org (1)
- Göteborgs Universitet (7)
- hmcpl.org (1)
- hypernova.fi (3)
- Independant Individuals (65)
- jns.fi (2)
- Koha Community Developers (170)
- koha-suomi.fi (3)
- KohaAloha (1)
- Libriotech (9)
- Loughborough University (1)
- nd.edu (1)
- Prosentient Systems (1)
- PTFS-Europe (369)
- rbit.cz (1)
- Rijks Museum (29)
- rot13.org (2)
- Solutions inLibro inc (9)
- student.uef.fi (2)
- Tamil (1)
- The City of Joensuu (1)
- Theke Solutions (160)
- ub.lu.se (1)
- Universidad Nacional de Córdoba (2)
- University of Helsinki (31)

We also especially thank the following individuals who tested patches
for Koha.

- Hugo Agud (20)
- Hasina Akhte (1)
- Axel Amghar (1)
- Tomás Cohen Arazi (227)
- Alex Arnaud (65)
- Cori Lynn Arnold (2)
- Donna Bachowski (1)
- Bob Bennhoff (1)
- Stefan Berndtsson (12)
- Sonia Bouis (56)
- Arthur Bousquet (10)
- Christopher Brannon (3)
- Alex Buckley (5)
- Frederik Chenier (4)
- Frédérik Chénier (11)
- Nick Clemens (198)
- David Cook (1)
- Holly Cooper (1)
- Chris Cormack (13)
- Sarah Cornell (1)
- Christophe Croullebois (1)
- Christopher Davis (1)
- Frédéric Demians (1)
- Michal Denar (62)
- Jason DeShaw (1)
- Jonathan Druart (91)
- Magnus Enger (2)
- Bouzid Fergani (14)
- Katrin Fischer (287)
- Martha Fuerst (5)
- Andrew Fuerste-Henry (16)
- Brendan Gallagher (11)
- Lucas Gass (13)
- Claire Gravely (17)
- Victor Grousset (1)
- Kyle Hall (184)
- Ron Houk (3)
- Andrew Isherwood (2)
- Pasi Kallinen (4)
- Jan Kolator (2)
- David Kuhn (1)
- Rhonda Kuiper (2)
- Joonas Kylmälä (13)
- Nicolas Legrand (2)
- Owen Leonard (75)
- Luis F. Lopez (2)
- Nabila Love (1)
- Ere Maijala (4)
- Hayley Mapley (30)
- Felicia Martin (1)
- Jesse Maseto (9)
- Julian Maurice (8)
- Kelly McElligott (3)
- Sean McGarvey (4)
- Matthias Meusburger (1)
- Laurel Moran (1)
- Josef Moravec (83)
- Agustín Moyano (39)
- David Nind (13)
- Kim Peine (1)
- Nadine Pierre (21)
- Séverine Queune (49)
- Elizabeth Quinn (1)
- Johanna Raisa (6)
- Liz Rea (107)
- Martin Renvoize (1484)
- David Roberts (1)
- Marcel de Rooy (200)
- Caroline Cyr La Rose (1)
- Alex Sassmannshausen (3)
- Lisette Scheer (18)
- Maksim Sen (1)
- Joe Sikowitz (1)
- Maryse Simard (73)
- Fridolin Somers (3)
- Mike Somers (1)
- Christian Stelzenmüller (1)
- Myka Kennedy Stephens (2)
- Arthur Suzuki (8)
- Theodoros Theodoropoulos (2)
- Mark Tompsett (57)
- Claudie Trégouët (2)
- Ed Veal (2)
- Marc Véron (2)
- Ian Walls (1)
- Bin Wen (10)
- George Williams (12)
- Jessica Zairo (3)
- Amandine Zocca (1)
- Nazlı Çetin (2)


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 19.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 27 Nov 2019 15:10:11.
