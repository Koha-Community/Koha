# RELEASE NOTES FOR KOHA 24.05.03
12 Aug 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 24.05.03 can be downloaded from:

- [Download](http://download.koha-community.org/koha-24.05.03.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 24.05.03 is a bugfix/maintenance release.

It includes 2 enhancements, 6 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [37323](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37323) Remote-Code-Execution (RCE) in picture-upload.pl
- [37370](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37370) opac-export.pl can be used even if exporting disabled
- [37464](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37464) Remote Code Execution in barcode function leads to reverse shell
- [37466](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37466) Reflected Cross Site Scripting
- [37488](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37488) Filepaths not validated in ZIP upload to picture-upload.pl
- [37508](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37508) SQL reports should not show patron password hash if queried

  **Sponsored by** *Reserve Bank of New Zealand*

## Bugfixes

### Acquisitions

#### Critical bugs fixed

- [37533](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37533) Invalid query when receiving an order

### Fines and fees

#### Critical bugs fixed

- [37255](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37255) Creating default waiting hold cancellation policy for all patron categories and itemtypes breaks Koha

  **Sponsored by** *Koha-Suomi Oy*

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/24.05/zh_Hant/html/) (76%)
- [English](https://koha-community.org/manual/24.05//html/) (100%)
- [English (USA)](https://koha-community.org/manual/24.05/en/html/)
- [French](https://koha-community.org/manual/24.05/fr/html/) (47%)
- [German](https://koha-community.org/manual/24.05/de/html/) (37%)
- [Greek](https://koha-community.org/manual/24.05//html/) (48%)
- [Hindi](https://koha-community.org/manual/24.05/hi/html/) (77%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (98%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Traditional) (90%)
- Czech (69%)
- Dutch (76%)
- English (100%)
- English (New Zealand) (63%)
- English (USA)
- Finnish (100%)
- French (99%)
- French (Canada) (96%)
- German (99%)
- German (Switzerland) (51%)
- Greek (57%)
- Hindi (99%)
- Italian (83%)
- Norwegian Bokmål (76%)
- Persian (fa_ARAB) (94%)
- Polish (98%)
- Portuguese (Brazil) (95%)
- Portuguese (Portugal) (88%)
- Russian (91%)
- Slovak (60%)
- Spanish (99%)
- Swedish (87%)
- Telugu (69%)
- Turkish (80%)
- Ukrainian (72%)
- hyw_ARMN (generated) (hyw_ARMN) (64%)
</div>

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 24.05.03 is


- Release Manager: 

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 24.05.03
<div style="column-count: 2;">

- [Koha-Suomi Oy](https://koha-suomi.fi)
- Reserve Bank of New Zealand
</div>

We thank the following individuals who contributed patches to Koha 24.05.03
<div style="column-count: 2;">

- Aleisha Amohia (3)
- Tomás Cohen Arazi (2)
- Nick Clemens (1)
- David Cook (5)
- Chris Cormack (1)
- Amit Gupta (1)
- Andreas Jonsson (1)
- Marcel de Rooy (2)
- Emmi Takkinen (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 24.05.03
<div style="column-count: 2;">

- BigBallOfWax (1)
- [ByWater Solutions](https://bywatersolutions.com) (1)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (2)
- Catalyst Open Source Academy (1)
- Informatics Publishing Ltd (1)
- [Koha-Suomi Oy](https://koha-suomi.fi) (1)
- Kreablo AB (1)
- [Prosentient Systems](https://www.prosentient.com.au) (5)
- Rijksmuseum, Netherlands (2)
- [Theke Solutions](https://theke.io) (2)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (3)
- Pedro Amorim (1)
- Tomás Cohen Arazi (21)
- Nick Clemens (5)
- David Cook (6)
- Chris Cormack (2)
- Victor Grousset (2)
- Amit Gupta (1)
- Marcel de Rooy (6)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 24.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 12 Aug 2024 18:20:31.
