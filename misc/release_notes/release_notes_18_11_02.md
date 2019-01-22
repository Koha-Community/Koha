# RELEASE NOTES FOR KOHA 18.11.02
22 Jan 2019

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 18.11.02 can be downloaded from:

- [Download](http://download.koha-community.org/koha-18.11.02.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 18.11.02 is a bugfix/maintenance release.

It includes 6 enhancements, 20 bugfixes.




## Enhancements

### Architecture, internals, and plumbing

- [[21912]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21912) Koha::Objects->search lacks tests



### Authentication

- [[21547]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21547) Use set_password in opac-passwd and remove sub goodkey

> Architectural enhancement backported to 18.11.x series to aid future backports. There should be no noticeable effects for the end user.



### I18N/L10N

- [[21789]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21789) Example usage of I18N Template::Toolkit plugin



### Test Suite

- [[21817]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21817) Mock userenv should be a t::lib::Mocks method

> Test suite enhancement backported to 18.11.x series to aid future backports. There should be no noticeable effects for the end user.




## Critical bugs fixed

### Acquisitions

- [[21605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21605) Cannot create EDI account

### Architecture, internals, and plumbing

- [[22052]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22052) DeleteExpiredOpacRegistrations should skip bad borrowers

### Circulation

- [[21915]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21915) Add a way to automatically reconcile balance for patrons

> Sponsored by ByWater Solutions


> In the past, if a patron had any credit existing on their account (newly added, or pre-existing), if debts were present then the credit balance would always be immediately applied to the debt.  This functionality was inadvertently removed during refactoring efforts which debuted in 16.11.  
This patch adds code to restore the functionality and allows it to be optionally applied to the system via a new system preference, `AccountAutoReconcile`.  
Note: The new preference defaults to the post 16.11 behaviour, if you wish to restore the 16.11 functionality then you will need to update the preference after the upgrade.


- [[21928]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21928) CircAutoPrintQuickSlip 'clear' is not working
- [[22020]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22020) Configure Columns for Patron Issues checkin hides renewal

### OPAC

- [[22030]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22030) OverDrive requires configuration for field passed as username

### REST api

- [[22071]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22071) authenticate_api_request does not stash koha.user in the OAuth use case

### Templates

- [[21813]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21813) In-page JavaScript causes error on patron entry page


## Other bugs fixed

### Acquisitions

- [[21929]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21929) Typo in orderreceive.tt

### Architecture, internals, and plumbing

- [[21909]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21909) Koha::Account::outstanding_* methods should preserve call context
- [[22007]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22007) KohaDates output does not need to be html filtered
- [[22033]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22033) related_resultset is a hole in the Koha::Object logic
- [[22059]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22059) Wrong exception parameters in Koha::Patron->set_password

### MARC Bibliographic data support

- [[22034]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22034) Viewing record with Default framework doesn't work on MARC tab

### Notices

- [[21571]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21571) Translate notices fail on ACCTDETAILS

### Packaging

- [[17108]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17108) Automatic debian/control updates (stable/18.11.x)

### Searching - Zebra

- [[22073]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22073) Diacritics Ž and ž not being mapped for searching (Non-ICU)

### Staff Client

- [[21802]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21802) Edit notices form is not aligned with accordeon headers

### Templates

- [[21990]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21990) No background color for div.error, must be .alert

### Test Suite

- [[22107]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22107) Avoid deleting data in some tests

## New sysprefs

- AccountAutoReconcile
- OverDriveUsername

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

- [Koha Manual](http://koha-community.org/manual/18.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (100%)
- Armenian (100%)
- Basque (63.9%)
- Chinese (China) (64.6%)
- Chinese (Taiwan) (100%)
- Czech (92.5%)
- Danish (56.1%)
- English (New Zealand) (89.2%)
- English (USA)
- Finnish (84.6%)
- French (95.4%)
- French (Canada) (98.9%)
- German (100%)
- German (Switzerland) (92.8%)
- Greek (76.5%)
- Hindi (94.7%)
- Italian (95.1%)
- Norwegian Bokmål (96%)
- Occitan (post 1500) (60.1%)
- Polish (86.2%)
- Portuguese (100%)
- Portuguese (Brazil) (77.7%)
- Slovak (91%)
- Spanish (93.6%)
- Swedish (91.5%)
- Turkish (99.8%)
- Ukrainian (60.5%)
- Vietnamese (53.9%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 18.11.02 is

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
- Documentation Manager: Caroline Cyr La Rose
- Documentation Team:
  - David Nind
  - Lucy Vaux-Harvey

- Translation Managers: 
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.in)
  - [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)

- Wiki curators: 
  - Caroline Cyr La Rose
- Release Maintainers:
  - 18.11 -- [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - 18.05 -- Lucas Gass
  - 18.05 -- Jesse Maseto
  - 17.11 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)
- Release Maintainer assistants:
  - 18.05 -- [Kyle Hall](mailto:kyle@bywatersolutions.com)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 18.11.02:

- ByWater Solutions

We thank the following individuals who contributed patches to Koha 18.11.02.

- Tomás Cohen Arazi (19)
- Colin Campbell (1)
- Nick Clemens (6)
- Jonathan Druart (13)
- Andrew Isherwood (1)
- Owen Leonard (1)
- Julian Maurice (1)
- Martin Renvoize (4)
- Marcel de Rooy (2)
- Mirko Tietgen (1)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 18.11.02

- abunchofthings.net (1)
- ACPL (1)
- BibLibre (1)
- ByWater-Solutions (6)
- Koha Community Developers (13)
- PTFS-Europe (6)
- Rijks Museum (2)
- Theke Solutions (19)

We also especially thank the following individuals who tested patches
for Koha.

- Hugo Agud (1)
- Tomás Cohen Arazi (9)
- Alex Arnaud (2)
- Nick Clemens (44)
- Jonathan Druart (1)
- Charles Farmer (4)
- Katrin Fischer (8)
- Lucas Gass (1)
- Kyle Hall (7)
- Owen Leonard (8)
- Josef Moravec (7)
- Eric Phetteplace (1)
- Martin Renvoize (66)
- Marcel de Rooy (5)
- Pierre-Marc Thibault (2)
- Mirko Tietgen (1)
- Marc Véron (1)
- Nazlı Çetin (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 18.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 Jan 2019 15:42:52.
