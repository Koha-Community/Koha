# RELEASE NOTES FOR KOHA 23.05.09
29 Feb 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 23.05.09 can be downloaded from:

- [Download](http://download.koha-community.org/koha-23.05.09.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.05.09 is a bugfix/maintenance release.

It includes 2 enhancements, 40 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


## Bugfixes

### About

#### Critical bugs fixed

- [35504](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35504) Release team 24.05

### Accessibility

#### Other bugs fixed

- [34647](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34647) name attribute is obsolete in anchor tag
- [35894](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35894) Duplicate link in booksellers.tt

### Acquisitions

#### Other bugs fixed

- [33457](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33457) Improve display of fund users when the patron has no firstname

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [35843](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35843) No such thing as Koha::Exceptions::Exception

#### Other bugs fixed

- [34999](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34999) REST API: Public routes should respect OPACMaintenance
  >This report ensures that if OPACMaintenance is set, public API calls are blocked with an UnderMaintenance exception.
- [35701](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35701) Cannot use i18n.inc from memberentrygen
- [35702](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35702) Reduce DB calls when performing authorities merge
- [35835](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35835) Fix shebang for cataloguing/ysearch.pl
- [36092](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36092) sessionID not passed to the template on auth.tt

### Authentication

#### Critical bugs fixed

- [36034](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36034) cas_ticket is set to serialized patron object in session

#### Other bugs fixed

- [29930](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29930) 'cardnumber' overwritten with userid when not mapped (LDAP auth)

### Cataloging

#### Other bugs fixed

- [33639](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33639) Adding item to item group from 'Add item' screen doesn't work
  >This fixes adding a new item to an item group (when using the item groups feature - EnableItemGroups system preference). before this fix, even if you selected an item group, it was not added to it.
- [35695](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35695) Remove useless item group code from cataloging_additem.js
- [35774](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35774) add_item_to_item_group additem.pl should be $item->itemnumber instead of biblioitemnumber

### Circulation

#### Critical bugs fixed

- [35341](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35341) Circulation rule dates are being overwritten
- [35518](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35518) Call to C4::Context->userenv happens before it's gets populated breaks code logic in circulation

#### Other bugs fixed

- [35360](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35360) Inconsistent use/look of 'Cancel hold(s)' button on circ/waitingreserves.pl

### Command-line Utilities

#### Other bugs fixed

- [30627](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30627) koha-run-backups delete the backup files after finished its job without caring days option
- [35373](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35373) Remove comment about bug 8000 in gather_print_notices.pl
- [35596](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35596) Error in writeoff_debts documentation

### Documentation

#### Other bugs fixed

- [35354](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35354) Update emailLibrarianWhenHoldisPlaced system preference description

### Hold requests

#### Critical bugs fixed

- [35322](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35322) AllowItemsOnHoldCheckoutSCO and AllowItemsOnHoldCheckoutSIP do not work

### Installation and upgrade (command-line installer)

#### Other bugs fixed

- [34979](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34979) System preferences missing from sysprefs.sql

### Packaging

#### Other bugs fixed

- [25691](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25691) Debian packages point to /usr/share/doc/koha/README.Debian which does not exist

### Patrons

#### Critical bugs fixed

- [34479](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34479) Clear saved patron search selections after certain actions
  >This fixes issues with patron search, and remembering the patrons selected after performing an action (such as Add to patron list, Merge selected patrons, Batch patron modification). Remembering selected patrons was introduced in Koha 22.11, bug 29971.
  >
  >Previously, the patrons selected after running an action were kept, and this either caused confusion, or could result in data loss if other actions were taken with new searches.
  >
  >Now, after performing a search and taking one of the actions available, you are now prompted with "Keep patrons selected for a new operation". When you return to the patron search:
  >- If the patrons are kept: those patrons should still be selected
  >- If the patrons aren't kept: the patron selection history is empty and no patrons are selected

#### Other bugs fixed

- [35756](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35756) Wrong use of encodeURIComponent in patron-search.inc

### SIP2

#### Other bugs fixed

- [35461](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35461) Renew All 66 SIP server response messages produce HASH content in replies

### Searching - Elasticsearch

#### Other bugs fixed

- [35086](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35086) Koha::SearchEngine::Elasticsearch::Indexer->update_index needs to commit in batches
  >This enables breaking large Elasticsearch or Open Search indexing requests into smaller chunks (for example, when updating many records using batch modifications).
  >
  >This means that instead of sending a single background request for indexing, which could exceed the limits of the search server or take up too many resources, it limits index update requests to a more manageable size.
  >
  >The default chunk size is 5,000. To configure a different chunk size, add a <chunk_size> directive to the elasticsearch section of the instance's koha-conf.xml (for example: <chunk_size>2000</chunk_size>).
  >
  >NOTE: This doesn't change the command line indexing script, as this already allows passing a commit size defining how many records to send.

### Staff interface

#### Other bugs fixed

- [32477](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32477) Hiding batch item modification columns isn't remembered correctly

  **Sponsored by** *Koha-Suomi Oy*
  >This fixes showing and hiding columns when batch item editing (Cataloging > Batch editing > Batch item modification). When using the show/hide column options, the correct columns and updating the show/hide selections were not correctly displayed, including when the page was refreshed (for example: selecting the Collection column hid the holds column instead, and the shown/hide option for Collection was not selected).
- [35865](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35865) Missing hint about permissions when adding managers to a basket

### System Administration

#### Other bugs fixed

- [35510](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35510) Non-patron guarantor missing from CollapseFieldsPatronAddForm  options
  >This adds Non-patron guarantor as an option to the CollapseFieldsPatronAddForm system preference - this section can now be collapsed on the patron form.

### Test Suite

#### Other bugs fixed

- [35507](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35507) Fix handling plugins in unit tests causing random failures on Jenkins
- [35904](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35904) C4::Auth::checkauth cannot be tested easily
- [35962](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35962) t/db_dependent/Koha/BackgroundJob.t failing on D10

### Tools

#### Other bugs fixed

- [35438](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35438) Importing records can create too large transactions
- [35641](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35641) Reduce DB calls when performing inventory on a list of barcodes
- [35817](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35817) Wrong hint on patron's category when batch update patron

### Web services

#### Critical bugs fixed

- [34893](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34893) ILS-DI can return the wrong patron for AuthenticatePatron

#### Other bugs fixed

- [34950](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34950) ILS DI Availability is not accurate for items on holds shelf or in transit

## Enhancements 

### OPAC

#### Enhancements

- [35663](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35663) Wording on OPAC privacy page is misleading

### Templates

#### Enhancements

- [35474](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35474) Add icon for protected patrons

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

The release team for Koha 23.05.09 is

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
  - Pedor Amorim

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
new features in Koha 23.05.09
<div style="column-count: 2;">

- [Koha-Suomi Oy](https://koha-suomi.fi)
</div>

We thank the following individuals who contributed patches to Koha 23.05.09
<div style="column-count: 2;">

- Pedro Amorim (1)
- Tomás Cohen Arazi (4)
- Matt Blenkinsop (5)
- Nick Clemens (8)
- Jonathan Druart (16)
- Laura Escamilla (1)
- Katrin Fischer (7)
- Lucas Gass (8)
- Victor Grousset (1)
- Michael Hafen (2)
- Kyle M Hall (7)
- Janik Hilser (1)
- Andreas Jonsson (2)
- Emily Lamancusa (1)
- Owen Leonard (7)
- Martin Renvoize (13)
- Marcel de Rooy (8)
- Caroline Cyr La Rose (1)
- Emmi Takkinen (2)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.05.09
<div style="column-count: 2;">

- Athens County Public Libraries (7)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (7)
- ByWater-Solutions (24)
- Independant Individuals (3)
- Koha Community Developers (17)
- Koha-Suomi (2)
- Kreablo AB (2)
- montgomerycountymd.gov (1)
- PTFS-Europe (19)
- Rijksmuseum (8)
- Solutions inLibro inc (1)
- Theke Solutions (4)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Michael Adamyk (1)
- Tomás Cohen Arazi (6)
- Matt Blenkinsop (4)
- Chris Cormack (1)
- Jonathan Druart (17)
- Sharon Dugdale (2)
- Magnus Enger (3)
- Katrin Fischer (62)
- Andrew Fuerste-Henry (1)
- Lucas Gass (82)
- Victor Grousset (5)
- Kyle M Hall (14)
- Emily Lamancusa (2)
- Brendan Lawlor (2)
- Owen Leonard (6)
- lmstrand (1)
- Julian Maurice (1)
- David Nind (22)
- Philip Orr (1)
- Martin Renvoize (32)
- Marcel de Rooy (13)
- Fridolin Somers (64)
- Loïc Vassaux--Artur (1)
- Alexander Wagner (3)
- Anneli Österman (1)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 23.05.x-security.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 29 Feb 2024 15:28:17.
