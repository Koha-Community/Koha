# RELEASE NOTES FOR KOHA 17.05.08
24 janv. 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.05.08 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.05.08.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.05.08 is a bugfix/maintenance release.

It includes 30 bugfixes and 4 enhancements.

## Enhancements

### Circulation

 - [[11210]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11210) Allow partial writeoff

### Architecture, internals, plumbing

 - [[19830]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19830) Add the Koha::Patron->old_checkout method

### OPAC

 - [[19573]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19573) Link to make a new list in masthead in OPAC only appears / works if no other list already exists
 - [[19338]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19338) Dates sorting incorrectly in opac-account.tt

## Bugs fixed

### Acquisitions

 - [[19694]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19694) Edited shipping cost in invoice doesn't save
 - [[19813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19813) MarcItemFieldsToOrder cannot handle a tag not existing
 - [[18183]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18183) jQuery append error related to script tags in cloneItemBlock

### Architecture, internals, plumbing

 - [[18923]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18923) Resolve a warn in Biblio::GetCOinSBiblio
 - [[19599]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19599) anonymise_issue_history can be very slow on large systems
 - [[19756]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19756) Encoding issues when update DB is run from the interface
 - [[19760]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19760) Die instead of warn if koha-conf is not accessible

### Cataloging

 - [[20063]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20063) $9 is lost when cataloguing authority records

### Circulation

 - [[19444]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19444) Automatic renewal script should not auto-renew if a patron's record has expired

### Installation and upgrade (web-based installer)

 - [[19514]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19514) No Password restrictions in onboarding tool patron creation

### MARC Authority data support

 - [[18458]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18458) Merging authority record incorrectly orders subfields

### Patrons

 - [[19510]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19510) edi_manage permission has no description
 - [[19621]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19621) Routing lists tab not present when viewing 'Holds history' tab for a patron

### Reports

 - [[19669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19669) Remove deprecated checkouts by patron category report

### OPAC

 - [[19450]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19450) OverDrive integration failing on missing method
 - [[19496]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19496) Patron notes about item does not get emailed as indicated
 - [[19702]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19702) Basket not displaying correctly on home page
 - [[19913]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19913) Embedded HTML5 videos are broken

### Searching

 - [[19807]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19807) IntranetCatalogSearchPulldown doesn't honor IntranetNumbersPreferPhrase

### Staff client

 - [[19857]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19857) Optionally hide SMS provider field in patron modification screen

### System Administration

 - [[19788]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19788) Case sensitivity is not preserved when creating local system preferences

### Templates

 - [[19918]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19918) span tag not closed in opac-registration-confirmation.tt

### Test Suite

 - [[17770]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17770) t/db_dependent/Sitemapper.t fails when date changes during test run
 - [[19602]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19602) Add usage statistics link to administration sidebar menu
 - [[19867]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19867) HouseboundRoles.t is failing randomly

### Tools

 - [[18201]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18201) Export data -Fix "Remove non-local items" option and add "Removes non-local records" option for existing functionality

### Web services

 - [[19725]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19725) OAI-PMH ListRecords and ListIdentifiers should use biblio_metadata.timestamp

## Security bugs fixed

 - [[19847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19847) tracklinks.pl accepts any url from a parameter for proxying
 - [[19881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19881) authorities-list.pl can be executed by anybody
 - [[19738]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19738) XSS in serials module


## System requirements

Important notes:
    
- Perl 5.10 is required
- Zebra is required

## Documentation

The Koha manual is maintained in DocBook.The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://manual.koha-community.org//en/)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](http://git.koha-community.org/gitweb/?p=kohadocs.git;a=summary)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- English (USA)
- Arabic (99%)
- Armenian (100%)
- Basque (79%)
- Chinese (China) (83%)
- Chinese (Taiwan) (99%)
- Czech (94%)
- Danish (69%)
- English (New Zealand) (91%)
- Finnish (99%)
- French (96%)
- French (Canada) (94%)
- German (99%)
- German (Switzerland) (99%)
- Greek (79%)
- Hindi (100%)
- Italian (100%)
- Norwegian Bokmål (57%)
- Occitan (76%)
- Persian (57%)
- Polish (100%)
- Portuguese (100%)
- Portuguese (Brazil) (84%)
- Slovak (90%)
- Spanish (100%)
- Swedish (96%)
- Turkish (100%)
- Vietnamese (71%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 17.05.08 is

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
  - 16.05 -- [Mason James](mailto:mtj@kohaaloha.com)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 17.05.08:

- Catalyst IT

We thank the following individuals who contributed patches to Koha 17.05.08.

- Aleisha Amohia (1)
- David Bourgault (2)
- Alex Buckley (1)
- Nick Clemens (3)
- Frédéric Demians (1)
- Marcel de Rooy (4)
- Jonathan Druart (16)
- Victor Grousset (1)
- Srdjan Jankovic (1)
- Janusz Kaczmarek (1)
- Owen Leonard (3)
- Julian Maurice (4)
- Kyle M Hall (2)
- Josef Moravec (1)
- Liz Rea (1)
- Fridolin Somers (4)
- Lari Taskula (1)
- Mark Tompsett (3)
- Koha translators (1)
- Chris Weeks (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.05.08

-  (0)
- ACPL (3)
- BibLibre (9)
- bugs.koha-community.org (16)
- ByWater-Solutions (5)
- Catalyst (4)
- jns.fi (1)
- Rijksmuseum (4)
- Solutions inLibro inc (2)
- Tamil (1)
- unidentified (6)

We also especially thank the following individuals who tested patches
for Koha.

- Alex Arnaud (1)
- Claire Gravely (3)
- David Bourgault (2)
- Dilan Johnpullé (3)
- Fridolin Somers (47)
- George Williams (1)
- Jonathan Druart (42)
- Jon Knight (6)
- Josef Moravec (9)
- Julian Maurice (5)
- Katrin Fischer (10)
- Liz Rea (1)
- Marci Chen (1)
- Nick Clemens (47)
- Owen Leonard (2)
- Scott Kehoe (2)
- Simon Pouchol (3)
- Tomas Cohen Arazi (1)
- Kyle M Hall (18)
- Your Full Name (2)
- Marcel de Rooy (8)


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

Autogenerated release notes updated last on 24 janv. 2018 09:27:32.
