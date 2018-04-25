# RELEASE NOTES FOR KOHA 17.05.11
25 avril 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.05.11 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.05.11.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.05.11 is a bugfix/maintenance release.

It includes 17 bugfixes.

## Critical bugs fixed

### Acquisitions

- [[18593]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18593) Suggestions aren't updated when one biblio is merged with another

### Architecture, internals, and plumbing

- [[20229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20229) Remove problematic SQL modes

### Command-line Utilities

- [[12812]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12812) Longoverdue.pl --mark-returned doesn't return items
- [[17717]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17717) Fix broken cronjobs due to permissions of the current directory

### OPAC

- [[20286]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20286) Subscribing to a search via rss goes to an empty page


## Other bugs fixed

### Architecture, internals, and plumbing

- [[19739]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19739) Add default ES configuration to koha-conf.xml

### Cataloging

- [[20341]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20341) Show authorized value description for withdrawn like damaged and lost

### Command-line Utilities

- [[11936]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11936) Consistent log message for item insert
- [[18709]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18709) koha-foreach should use koha-shell, internally
- [[20234]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20234) Make maintenance scripts use koha-zebra instead of koha-*-zebra

### Database

- [[19547]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19547) Maria DB doesn't have a debian.cnf

### MARC Authority data support

- [[20430]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20430) Z39.50 button display depends on wrong server count

### Serials

- [[20461]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20461) New subscription form: "Item type" and "item type for older issues" fields are ignored

### System Administration

- [[20383]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20383) Hide link to plugin management if plugins are not enabled

### Templates

- [[20372]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20372) Correct toolbar markup on some pages

### Test Suite

- [[20311]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20311) get_age tests can fail on February 28th

### Tools

- [[20376]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20376) "Select all" button no longer selects disabled checkboxes in Batch Record Deletion Tool



## System requirements

Important notes:
    
- Perl 5.10 is required
- Zebra is required

## Documentation

The Koha manual is maintained in DocBook. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/17.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](http://git.koha-community.org/gitweb/?p=kohadocs.git;a=summary)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99.2%)
- Armenian (100%)
- Basque (78.7%)
- Chinese (China) (83.3%)
- Chinese (Taiwan) (99.8%)
- Czech (94.2%)
- Danish (68.8%)
- English (New Zealand) (90.6%)
- English (USA)
- Finnish (99.7%)
- French (96.2%)
- French (Canada) (94.5%)
- German (100%)
- German (Switzerland) (99.8%)
- Greek (79.5%)
- Hindi (100%)
- Italian (99.9%)
- Korean (50.2%)
- Norwegian Bokmål (57.4%)
- Occitan (post 1500) (76.3%)
- Persian (57.4%)
- Polish (99.9%)
- Portuguese (100%)
- Portuguese (Brazil) (84.3%)
- Slovak (89.7%)
- Spanish (100%)
- Swedish (95.6%)
- Turkish (100%)
- Vietnamese (70.6%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 17.05.11 is

- Release Manager: [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
- Release Manager assistant: [Nick Clemens](mailto:nick@bywatersolutions.com)

- QA Team:
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
- Bug Wranglers:
  - [Amit Gupta](mailto:amitddng135@gmail.com)
  - Claire Gravely
  - Josef Moravec
  - [Marc Véron](mailto:veron@veron.ch)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Team:
  - [Chris Cormack](mailto:chrisc@catalyst.net.nz)
  - [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Release Maintainers:
  - 17.05 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)
  - 16.11 -- [Chris Cormack](mailto:chris@bigballofwax.co.nz)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 17.05.11:

- Orex Digital

We thank the following individuals who contributed patches to Koha 17.05.11.

- Tomás Cohen Arazi (5)
- Marcel de Rooy (2)
- Jonathan Druart (5)
- Magnus Enger (1)
- Victor Grousset (1)
- Owen Leonard (2)
- Julian Maurice (1)
- Kyle M Hall (1)
- Josef Moravec (1)
- Maksim Sen (1)
- Fridolin Somers (4)
- Mark Tompsett (2)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.05.11

- ACPL (2)
- BibLibre (6)
- bugs.koha-community.org (5)
- bywatetsolutions.com (1)
- Libriotech (1)
- Rijksmuseum (2)
- Solutions inLibro inc (1)
- Theke Solutions (5)
- unidentified (3)

We also especially thank the following individuals who tested patches
for Koha.

- delaye (2)
- Hugo Agud hagud@orex.es (1)
- Hugo Agud hagud@orex.es (1)
- JM Broust (1)
- Nick Clemens (22)
- Tomas Cohen Arazi (1)
- Marcel de Rooy (7)
- Jonathan Druart (18)
- Katrin Fischer (4)
- Brendan Gallagher (3)
- Lucie Gay (1)
- Claire Gravely (1)
- Dilan Johnpullé (1)
- Julian Maurice (6)
- Kyle M Hall (4)
- Josef Moravec (4)
- Séverine QUEUNE (2)
- Maksim Sen (1)
- Fridolin Somers (25)


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 17.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 25 avril 2018 06:27:26.
