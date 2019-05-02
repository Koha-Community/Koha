# RELEASE NOTES FOR KOHA 18.05.12
29 Apr 2019

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 18.05.12 can be downloaded from:

- [Download](http://download.koha-community.org/koha-18.05.12.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 18.05.12 is a bugfix/maintenance release with security fixes.

It includes 4 security fixes, 1 enhancements, 31 bugfixes.


## Security bugs

### Koha

- [[22068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22068) Canceling article request should verify the request belongs to the borrower
- [[22478]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22478) Cross-site scripting vulnerability in paginations
- [[22542]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22542) Back browser should not allow to see other patrons details (see bug 5371)
- [[22692]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22692) Logging in via cardnumber circumvents account logout


## Enhancements

### Circulation

- [[20450]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20450) Add collection to list of items when placing hold on specific copy


## Critical bugs fixed

### Acquisitions

- [[22611]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22611) Typo introduced into Koha::EDI by bug 15685

### Cataloging

- [[21049]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21049) Rancor 007 field does not retain value

### Circulation

- [[21346]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21346) Clean up dialogs in returns.pl

### Course reserves

- [[22652]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22652) Editing Course reserves is broken

### Web services

- [[21832]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21832) Restore is_expired in ILS-DI GetPatronInfo service


## Other bugs fixed

### Acquisitions

- [[20782]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20782) EDI: Clicking the 'Invoice' link on the 'EDI Messages' page does not take you directly to the corresponding invoice
- [[21659]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21659) Link to basket groups from order receive page are broken
- [[22444]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22444) currencies_manage permission doesn't provide link to manage currencies when selected alone

### Architecture, internals, and plumbing

- [[22607]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22607) Default value in issues.renewals should be '0' not null

### Cataloging

- [[10345]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10345) Copy number should be incremented when adding multiple items at once

### Circulation

- [[13763]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13763) Renew feature does not check for the BarcodeInputFilter option

> Sponsored by Catalyst IT

- [[21013]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21013) Missing itemtype for checkut makes patron summary print explode
- [[22536]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22536) Display problem in Holds to Pull report

### Command-line Utilities

- [[17746]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17746) koha-reset-passwd should use Koha::Patron->set_password

### Course reserves

- [[21003]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21003) Don't show warning when editing a reserve item

### Hold requests

- [[21263]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21263) Pickup library not set correctly when using Default holds policy by item type

### I18N/L10N

- [[19497]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19497) Translatability: Get rid of "Edit [% field.name |html %] field"

> Sponsored by Catalyst IT


### Notices

- [[14358]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14358) Changing the module refreshes the page and resets library choice
- [[20937]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20937) PrintNoticesMaxLines is not effective for overdue notices with a print type specified where a patron has an email

### OPAC

- [[13629]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13629) SingleBranchMode removes both library and availability search from advanced search
- [[22075]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22075) Encoding problem with RIS export
- [[22560]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22560) Forgotten password "token expired" page still shows boxes to reset password
- [[22561]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22561) Forgotten password requirements hint doesn't list all rules for new passwords
- [[22620]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22620) OPAC description for collection in opac-reserve.tt
- [[22624]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22624) Show OPAC description for authorised values in OPAC

### Searching

- [[12441]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12441) search.pl has incorrect reference to OPACdefaultSortField and OPACdefaultSortOrder

> Sponsored by Catalyst IT

- [[20823]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20823) UNIMARC XSLT does not display 604$t

### Searching - Elasticsearch

- [[19670]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19670) search_marc_map.marc_field should have COLLATE= utf8mb4_bin

### Serials

- [[13735]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13735) Item form in serials module doesn't respect max length set in the frameworks

### System Administration

- [[22575]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22575) Item type administration uses invalid error class for dialog

### Templates

- [[21130]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21130) Detail XSLT produces translatable HTML class



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

- [Koha Manual](http://koha-community.org/manual/18.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99.4%)
- Armenian (100%)
- Basque (72.2%)
- Chinese (China) (76.9%)
- Chinese (Taiwan) (98.5%)
- Czech (92.1%)
- Danish (63.4%)
- English (New Zealand) (95.2%)
- English (USA)
- Finnish (92.1%)
- French (98.5%)
- French (Canada) (93.7%)
- German (100%)
- German (Switzerland) (98.1%)
- Greek (80.5%)
- Hindi (100%)
- Italian (97.1%)
- Norwegian Bokmål (67.3%)
- Occitan (post 1500) (70.2%)
- Persian (52.9%)
- Polish (93.4%)
- Portuguese (100%)
- Portuguese (Brazil) (87.2%)
- Slovak (97.6%)
- Spanish (100%)
- Swedish (93.6%)
- Turkish (99.5%)
- Vietnamese (64.9%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 18.05.12 is

- Release Manager: [Nick Clemens](mailto:nick@bywatersolutions.com)
- Release Manager assistants:
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
- QA Manager: [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
- QA Team:
  - [Alex Arnaud](mailto:alex.arnaud@biblibre.com)
  - [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - Josef Moravec
  - [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Chris Cormack](mailto:chrisc@catalyst.net.nz)
- Topic Experts:
  - SIP2 -- Colin Campbell
  - EDI -- Colin Campbell
  - Elasticsearch -- Ere Maijala
  - REST API -- Tomás Cohen Arazi
  - UI Design -- Owen Leonard
- Bug Wranglers:
  - Luis Moises Rojas
  - Jon Knight
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.in)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Manager: Caroline Cyr-La-Rose
- Documentation Team:
  - David Nind
  - Lucy Vaux-Harvey

- Translation Managers: 
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.in)
  - [Bernardo González Kriegel](mailto:bgkriegel@gmail.com)

- Wiki curators: 
  - Caroline Cyr-La-Rose
- Release Maintainers:
  - 18.11 -- [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - 18.05 -- Lucas Gass
  - 18.05 -- Jesse Maseto
  - 17.11 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)
- Release Maintainer assistants:
  - 18.05 -- [Kyle Hall](mailto:kyle@bywatersolutions.com)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 18.05.12:

- Catalyst IT

We thank the following individuals who contributed patches to Koha 18.05.12.

- Tomás Cohen Arazi (4)
- Philippe Blouin (1)
- David Bourgault (1)
- Christopher Brannon (4)
- Colin Campbell (1)
- Nick Clemens (3)
- Jonathan Druart (4)
- Katrin Fischer (6)
- Lucas Gass (6)
- Owen Leonard (8)
- Ere Maijala (1)
- Hayley Mapley (5)
- Julian Maurice (2)
- Josef Moravec (2)
- Björn Nylen (1)
- Martin Renvoize (4)
- Marcel de Rooy (1)
- Maryse Simard (1)
- Fridolin Somers (5)
- Lyon 3 Team (1)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 18.05.12

- ACPL (8)
- BibLibre (7)
- BSZ BW (6)
- ByWater-Solutions (9)
- Catalyst (5)
- Coeur D'Alene Public Library (4)
- Independant Individuals (3)
- Koha Community Developers (4)
- PTFS-Europe (5)
- Rijks Museum (1)
- Solutions inLibro inc (2)
- Theke Solutions (4)
- ub.lu.se (1)
- University of Helsinki (1)
- Université Jean Moulin Lyon 3 (1)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (6)
- Mikaël Olangcay Brisebois (3)
- Nick Clemens (45)
- Chris Cormack (4)
- Michal Denar (3)
- Jonathan Druart (3)
- Katrin Fischer (21)
- Lucas Gass (60)
- Kyle Hall (4)
- Owen Leonard (1)
- Ere Maijala (1)
- Hayley Mapley (2)
- Jose-Mario Monteiro-Santos (2)
- Josef Moravec (10)
- Séverine Queune (1)
- Liz Rea (14)
- Martin Renvoize (67)
- David Roberts (1)
- Marcel de Rooy (7)
- Lisette Scheer (3)
- Maryse Simard (1)
- Pierre-Marc Thibault (4)
- Bin Wen (4)
- Mengü Yazıcıoğlu (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 18.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 02 May 2019 12:42:22.
