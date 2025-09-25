# RELEASE NOTES FOR KOHA 24.11.09
25 Sep 2025

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 24.11.09 can be downloaded from:

- [Download](https://download.koha-community.org/koha-24.11.09.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.11.09 is a bugfix/maintenance release with security bugs.

It includes 5 enhancements, 41 bugfixes (2 security).

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [40748](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40748) Remote-Code-Execution (RCE) in update_social_data.pl
- [40766](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40766) Reflected XSS in set-library.pl

## Bugfixes

### About

#### Other bugs fixed

- [40466](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40466) Zebra status misleading in "Server information" tab.

### Accessibility

#### Other bugs fixed

- [39998](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39998) Missing presentation role on layout tables.

### Acquisitions

#### Other bugs fixed

- [36155](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36155) Improve performance of suggestion.pl when there are many budgets
- [39914](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39914) Can't use table export function on late orders
  >This fixes the export option for the acquisition's late orders table (Acquisitions > Late orders). Export now works as expected - previously, a progress spinner was shown and the table data was not exported.

### Architecture, internals, and plumbing

#### Other bugs fixed

- [40132](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40132) Remove some POD from Koha/Template/Plugin/AdditionalContents.pm
- [40516](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40516) Boolean filters are broken on datatables

### Cataloging

#### Critical bugs fixed

- [40544](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40544) Manage bundle button broken
  >Fixes the "Manage bundle" feature broken by Bug 40127

#### Other bugs fixed

- [40156](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40156) Advanced editor should not create empty fields and subfields

  **Sponsored by** *Ignatianum University in Cracow*

### Circulation

#### Critical bugs fixed

- [40296](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40296) Bookings that are checked out do not have status updated to completed

#### Other bugs fixed

- [39180](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39180) Handle and report exception at checkout/checkin due to missing guarantor
  >This fixes checking out, checking in, and renewing items for a patron where a guarantor is required, and they don't have one (where the ChildNeedsGuarantor system preference is enabled).
  >
  >These actions are now completed correctly, and a warning message is now shown on the patron's page where a guarantor is required and they don't have one: "System preference 'ChildNeedsGuarantor' is enabled and this patron does not have a guarantor.".
  >
  >Previously:
  >- checking items in or out generated a 500 error message, even though the actions were successfully completed
  >- attempting to renew items generated this message "Error: Internal Server Error" and the items were not renewed
  >- no message was shown on the patron page warning that they needed a guarantor

### ERM

#### Critical bugs fixed

- [40198](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40198) Datatables search for data providers is broken

### Hold requests

#### Critical bugs fixed

- [40654](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40654) Sorting holds table can cause priority issues
  >This patchset fixes a problem where hold priority could be incorrectly updated depending on how the table is sorted on reserve/request.tt.

#### Other bugs fixed

- [38412](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38412) Koha should warn when hold on bibliographic record requires hold policy override

  **Sponsored by** *BibLibre* and *Westlake Porter Public Library*
- [40530](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40530) Show hold cancellation reason in patron holds history
  >This fixes the status message when a hold is cancelled on the patron's holds history page in the staff interface. It displayed "Cancelled(FIXME)", instead of the actual reason. (This is related to bug 35560 - Use the REST API for holds history, added in Koha 25.05.00 and 24.11.05.)

### I18N/L10N

#### Other bugs fixed

- [33856](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33856) Inventory tool CSV export contains untranslatable strings

### Lists

#### Other bugs fixed

- [39427](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39427) Searching lists table by owner can only enter firstname or surname
- [40488](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40488) "Public lists" breadcrumb link doesn't work when editing public list in staff interface
  >Fixes breadcrumb link when editing public lists in staff interface.

  **Sponsored by** *Athens County Public Libraries*

### Notices

#### Other bugs fixed

- [39279](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39279) Terminology:  Please return or renew them at the branch below as soon as possible.
  >This fixes the terminology used in the overdue notice (ODUE) to change 'branch' to 'library': "Please return or renew your overdue items at the library as soon as possible.".
  >
  >Note: The notice is not automatically updated for existing installations. Update the notice manually to change the wording if required, or replace the default notice using "View default" and "Copy to template" if you have not customized the notice.

### OPAC

#### Other bugs fixed

- [40540](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40540) OPAC generates warnings in logs when no results are found

  **Sponsored by** *Ignatianum University in Cracow*
- [40590](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40590) OPACAuthorIdentifiersAndInformation shows empty list elements for unknown 024$2

  **Sponsored by** *Athens County Public Libraries*

### Patrons

#### Other bugs fixed

- [40321](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40321) DataTables search ( dt-search ) does not work on holds history page
- [40459](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40459) Preferred name is lost when editing partial record
- [40469](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40469) Reword anonymous_refund permission description

### SIP2

#### Other bugs fixed

- [40270](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40270) Remove useless warnings on failed SIP2 login

### Searching

#### Other bugs fixed

- [39896](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39896) System preference AuthorLinkSortBy is not working for UNIMARC or custom XSLT
  >This fixes the default UNIMARC XSLT files so that the AuthorLinkSortBy and AuthorLinkSortOrder system preferences now work with UNIMARC, not just MARC21. 
  >
  >A note was also added to the system preference for those that use custom XSLT (for OPACXSLTDetailsDisplay, OPACXSLTResultsDisplay, XSLTDetailsDisplay, and XSLTResultsDisplay) - they need to update their templates to support these features for both MARC21 and UNIMARC.
  >
  >(These preferences were added in Koha 23.11 by Bug 33217 - Allow different default sorting when click author links, but only the default XSLT files for MARC21 were updated.)

### Staff interface

#### Other bugs fixed

- [39712](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39712) Query parameters break the manual mappings in vue modules
- [40081](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40081) textareas appear to now be fixed width
  >This fixes OPAC and staff interface forms with text area fields. You can now adjust the size both vertically and horizontally - after the Bootstrap 5 upgrade you could only adjust the size vertically. (This is related to the OPAC and staff interface Bootstrap 5 upgrade in Koha 24.11.)

  **Sponsored by** *Athens County Public Libraries*
- [40121](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40121) library and category not selected on the patron search
- [40298](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40298) A select2 in a bootstrap modal, like in the patron card batch patron search modal, needs it's parent defined
- [40647](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40647) "dictionary" misspelled in rep_dictonary class
  >This fixes a spelling error in the class name on the reports home page in the staff interface: "rep_dictonary" to "rep_dictionary".

### System Administration

#### Other bugs fixed

- [40114](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40114) Can't select new library when editing a desk
  >This patch fixes a problem that made it impossible to select a new library/branch when editing a desk from Administration -> Desks.

  **Sponsored by** *Athens County Public Libraries*
- [40547](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40547) Unable to view background job if enable_plugins is 0

### Templates

#### Other bugs fixed

- [38964](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=38964) Fix column span in footer of staff interface account payment page
  >This fixes an alignment problem on the 'Make a payment' screen where the table footer had an inconsistent number of columns.

  **Sponsored by** *Athens County Public Libraries*
- [40222](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40222) Bootstrap popover components not updated for BS5

  **Sponsored by** *Athens County Public Libraries*
- [40413](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40413) Patron list input missing "Required" label

  **Sponsored by** *Athens County Public Libraries*
- [40451](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40451) Link patron restriction types to correct section in manual

  **Sponsored by** *Athens County Public Libraries*

### Test Suite

#### Other bugs fixed

- [40490](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40490) Warnings from GD::Barcode::QRcode on U24

### Tools

#### Other bugs fixed

- [31930](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31930) Ignore whitespace before and after barcodes when adding items to rotating collections
  >This fixes adding or removing items to a rotating collection (Tools > Patrons and circulation > Rotating collections). If a barcode has a space before it, it is now ignored instead of generating an error message.
- [40549](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40549) Warnings generated when using Import Patrons tool

## Enhancements 

### About

#### Enhancements

- [34783](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34783) Update list of 'Contributing companies and institutions' on about page

### Acquisitions

#### Enhancements

- [34127](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34127) Allow to customize CSV export of basketgroup and add a ODS export
  >It is now possible to export any basket to CSV, even the closed ones or those linked to a group.

### Cataloging

#### Enhancements

- [37604](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37604) Give skip_open_orders checkbox an ID in batch record deletion template
  >This enhancement adds an ID to the "Skip bibliographic records with open acquisition orders" checkbox on the batch record deletion page (Cataloging > Batch editing > Batch record deletion").
  >
  >This is required so that when selecting or unselecting the checkbox, the focus remains on the checkbox. The ID semantically links the checkbox to its label so machines (screenreaders and computers) can tell they are related elements.

### Circulation

#### Enhancements

- [39923](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=39923) Add classes to email and phone in overdue report to allow for customization
  >This patches adds a overdue_email and overdue_phone to the overdue report making it easier to target the phone/email with CSS or JavaScript.

  **Sponsored by** *Athens County Public Libraries*

### REST API

#### Enhancements

- [40542](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=40542) Add `cancellation_reason` to holds strings embed

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/24.11/en/html/)
- [French](https://koha-community.org/manual/24.11/fr/html/) (75%)
- [German](https://koha-community.org/manual/24.11/de/html/) (95%)
- [Greek](https://koha-community.org/manual/24.11/el/html/) (95%)
- [Hindi](https://koha-community.org/manual/24.11/hi/html/) (67%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (95%)
- Armenian (hy_ARMN) (99%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (86%)
- Chinese (Traditional Han script) (99%)
- Czech (68%)
- Dutch (88%)
- English (100%)
- English (New Zealand) (63%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (99%)
- German (99%)
- Greek (67%)
- Hindi (97%)
- Italian (82%)
- Norwegian Bokmål (74%)
- Persian (fa_ARAB) (96%)
- Polish (99%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (94%)
- Slovak (61%)
- Spanish (99%)
- Swedish (87%)
- Telugu (68%)
- Tetum (52%)
- Turkish (83%)
- Ukrainian (73%)
- Western Armenian (hyw_ARMN) (62%)
</div>

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 24.11.09 is


- Release Manager: Lucas Gass

- QA Manager: Martin Renvoize

- QA Team:
  - Andrew Fuerste-Henry
  - Andrii Nugged
  - Baptiste Wojtkowski
  - Brendan Lawlor
  - David Cook
  - Emily Lamancusa
  - Jonathan Druart
  - Julian Maurice
  - Kyle Hall
  - Laura Escamilla
  - Lisette Scheer
  - Marcel de Rooy
  - Nick Clemens
  - Paul Derscheid
  - Petro V
  - Tomás Cohen Arazi
  - Victor Grousset

- Documentation Manager: David Nind

- Documentation Team:
  - Aude Charillon
  - Caroline Cyr La Rose
  - Donna Bachowski
  - Heather Hernandez
  - Kristi Krueger
  - Philip Orr

- Translation Manager: Jonathan Druart


- Wiki curators: 
  - George Williams
  - Thomas Dukleth

- Release Maintainers:
  - 25.05 -- Paul Derscheid
  - 24.11 -- Fridolin Somers
  - 24.05 -- Jesse Maseto
  - 22.11 -- Catalyst IT (Wainui, Alex, Aleisha)

- Release Maintainer assistants:
  - 25.05 -- Martin Renvoize
  - 24.11 -- Baptiste Wojtkowski
  - 24.05 -- Laura Escamilla

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 24.11.09
<div style="column-count: 2;">

- Athens County Public Libraries
- [BibLibre](https://www.biblibre.com)
- Ignatianum University in Cracow
- [Westlake Porter Public Library](https://westlakelibrary.org)
</div>

We thank the following individuals who contributed patches to Koha 24.11.09
<div style="column-count: 2;">

- Tomás Cohen Arazi (4)
- Matt Blenkinsop (1)
- Courtney Brown (1)
- Nick Clemens (4)
- David Cook (2)
- Jake Deery (1)
- Paul Derscheid (1)
- Jonathan Druart (14)
- Marion Durand (1)
- Laura Escamilla (1)
- Katrin Fischer (1)
- David Flater (1)
- Lucas Gass (4)
- Michael Hafen (1)
- Kyle M Hall (1)
- Andrew Fuerste Henry (2)
- Janusz Kaczmarek (3)
- Emily Lamancusa (1)
- Owen Leonard (9)
- CJ Lynce (1)
- nina martinez (1)
- David Nind (1)
- Aman Pilgrim (1)
- Martin Renvoize (2)
- Marcel de Rooy (2)
- Fridolin Somers (3)
- Arthur Suzuki (1)
- Imani Thomas (1)
- Yvonne Waterman (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.11.09
<div style="column-count: 2;">

- Athens County Public Libraries (9)
- [BibLibre](https://www.biblibre.com) (6)
- [Bibliotheksservice-Zentrum Baden-Württemberg (BSZ)](https://bsz-bw.de) (1)
- [ByWater Solutions](https://bywatersolutions.com) (13)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (1)
- ctalyst.net.nz (1)
- David Nind (1)
- Independant Individuals (6)
- Koha Community Developers (14)
- [LMSCloud](https://www.lmscloud.de) (1)
- [Montgomery County Public Libraries](https://montgomerycountymd.gov) (1)
- [Open Fifth](https://openfifth.co.uk/) (4)
- [Prosentient Systems](https://www.prosentient.com.au) (2)
- Rijksmuseum, Netherlands (2)
- [Theke Solutions](https://theke.io) (4)
- westlakelibrary.org (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (1)
- Pedro Amorim (3)
- Tomás Cohen Arazi (3)
- Wojciech Baran (1)
- Aude Charillon (4)
- Nick Clemens (12)
- David Cook (6)
- Jake Deery (1)
- Paul Derscheid (56)
- Roman Dolny (5)
- Jonathan Druart (4)
- Marion Durand (1)
- Laura Escamilla (6)
- Katrin Fischer (4)
- David Flater (4)
- Lucas Gass (54)
- Kyle M Hall (2)
- Emily Lamancusa (5)
- Sam Lau (1)
- Brendan Lawlor (2)
- Owen Leonard (3)
- CJ Lynce (1)
- Michaela (2)
- David Nind (17)
- Martin Renvoize (1)
- Phil Ringnalda (1)
- Marcel de Rooy (11)
- Caroline Cyr La Rose (2)
- Fridolin Somers (61)
- Dominique et Stephanie (1)
- Baptiste Wojtkowski (5)
-  Anneli Österman (1)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 24.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 25 Sep 2025 14:49:50.
