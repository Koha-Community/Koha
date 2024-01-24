# RELEASE NOTES FOR KOHA 23.05.08
24 Jan 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 23.05.08 can be downloaded from:

- [Download](http://download.koha-community.org/koha-23.05.08.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.05.08 is a bugfix/maintenance release.

It includes 38 bugfixes and 1 security bugfix.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).

#### Security bugs
- [34893](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34893) ILS-DI can return the wrong patron for AuthenticatePatron

## Bugfixes

### Architecture, internals, and plumbing

#### Other bugs fixed

- [35309](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35309) Remove DT's fnSetFilteringDelay
- [35405](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35405) MarcAuthorities: Use of uninitialized value $tag in hash element at MARC/Record.pm line 202.
- [35491](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35491) Reverting waiting status for holds is not logged
- [35629](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35629) Redundant code in includes/patron-search.inc

### Circulation

#### Critical bugs fixed

- [33847](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33847) Database update replaces undefined rules with defaults rather than the value that would be used

#### Other bugs fixed

- [35310](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35310) Current renewals 'view' link doesnt work if renewals correspond to an item no longer checked out
  >This fixes the current renewals information (shown under the statuses section) on the item page for records in the staff interface so that:
  >1. The current renewals row is only now shown if there are current renewals for the item (previously it was shown for all items, even if they had no renewals).
  >2. It only shows the number of current renewals for the current check out (previously the number shown would include all renewals, including for previous check-outs).
- [35587](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35587) Items lose their lost status when check-in triggers a transfer even though BlockReturnOfLostItems is enabled

  **Sponsored by** *Pymble Ladies' College*
- [35600](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35600) Prevent checkouts table to flicker

### Hold requests

#### Critical bugs fixed

- [35489](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35489) Holds on items with no barcode are missing an input for itemnumber

### I18N/L10N

#### Other bugs fixed

- [34900](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34900) The translation of the string "The " should depend on context
- [35567](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35567) Host-item in "Show analytics" link can be translated

### Installation and upgrade (command-line installer)

#### Other bugs fixed

- [35698](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35698) Wrong bug number in db_revs/220600084.pl

### Lists

#### Other bugs fixed

- [35547](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35547) When using "Add to a list" button with more than 10 lists, "staff only" does not show up

### Notices

#### Other bugs fixed

- [30287](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30287) Notices using HTML render differently in notices.pl
  >This fixes notice previews for patrons in the staff interface (Patrons > [Patron account] > Notices), where HTML is used in the email notices. For example, previously if <br>s were used then the preview would match the email sent, however, using <p>s would add extra lines in the preview.

### OPAC

#### Other bugs fixed

- [35488](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35488) Placing a hold on the OPAC takes the user to their account page, but does not activate the holds tab
- [35492](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35492) Suspending/unsuspending a hold on the OPAC takes the user to their account page, but does not activate the holds tab
- [35495](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35495) Cancelling a hold on the OPAC takes the user to their account page, but does not activate the holds tab
- [35496](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35496) Placing an article request on the OPAC takes the user to their account page, but does not activate the article request tab

### Packaging

#### Other bugs fixed

- [35713](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35713) Remove debian/docs/LEEME.Debian

### Patrons

#### Other bugs fixed

- [25835](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25835) Include overdue report (under circulation module) as a staff permission
- [35493](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35493) Housebound roles show as a collapsed field option when checked in CollapseFieldsPatronAddForm, even if housebound is off

### Plugin architecture

#### Other bugs fixed

- [35070](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35070) Koha plugins implementing "background_jobs" hook can't provide view template

### REST API

#### Critical bugs fixed

- [35204](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35204) REST API: POST endpoint /auth/password/validation dies on patron with expired password
- [35658](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35658) Typo in /patrons/:patron_id/holds

#### Other bugs fixed

- [32551](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32551) API requests don't carry language related information

### Reports

#### Other bugs fixed

- [35498](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35498) SQL auto-complete should not prevent use of tab for spacing

### Searching - Zebra

#### Other bugs fixed

- [35455](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35455) ICU does not strip = when indexing/searching
  >This change fixes an issue with Zebra ICU searching where titles with colons aren't properly searchable, especially when used with Analytics.
  >
  >A full re-index of Zebra is needed for this change to take effect.

### Serials

#### Other bugs fixed

- [28012](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28012) Error on saving new numbering pattern
  >This fixes the serials new numbering pattern input form so that the name and numbering formula fields are marked as required. Before this, there was no indication that these fields were required and error trace messages were displayed if these were not completed - saving a new pattern or editing an existing pattern would also silently fail.
  >
  >NOTE: Making the description field optional will be fixed in bug 31297. Until this is done, a value needs to be entered into this field - even though it doesn't indicate that it is required.
- [31297](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31297) Cannot add new subscription patterns from edit subscription page

### Staff interface

#### Other bugs fixed

- [35619](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35619) Change password form in patron account has misaligned validation errors

### System Administration

#### Other bugs fixed

- [31694](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31694) MARC overlay rules presets don't change anything if presets are translated
- [34644](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34644) Add clarifying text to sysprefs to indicate that MarcFieldsToOrder is a fallback to MarcItemFieldsToOrder
  >This updates the descriptions for system preferences MarcFieldsToOrder and MarcItemFieldsToOrder.

### Templates

#### Other bugs fixed

- [35557](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35557) LoadResultsCovers is not used (staff)

### Test Suite

#### Other bugs fixed

- [35598](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35598) selenium/authentication_2fa.t is still failing randomly

### Tools

#### Critical bugs fixed

- [35696](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35696) Transit status not properly updated for items advanced in Stock Rotation tool

#### Other bugs fixed

- [35579](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35579) marcrecord2csv searches authorised values inefficiently
  >This significantly improves the speed of downloading large lists in CSV format. (It adds a get_descriptions_by_marc_field" method which caches AuthorisedValue descriptions when searched by MARC field, which is used when exporting MARC to CSV.)
- [35588](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35588) marcrecord2csv retrieves authorised values incorrectly for fields
  >This fixes the CSV export of records so that authorized values are exported correctly. It ensures that the authorized value descriptions looked up are for the correct field/subfield designated in the CSV profile. Example: If the 942$s (Serial record flag) for a record has a value of "1", it was previously exported as "Yes" even though it wasn't an authorized value.

### translate.koha-community.org

#### Critical bugs fixed

- [35428](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35428) gulp po tasks do not clean temporary files

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 23.05.08 is


- Release Manager: 

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 23.05.08
<div style="column-count: 2;">

- Pymble Ladies' College
</div>

We thank the following individuals who contributed patches to Koha 23.05.08
<div style="column-count: 2;">

- Aleisha Amohia (1)
- Pedro Amorim (5)
- Tomás Cohen Arazi (5)
- Matt Blenkinsop (3)
- Kevin Carnes (2)
- Nick Clemens (4)
- David Cook (5)
- Jonathan Druart (6)
- Katrin Fischer (4)
- Lucas Gass (8)
- Victor Grousset (1)
- Kyle M Hall (8)
- Andrew Fuerste Henry (1)
- Joonas Kylmälä (2)
- Owen Leonard (4)
- Julian Maurice (6)
- David Nind (2)
- Martin Renvoize (5)
- Marcel de Rooy (1)
- Caroline Cyr La Rose (1)
- Shi Yao Wang (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.05.08
<div style="column-count: 2;">

- Athens County Public Libraries (4)
- BibLibre (6)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (4)
- ByWater-Solutions (20)
- Catalyst Open Source Academy (1)
- David Nind (2)
- dubcolib.org (1)
- Independant Individuals (2)
- Koha Community Developers (7)
- Prosentient Systems (5)
- PTFS-Europe (13)
- Rijksmuseum (1)
- Solutions inLibro inc (2)
- Theke Solutions (5)
- ub.lu.se (2)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Pedro Amorim (1)
- Tomás Cohen Arazi (12)
- Kevin Carnes (1)
- Nick Clemens (5)
- Jonathan Druart (5)
- Esther (1)
- Katrin Fischer (64)
- Andrew Fuerste-Henry (4)
- Lucas Gass (72)
- Victor Grousset (12)
- Kyle M Hall (1)
- Jan Kissig (4)
- Emily Lamancusa (2)
- Owen Leonard (3)
- Mikko Liimatainen (1)
- Julian Maurice (9)
- Kelly McElligott (1)
- David Nind (33)
- Martin Renvoize (9)
- Marcel de Rooy (7)
- sabrina (1)
- Fridolin Somers (66)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is (HEAD detached from 1030b6f971).

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 24 Jan 2024 18:03:45.
