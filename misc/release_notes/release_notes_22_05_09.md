# RELEASE NOTES FOR KOHA 22.05.09
25 Jan 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.05.09 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.05.09.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.05.09 is a bugfix/maintenance release.

It includes 1 enhancements, 29 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha [here](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).




## Enhancements

### Self checkout

- [[32115]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32115) Add ID to check-out default help message dialog to allow customization


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[32481]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32481) Rabbit times out when too many jobs are queued and the response takes too long


## Other bugs fixed

### Acquisitions

- [[32016]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32016) Fix 'clear filter' button behavior on datatable saving their state

### Architecture, internals, and plumbing

- [[31675]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31675) Remove packages from debian/control that are no longer used
- [[31873]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31873) Can't call method "safe_delete" on an undefined value at cataloguing/additem.pl
- [[32330]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32330) Table background_jobs is missing indexes
- [[32457]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32457) CGI::param called in list context from acqui/addorder.pl line 182
- [[32465]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32465) koha-worker debian script missing 'queue' in help

  >This adds information about the --queue option to the help text for the koha-worker script.

### Cataloging

- [[31881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31881) Link in MARC view does not work

### Circulation

- [[28975]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28975) Holds queue lists can show holds from all libraries even with IndependentBranches

### Fines and fees

- [[22042]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22042) BlockReturnofWithdrawn Items does not block refund generation when item is withdrawn and lost

### Hold requests

- [[32247]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32247) Real time HoldsQueue does not need to check items if there are no holds

### Lists

- [[32302]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32302) "ISBN" label shows when no ISBN data present when sending list

  >This fixes email messages sent when sending lists so that if there are no ISBNs for a record, an empty label is not shown.

### OPAC

- [[32597]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32597) Article requests not stacking in patron view

### Patrons

- [[31166]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31166) Digest option is not selectable for phone when PhoneNotification is enabled
- [[31492]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31492) Patron image upload fails on first attempt with CSRF failure
- [[32491]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32491) Can no longer search patrons in format 'surname, firstname'
- [[32505]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32505) Cannot search by dateofbirth in specified dateformat

### Searching

- [[20596]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20596) Authority record matching rule causes staging failure when MARC record contains multiple tag values for a match point

### Staff interface

- [[32355]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32355) Add class url to all URL syspref
- [[32596]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32596) Background jobs viewer not showing finished jobs

### System Administration

- [[30694]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30694) Impossible to delete line in circulation and fine rules

  **Sponsored by** *Koha-Suomi Oy*
- [[32291]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32291) "library category" messages should be removed (not used)

### Templates

- [[32348]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32348) Library public is missing from columns settings

### Test Suite

- [[32349]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32349) Remove TEST_QA
- [[32622]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32622) Auth.t failing on D10

### Tools

- [[32037]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32037) Circulation module in action logs has bad links for deleted items
- [[32255]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32255) Cannot use file upload in batch record modification
- [[32389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32389) Syndetics links are built wrong on the staff results page
- [[32456]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32456) Date accessioned is now cleared when items are replaced



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/22.05/ar/html/) (28.2%)
- [Chinese (Taiwan)](https://koha-community.org/manual/22.05/zh_TW/html/) (62.7%)
- [English (USA)](https://koha-community.org/manual/22.05/en/html/)
- [French](https://koha-community.org/manual/22.05/fr/html/) (59.5%)
- [German](https://koha-community.org/manual/22.05/de/html/) (63.5%)
- [Hindi](https://koha-community.org/manual/22.05/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/22.05/it/html/) (41.2%)
- [Spanish](https://koha-community.org/manual/22.05/es/html/) (29.7%)
- [Turkish](https://koha-community.org/manual/22.05/tr/html/) (33.5%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (77.9%)
- Armenian (100%)
- Armenian (Classical) (71.6%)
- Bulgarian (85.6%)
- Chinese (Taiwan) (93.8%)
- Czech (62.4%)
- English (New Zealand) (56.5%)
- English (USA)
- Finnish (94.8%)
- French (97.2%)
- French (Canada) (99.9%)
- German (100%)
- German (Switzerland) (54.1%)
- Greek (55.5%)
- Hindi (100%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (84.7%)
- Norwegian Bokmål (56%)
- Persian (58.7%)
- Polish (100%)
- Portuguese (85.8%)
- Portuguese (Brazil) (76.8%)
- Russian (78.4%)
- Slovak (63.9%)
- Spanish (100%)
- Swedish (78.6%)
- Telugu (84.6%)
- Turkish (92%)
- Ukrainian (74.2%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 22.05.09 is


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
new features in Koha 22.05.09

- [Koha-Suomi Oy](https://koha-suomi.fi)

We thank the following individuals who contributed patches to Koha 22.05.09

- Nick Clemens (7)
- David Cook (4)
- Jonathan Druart (6)
- Géraud Frappier (1)
- Lucas Gass (5)
- Didier Gautheron (1)
- Thibaud Guillot (2)
- Kyle M Hall (3)
- The Minh Luong (1)
- David Nind (1)
- Mona Panchaud (1)
- Marcel de Rooy (2)
- Fridolin Somers (4)
- Emmi Takkinen (1)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.05.09

- BibLibre (7)
- ByWater-Solutions (15)
- David Nind (1)
- Koha Community Developers (6)
- Koha-Suomi (1)
- mpan.ch (1)
- Prosentient Systems (4)
- Rijksmuseum (2)
- Solutions inLibro inc (2)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (33)
- Matt Blenkinsop (3)
- Nick Clemens (1)
- David Cook (1)
- Jonathan Druart (2)
- Katrin Fischer (11)
- Andrew Fuerste-Henry (3)
- Lucas Gass (36)
- Kyle M Hall (7)
- Evelyn Hartline (1)
- Mason James (1)
- Jan Kissig (2)
- Owen Leonard (3)
- David Nind (10)
- Jacob O'Mara (16)
- Martin Renvoize (22)
- Marcel de Rooy (8)
- Danyon Sewell (1)
- Fridolin Somers (2)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is rmain2205.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 25 Jan 2023 21:44:58.
