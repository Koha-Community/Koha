# RELEASE NOTES FOR KOHA 17.11.11
24 oct. 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.11.11 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.11.11.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.11.11 is a bugfix/maintenance release.

It includes 4 enhancements, 38 bugfixes.




## Enhancements

### Architecture, internals, and plumbing

- [[20669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20669) Add upgrade method to plugins

> This enhancement standardises the methods used by plugin authors to maintain their plugin data across plugin versions.


- [[21352]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21352) Allow plugins to add CSS and Javascript to Staff interface

> This enhancement allows plugin authors to make adaptations to the staff client using css and javascript.



### OPAC

- [[20181]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20181) Allow plugins to add CSS and Javascript to OPAC

### Patrons

- [[18635]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18635) Koha::Patron->guarantees() should return results alphabetically


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[21133]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21133) Missing use C4::Accounts statement in Koha/Patron.pm

### Circulation

- [[10382]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10382) collection not returning to null when removed from course reserves
- [[21176]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21176) decreaseLoanHighHolds does not properly calculate date when  TimeFormat set to 12 hour

### Installation and upgrade (command-line installer)

- [[16690]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16690) Improve security of remote database installations
- [[21440]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21440) koha-create expects the file passed by $DEFAULTSQL to be in gzip format

> Add support to koha-create to allow it to accept both compressed and uncompressed files for DEFAULTSQL



### Label/patron card printing

- [[21281]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21281) Label Template - Creation not working

### OPAC

- [[21479]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21479) Removing from cart removes 2 items

### translate.koha-community.org

- [[21480]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21480) misc/translator/translate does not work with perl 5.26


## Other bugs fixed

### Acquisitions

- [[16739]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16739) Generate EDIFACT on basket groups falsely showing when configuration is incomplete
- [[19271]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19271) Ordered/Spent lists should display vendor name, not vendor code
- [[21398]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21398) Search term when adding an order from an existing record should be required
- [[21425]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21425) basketno not being interpolated into error message

### Authentication

- [[20023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20023) Password recovery should be case insensitive
- [[21323]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21323) Redirect page after login missing multiple params

### Cataloging

- [[18655]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18655) Unimarc field 210c fails on importing fields with a simple quote
- [[20785]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20785) Advanced Editor does not honor MarcFieldDocURL
- [[21362]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21362) Advanced MARC Editor - Rancor - Tab navigation not working in fixed fields
- [[21407]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21407) Can't enter new macros in the advanced cataloging editor (rancor)

### Command-line Utilities

- [[21322]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21322) process_message_queue.pl --type should take an argument

### Database

- [[5458]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5458) length of items.ccode disagrees with authorised_values.authorised_value

### Fines and fees

- [[21196]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21196) Allow calcfine to consider default item type replacement cost

### I18N/L10N

- [[19500]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19500) Make module names on letters overview page translatable

### ILL

- [[21289]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21289) Error when sending emails to partner libraries

### Lists

- [[21297]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21297) "More lists" screen missing "Select an Existing list" fieldset when all lists are public

### Notices

- [[15971]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15971) Serial claim letters should allow the use of all biblio and biblioitems fields (like issn)

### OPAC

- [[20994]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20994) Fix capitalization on OPAC result list "Save to Lists"
- [[21078]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21078) Overdrive JS breaks when window opened from another site

### Patrons

- [[21353]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21353) Merge patrons option only available with manage_patron_lists

### Searching

- [[20151]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20151) Search is broken when stemming has no language

### Searching - Zebra

- [[21416]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21416) 'gr' option missing from ZEBRA_LANGUAGE options in koha-sites.conf

### Serials

- [[20241]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20241) Fix display of publication year in subscription record search for MARC21
- [[20616]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20616) Using "Edit serials" with no issues selected gives an ugly error

### Templates

- [[13272]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13272) Many inputs lack a type attribute
- [[21038]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21038) Reserves should be holds
- [[21397]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21397) Routing list tab not marked as active

### Test Suite

- [[20764]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20764) t/Koha_Template_Plugin_KohaPlugins.t is DB dependent

### Tools

- [[20131]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20131) Inventory optional filters always shows "For loan" for value 0
- [[21141]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21141) Batch item modification tool throws error 500 when an itemnumber is invalid



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

- [Koha Manual](http://koha-community.org/manual/17.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99.4%)
- Armenian (99.9%)
- Basque (75.3%)
- Chinese (China) (79.7%)
- Chinese (Taiwan) (99.7%)
- Czech (94.1%)
- Danish (65.7%)
- English (New Zealand) (99.4%)
- English (USA)
- Finnish (95.6%)
- French (98.9%)
- French (Canada) (92%)
- German (100%)
- German (Switzerland) (99.4%)
- Greek (82.4%)
- Hindi (99.9%)
- Italian (99.8%)
- Norwegian Bokmål (54.5%)
- Occitan (post 1500) (72.8%)
- Persian (54.8%)
- Polish (97.5%)
- Portuguese (99.9%)
- Portuguese (Brazil) (84.4%)
- Slovak (96.6%)
- Spanish (99.9%)
- Swedish (91.6%)
- Turkish (100%)
- Vietnamese (67.4%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 17.11.11 is

- Release Manager: [Nick Clemens](mailto:nick@bywatersolutions.com)
- Release Manager assistants:
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)

- Module Maintainers:
  - REST API -- [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - Elasticsearch -- [Nick Clemens](mailto:nick@bywatersolutions.com)
- QA Manager: [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)

- QA Team:
  - [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
  - Josef Moravec
  - [Alex Arnaud](mailto:alex.arnaud@biblibre.com)
  - [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Chris Cormack](mailto:chrisc@catalyst.net.nz)
- Bug Wranglers:
  - Claire Gravely
  - Jon Knight
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.inc)
  - [Amit Gupta](mailto:amitddng135@gmail.com)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Team:
  - Lee Jamison
  - David Nind
  - Caroline Cyr La Rose
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Release Maintainers:
  - 18.05 -- [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - 17.11 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 17.11.11:


We thank the following individuals who contributed patches to Koha 17.11.11.

- Blou (1)
- Alex Arnaud (2)
- Christopher Brannon (1)
- Colin Campbell (1)
- Nick Clemens (3)
- Tomás Cohen Arazi (1)
- Marcel de Rooy (2)
- Jonathan Druart (17)
- Magnus Enger (1)
- Katrin Fischer (7)
- Andrew Isherwood (1)
- Pasi Kallinen (1)
- Olli-Antti Kivilahti (1)
- Jon Knight (1)
- Owen Leonard (3)
- Ere Maijala (1)
- Kyle M Hall (8)
- Martin Renvoize (1)
- Andreas Roussos (2)
- Fridolin Somers (8)
- Mirko Tietgen (1)
- Mark Tompsett (6)
- Koha translators (1)
- Baptiste Wojtkowski (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.11.11

- abunchofthings.net (1)
- ACPL (3)
- BibLibre (11)
- BSZ BW (7)
- bugs.koha-community.org (17)
- ByWater-Solutions (5)
- bywatetsolutions.com (6)
- cdalibrary.org (1)
- helsinki.fi (2)
- joensuu.fi (1)
- Libriotech (1)
- Loughborough University (1)
- PTFS-Europe (3)
- Rijksmuseum (2)
- Solutions inLibro inc (1)
- Theke Solutions (1)
- unidentified (8)

We also especially thank the following individuals who tested patches
for Koha.

- Barry Cannon (1)
- Nick Clemens (51)
- Tomas Cohen Arazi (5)
- Chris Cormack (7)
- Caroline Cyr La Rose (3)
- Michal Denar (6)
- Marcel de Rooy (8)
- Jonathan Druart (26)
- Katrin Fischer (19)
- Claire Gravely (1)
- Dilan Johnpullé (1)
- Pasi Kallinen (1)
- Owen Leonard (9)
- Julian Maurice (4)
- Kyle M Hall (3)
- Josef Moravec (3)
- David Nind (3)
- Séverine QUEUNE (6)
- Martin Renvoize (65)
- Fridolin Somers (67)
- Mark Tompsett (5)
- Marc Véron (1)


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 17.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 24 oct. 2018 09:31:21.
