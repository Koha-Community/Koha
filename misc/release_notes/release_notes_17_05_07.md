# RELEASE NOTES FOR KOHA 17.05.07
23 dec. 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.05.07 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.05.07.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.05.07 is a bugfix/maintenance release.

It includes 1 enhancements, 26 bugfixes.

## Enhancements

### Templates

- [[19751]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19751) Holds awaiting pickup report should not be fixed-width

## Security bugs fixed

- [[19614]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19614) Fix XSS in members/pay.pl
- [[19612]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19612) Fix XSS in members/memberentry.pl
- [[19611]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19611) Fix XSS Flaws in supplier.pl
- [[19319]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19319) Reflected XSS Vulnerability in opac-MARCdetail.pl
- [[19570]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19570) autocomplete="off" no set for login forms at the OPAC
- [[19569]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19569) Set X-Frame-Options=SAMEORIGIN - opac-showmarc.ok
- [[19568]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19568) Escape url params with url filter - opac-opensearch.tt

## Critical bugs fixed

### Architecture, internals, and plumbing

- [[19655]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19655) To.json doesn't escape newlines which can create invalid JSON

### Cataloging

- [[19646]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19646) value_builder marc21_linking_section template is broken


## Other bugs fixed

### Cataloging

- [[18833]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18833) plugin unimarc_field_210c pagination error
- [[19595]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19595) Clicking plugin link does not fill item's date acquired field

### Command-line Utilities

- [[19190]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19190) Silly calculation of average time in touch_all scripts

### Database

- [[19724]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19724) Add timestamp to biblio_metadata and deletedbiblio_metadata

### Hold requests

- [[19533]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19533) Hold pulldown for itemtype is empty if hold placement needs override

### Label/patron card printing

- [[10222]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10222) Error when saving Demco label templates
- [[19681]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19681) label-item-search.pl result count formatting error when there is only one page

### Notices

- [[18990]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18990) Overdue Notices are not sending through SMS correctly

### OPAC

- [[12497]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12497) Make OPAC search history feature accessible when it should
- [[19640]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19640) IdRef webservice display is broken

### Packaging

- [[18907]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18907) Warning "dpkg-source: warning: relation < is deprecated: use << or <="

### Reports

- [[19638]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19638) False positives for 'Update SQL' button

### Templates

- [[19692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19692) Unclosed div in opac-shelves.tt

### Test Suite

- [[19775]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19775) Search/History.t is failing randomly

### Tools

- [[19643]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19643) Pagination buttons on staged marc management are stacking instead of inline
- [[19674]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19674) Broken indicators of changed fields in manage staged MARC records template
- [[19683]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19683) Export.pl does not populate the Authority Types dropdown correctly



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

The release team for Koha 17.05.07 is

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
new features in Koha 17.05.07:


We thank the following individuals who contributed patches to Koha 17.05.07.

- root (1)
- David Bourgault (2)
- Nick Clemens (2)
- Marcel de Rooy (4)
- Jonathan Druart (8)
- Victor Grousset (2)
- Amit Gupta (3)
- Owen Leonard (4)
- Kyle M Hall (3)
- Chris Nighswonger (1)
- Simon Pouchol (1)
- Fridolin Somers (6)
- Mark Tompsett (3)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.05.07

- ACPL (4)
- BibLibre (9)
- bugs.koha-community.org (8)
- ByWater-Solutions (5)
- Foundations (1)
- informaticsglobal.com (3)
- Rijksmuseum (4)
- Solutions inLibro inc (2)
- translate.koha-community.org (1)
- unidentified (3)

We also especially thank the following individuals who tested patches
for Koha.

- BWS Sandboxes (1)
- Charles Farmer (2)
- Chris Cormack (2)
- Claire Gravely (2)
- David Bourgault (5)
- Dilan Johnpullé (1)
- Dominic Pichette (1)
- Fridolin Somers (37)
- George Williams (1)
- Jonathan Druart (35)
- Jonathan Druat (1)
- Josef Moravec (6)
- Katrin Fischer (9)
- Mark Tompsett (4)
- Nick Clemens (37)
- Owen Leonard (2)
- Simon Pouchol (3)
- Marcel de Rooy (23)


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

Autogenerated release notes updated last on 23 dec. 2017 10:01:54.
