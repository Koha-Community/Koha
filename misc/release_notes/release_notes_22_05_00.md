# RELEASE NOTES FOR KOHA 22.05.00
26 May 2022

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.05.00 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.05-latest.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.05.00 is a major release, that comes with many new features.

It includes 6 new features, 239 enhancements, 360 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations



## New features

### Authentication

- [[28786]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28786) Two-factor authentication for staff client - TOTP

  **Sponsored by** *Orex Digital*

  >This new feature adds an initial optional implementation of two-factor authentication (2FA) to improve security when logging into the staff interface.
  >
  >This implementation uses time-based, one-time passwords (TOTP) as the second factor, letting librarians use an application to handle it and provide them the code they need when logging in.
  >
  >It is enabled using the new system preference "TwoFactorAuthentication". 
  >
  >Librarians can then enable 2FA for their account from More > Manage Two-Factor authentication. To setup: 1) Scan the QR code with an authenticator app. 2) Enter the one time code generated. For future logins, librarians are prompted to enter the authenticator code after entering their normal login credentials.
  >
  >Any authenticator app, such as Google Authenticator, andOTP, and many others can be used. Applications that enable backup of their 2FA accounts (either cloud-based or automatic) are recommended.
- [[29924]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29924) Introduce password expiration to patron categories

### Circulation

- [[19532]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19532) Recalls for Koha

  >This new feature introduces the ability for patrons to place a recall on an item from the OPAC detail. Patrons can see details of their requested recalls in the OPAC and can cancel the recall before it is returned. 
  >
  >Librarians can view and administer the recalls in the Circulation interface of the staff interface which displays a list of recalls, overdue recalls, recalls awaiting pickup, recalls to pull, and old recalls.
  >
  >The amount of time the recalled item has to be returned and the amount of time it will wait for pickup can be set in circulation and fine rules in the unit of days. 
  >
  >After an item is recalled it cannot be renewed. When the item is returned the recall can be confirmed or cancelled. 
  >
  >Recalls are marked as overdue by the overdue_recalls.pl cronjob or expired by the expired_recalls.pl cronjob.
  >See https://wiki.koha-community.org/wiki/Catalyst_IT_Recalls

### Patrons

- [[6815]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6815) Capture member photo via webcam

  >Adds the option to take a photo of the patron via a webcam for patron photos.

### System Administration

- [[13952]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13952) Import and export of authority types

  **Sponsored by** *Catalyst*

  >This feature allows the import and export of authority types to match the capabilities of biblio frameworks.

### Templates

- [[30136]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30136) Add back to top button when scrolling

## Enhancements

### About

- [[30544]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30544) Add font awesome version to licenses page

### Acquisitions

- [[16258]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16258) Add a preference to turn EDIFACT off
- [[26296]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26296) Use new table column selection modal for OPAC suggestion fields

  >This changes the selection of values for OPACSuggestionUnwantedFields and OPACSuggestionMandatoryFields from drop down lists to a modal.
- [[27212]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27212) Add column configuration to the acquisitions home page
- [[28082]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28082) Add acquisitions toolbar to vendors on vendor search page

  >This patch updates the vendor search results page in acquisitions so that a button toolbar is shown for each vendor in search results. This gives quick access to operations for each vendor, like editing the vendor, adding a basket, or receiving a shipment.
  >
  >Now the number of open baskets and subscriptions is shown for each vendor in the search result, linking to the details of those entries.
  >
  >Inactive vendors are now styled differently than active vendors in order to improve clarity.
- [[30130]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30130) Allow setting EDI type at the vendor level

  >There are two predominant competing EDI standards, EDItEUR and BiC, with subtle differences in how they interpret some EDI message fields.
  >
  >This patch allows administrators to pick which standard the Vendor is conforming to rather than using a hardcoded and un-maintained SAN mapping in the module.
- [[30135]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30135) We should allow configuration of whether EDI LSQ segments map to 'location' or 'collection'

  >EDItEUR describes the LSQ segment as "A code or other designation which identifies stock which is to be shelved in a specified sequence or collection."
  >
  >In Koha, this could be interpreted as either 'location' or 'ccode'; This bug makes that configurable for each EDI vendor, defaulting to location as that was the previously hard coded configuration.
- [[30438]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30438) Add select all/clear buttons to invoices.tt open and closed tables
- [[30510]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30510) Add a Patron reason column to the suggestion table in the staff interface

  >This adds the patron reason for a suggestion to the suggestions summary table in the staff interface.

### Architecture, internals, and plumbing

- [[26019]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26019) Koha should set SameSite attribute on cookies
- [[26704]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26704) Koha::Item store triggers should utilise Koha::Object::Messages for message passing
- [[27266]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27266) Move C4::Biblio::GetMarcAuthors to Koha namespace

  **Sponsored by** *Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)*

  >This enhancment moves C4::Biblio::GetMarcAuthors to Koha::Biblio->get_marc_authors. This is so the method can be used in templates and notices.
- [[27344]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27344) Implement Elastic's update_index_background using Koha::BackgroundJob
- [[27783]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27783) Introduce background job queues
- [[28416]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28416) Email::Sender::Transport::SMTP is using 10Mo of RAM
- [[28617]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28617) misc/kohalib.pl no longer useful

  >This enhancement removes the script misc/kohalib.pl.
  >
  >The purpose of this script was to load the relevant Koha lib for the different scripts (installation, cronjob, CLI, etc.). However, it is not used consistently and we prefer to rely on PERL5LIB.
  >
  >If upgrading ancient Koha systems from tarballs double-check that PERL5LIB is set in crontab.
- [[28998]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28998) Encrypt borrowers.secret

  >Sponsored-by: Orex Digital
- [[29155]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29155) Upgrade jquery version to 3.6.0
- [[29397]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29397) Add a select2 wrapper for the API
- [[29403]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29403) dt_from_string should fail if passed more data than expected for the format
- [[29420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29420) HTTP status code incorrect when calling error pages directly under Plack/PSGI
- [[29486]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29486) _koha_marc_update_bib_ids no longer needed for GetMarcBiblio
- [[29516]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29516) Remove dependency on IO::Scalar
- [[29562]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29562) Pass objects to CanItemBeReserved and checkHighHolds
- [[29609]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29609) Links to guess the biblio default view need to be centralized
- [[29629]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29629) Remove two unused intranet MODS XSLT sheets
- [[29660]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29660) reserve/request.pl should not deal with biblioitem
- [[29695]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29695) Centralize columns' descriptions
- [[29703]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29703) Simplify GetBranchItemRule using get_effective_rules
- [[29718]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29718) DateTime - our 'iso' is not ISO 8601
- [[29741]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29741) Add Koha::Patron->safe_to_delete

  >This enhancement adds a handy method for checking if a patron meets the conditions to be deleted. These conditions are:
  >
  >- Has no linked guarantees
  >- Has no pending debts
  >- Has no current checkouts
  >- Is not the system-configured anonymous user
  >
  >It also adapts the DELETE /patrons route to use the newly introduced Koha::Patron->safe_to_delete method.
- [[29746]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29746) Add a handy Koha::Result::Boolean class

  >This development introduces a new library, Koha::Result::Boolean, that will be used in method that need to return a boolean, but could also want to carry some more information such as the reason for a 'false' return value.
  >
  >A Koha::Result::Boolean object will be evaluated as a boolean in bool context, while retaining its object nature and methods.
- [[29757]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29757) Add filter_by_non_reversible/reversible methods for offsets
- [[29765]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29765) Make Koha::Patron->safe_to_delete return a Koha::Result::Boolean object
- [[29780]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29780) Add Koha::Old::Holds->anonymize
- [[29788]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29788) Make Koha::Item->safe_to_delete return a Koha::Result::Boolean object
- [[29791]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29791) KohaOpacLanguage cookie should set the secure flag if using HTTPS
- [[29843]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29843) Add ->anonymize and ->filter_by_anonymizable to Koha::Old::Checkouts
- [[29844]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29844) Remove uses of wantarray in Koha::Objects
- [[29847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29847) Koha::Patron::HouseboundProfile->housebound_visits should return a resultset
- [[29859]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29859) Favor iterators over as_list
- [[29868]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29868) Add Koha::Old::Hold->anonymize
- [[29869]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29869) Add Koha::Hold->fill
- [[29886]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29886) Add Koha::Suggestions->search_limited
- [[29894]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29894) 2FA: Add few validations, clear secret, send register notice
- [[30007]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30007) Make ->anonymize methods throw an exception if AnonymousPatron is not set
- [[30023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30023) Add Koha::Old::Checkout->anonymize
- [[30058]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30058) Add a Koha::Patrons method to filter by permissions
- [[30059]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30059) Add a JS equivalent to Koha::Patron->get_age
- [[30060]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30060) Missing primary key on user_permissions
- [[30061]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30061) Simplify Koha::Patron->get_age
- [[30076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30076) Add ability to check patron messaging preferences from a notice

  >This enhancement gives notices access to a patron's messaging preferences. For example, a hold slip could contain a line if the patron has requested SMS notifications for waiting holds, or perhaps phone notifications. The format for this new method is as follows: [% patron.has_messaging_preference({ message_name => 'Item_Checkout', message_transport_type => 'email' }) %]
- [[30181]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30181) Koha::BackgroundJob->_derived_class returns an empty object
- [[30360]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30360) Add helper methods to Koha::BackgroundJobs
- [[30394]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30394) Add 'draw' handling to the datatables wrapper and REST API
- [[30459]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30459) BatchDeleteAuthority task does not deal with indexation correctly
- [[30460]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30460) BatchDeleteBiblio task does not deal with indexation correctly
- [[30464]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30464) BatchUpdateAuthority task does not deal with indexation correctly
- [[30465]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30465) BatchUpdateBiblio task does not deal with indexation correctly
- [[30728]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30728) Allow real-time holds queue opt-out

### Authentication

- [[29873]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29873) 2FA: Generate QR code without exposing secret via HTTP GET

  >Instead of calling the (deprecated) Google Charts API and exposing our secret, we create the image ourself and push it as a data uri in the src attribute of the image (inline image).
- [[29925]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29925) Add a 'set new password' page for patron's with expired passwords
- [[29926]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29926) Add ability for superlibrarians to edit password expiration dates

### Cataloging

- [[26587]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26587) Cache libraries in Branches TT plugin to improve performance

  **Sponsored by** *Lund University Library*
- [[29391]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29391) Improve output of reservoir search

  >This patch makes the cataloging reservoir search results a configurable DataTable. This adds column configuration, export, and sorting. The empty edition and date columns are removed, and an import data column is added.
- [[29781]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29781) Allow item batch modification to use capturing groups in regex option

  >This enhancement adds support for capture groups in the regular expression option of batch item modification.
  >
  >One may now use `(\d+)` for example to capture digits in the match and then the `$1` placeholder in the replace.
- [[30604]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30604) Add value builders for UNIMARC 146 ($a, $h and $i)

  >This enhancement for UNIMARC field 146 adds value builders for subfields $a, $h, and $i. These are based on the official UNIMARC codes.

### Circulation

- [[18392]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18392) Allow exporting circulation conditions as CSV or spreadsheet
- [[27946]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27946) Add a charge per article request to patron categories
- [[29519]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29519) Add option to resolve a return claim at checkin

  >This enhancement adds the option to resolve a return claim upon the next check-in of the item.
- [[30226]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30226) Add system preference to disable auto-renew checkbox at checkout

### Command-line Utilities

- [[28962]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28962) Unverified self registrations should be removed shortly

  >This fixes the cleanup_database script so that the option to delete unverified self registrations (del-unv-selfreg) works. It also adds this option to the standard crontab, defaulting to 14 days (the default notice says unverified registrations will expire "shortly").
  >
  >Note: If you don't use self registration with a verification email, this does not affect you. If you do use self registration, check the system preferences and settings - particularly PatronSelfRegistrationDefaultCategory.
- [[30511]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30511) Don't lock entire database when dumping Koha instance

  **Sponsored by** *Catalyst*

### Fines and fees

- [[28138]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28138) Add system preference to make the payment type required
- [[29759]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29759) Refund credit when cancelling an article request

### Hold requests

- [[27868]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27868) Adding the Expiration Date to the Holds Awaiting Pickup report

  >This enhancement makes each hold's expiration date visible on the Holds Awaiting Pickup page. Since this is the date Koha uses to decide when a waiting hold should expire and be cancelled, making it visible decreases confusion.
- [[28377]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28377) Use the API to suspend/resume holds

  >This enhancement changes the patron page (detail and circulation) so that is uses the API to suspend and resume holds on the holds tab.
  >
  >It also removes the svc/hold/{resume|suspend} files as they are no longer used.
- [[28782]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28782) Get rid of custom query param list creation for request.pl
- [[29058]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29058) Add option to not load existing holds table automatically
- [[29346]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29346) Real-time holds queue update

  **Sponsored by** *Montgomery County Public Libraries*

  >Enabled by default, this feature can be opted out using the *RealTimeHoldsQueue* system preference.
- [[29517]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29517) CanItemBeReserved fetches biblio for agerestriction check if feature not enabled
- [[29760]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29760) Show patron category in Holds queue

  >Adds the patron category as a new column to Circulation > Holds queue.
- [[30108]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30108) Allow making hold dates required

### I18N/L10N

- [[22038]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22038) When exporting account table to excel, decimal is lost
- [[26244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26244) Move translatable strings out of memberentrygen.tt and into JavaScript
- [[26257]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26257) Move translatable strings out of subscription-add.tt and into subscription-add.js

  >This enhancement moves the definition of translatable strings for serial subscriptions (subscription-add.tt) out of templates and into the corresponding JavaScript file, using the new JS i81n function.
- [[29596]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29596) Add Yiddish language

  **Sponsored by** *Universidad Nacional de San Martín*

  >This enhancement adds the Yiddish (יידיש) language to Koha. Yiddish now appears as an option for refining search results in the staff interface advanced search (Search > Advanced search > More options > Language and Language of original) and the OPAC (Advanced search > More options > Language).
- [[30373]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30373) Rewrite UNIMARC installer data to YAML
- [[30476]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30476) Remove NORMARC translation files
- [[30477]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30477) Add new UNIMARC installer translation files

### Lists

- [[26346]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26346) Add option to make a public list editable by library staff only

  **Sponsored by** *Catalyst* and *Horowhenua District Council, New Zealand*

  >Add a new option for staff users to manage the contents of public lists from the staff client and OPAC. 
  >
  >This patchset also allows superlibrarian users, or those with the 'edit_public_lists' sub-permission, to edit the configuration of existing public lists.
- [[28716]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28716) Hide toolbar and opaccredits when printing lists

  >This removes the toolbar (Advanced Search | Authority Search | etc) and opaccredits (where set) from printed lists. The printed lists are cleaner without these.

### MARC Authority data support

- [[11083]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11083) Authority search result display in staff interface should be XSLT driven

  >This enhancement enables customising the authority search results summary in the staff interface using XSLT (for MARC21 and UNIMARC). 
  >
  >Key features;
  >- Use the new system preference AuthorityXSLTResultsDisplay to set the location of the XSLT file, either the full path to a file on the Koha server or a URL. 
  >- The system preference value can contain {langcode} and {authtypecode} which will be replaced by the appropriate value.
  >- If errors occur, the custom XSLT file is ignored and the default summary is displayed.
- [[13412]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13412) Allow configuration of auto-created authorities
- [[20615]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20615) Add the link of number of times the authority are used in edit mode
- [[29965]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29965) MARC preview for authority search results

  **Sponsored by** *Education Services Australia SCIS*

  >This enhancement makes the authority MARC preview modal available for the general authority search results.
- [[29990]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29990) Show authority heading use in search results

  **Sponsored by** *Education Services Australia SCIS*

  >Authority heading use is based on authority MARC 008/14-16. This could be useful to show on authority search results, if new system preference ShowHeadingUse is enabled.

### MARC Bibliographic data support

- [[20362]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20362) Direct link to authority records missing in staff detail view (1xx, 7xx)

### Notices

- [[29491]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29491) Improve display of notices in patron details

  >In patron notices table, notices are now shown in a modal dialog instead of inline in the table.
  >The "Resend" button is shown in the modal window controls.
- [[30290]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30290) Article requests: Add TOC information to AR notices

### OPAC

- [[13188]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13188) Make it possible to configure mandatory patron data differently between OPAC registration and modification

  >Adds the system preference PatronSelfModificationMandatoryField in order to separate borrower registration from borrower modification.
  >Initial value is a copy of system preference PatronSelfRegistrationBorrowerMandatoryField.
- [[14242]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14242) Use ISBN-field to fill out purchase suggestions using Google Books API

  >This patch adds a system preference, OPACSuggestionAutoFill, which enables a feature within the OPAC Purchase Suggestions where a user can enter an ISBN and use a Google API to pull the relevant data and input it into the form.
- [[15594]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15594) Sequence of  MARC 260 subfields different on XSLT result list and detail page

  >This enhancement improves the display of MARC field 260 in the detail page for the OPAC and staff interface by using the order of subfields in the record.  Previously, $a$b$a$b would display as aabb.
- [[17018]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17018) Split AdvancedSearchTypes for staff and OPAC

  >Add a new system preference, OpacAdvancedSearchTypes, as an OPAC-specific version of the AdvancedSearchTypes preference.
  >Values from AdvancedSearchTypes are copied to OpacAdvancedSearchTypes so that behavior is consistent.
- [[24220]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24220) Convert OpacMoreSearches system preference to news block
- [[24221]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24221) Convert OPACMySummaryNote system preference to news block

  >OPACMySummaryNote system preference is converted to a news block.
  >
  >Note that its HTML id is now 'OpacMySummaryNote' instead of 'opac-my-summary-note'.
- [[24630]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24630) UNIMARC XSLT Update for bug 7611
- [[27613]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27613) Pipe separated contents are hard to customize (OPAC)
- [[28876]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28876) No renewal before advisory text not wrapped in selector

  >This enhancement adds more `<span>`s to the user summary page in the OPAC so that information about the renewal status can be targeted with CSS or JS. It adds each `<span>` with a "usr-msg" class for general styling and a specific class for each renewal message, for example:
  >
  >`<span class="usr-msg no-renew-hold">Not renewable <span class="renewals">(on hold)</span></span>`
  >
  >These classes are added:
  >
  >- no-renew-hold: Not renewable (on hold)
  >- no-renew-too-many: Not renewable (too many renewals)
  >- no-renew-unseen: Item must be renewed at the library
  >- no-renew-overdue: Not allowed (overdue)
  >- no-renew-too-late: No longer renewable
  >- auto-renew-fines: Automatic renewal failed, you have unpaid fines
  >- auto-renew-expired: Automatic renewal failed, your account is expired
  >- no-renewal-before: No renewal before [date]
  >- automatic-renewal: Automatic renewal
- [[29066]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29066) Remove text in OPAC search form and use Font Awesome icons
- [[29212]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29212) Use Flatpickr on OPAC pages

  >This enhancement replaces the jQueryUI date picker used on OPAC pages with Flatpickr. The jQueryUI date picker is no longer supported.
- [[29515]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29515) Don't require title for HTML customizations
- [[29526]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29526) Add 'Immediately delete holds history' button to patron privacy tab in opac
- [[29616]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29616) Replace library information popup in the OPAC with a modal
- [[29713]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29713) Make item table when placing an item level hold sortable
- [[29845]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29845) Styling OverDrive buttons is difficult

  >Adds ID's to the action buttons on the OverDrive results page in order to make them easier to individually style.
- [[29899]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29899) Show public note to patrons when placing a hold
- [[29949]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29949) Remove use of title-numeric sorting routine from OPAC datatables JS
- [[29960]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29960) Remove Modernizr dependency in the OPAC

  >This patch refactors the code around JavaScript-driven responsive behavior in the OPAC. The use of Modernizr removed as it is no longer needed.
  >
  >It also adds a missing entry for Enquire.js licensing on the About page.
- [[30190]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30190) Green buttons turn blue for a second when clicking them
- [[30243]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30243) When OPACSuggestionMandatoryFields includes branchcode the dropdown should default to an empty value

  >Creates an empty value and defaults to it when OPACSuggestionMandatoryFields includes branchcode. This forces users to make a choice regarding branch.
- [[30288]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30288) Provide links to OPACUserJS and OPACUserCSS from News/HTML customizations

  **Sponsored by** *Catalyst*

### Patrons

- [[9097]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9097) Add option to trigger 'Welcome mail' manually

  >This enhancement adds a button to the more menu of the patron details page allowing staff to manually trigger sending the WELCOME notice to the user.
- [[15156]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15156) Get all Borrowers with pending/unpaid fines/accountlines

  >This enhancement adds an API call that returns patrons filtered by how much money they owe, between passed limits (for example less than $2.50 or more than $0.50). Optionally, can limit to debts of a particular debit_type and owed to a particular library.
- [[29005]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29005) Add option to send WELCOME notice for new patrons added via patron imports

  >This enhancement adds a new option to patron imports allowing imports to trigger sending the 'WELCOME' notice for new user accounts created via this mechanism.
- [[29059]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29059) Keep non-repeatable attribute from patron to preserve
- [[29525]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29525) Privacy settings for patrons should also affect holds history
- [[29617]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29617) BorrowerUnwantedField should exclude the ability to hide categorycode
- [[30055]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30055) Rewrite some of the patron searches to make them use the REST API routes
- [[30063]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30063) Make the main patron search use the /patrons REST API route
- [[30093]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30093) Rewrite the patron search when placing a hold with the REST API route
- [[30094]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30094) Rewrite the patron search when requesting an article with the REST API route
- [[30120]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30120) Allow extended attributes during self registration when using PatronSelfRegistrationVerifyByEmail
- [[30237]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30237) Rename/rephrase AutoEmailOpacUser/ACCTDETAILS feature to clarify intended use

  >With the removal of patron plaintext passwords from the ACCTDETAILS notice in bug 27812 the feature effectively got repurposed to become a 'Welcome email'.
  >
  >This enhancement rephrases the system preference description and replaces the ACCTDETAILS notice with a new WELCOME notice.
  >
  >We keep the ACCTDETAILS notice for reference at upgrades, but it will not appear for new installations and it is not longer sent in any circumstances.
- [[30563]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30563) Add system preference to make the cash register field required when collecting a payment
- [[30611]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30611) Add ability to trigger a patron password reset from the staff client

  >This enhancement adds a button to the patron details page in the client to allow librarians, with appropriate permissions, to trigger a password reset for patrons.
  >
  >The result is a notice sent to the user with a fresh password reset link allowing the user to enter a new password for their account.

### Plugin architecture

- [[29787]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29787) Add plugin version to plugin search results
- [[30072]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30072) Add more holds hooks

  >This development adds plugin hooks for several holds actions. The hook is called *after_hold_action* and has two parameters
  >
  >* **action**: containing a string that represents the _action_, possible values: _fill_, _cancel_, _suspend_ and _resume_.
  >* **payload**: A hashref containing a _hold_ key, which points to the Koha::Hold object.
- [[30180]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30180) Deprecate after_hold_create hook

  >The 'after_hold_create' hook is deprecated and scheduled for removal in the next major release.
  >
  >If you find deprecation warnings for some plugin in your logs, please ask the plugin authors to update it to use the new 'after_hold_action' hook instead.
- [[30410]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30410) Add a way for plugins to register background tasks

### REST API

- [[28020]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28020) Error responses should return a code

  >This development makes our error responses include an `error_code` that will be documented on each route, allowing better API usage on error conditions.
- [[29620]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29620) Move the OpenAPI spec to YAML format

  >This enhancement moves all the Koha REST API specification from json to YAML format. It also corrects two named parameters incorrectly in camelCase to sanake_case (fundidPathParam => fund_id_pp, vendoridPathParam => vendor_id_pp).
- [[29772]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29772) Make DELETE /patrons/:patron_id return error codes in error conditions
- [[29810]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29810) Add embed options documentation

  >This patch adds documentation of the different embed options the REST API provides.
- [[30074]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30074) Missing extended_attributes relationship in DBIC schema
- [[30194]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30194) Update required JSON::Validator version

  >This development adapts Koha so it works with the latest versions of:
  >
  >- Mojolicious
  >- JSON::Validator
  >- Mojolicious::Plugin::OpenAPI
- [[30674]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30674) x-koha-override should use collectionFormat: csv

### Reports

- [[5697]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5697) Automatic linking in guided reports

  >This patch adds a feature to automatically link certain database columns in report results. If your report returns itemnumber, biblionumber, cardnumber, or borrowernumber, that cell in the report will contain a menu:
  >
  >- borrowernumber: View, edit, check out
  >- cardnumber: Check out
  >- itemnumber: View, edit
  >- biblionumber: View, edit
  >
  >A link at the top of the report results will toggle the new menus on and off in case you don't want to see the menus. Your choice will persist until you log out.
  >
  >The feature works with column name placeholders, so if you want the table column to be a human readable label you can still get automatic linking, for example: [[items.itemnumber|Item number]]
- [[29767]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29767) Add cash registers, debit and credit types to report runtime parameters

### SIP2

- [[20517]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20517) Use the "sort bin" field in SIP2 Checkin Response
- [[25815]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25815) SIP Checkout: add more information on why the patron is blocked
- [[26370]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26370) Add ability to disable demagnetizing items via SIP2 based on patron categories

  >This patch adds a new option to the SIP config, `inhouse_patron_categories`. Adding a comma-separated list of patron category codes to this option will cause the SIP checkout to never send the 'demagnetize' command to the checkout preventing said users from removing the items from the library.
- [[29874]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29874) Remove unused method C4::SIP::ILS::Item::fill_reserve
- [[29936]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29936) Add ability to disable hold capture via SIP checkin

  **Sponsored by** *Cheshire Libraries Shared Services*

  >This enhancement adds a new `holds_get_captured` configuration option to SIP accounts.
  >
  >The new option defaults to enabled, as has been the case since bug 3638 was pushed. However, it allows for disabling hold capture so that items are not automatically assigned to holds at SIP check-in; The alerts messages will continue to show, however, to allow items to be put to one side and then captured by a subsequent staff check-in.

### Searching

- [[20689]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20689) Improve usability of Item search fields administration page
- [[22605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22605) Adding the option to modify/edit searches on the staff interface
- [[27035]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27035) Shows the number of results in a facets after facet selection

### Searching - Elasticsearch

- [[29856]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29856) Make the ES config more flexible

### Serials

- [[6734]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=6734) Show location in full and brief subscription history in OPAC
- [[23352]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23352) Define serial's collection in the subscription

  **Sponsored by** *Catalyst*
- [[29815]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29815) Pre-populate 'Date acquired' field when adding/editing items

### Staff Client

- [[17748]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17748) Show due date in item search results

  **Sponsored by** *Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)*

  >This enhancement adds the due date of an item to the item search results. The due date column will also show when exporting results to a CSV file.
- [[20398]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20398) Add a system preference to disable search result highlighting in the staff interface

  >This enhancement adds a new system preference StaffHighlightWords. This enables highlighting of words in search results for the staff interface to be turned on or off.
- [[21225]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21225) Add Syndetics cover images to staff client
- [[27631]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27631) Accessibility: Staff interface - `h1` on each page is Logo but should be page description/title

  **Sponsored by** *Catalyst*

  >This enhancement, as part of improving the accessibility of the staff interface, makes the main topic/title of the page the `h1` rather than the logo.
- [[29575]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29575) Add a JS render function equivalent of the patron-title.inc TT include

  >This enhancement adds a re-usable javascript render function that accepts a Koha REST APIi Patron object and outputs the HTML representation.
- [[30081]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30081) Display item type in patron's holds table

### System Administration

- [[7374]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7374) Add remote image option for authorized values

  >This patch updates authorized values management to add the option of specifying a remote image to be associated with an authorized value. This functionality matches what was already available for item types: The ability to specify a full URL to an image file. Modifying a collection code with a remote image will make the image visible on catalog advanced search pages in the OPAC and staff interface when the option to select a collection is enabled.
- [[29626]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29626) Map biblioitems.place to 264$a by default (MARC21)

  >This updates the default Koha to MARC mappings so that biblioitems.place maps to 264$a. Currently it only maps to 260$a, and RDA uses 264$a.
- [[29627]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29627) Map biblioitems.publishercode to 264$b by default (MARC21)

  >This updates the default Koha to MARC mappings so that biblioitems.publishercode maps to 264$b. Currently it only maps to 260$b,and RDA uses 264$b.
- [[29634]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29634) Map biblio.medium to 245$h by default (MARC21)

  >This updates the default Koha to MARC mappings so that biblio.medium maps to 245$h. The medium field was added in 19.11 but it was not linked to 245$h.
- [[29832]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29832) Make library column in desk list sortable

### Templates

- [[24415]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24415) Authority enhancement - Improve access to tabs
- [[25025]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25025) Drag-and-drop cover image upload
- [[26975]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26975) Reindent authorities editor template
- [[27470]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27470) Improve link text for logging in

  **Sponsored by** *Catalyst*
- [[27750]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27750) Remove jquery.cookie.js plugin
- [[28405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28405) Add author info to the holds page in the staff interface

  >This patch adds the author name to place a hold page (request.tt)
- [[28993]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28993) Switch magnifying glass in staff detail pages to FA icon
- [[29228]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29228) Use Flatpickr on offline circulation page
- [[29277]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29277) Replace the use of jQueryUI tabs on item circulation alerts page
- [[29289]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29289) 'Show fines to guarantor' should have its own id on patron detail page
- [[29406]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29406) Improve display of OPAC suppression message

  >This enhancement changes the way the "Suppressed in OPAC" message is shown on the staff interface search results and the bibliographic detail page. Now the information is displayed like other bibliographic details.
- [[29458]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29458) Show login button consistently in relation to login instructions, reset and register links
- [[29602]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29602) We must be nicer with translators
- [[29648]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29648) Make KohaTable tables 'default length' and 'default sort' configurable
- [[29867]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29867) Reindent authorized values administration template
- [[29876]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29876) Style report id in report results heading
- [[29998]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29998) Replace the use of jQueryUI tabs on item types administration page
- [[29999]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29999) Replace the use of jQueryUI tabs on authorized values administration page
- [[30000]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30000) Replace the use of jQueryUI tabs on the search engine configuration page
- [[30011]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30011) Upgrade jQueryUI to 1.13.1 in the OPAC and staff interface
- [[30212]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30212) Make Select2 available for ILL backend developers
- [[30223]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30223) Move book cover image upload JS to a separate file
- [[30227]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30227) Replace the use of jQueryUI tabs on bibliographic detail page
- [[30316]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30316) Replace the use of jQueryUI tabs on MARC detail page
- [[30317]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30317) Replace the use of jQueryUI tabs on search history page
- [[30378]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30378) Convert about page tabs to Bootstrap
- [[30396]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30396) Convert basket groups page tabs to Bootstrap
- [[30398]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30398) Reindent invoices template
- [[30400]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30400) Convert invoices page tabs to Bootstrap
- [[30401]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30401) Convert budgets administration page tabs to Bootstrap
- [[30417]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30417) Switch to Bootstrap tabs on the basic library transfer limit page
- [[30419]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30419) Convert authority detail page tabs to Bootstrap
- [[30423]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30423) Convert authority merge page tabs to Bootstrap
- [[30424]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30424) Reindent advanced search template in the staff interface
- [[30433]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30433) Convert advanced search tabs to Bootstrap
- [[30434]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30434) Convert catalog merge page tabs to Bootstrap
- [[30436]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30436) Convert article requests tabs to Bootstrap
- [[30453]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30453) Convert offline circulation tabs to Bootstrap
- [[30454]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30454) Convert holds awaiting pickup tabs to Bootstrap
- [[30456]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30456) Convert checkout history tabs to Bootstrap
- [[30457]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30457) Convert holds page tabs to Bootstrap
- [[30466]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30466) Convert serials pages tabs to Bootstrap
- [[30473]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30473) Convert suggestions page tabs to Bootstrap
- [[30474]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30474) Convert tools pages tabs to Bootstrap (part 1)
- [[30475]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30475) Convert tools pages tabs to Bootstrap (part 2)
- [[30489]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30489) Convert MARC and authority subfield edit tabs to Bootstrap
- [[30491]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30491) Convert saved reports tabs to Bootstrap
- [[30494]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30494) Replace the use of jQueryUI Accordion on the table settings page
- [[30545]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30545) Replace the use of jQueryUI Accordion on the notices page
- [[30549]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30549) Replace the use of jQueryUI Accordion on pending patron updates page
- [[30695]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30695) Checkouts and holds count display in tab could be better in patron details

### Test Suite

- [[30125]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30125) Add full-stack tests for API pagination
- [[30446]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30446) Add a test for GetTagsLabels

### Tools

- [[14393]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14393) Add collection code filter to inventory
- [[20076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20076) Overdues email to library for patrons without email should be optional

  >Currently, two print notices are generated when running overdue_notices.pl if a patron does not have an email address:
  >- a print overdue notice for the patron, and 
  >- an email message to the library with all the print versions of the overdue notices.
  >
  >Depending on a library's work processes, they may want both or only the patron print overdue notice generated.
  >
  >This enhancement adds a new system preference, EmailOverduesNoEmail, that allows libraries to choose whether to send or not send overdue notices for patrons without an email address to library staff. The default is set to send, as this preserves the current behaviour.
- [[22785]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22785) Manage matches when importing through stage MARC record import
- [[22827]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22827) Automatic item modifications by age: add age depencency on other field(s) than dateaccessioned

  >This enhancement enables librarians to automatically modify items based on date fields other than items.dateaccessioned. 
  >
  >The 'Automatic item modifications by age' tool can now key rules off any one the following: items.dateaccessioned, items.replacementpricedate, items.datelastborrowed, items.datelastseen, items.damaged_on, items.itemlost_on, items.withdrawn_on.
  >
  >Existing rules will continue to key off the items.dateaccessioned field.
- [[23873]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23873) Allow marc modification templates to use capturing groups in substitutions
- [[27904]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27904) Improve display in creating profile for staging MARC records for import
- [[28840]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28840) Better texts in batch record modification/deletion
- [[29698]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29698) items are not available for TT syntax for PREDUEDGST
- [[29821]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29821) Add interface for generating barcodes using svc/barcode
- [[29824]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29824) Allow for quick spine labels to be editable for printing

  >Adds the ability to edit quick spine labels after they have been generated.
- [[29946]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29946) Sort profiles alphabetically when  staging MARC records for import

### Web services

- [[20894]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20894) Add barcode size parameters to /svc/barcode
- [[22347]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22347) Translatability of ILSDI results for getavaibility

  **Sponsored by** *University Lyon 3*
- [[28238]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28238) Add itemcallnumber to ILS-DI GetAvailability output

  **Sponsored by** *University Lyon 3*

  >This enhancement adds the item call number to the ILS-DI GetAvailability output. This is useful for libraries that use discovery tools as patrons often don't check further for the call number, and then they don't have it when they look for the item.


## Critical bugs fixed

(This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### Acquisitions

- [[29464]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29464) GET /acquisitions/orders doesn't honour sorting

  **Sponsored by** *ByWater Solutions*
- [[29570]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29570) Unable to sort summary column of pending_orders table on parcel.pl by summary column
- [[29670]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29670) Restore functionality broken by bug 27708 for AcqCreateItem set to "placing an order"

  >This patch restores the lost GIR segments in EDI messages generated by orders with items attached.

### Architecture, internals, and plumbing

- [[29631]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29631) 21.06.000.12 may fail

  >This fixes an issue when upgrading from 21.05.x to 21.11 - the uniq_lang unique key is failing to be created because several rows with the same subtag and type exist in database table language_subtag_registry.
- [[29684]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29684) Warning File not found: js/locale_data.js
- [[29804]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29804) Koha::Hold->is_pickup_location_valid explodes if empty list of pickup locations
- [[29857]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29857) We must stringify our exceptions correctly
- [[29914]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29914) check_cookie_auth not strict enough
- [[29956]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29956) Cookie can contain plain text password
- [[30004]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30004) Prevent TooMany from executing too many SQL queries
- [[30167]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30167) Return soonest renewal date when CanBookBeRenewed returns %too_soon
- [[30172]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30172) Background jobs failing due to race condition
- [[30291]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30291) Rename recalls.* column names
- [[30501]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30501) sysprefs.sql has an error
- [[30540]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30540) Double processing invalid dates can lead to ISE
- [[30626]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30626) DT REST API wrapper not building the filter query correctly
- [[30639]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30639) Patron search does not split search terms

### Authentication

- [[29915]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29915) Anonymous session generates 1 new session ID per hit

### Cataloging

- [[29689]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29689) Update to 21.11 broken auto-generated barcode in `<branchcode>0001` option
- [[29690]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29690) Software error in details.pl when invalid MARCXML
- [[30178]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30178) Every librarian can edit every item with IndependentBranches on
- [[30644]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30644) Cannot delete items
- [[30717]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30717) Dates displayed in ISO format when editing items

### Circulation

- [[29495]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29495) Issue link is lost in return claims when using 'MarkLostItemsAsReturned'
- [[29637]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29637) AutoSwitchPatron is broken since Bug 26352

  >This fixes an issue introduced by bug 26352 in 21.11 that caused the AutoSwitchPatron system preference to no longer work. (When AutoSwitchPatron is enabled and a patron barcode is scanned instead of a book, it automatically redirects to the patron.)
- [[30099]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30099) Error when accessing circulation.pl without patron parameter
- [[30104]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30104) Holds to pull is broken
- [[30114]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30114) Koha offline circulation will always cancel the next hold when issuing item to a patron
- [[30222]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30222) Auto_renew_digest still sends every day when renewals are not allowed
- [[30251]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30251) With IndependentBranches non-superlibrarians do not get autocomplete list in circulation module

### Command-line Utilities

- [[29794]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29794) delete_items.pl missing include
- [[30520]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30520) Command line stage and import broken

### Database

- [[29605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29605) DB structure may not be synced with kohastructure.sql
- [[30600]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30600) Recalls sync problem between DBIx and kohastructure.sql

  **Sponsored by** *Catalyst*
- [[30852]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30852) article_requests missing index on debit_id

### Fines and fees

- [[27801]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27801) Entering multiple lines of an item in Point of Sale can make the Collect Payment field off

  >This fixes the POS transactions page so that the total for the sale and the amount to collect are the same.
  >
  >Before this a POS transaction with multiple items in the Sale box, say for example 9 x .10 items, the total in the Sale box appears correct, but the amount to Collect from Patron is off by a cent.
- [[29385]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29385) Add missing cash register support to SIP2
- [[29457]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29457) Fee Cancellation records the wrong manager_id

  >Prior to this patch inadvertently the field borrowers.userid was used to fill accountslines.manager_id. This should have been borrowernumber.
  >
  >This report fixes that and prints a generic warning.
- [[30003]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30003) Register entries doubled up if form fails validation on first submission
- [[30139]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30139) Point of sale sets wrong 'Amount being paid' with CurrencyFormat = FR
- [[30346]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30346) Editing circ rule with Overdue fines cap (amount) results in data loss and extra fines

### Hold requests

- [[29136]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29136) Patron search on request.pl has performance and display issues

  >This fixes the performance and display of patron search results when placing a hold from a record details page using the staff interface. Patron results are now paginated and all the results are now available - previously all results were listed on one page, which could cause performance issues.
- [[29349]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29349) Item-level holds should assume the same pickup location as bib-level holds

  >Up until Koha 20.11 the pickup location when placing item-level holds was the currently logged-in library.
  >
  >From Koha 21.05 the holding branch was used as the default.
  >
  >This restores the previous behaviour so that the logged-in library (if a valid pickup location) is selected as the default pickup location for item-level holds. When it is not, an empty dropdown is used as a fallback.
- [[29736]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29736) Error when placing a hold for a club without members
- [[29737]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29737) Cannot suspend holds
- [[29906]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29906) When changing hold parameters over API (PUT) it forcibly gets to "suspended" state

  >The PATCH/PUT /api/v1/holds/{hold_id} API endpoint allows for partial updates of Holds.  Priority and Pickup Location are both available to change (though it is preferred to use the routes specifically added for manipulating them).
  >
  >Suspend_until can also be added/updated to add or lengthen an existing suspension, but the field cannot be set to null to remove the suspension at present.
  >
  >This patch restores the suspen_until function to ensure suspensions are not triggered by unrelated pickup location or priority changes.
- [[29969]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29969) Cannot update hold list after holds cancelled in bulk
- [[30266]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30266) Holds marked waiting with a holdingbranch that does not match can cause loss of pickup locations
- [[30395]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30395) Internal server error at reserve/request.pl on a biblio with non-ISO formatted date in publicationyear
- [[30432]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30432) get_items_that_can_fill needs to specify table for biblionumbers
- [[30583]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30583) Hold system broken for translated template
- [[30630]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30630) Checking in a waiting hold at another branch when HoldsAutoFill is enabled causes errors
- [[30730]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30730) Holds to Pull should not list items with a notforloan status

### ILL

- [[28932]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28932) Backend overriding status_graph element causes duplicate actions
- [[30183]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30183) ILL table search filtering broken

### Installation and upgrade (web-based installer)

- [[27619]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27619) Remove fr-FR installer data
- [[30276]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30276) Web-based installer failing on db upgrade for 30060

### Label/patron card printing

- [[24001]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24001) Cannot edit card template

  >This fixes errors that caused creating and editing patron card templates and printer profiles to fail.

### Lists

- [[29669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29669) Uninitialized value warnings when XSLTParse4Display is called

### Notices

- [[29586]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29586) "Hold reminder" notice doesn't show in messaging preferences in new installation

  >This fixes an issue with the installer files that meant "Hold reminder" notices were not shown in messaging preferences for new installations.
- [[30354]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30354) AUTO_RENEWALS_DGST notices are not generated if patron set to receive notice via SMS and no SMS notice defined

  >If an SMS notice is not defined for AUTO_RENEWALS_DGST and a patron has selected to receive a digest notification by SMS when items are automatically renewed, it doesn't generate a notice (even though the item(s) is renewed). This fixes the issue so that an email message is generated.

### OPAC

- [[28955]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28955) Add option to set default branch from Apache

  >Add support for OPAC_BRANCH_DEFAULT as an environment option.
  >It allows setting a default branch for the anonymous OPAC session such that you can display the right OPAC content blocks prior to login if you have set up per branch website.
- [[29544]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29544) A patron can set everybody's checkout notes
- [[29696]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29696) "Suggest for purchase" missing biblio link
- [[29778]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29778) Deleting additional_contents leaves entries for additional languages
- [[29803]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29803) Local cover images don't show in detail page, but only in results
- [[30045]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30045) SCO print slip is broken
- [[30089]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30089) Placing holds on OPAC broken
- [[30101]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30101) OPAC advanced search page broken by Bug 29844
- [[30147]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30147) OpacBrowseResults causing error on detail page
- [[30488]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30488) Error when placing a recall in the OPAC

  **Sponsored by** *Catalyst*

### Packaging

- [[29881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29881) Remove SQLite2 dependency
- [[30084]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30084) Remove dependency of liblocale-codes-perl
- [[30209]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30209) Upgrade 'libdbd-sqlite2-perl' package to 'libdbd-sqlite3-perl'

### Patrons

- [[28943]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28943) Lower the risk of accidental patron deletion by cleanup_database.pl

  >If you use self registration but you do not use a temporary self registration patron category,
  >you should actually clear the preference
  >PatronSelfRegistrationExpireTemporaryAccountsDelay.
- [[30325]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30325) (Bug 30098 follow-up) Broken patron search redirect when one result
- [[30576]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30576) DefaultPatronSearchFields no longer takes effect
- [[30603]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30603) Sort 1 and Sort 2 on patron form are on longer free text when AV categories are empty
- [[30622]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30622) Search for cardnumber needs to go directly to patron record when placing a hold

### Plugin architecture

- [[29931]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29931) Script plugins-enable.pl should check the cookie status before running plugins

### REST API

- [[29018]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29018) Deleting patrons from REST API doesn't do any checks or move to deletedborrowers

  >This fixes the REST API route for deleting patrons so that it now checks for guarantees, debts, and current checkouts. If any of these checks fail, the patron is not deleted.
- [[29877]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29877) MaxReserves should be enforced consistently between staff interface and API
- [[30133]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30133) Pagination broken on pickup_locations routes when AllowHoldPolicyOverride=1
- [[30165]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30165) Several q parameters break the filters
- [[30408]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30408) API and OpenAPI versions should be string in spec
- [[30663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30663) POST /api/v1/suggestions won't honor suggestions limits

### Reports

- [[29786]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29786) Holds to pull report shows incorrect item for item level holds

  >This patch corrects an issue with the Holds to Pull report in which an incorrect barcode number could be shown for an item-level hold. The correct barcode will now be shown.
- [[30532]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30532) guided_reports.pl has a problem
- [[30551]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30551) Cash register report shows wrong library when paying fees in two different libraries

### SIP2

- [[29754]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29754) Patron fines counted twice for SIP when NoIssuesChargeGuarantorsWithGuarantees is enabled
- [[29755]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29755) SIP2 code does not correctly handle NoIssuesChargeGuarantees  or  NoIssuesChargeGuarantorsWithGuarantees

  >This fixes SIP2 so that it correctly determines if issues should be blocked for patrons when the NoIssuesChargeGuarantees and NoIssuesChargeGuarantorsWithGuarantees system preferences are set. Currently, it only checks the noissuescharge system preference as the limit for charges, and not the other 'No Issues charge' system preferences.

### Searching - Elasticsearch

- [[27770]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27770) ES: Deprecated aggregation order key [_term] used, replaced by [_key]

  **Sponsored by** *Lund University Library*
- [[28610]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28610) Elasticsearch 7 - hits.total is now an object

  **Sponsored by** *Lund University Library*

  >This is one of the changes to have Koha compatible with ElasticSearch 7. This one also causes the full end of compatibility with ElasticSearch 5. Users are advised to upgrade as soon as possible to ElasticSearch 7 since version 5 and 6 are not supported anymore by their developers.
- [[29893]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29893) ElasticSearch Config UI deletes mappings
- [[30584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30584) Cannot add field mappings to Elasticsearch configuration

### Self checkout

- [[28735]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28735) Self-checkout users can access opac-user.pl for sco user when not using AutoSelfCheckID
- [[29543]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29543) Self-checkout allows returning everybody's loans
- [[30199]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30199) self checkout login by cardnumber is broken if you input a non-existent cardnumber

### Staff Client

- [[29540]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29540) Accounts with just 'catalogue' permission can modify/delete holds
- [[29541]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29541) Patron images can be accessed with just 'catalogue' permission
- [[30610]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30610) The 'Print receipt' button on cash management registers page fails on second datatables page

### Templates

- [[30525]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30525) Items batch modification broken

### Test Suite

- [[19169]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19169) Add a test to detect unneeded 'atomicupdate' files
- [[29779]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29779) selenium/regressions.t fails if Selenium lib is not installed

### Tools

- [[29719]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29719) onloan dates are cleared from items when importing and overlaying
- [[29747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29747) Cataloguing upload plugin broken
- [[29808]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29808) Stock rotation fails to advance when an item is checked out from the branch that is the next stage
- [[30402]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30402) Authority import hanging when replacing matched record

  **Sponsored by** *Educational Services Australia SCIS*
- [[30461]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30461) Batch authority tool is broken
- [[30518]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30518) StockRotationItems crossing DST boundary throw invalid local time exception
- [[30628]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30628) Batch borrower modifications only affect the current page

  >This fixes the batch patron modification tool (Tools > Patrons and circulation > Batch patron modification) so that the changes for all selected patrons are modified. Before this, only the patrons listed on the current page were modified.


## Other bugs fixed

(This list includes all bugfixes since the previous major version. Most of them
have already been fixed in maintainance releases)

### About

- [[30808]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30808) Release team 22.11

### Acquisitions

- [[24866]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24866) Display budget hierarchy in the budget dropdown menu used when placing a new order

  >This improves the display for selecting a fund when placing a new order in acquisitions. It now displays as a hierarchy instead of a list without any indentation, for example:
  >
  >  Budget 2021
  >  -- Book
  >  -- -- Adult fiction
- [[28855]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28855) Purging suggestions test should not be on timestamp

  >This changes the date field that cronjob misc/cronjobs/purge_suggestions.pl uses to calculate the number of days for deleting accepted or rejected suggestions. It now uses the managed on date, as the last updated date that was used can be changed by other database updates.
- [[29287]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29287) Display of funds on acquisitions home is not consistent with display on funds page
- [[29419]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29419) Suggest for purchase clears item type, quantity, library and reason if bib exists
- [[29895]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29895) Button [Add multiple items] stops responding when it's pressed and some multiple items added to basket
- [[30127]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30127) By default show pending suggestions tab
- [[30599]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30599) Allow archiving multiple suggestions

### Architecture, internals, and plumbing

- [[18320]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18320) patroncards/edit-layout.pl raises warnings
- [[18540]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18540) koha-indexdefs-to-zebra.xsl introduces MARC21 stuff into UNIMARC xslts
- [[27253]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27253) borrowers.updated_on cannot be null on fresh install, but can be null with upgrade
- [[29336]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29336) Some authorised_value FKs are too short

  >This fixes the length of the field definitions in the database for several authorised_value and authorised_value_category columns as they are too short. It changes the value to varchar(32).
- [[29483]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29483) AllowRenewalIfOtherItemsAvailable has poor performance for records with many items
- [[29494]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29494) html-template-to-template-toolkit.pl no longer required
- [[29498]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29498) Remove usage of deprecated Mojolicious::Routes::Route::detour
- [[29625]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29625) Wrong var name in Koha::BiblioUtils get_all_biblios_iterator
- [[29646]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29646) Bad or repeated opac-password-recovery attempt crashes on wrong borrowernumber
- [[29687]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29687) Get rid of an uninitialized warning in XSLT.pm
- [[29702]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29702) all_libraries routine in library groups make a DB call per member of group
- [[29717]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29717) Too many DateTime manipulation in tools/additional-contents.pl
- [[29758]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29758) CGI::param in list context in boraccount.pl warning

  >This removes the cause of warning messages ([WARN] CGI::param called in list context from...) in the plack-intranet-error.log when accessing the accounting transactions tab for a patron.
- [[29764]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29764) EmbedItems RecordProcessor filter POD incorrect
- [[29771]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29771) Get rid of CGI::param in list context warnings
- [[29785]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29785) Koha::Object->messages must be renamed
- [[29789]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29789) Unused $error in cataloguing/additem.pl
- [[29806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29806) ->pickup_locations should always be called in scalar context

  >The Koha::Biblio->pickup_locations and Koha::Item->pickup_location methods don't always honour list context. Because of this, when used, they should assume scalar context. If list context was required, the developer needs to explicitly chain a ->as_list call.
  >
  >This patch tracks the uses of this methods and adjusts accordingly.
- [[29809]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29809) StockRotationItems->itemnumber is poorly named
- [[29812]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29812) C4::Context not included, but used in Koha::Token
- [[29865]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29865) Wrong includes in circ/returns.pl
- [[29957]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29957) Cookies not removed after logout

  >This patch adds a new config variable to koha-conf.xml called do_not_remove_cookie.
  >By default, all cookies are cleared now. But you could uncomment the KohaOpacLanguage entry to preserve it.
- [[29966]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29966) SCO Help page passes flags while not needing authentication
- [[29984]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29984) Remove unused method Koha::Patrons->anonymise_issue_history
- [[30008]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30008) Software error in details.pl when invalid MARCXML and showing component records
- [[30009]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30009) Records with invalid MarcXML show notes tab 'Descriptions(1)' but tab is empty
- [[30110]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30110) Potential bug source: plenty of "my" declarations with conditional assignments
- [[30115]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30115) Uninitialized value warning in C4/Output.pm
- [[30143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30143) OAI-PMH provider may end up in an eternal loop due to missing sort
- [[30161]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30161) Remove duplicate z3950_search include lines
- [[30185]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30185) Missing return in db rev 210600003.pl
- [[30253]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30253) Double mana_success line is no success
- [[30294]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30294) Rename Koha::Recall->* used relationship names
- [[30345]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30345) Koha::BackgroundJob->enqueue should set borrowernumber=undef if no userenv
- [[30377]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30377) Fix two CGI::param called in list context-warnings
- [[30393]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30393) datatables wrapper should handle searching for %, _ and \
- [[30406]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30406) Our DT tables not filtering on the correct column if hidden by default
- [[30467]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30467) BatchDeleteItem task does not deal with indexation correctly
- [[30638]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30638) Odd number of elements in anonymous hash at C4/Letters.pm line 827
- [[30668]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30668) UpdateItemLocationOnCheckin spams the cataloguing log
- [[30692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30692) Wrong progress displayed for ES indexing tasks
- [[30702]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30702) Remove Context L785 warning
- [[30703]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30703) Remove a few CookieManager warnings
- [[30714]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30714) Checkins from other branches spam the cataloguing log
- [[30727]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30727) Holds queue updates can be called multiple times on batch record deletion

### Authentication

- [[29487]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29487) Set autocomplete off for userid/password fields at login

  >This turns autocompletion off for userid and password fields on the login forms for the OPAC and staff interface.

### Browser compatibility

- [[22671]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22671) Warn the user in offline circulation if applicationCache isn't supported

### Cataloging

- [[9565]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9565) Deleting a record should alert or fail if there are current subscriptions

  >This change prevents the deletion of records with current serial subscriptions. 
  >
  >Selecting "Delete record" when there are existing subscriptions no longer deletes the record and subscription, and adds an alert box "[Count] subscription(s) are attached to this record. You must delete all subscriptions before deleting this record.".
  >
  >It also:
  >- adds a "Subscriptions" column in the batch deletion records tool with the number of subscriptions and a link to the search page with all the subscriptions for the record, and
  >- adds a button in the toolbar to enable selecting only records without subscriptions.
- [[25251]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25251) When a record has no items click delete all does not need an alert
- [[26328]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26328) incremental barcode generation fails when incorrectly converting strings to numbers
- [[28853]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28853) Textarea in biblio record editor breaks authority plugin

  >This fixes an issue when adding or editing record subfields using the authority plugin and it has a value with more than 100 characters. (When a subfield has more than 100 characters it changes to a text area rather than a standard input field, this caused JavaScript issues when using authority terms over 100 characters.)
- [[29511]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29511) While editing MARC records, blank subfields appear in varying order
- [[29962]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29962) Table of items on item edit page missing columns button
- [[30159]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30159) Fix display of validation of important fields when biblio cataloguing

  **Sponsored by** *Education Services Australia SCIS*

  >This patch adds a check for both mandatory and important fields when validating bibliographic records during cataloguing.
- [[30224]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30224) Wrong important field shown in cataloguing validation

  **Sponsored by** *Education Services Australia SCIS*

  >This patch fxes the cataloguing validation messages to show the correct tag, when the whole field is important (not just a subfield).
- [[30376]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30376) Unable to save item if field date acquired is set mandatory
- [[30435]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30435) Remove unused MACLES cataloging plugin
- [[30482]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30482) Potential for bad string concatenation in cataloging validation error message
- [[30797]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30797) Subfields linked to the dateaccessioned.pl value builder on addbiblio.pl throw a JS error

  **Sponsored by** *Chartered Accountants Australia and New Zealand*

### Circulation

- [[11750]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11750) Overdue report does not limit patron attributes
- [[29220]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29220) Minor fixes and improved code readability in circulation.pl

  **Sponsored by** *Gothenburg University Library*
- [[29476]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29476) Earliest renewal date is displayed wrong in circ/renew.pl for issues with auto renewing
- [[29537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29537) Simplify auto-renewal code in CanBookBeRenewed
- [[29820]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29820) Print summary just show 20 items
- [[29889]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29889) Incorrect library check in patron message deletion logic

  >This fixes the logic controlling whether a patron message on the circulation or patron details page has a "Delete" link. An error in the logic prevented messages from being removed by staff who should have been authorized to do so.
- [[30155]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30155) We shouldn't calculate get_items_that_can_fill when we don't have any holds
- [[30735]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30735) Filtering by patron attribute with AV does not work in overdues report

### Command-line Utilities

- [[10517]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10517) koha-restore fails to create mysqluser@mysql_hostname so zebra update fails

  **Sponsored by** *Reformational Study Centre*
- [[29054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29054) Stop warns from advance_notices.pl if not running in verbose mode

  **Sponsored by** *Catalyst*
- [[29501]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29501) gather_print_notices.pl does not use SMTP servers
- [[30666]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30666) Holds reminder cronjob (holds_reminder.pl) uses DateTime::subtract wrong
- [[30667]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30667) Holds reminder cronjob (holds_reminder.pl) never uses default letter template
- [[30776]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30776) import_webservice_batch.pl cronjob completely broken

### Database

- [[30128]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30128) language_subtag_registry.description is too short
- [[30449]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30449) Missing FK constraint on borrower_attribute_types
- [[30481]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30481) Drop unique constraint deleteditemsstocknumberidx for deleteditems
- [[30498]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30498) Enum search_field.type should contain year in kohastructure
- [[30565]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30565) Field stockrotationrotas.description should be NOT NULL, title UNIQUE
- [[30572]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30572) Field search_marc_to_field.sort needs syncing too
- [[30620]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30620) Add a warning close to /*!VERSION lines in kohastructure.sql

### Fines and fees

- [[28481]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28481) Register details "Older transactions" search does not include the selected day in the "To" field in date range

  >This fixes the search and display of older transactions in the cash register so that items from today are included in the results. Previously, transactions for the current day were incorrectly not included.
- [[28663]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28663) One should not be able to apply a discount to a VOID accountline

  >This removes the display of the 'Apply discount' button for VOID transactions.
- [[29952]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29952) Filter Paid Transactions Broken on Transactions tab in Staff

  >This fixes the "Filter paid transactions" link in the staff interface on the Patron account > Accounting > Transactions tab. It now correctly filters the list of transactions - only transactions with an outstanding amount greater than zero are shown ("Show all transactions" clears the filter). Before this fix, clicking on the link didn't do anything and didn't filter any of the transactions as expected.
- [[30132]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30132) overdue_notices.pl POD is incorrect regarding passing options

### Hold requests

- [[21652]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21652) reserves.waitingdate is set to current date by printing new hold slip
- [[21729]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21729) When reverting a hold the expirationdate should be reset
- [[29043]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29043) Items are processed but not displayed on request.pl before a patron is selected
- [[29103]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29103) reserves.desk_id for desk of waiting hold only updates when printing new hold slip
- [[29115]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29115) Placing a club hold is not showing warnings when unable to place a hold

  >This fixes placing club holds so that checks are correctly made and warning messages displayed when patrons are debarred or have outstanding fees and charges.
- [[29338]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29338) Reprinting holds slip with updated expiration date

  >This patch adds a "Print hold/transfer" button to request.tt so staff can reprint hold/transfer slips without re-checking an item.
- [[29474]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29474) Automatic renewals cronjob is slow on systems with large numbers of reserves
- [[29553]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29553) Holds: Can't call method "notforloan" on an undefined value when placing a hold
- [[29704]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29704) Holds reminder emails should allow configuration for a specific number of days
- [[29976]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29976) (Bug 21729 followup) fix holds unit tests
- [[30085]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30085) Improve performance of CanItemBeReserved
- [[30207]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30207) Librarians with only "place_holds" permission can no longer update hold pickup locations
- [[30577]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30577) Item specific holds location can be missed when placing title level holds
- [[30693]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30693) Javascript broken on request.pl
- [[30710]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30710) Background tasks can be called multiple times on batch item deletion

### I18N/L10N

- [[29040]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29040) Uninitialized value warning in Languages.pm

  >This removes the cause of the warning message "Use of uninitialized value $interface in concatenation (.) or string at /kohadevbox/koha/C4/Languages.pm line 121." when editing item types.
- [[29585]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29585) "Go to field" in cataloguing alerts is not translatable

  >This fixes the 'Go to field' and 'Errors' strings in the basic MARC editor to make them translatable. (This is a follow-up to bug 28694 that changed the way validation error messages are displayed when using the basic MARC editor in cataloging.)
- [[29588]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29588) Yesterday and tomorrow in datepicker don't translate

  >This fixes "or", "Yesterday", "Today" and "Tomorrow" in the flatpickr date selector so they can be translated. (This was because __ was used when _ should have been used (__ is for .js files only)).
- [[29589]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29589) Translation issue with formatting in MARC overlay rules page

### Installation and upgrade (command-line installer)

- [[29813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29813) skeleton.pl missing semicolon
- [[30366]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30366) Warn when running automatic_item_modification_by_age.pl

### Installation and upgrade (web-based installer)

- [[29837]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29837) JS error during installer

### Lists

- [[29601]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29601) The list download option ISBD is useless when you cleared OPACISBD

### Notices

- [[17648]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17648) ACCTDETAILS notice doesn't show in the notices tab in staff
- [[29230]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29230) Patron's messages not accessible from template notices
- [[29557]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29557) Auto renew notices should handle failed renewal due to patron expiration

  >This enhancement updates the default auto-renewal notices to tell patrons that their renewals have failed because their account has expired.
- [[29943]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29943) Fix typo in notices yaml file
- [[30509]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30509) Accordion on letter.tt is broken

### OPAC

- [[17127]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17127) Can't hide MARC21 500 and others with NotesToHide

  >This fixes hiding notes fields (5XX in MARC21 and 3XX in UNIMARC) using NotesToHide. Before this you could hide one field and it worked. However, when hiding multiple fields one field would still always be visible. Now hiding notes fields works as expected.
- [[27627]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27627) Fix invalid HTML in OPAC results XSLT: change spans to divs
- [[29036]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29036) Accessibility: OPAC buttons don't have sufficient contrast

  >This improves the accessibility of the OPAC by increasing the contrast ratio for buttons, making the button text easier to read. 
  >
  >As part of this change the OPAC SCSS was modified so that a "base theme color" variable is defined which can be used to color button backgrounds and similar elements. It also moves some other colors into variables and removes some unused CSS.
- [[29320]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29320) Use OverDrive availability API V2
- [[29481]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29481) Terminology: Collection code
- [[29482]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29482) Terminology: This item belongs to another branch.

  >This replaces the word "branch" with the word "library" for a self-checkout message, as per the terminology guidelines.  ("This item belongs to another branch." changed to "This item belongs to another library".)
- [[29556]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29556) MARC21slim2MODS.xsl broken by duplicate template name "part"

  >This fixes an error when making an unAPI request in the OPAC using the MODS format. A 500 page error was displayed instead of an XML file. Example URL: http://your-library-opac-domain/cgi-bin/koha/unapi?id=koha:biblionumber:1&format=MODS
- [[29603]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29603) Fix responsive behavior of facets menu in OPAC search results
- [[29604]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29604) Term highlighting adds unwanted pseudo element in the contentblock of OPAC details page
- [[29611]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29611) Clubs enrollment layout problem in the OPAC

  >This fixes a minor HTML issue with the clubs enrollment form in the OPAC. The "Finish enrollment" button is now positioned correctly inside the bordered area and uses standard colors.
- [[29685]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29685) 'If all unavailable' state for 'on shelf holds' makes holds page very slow if there's a lot of items on opac
- [[29686]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29686) Adapt OverDrive for new fulfillment API
- [[29706]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29706) When placing a request on the opac, the user is shown titles they cannot place a hold on
- [[29795]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29795) If branch is mandatory on patron self registration form, the pull down should default to empty

  >Creates an empty value and defaults to it when PatronSelfRegistrationBorrowerMandatoryField includes branchcode. This forces self registering users to make a choice for the library.
- [[29802]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29802) biblionumber in OPACHiddenItems breaks opac lists
- [[29840]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29840) opac-reserve explodes if invalid biblionumber is passed
- [[30191]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30191) Authority search result list in the OPAC should use 'record' instead of 'biblios'
- [[30220]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30220) Purchase suggestion defaults to first library
- [[30244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30244) Hide lost items not respected in OPAC results XSLT
- [[30426]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30426) suggestion service missing Auth and Output imports
- [[30550]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30550) OPAC recalls page tries to use jQueryUI datepicker
- [[30613]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30613) Hide RSS feed link when viewing private list in the OPAC
- [[30688]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30688) Error in path to CSS background image
- [[30689]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30689) Incorrect Babeltheque setting can cause console warning

### Packaging

- [[26685]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26685) Move Starman out of debian/control.in and into cpanfile
- [[30252]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30252) lower version of 'Locale::XGettext::TT2' to 0.6

### Patrons

- [[22993]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22993) Messaging preferences not set for patrons imported through API
- [[27812]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27812) Remove the ability to transmit a patron's plain text password over email

  >This bugfix/enhancement improves the default security of Koha by removing the pass of the plain text password to the ACCTDETAILS notice on patron creation.
  >
  >WARNING: You will need to update your notice template if you were relying on `<<borrowers.password>>` in this notice.
- [[28576]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28576) Add patron image in patron detail section does not specify image size limit

  >This updates the add patron image screen to specify that the maximum image size is 2 MB. If it is larger, the patron image is not added.
- [[29576]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29576) Add street type to fields which can be copied from guarantor to guarantee
- [[30090]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30090) Don't export action buttons from patron results
- [[30098]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30098) Patron search redirects when one result on any page of results
- [[30175]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30175) Digest options not enabled when populating messaging preferences for a selected category during patron entry
- [[30177]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30177) When changing patron categories of existing accounts it should not reset message prefs without warning
- [[30214]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30214) Send WELCOME notice for new patrons added via self registration

  >This enhancement extends the 'AutoEmailOpacUser' feature to also send WELCOME notices to users who register via the opac self registration system.
- [[30404]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30404) Enlarge all patron searches pop-up
- [[30405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30405) Style of address in patron search result are 110%
- [[30485]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30485) Searching all patrons from the header does not display the patron search view
- [[30607]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30607) Enable 'Clear filter' option on DataTables Search for patron searches

### Plugin architecture

- [[25285]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25285) Wrong message when plugin required Koha version isn't met

### REST API

- [[29503]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29503) GET /patrons should use Koha::Patrons->search_limited
- [[29506]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29506) objects.search should call search_limited if present
- [[29508]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29508) GET /patrons/:patron_id should use Koha::Patrons->search_limited
- [[29593]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29593) Wrong tag in GET /public/libraries spec

  >This updates the tag in GET /public/libraries (api/v1/swagger/paths/libraries.json file) from library to libraries.
- [[29975]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29975) (Bug 21729 followup) patron_expiration_date missing in API
- [[30534]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30534) borrowers.guarantorid not present on database
- [[30536]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30536) Embeds should be defined in a single place

### Reports

- [[26269]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26269) Overdues: Download file doesn't match result in staff interface when due date filters or 'show any available items currently checked out' are used
- [[26669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26669) Last Run column not updated when report is run publicly (via CoverFlow or elsewhere)
- [[28977]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28977) Most-circulated items (cat_issues_top.pl) is failing with SQL Mode ONLY_FULL_GROUP_BY

  >This fixes an error that causes the most circulated items report to fail when run on a database with SQL mode ONLY_FULL_GROUP_BY and in strict SQL mode.
- [[29488]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29488) NumSavedReports system preference doesn't work

  >This fixes the saved reports page so that the NumSavedReports system preference works as intended - the number of reports listed should default to the value in the system preference (the initial default is 20).
- [[29530]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29530) When NumSavedReports is set, show value in pull down of entries

  >This updates the way the NumSavedReports preference value is used on the saved reports page. For the "Show" dropwdown list:
  >- it now displays the number set in NumSavedReports (previously it showed 20)
  >- when expanded it now shows the number set in NumSavedReports sequentially (for example, if NumSavedReports is 78, the menu options should be "10, 20, 50, 78, 100, All"), and
  >- it now displays 'All' if NumSavedReports is blank.
  >
  >It also updates the description for the NumSavedReports preference to clarify that all reports are shown when no value is entered.
- [[29679]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29679) Reports result menu shows too many dividers

  >This removes borders between sections that are not required. The SQL report batch operations dropdown menu has divider list items which add a border between sections (bibliographic records, item records, etc.). This element is redundant because the sections have "headers" which also add a border.
- [[29680]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29680) Reports menu 'Show SQL code' wrong border radius
- [[29729]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29729) If serials_stats.pl returns no results dataTables get angry
- [[30129]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30129) 500 error when search reports by date
- [[30282]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30282) Overdues report does not display subtitle and other information

### SIP2

- [[30118]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30118) holds_block_checkin behavior is different in Koha and in SIP

### Searching

- [[30740]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30740) Link to authorities 'used in' should not use equal

### Searching - Elasticsearch

- [[25616]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25616) Uppercase hard coded lower case boolean operators for Elasticsearch
- [[29077]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29077) Warns when searching blank index
- [[29436]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29436) Cannot reorder facets in staff interface elasticsearch configuration
- [[30142]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30142) ElasticSearch MARC mappings should not accept whitespaces

  **Sponsored by** *Steiermärkische Landesbibliothek*
- [[30153]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30153) FindDuplicate ElasticSearch should not use lowercase 'and'

  **Sponsored by** *Steiermärkische Landesbibliothek*

### Serials

- [[28216]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28216) Fix vendor list group by in serials statistics wizard

  >This fixes an issue where vendors are repeated in the serials report.
- [[29790]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29790) Deleting serial items fail without warning
- [[30035]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30035) Wrong month name in numbering pattern

  **Sponsored by** *Orex Digital*

  >Sponsored-by: Orex Digital
- [[30204]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30204) Add subtitle to serial subscription search

  >Adds the biblio.subtitle to the 'Title' column on serial-search.pl.
- [[30205]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30205) Add biblio.subtitle to the subscription-detail.pl page

  >Add the biblio.subtitle to the serial subscription details page.

### Staff Client

- [[29092]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29092) Table settings for account_fines table is missing Updated on column and hides the wrong things

  **Sponsored by** *Koha-Suomi Oy*
- [[29542]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29542) User with 'catalogue' permission can view everybody's (private) virtualshelves
- [[29903]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29903) Message deletion possible from different branch
- [[30164]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30164) Header filter not taken into account on the cities view
- [[30747]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30747) Column settings on otherholdings table in detail.tt doesnt work

### System Administration

- [[29591]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29591) Add autorenew_checkouts to BorrowerMandatory/Unwanted fields system preferences
- [[29875]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29875) Update text on MaxReserves system preference to describe functionality.
- [[30107]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30107) When editing a desk, the currently logged in library is selected

  >Corrects a problem on the administration page for circulation desks where the default library was always being set to the logged in library instead of the library of the desk.
- [[30597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30597) Update wording of RestrictionBlockRenewing to include auto-renew

### Templates

- [[11873]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11873) Upgrade jstree jQuery plugin to the latest version
- [[13142]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13142) Change "mobile phone" label back to "other phone"
- [[26102]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26102) Javascript injection in intranet search
- [[29513]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29513) Accessibility: Staff Client - Convert remaining breadcrumbs sections from div to nav blocks

  >This improves the accessibility of breadcrumbs so that they adhere to the WAI-ARIA Authoring Practices. It covers additional breadcrumbs that weren't fixed in bug 27486 in these areas: 
  >* Home > Acquisitions > [Vendor name > [Basket name]
  >* Home > Administration > Set library checkin and transfer policy
  >* Home > Patrons > Merge patron records
- [[29514]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29514) ILL requests: Remove extraneous &rsaquo; HTML entity from breadcrumbs

  >This fixes a small typo in the breadcrumbs section for ILL requests - it had an extra &rsaquo; HTML entity after "Home".
- [[29528]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29528) Breadcrumbs on HTML customizations take you to news

  >This change removes the "Additional contents" breadcrumb when working with news items or HTML customizations. Since news and HTML customizations are separate links on the tools home page there's no reason to have the breadcrumbs imply the two sections are connected in any way. We already have the "See News" link, for example, for switching quickly between the two areas.
- [[29529]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29529) Fix \n in hint on Koha to MARC mappings

  >This fixes:
  >- a string in Koha to MARC mappings (koha2marclinks.tt:86) so that it can be correctly translated (excludes "\n" from what is translated), and
  >- capitalization for the breadcrumb link: Administration > Koha to MARC mappings.
- [[29552]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29552) flatpickr quick shortcuts should be 'Disabled' for invalid dates
- [[29571]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29571) Mainpage : "All libraries" pending suggestions are visible only if the current library has suggestions

  >This fixes the display of pending suggestions in the staff interface so that it now shows pending suggestions for all libraries, for example: "Suggestions pending approval: Centerville: 0 / All libraries: 1.". Previously suggestions pending approval was only shown if there were suggestions for the user's current library.
- [[29580]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29580) Misplaced closing 'td' tag in overdue.tt
- [[29688]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29688) Incorrect use of _() in holds.js
- [[29735]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29735) Remove flatpickr instantiations from .js files
- [[29807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29807) Branches template plugin doesn't handle empty lists correctly

  >The Branches TT plugin had wrong logic in it, that made it crash, or display wrong pickup locations when the item/biblio didn't have any valid pickup location.
- [[29853]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29853) Text needs HTML filter before KohaSpan filter
- [[29932]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29932) Phase out jquery.cookie.js: bibs_selected (Browse selected records)
- [[29933]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29933) Fix stray usage of jquery.cookie.js plugin
- [[29940]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29940) Phase out jquery.cookie.js in the OPAC
- [[29967]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29967) Increase size of description fields for authorized values in templates

  >Extends the length of the description and OPAC description fields on authorised_values.tt making it easier to see and edit text that has longer descriptions.
- [[29989]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29989) Improve headings in MARC staging template
- [[30082]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30082) Bibliographic details tab missing when user can't add local cover image
- [[30422]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30422) Authorities editor update broke the feature added by Bug 20154
- [[30512]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30512) Staff interface search results template error
- [[30514]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30514) Error in date format check following datepicker removal
- [[30587]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30587) Incorrect translations in some templates
- [[30632]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30632) Fix report author display in list of saved reports

  >This fixes the display of report authors in the list of saved reports to remove the extra space before the comma (Lastname, Firstname was displaying as Lastname , Firstname).
- [[30640]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30640) Focus does not always move to correct search header form field
- [[30706]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30706) DateFormat change only takes effect after a restart of services
- [[30720]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30720) Batch delete links from result list missing permission checks
- [[30721]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30721) Markup error in detail page's component parts tab
- [[30722]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30722) Typo in overdue recalls template

### Test Suite

- [[29705]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29705) Test suite has some IssuingRules left-overs
- [[29826]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29826) Manage call of Template Plugin Branches GetName() with null or empty branchcode
- [[29838]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29838) No string interpolation when expected in t/db_dependent/ImportBatch.t
- [[29862]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29862) TestBuilder.t fails with ES enabled
- [[29884]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29884) Missing test in api/v1/patrons.t
- [[30203]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30203) Prevent data loss when running Circulation.t without prove
- [[30531]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30531) Search.t needs update for Recalls
- [[30595]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30595) update_child_to_adult.t is failing randomly
- [[30596]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30596) api/v1/acquisitions_baskets.t is failing randomly
- [[30734]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30734) t/db_dependent/Koha/BackgroundJob.t fails on D9 and D10

### Tools

- [[29156]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29156) File missing warning in Koha::UploadedFile should be for permanent files only

  >This removes the warning from the log files when temporarily uploaded files are deleted and the file no longer exists (for example, when the temporary files are in /tmp directory and the system is rebooted they are deleted).
- [[29521]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29521) Patron Club name hyperlinks not operational + weird CSS behavior

  >This removes the link from thea patron club name on the patrons club listing page as it didn't work. It also improves the consistency of the table of patron clubs so that the interface is consistent whether you're looking at clubs during the holds process or during the clubs management view.
- [[29693]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29693) CodeMirror broken on additional_contents.tt
- [[29722]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29722) Add some diversity to sample quotes

  **Sponsored by** *Catalyst*

  >This patch adds sample quotes from women, women of colour, trans women, Black and Indigenous women, and people who weren't US Presidents!
- [[29761]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29761) Patron batch modification tool - duplicated information on the listing page
- [[29797]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29797) Background job detail for batch delete items not listing the itemnumbers
- [[30701]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30701) On small screens, upload tool buttons cannot be clicked

  **Sponsored by** *Chartered Accountants Australia and New Zealand*
- [[30709]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30709) 'Insert' button in notices editor not adding selected placeholders to notice

### Web services

- [[22379]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22379) ILS-DI Method "CancelHold" don't check CanReserveBeCanceledFromOpac
- [[29484]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29484) ListSets doesn't return noSetHierarchy when appropriate

  >This fixes Koha's OAI-PMH server so that it returns the appropriate error code when no sets are defined.

### Z39.50 / SRU / OpenSearch Servers

- [[19865]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19865) Side scroll bar in z39.50 MARC view

  >Makes the horizontal scroll bar of the MARC preview modal on  cataloguing/z3950_search.tt always visible for an easier user experience.

## New system preferences
- AllowSetAutomaticRenewal
- AuthorityXSLTResultsDisplay
- EDIFACT
- EdifactLSQ
- EmailOverduesNoEmail
- EnableExpiredPasswordReset
- GenerateAuthorityField667
- GenerateAuthorityField670
- OPACMandatoryHoldDates
- OPACSuggestionAutoFill
- OpacAdvancedSearchTypes
- PatronSelfModificationMandatoryField
- RealTimeHoldsQueue
- RecallsLog
- RecallsMaxPickUpDelay
- RequireCashRegister
- RequirePaymentType
- SIP2SortBinMapping
- ShowHeadingUse
- StaffHighlightedWords
- TwoFactorAuthentication
- UseRecalls

## Renamed system preferences
- AutoEmailOpacUser renamed AutoEmailNewUser
- RecordIssuer renamed RecordStaffUserOnCheckout

## Deleted system preferences
- NumSavedReports
- OPACMySummaryNote
- OpacMoreSearches


## New Authorized value categories
- TYPEDOC


## New letter codes
 - 2FA_DEREGISTER
 - 2FA_DISABLE
 - 2FA_ENABLE
 - 2FA_REGISTER
 - PICKUP_RECALLED_ITEM
 - RECALL_REQUESTER_DET
 - RETURN_RECALLED_ITEM
 - STAFF_PASSWORD_RESET
 - WELCOME

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)



The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (79.5%)
- Armenian (95.1%)
- Armenian (Classical) (71.6%)
- Bulgarian (83.8%)
- Chinese (Taiwan) (77.6%)
- Czech (63.6%)
- English (New Zealand) (57.2%)
- English (USA)
- Finnish (90.2%)
- French (95.4%)
- French (Canada) (87.6%)
- German (100%)
- German (Switzerland) (55%)
- Greek (54.7%)
- Hindi (90.9%)
- Italian (92.9%)
- Nederlands-Nederland (Dutch-The Netherlands) (81%)
- Norwegian Bokmål (56.9%)
- Polish (89.2%)
- Portuguese (81.6%)
- Portuguese (Brazil) (77.3%)
- Russian (77.8%)
- Slovak (65.1%)
- Spanish (97.9%)
- Swedish (78.8%)
- Telugu (86.7%)
- Turkish (89.6%)
- Ukrainian (68.9%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 22.05.00 is


- Release Manager: Fridolin Somers

- Release Manager assistants:
  - Jonathan Druart
  - Martin Renvoize
  - Tomás Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - Andrew Nugged
  - Jonathan Druart
  - Joonas Kylmälä
  - Kyle M Hall
  - Marcel de Rooy
  - Martin Renvoize
  - Nick Clemens
  - Petro Vashchuk
  - Tomás Cohen Arazi
  - Victor Grousset

- Topic Experts:
  - UI Design -- Owen Leonard
  - REST API -- Tomás Cohen Arazi
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize

- Bug Wranglers:
  - Indranil Das Gupta
  - Erica Rohlfs

- Packaging Manager: 


- Documentation Manager: David Nind


- Documentation Team:
  - Aude Charillon
  - Caroline Cyr La Rose
  - Kelly McElligott
  - Lucy Vaux-Harvey
  - Martin Renvoize
  - Rocio Lopez

- Translation Managers: 
  - Bernardo González Kriegel

- Wiki curators: 
  - Thomas Dukleth

- Release Maintainers:
  - 21.11 -- Kyle M Hall
  - 21.05 -- Andrew Fuerste-Henry
  - 20.11 -- Victor Grousset
  - 19.11 -- Wainui Witika-Park

## Credits
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 22.05.00

- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)
- [ByWater Solutions](https://bywatersolutions.com)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Chartered Accountants Australia and New Zealand
- Cheshire Libraries Shared Services
- Education Services Australia SCIS
- Educational Services Australia SCIS
- Gothenburg University Library
- Horowhenua District Council, New Zealand
- Koha-Suomi Oy
- Lund University Library
- Montgomery County Public Libraries
- Orex Digital
- Reformational Study Centre
- Steiermärkische Landesbibliothek
- Universidad Nacional de San Martín
- [University Lyon 3](https://www.univ-lyon3.fr)

We thank the following individuals who contributed patches to Koha 22.05.00

- Salman Ali (1)
- Aleisha Amohia (54)
- Tomás Cohen Arazi (234)
- Philippe Blouin (5)
- Henry Bolshaw (1)
- Florian Bontemps (3)
- Jérémy Breuillard (2)
- Alex Buckley (14)
- Rudolf Byker (1)
- Colin Campbell (1)
- Kevin Carnes (2)
- Nick Clemens (131)
- David Cook (6)
- Chris Cormack (1)
- Roch D'Amour (1)
- Jake Deery (1)
- Jonathan Druart (311)
- Marion Durand (8)
- Magnus Enger (1)
- Katrin Fischer (37)
- Andrew Fuerste-Henry (2)
- Lucas Gass (44)
- Didier Gautheron (3)
- Victor Grousset (4)
- Thibaud Guillot (3)
- David Gustafsson (2)
- Michael Hafen (2)
- Kyle M Hall (27)
- Andrew Isherwood (2)
- Mason James (9)
- Andreas Jonsson (1)
- Janusz Kaczmarek (2)
- Pasi Kallinen (1)
- Thomas Klausner (2)
- Bernardo González Kriegel (14)
- Joonas Kylmälä (7)
- Nicolas Legrand (1)
- Owen Leonard (153)
- Ava Li (1)
- The Minh Luong (2)
- Ere Maijala (1)
- Julian Maurice (13)
- Matthias Meusburger (2)
- Andrew Nugged (3)
- Björn Nylén (1)
- Hayley Pelham (1)
- Martin Renvoize (138)
- Marcel de Rooy (96)
- Caroline Cyr La Rose (3)
- Andreas Roussos (3)
- David Schmidt (1)
- Fridolin Somers (190)
- Martin Stenberg (1)
- Adam Styles (3)
- Arthur Suzuki (3)
- Emmi Takkinen (1)
- Lari Taskula (2)
- Lyon 3 Team (1)
- Mark Tompsett (1)
- Petro Vashchuk (6)
- Timothy Alexis Vass (1)
- George Veranis (3)
- Shi Yao Wang (6)
- Wainui Witika-Park (17)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.05.00

- Athens County Public Libraries (153)
- BibLibre (227)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (37)
- Bibliothèque Universitaire des Langues et Civilisations (BULAC) (1)
- BigBallOfWax (1)
- ByWater-Solutions (204)
- Catalyst (32)
- Catalyst Open Source Academy (54)
- Dataly Tech (6)
- esa.edu.au (3)
- gmx.at (1)
- Hypernova Oy (2)
- Independant Individuals (26)
- Koha Community Developers (315)
- Koha-Suomi (2)
- KohaAloha (9)
- Kreablo AB (1)
- Libriotech (1)
- Prosentient Systems (6)
- PTFS-Europe (142)
- Rijksmuseum (96)
- Solutions inLibro inc (18)
- Theke Solutions (234)
- ub.lu.se (4)
- UK Parliament (1)
- Universidad Nacional de Córdoba (14)
- University of Helsinki (2)
- Université Jean Moulin Lyon 3 (1)
- xinxidi.net (1)

We also especially thank the following individuals who tested patches
for Koha

- Aleisha Amohia (3)
- Tomás Cohen Arazi (189)
- Marjorie Barry-Vila (1)
- Bob Bennhoff (10)
- Florian Bontemps (7)
- Sonia Bouis (4)
- Christopher Brannon (1)
- Jérémy Breuillard (2)
- Felicity Brown (1)
- Emmanuel Bétemps (2)
- Nick Clemens (162)
- Rebecca Coert (2)
- David Cook (6)
- Chris Cormack (3)
- Ben Daeuber (3)
- Michal Denar (23)
- Solène Desvaux (2)
- Jonathan Druart (270)
- Eugene Espinoza (1)
- Jonathan Field (2)
- Katrin Fischer (340)
- Andrew Fuerste-Henry (83)
- Lucas Gass (78)
- Victor Grousset (16)
- Thibaud Guillot (3)
- Amit Gupta (1)
- hakam (1)
- Kyle M Hall (74)
- Stina Hallin (1)
- Frank Hansen (3)
- Sally Healey (11)
- Samu Heiskanen (7)
- Jo Hunter (2)
- Mason James (6)
- Jessica (1)
- Barbara Johnson (21)
- Jose-Mario (1)
- Mazen Khallaf (8)
- Bernardo González Kriegel (1)
- Rhonda Kuiper (1)
- Joonas Kylmälä (7)
- Nicolas Legrand (1)
- Owen Leonard (135)
- The Minh Luong (4)
- ManuB (1)
- Marjorie (1)
- Julian Maurice (1)
- kelly mcelligott (1)
- Kelly McElligott (3)
- David Nind (210)
- Hayley Pelham (4)
- Séverine Queune (71)
- Johanna Raisa (1)
- Laurence Rault (1)
- Martin Renvoize (451)
- Alexis Ripetti (1)
- Marcel de Rooy (134)
- Caroline Cyr La Rose (1)
- Andreas Roussos (3)
- Lisette Scheer (1)
- Fridolin Somers (1400)
- Christian Stelzenmüller (3)
- Michael Sutherland (1)
- Arthur Suzuki (7)
- Emmi Takkinen (1)
- Theodoros Theodoropoulos (1)
- Mark Tompsett (2)
- Petro Vashchuk (2)
- Shi Yao Wang (4)
- George Williams (1)
- Jessie Zairo (1)


And people who contributed to the Koha manual during the release cycle of Koha 22.05.00

- Aude Charillon (6)
- Caroline Cyr La Rose (14)
- David Nind (4)
- Martin Renvoize (4)
- Lucy Vaux-Harvey (1)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is master.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 26 May 2022 07:06:40.
