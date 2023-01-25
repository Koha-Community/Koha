# RELEASE NOTES FOR KOHA 22.11.02
25 Jan 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.11.02 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.11.02.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.11.02 is a bugfix/maintenance release.

It includes 3 enhancements, 37 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha [here](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).




## Enhancements

### Staff interface

- [[32173]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32173) Add count of total titles in list to staff client view

### Templates

- [[32095]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32095) Remove bullets from statuses in inventory tool
- [[32319]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32319) Give header search submit button more padding


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[32481]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32481) Rabbit times out when too many jobs are queued and the response takes too long

### Cataloging

- [[32550]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32550) 'Clear on loan' link on Batch item modification doesn't untick on loan items

### OPAC

- [[32445]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32445) Status display of 'not for loan' items is broken in OPAC/staff

### Packaging

- [[32666]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32666) Automatic debian/control updates (stable)

### Staff interface

- [[31935]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31935) Serials subscription form is misaligned

  >This fixes the alignment of the serials subscription form.
- [[32517]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32517) Patron search dies on case mismatch of patron category

  >This fixes patron search so that searching by category will work regardless of the patron category code case (upper, lower, and sentence case). Before this, category codes in upper case were expected - where they weren't this caused the search to fail, resulting in no search results.

### Tools

- [[32054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32054) GetImportRecordMatches returns the wrong match when passed 'best only'


## Other bugs fixed

### Acquisitions

- [[32531]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32531) Filter 'Include archived' no longer shows non-archived suggestions

### Architecture, internals, and plumbing

- [[32465]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32465) koha-worker debian script missing 'queue' in help

  >This adds information about the --queue option to the help text for the koha-worker script.
- [[32528]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32528) Koha::Item->safe_to_delete should short-circuit earlier
- [[32529]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32529) Holds in processing should block item deletion
- [[32582]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32582) Mailmap maps to wrong email address

### Circulation

- [[14784]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14784) Missing checkin message for debarred patrons when issuing rules 'fine days = 0'
- [[31233]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31233) Fine grace period in circulation conditions is misnamed

### Fines and fees

- [[22042]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22042) BlockReturnofWithdrawn Items does not block refund generation when item is withdrawn and lost

### MARC Bibliographic data support

- [[23032]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23032) Add 264 to Alternate Graphic Representation (MARC21 880)

### OPAC

- [[32597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32597) Article requests not stacking in patron view

### Patrons

- [[31492]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31492) Patron image upload fails on first attempt with CSRF failure
- [[32491]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32491) Can no longer search patrons in format 'surname, firstname'
- [[32505]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32505) Cannot search by dateofbirth in specified dateformat

### Staff interface

- [[31950]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31950) Page section on library view is too wide / not aligned with toolbar
- [[32272]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32272) Last borrower and previous borrower display on moredetail.pl is broken
- [[32475]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32475) The phrase "System prefs" should be replaced with the correct terminology "System preferences"
- [[32596]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32596) Background jobs viewer not showing finished jobs

### System Administration

- [[30694]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30694) Impossible to delete line in circulation and fine rules

  **Sponsored by** *Koha-Suomi Oy*
- [[32535]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32535) BorrowerUnwantedField syspref should not include borrowers.flags

### Templates

- [[32348]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32348) Library public is missing from columns settings
- [[32400]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32400) Add page-section to tables for end of year rollover (acq)
- [[32616]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32616) Add 'page-section' to various acquisitions pages
- [[32628]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32628) Add 'page-section' to various serials pages
- [[32632]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32632) Add 'page-section' to some tools pages

### Test Suite

- [[28670]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28670) api/v1/patrons_holds.t is failing randomly
- [[32349]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32349) Remove TEST_QA
- [[32622]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32622) Auth.t failing on D10
- [[32650]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32650) Koha/Holds.t is failing randomly

### Tools

- [[32255]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32255) Cannot use file upload in batch record modification
- [[32456]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32456) Date accessioned is now cleared when items are replaced



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)



The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (73.6%)
- Armenian (100%)
- Bulgarian (93.1%)
- Chinese (Taiwan) (83.9%)
- Czech (59.3%)
- English (New Zealand) (60%)
- English (USA)
- Finnish (96.1%)
- French (97.8%)
- French (Canada) (94.8%)
- German (100%)
- German (Switzerland) (51.1%)
- Greek (50.8%)
- Hindi (100%)
- Italian (94.5%)
- Nederlands-Nederland (Dutch-The Netherlands) (77.9%)
- Norwegian Bokmål (53.1%)
- Persian (58.9%)
- Polish (93.6%)
- Portuguese (74.9%)
- Portuguese (Brazil) (72.4%)
- Russian (83.7%)
- Slovak (60.2%)
- Spanish (100%)
- Swedish (77%)
- Telugu (79.6%)
- Turkish (88.5%)
- Ukrainian (77.8%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 22.11.02 is


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

- Packaging Manager:


- Documentation Manager: Caroline Cyr La Rose


- Documentation Team:
  - Aude Charillon
  - David Nind
  - Lucy Vaux-Harvey

- Translation Managers:
  - Bernardo González Kriegel

- Wiki curators:
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 22.11 -- PTFS Europe
  - 22.05 -- Lucas Gass
  - 21.11 -- Arthur Suzuki
  - 21.05 -- Wainui Witika-Park

## Credits
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 22.11.02

- [Koha-Suomi Oy](https://koha-suomi.fi)

We thank the following individuals who contributed patches to Koha 22.11.02

- Tomás Cohen Arazi (4)
- Matt Blenkinsop (1)
- Nick Clemens (7)
- David Cook (2)
- Frédéric Demians (1)
- Jonathan Druart (17)
- Katrin Fischer (4)
- Géraud Frappier (1)
- Lucas Gass (6)
- Kyle M Hall (1)
- Mason James (1)
- Owen Leonard (4)
- Jacob O'Mara (4)
- Martin Renvoize (4)
- Fridolin Somers (2)
- Emmi Takkinen (1)
- Koha translators (1)
- Shi Yao Wang (2)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.11.02

- Athens County Public Libraries (4)
- BibLibre (2)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (4)
- ByWater-Solutions (14)
- Koha Community Developers (17)
- Koha-Suomi (1)
- KohaAloha (1)
- Prosentient Systems (2)
- PTFS-Europe (9)
- Solutions inLibro inc (3)
- Tamil (1)
- Theke Solutions (4)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (30)
- Matt Blenkinsop (7)
- Nick Clemens (13)
- David Cook (1)
- Jonathan Druart (6)
- Katrin Fischer (11)
- Andrew Fuerste-Henry (6)
- Lucas Gass (7)
- Kyle M Hall (13)
- Mason James (1)
- Barbara Johnson (1)
- Owen Leonard (3)
- Johanna Miettunen (1)
- David Nind (21)
- Jacob O'Mara (47)
- Martin Renvoize (32)
- Marcel de Rooy (10)
- Fridolin Somers (2)
- Hammat Wele (1)



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

Autogenerated release notes updated last on 25 Jan 2023 16:26:00.
