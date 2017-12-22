# RELEASE NOTES FOR KOHA 17.11.01
22 Dec 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.11.01 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.11.01.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.11.01 is a bugfix/maintenance release.

It includes 5 enhancements, 34 bugfixes.




## Enhancements

### Acquisitions

- [[17182]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17182) Allow Keyword to MARC mapping for acquisitions searches (subtitle)

### Hold requests

- [[19769]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19769) 'Pickup library is different' message does not display library branch name when placing hold

### Staff Client

- [[19806]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19806) Add class to items.itemnotes_nonpublic

### System Administration

- [[19292]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19292) Add MARC code column on libraries list

### Templates

- [[19751]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19751) Holds awaiting pickup report should not be fixed-width


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[19439]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19439) Some error responses from opac/unapi get lost in eval
- [[19766]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19766) Preview routing slip is broken

### Cataloging

- [[19646]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19646) value_builder marc21_linking_section template is broken
- [[19706]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19706) Item search: Unsupported format html

### OPAC

- [[19496]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19496) Patron notes about item does not get emailed as indicated
- [[19808]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19808) Reviews from deleted patrons make few scripts to explode
- [[19843]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19843) reviews.datereviewed is not set

### Searching - Elasticsearch

- [[19563]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19563) Generation of sort_fields uses incorrect condition


## Other bugs fixed

### About

- [[7143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7143) Bug for tracking changes to the about page

### Acquisitions

- [[3841]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3841) Add a Default ACQ framework

### Architecture, internals, and plumbing

- [[19746]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19746) Debug statements are left in returns.pl

### Cataloging

- [[18833]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18833) plugin unimarc_field_210c pagination error
- [[19595]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19595) Clicking plugin link does not fill item's date acquired field

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

- [[19551]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19551) Cash register report has bad erroneous results from wrong order of operations
- [[19638]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19638) False positives for 'Update SQL' button

### Serials

- [[19315]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19315) Routing preview may use wrong biblionumber
- [[19767]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19767) serial-issues.pl is unused and should be removed

### Staff Client

- [[19456]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19456) Some pages title tag contains html

### System Administration

- [[19560]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19560) Unable to delete library when branchcode contains special characters

### Templates

- [[19602]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19602) Add usage statistics link to administration sidebar menu
- [[19692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19692) Unclosed div in opac-shelves.tt

### Test Suite

- [[19759]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19759) TestBuilder generates too many decimals for float
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
- Armenian (97%)
- Basque (76%)
- Chinese (China) (80%)
- Chinese (Taiwan) (99%)
- Czech (94%)
- Danish (66%)
- English (New Zealand) (99%)
- Finnish (95%)
- French (97%)
- French (Canada) (92%)
- German (99%)
- German (Switzerland) (99%)
- Greek (77%)
- Hindi (99%)
- Italian (100%)
- Norwegian Bokmål (55%)
- Occitan (73%)
- Persian (55%)
- Polish (98%)
- Portuguese (99%)
- Portuguese (Brazil) (81%)
- Slovak (93%)
- Spanish (100%)
- Swedish (92%)
- Turkish (100%)
- Vietnamese (68%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 17.11.01 is

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
  - 17.11 -- [Nick Clemens](mailto:nick@bywatersolutions.com)
  - 17.05 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)
  - 16.11 -- [Chris Cormack](mailto:chris@bigballofwax.co.nz)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 17.11.01:

- Catalyst IT

We thank the following individuals who contributed patches to Koha 17.11.01.

- root (1)
- Aleisha Amohia (1)
- David Bourgault (2)
- Nick Clemens (11)
- Marcel de Rooy (4)
- Jonathan Druart (21)
- Claire Gravely (1)
- Victor Grousset (3)
- Amit Gupta (3)
- David Gustafsson (1)
- Owen Leonard (6)
- Julian Maurice (1)
- Kyle M Hall (2)
- Josef Moravec (3)
- Chris Nighswonger (1)
- Simon Pouchol (1)
- Fridolin Somers (3)
- Mark Tompsett (3)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.11.01

- ACPL (6)
- BibLibre (8)
- BSZ BW (1)
- bugs.koha-community.org (21)
- ByWater-Solutions (13)
- Foundations (1)
- Göteborgs universitet (1)
- informaticsglobal.com (3)
- Rijksmuseum (4)
- Solutions inLibro inc (2)
- translate.koha-community.org (1)
- unidentified (7)

We also especially thank the following individuals who tested patches
for Koha.

- BWS Sandboxes (1)
- Charles Farmer (2)
- Chris Cormack (2)
- Claire Gravely (2)
- David Bourgalt (1)
- David Bourgault (8)
- Dilan Johnpullé (1)
- Dominic Pichette (2)
- George Williams (1)
- Jonathan Druart (64)
- Jonathan Druat (1)
- Jon Knight (4)
- Josef Moravec (15)
- Julian Maurice (6)
- Katrin Fischer (12)
- Mark Tompsett (6)
- Nick Clemens (74)
- Nicolas Legrand (1)
- Owen Leonard (8)
- Simon Pouchol (3)
- Tomas Cohen Arazi (2)
- Kyle M Hall (5)
- Signed-off-by Owen Leonard (1)
- Marcel de Rooy (25)


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 1711_rel.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 Dec 2017 11:18:33.
