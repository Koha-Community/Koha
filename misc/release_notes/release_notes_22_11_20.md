# RELEASE NOTES FOR KOHA 22.11.20
13 Aug 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.11.20 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.11.20.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.11.20 is a bugfix/maintenance release.

It includes 2 enhancements, 5 bugfixes.

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

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/22.11/zh_Hant/html/) (75%)
- [English](https://koha-community.org/manual/22.11//html/) (100%)
- [English (USA)](https://koha-community.org/manual/22.11/en/html/)
- [French](https://koha-community.org/manual/22.11/fr/html/) (47%)
- [German](https://koha-community.org/manual/22.11/de/html/) (37%)
- [Greek](https://koha-community.org/manual/22.11//html/) (48%)
- [Hindi](https://koha-community.org/manual/22.11/hi/html/) (76%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (90%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Traditional) (81%)
- Czech (72%)
- Dutch (88%)
- English (100%)
- English (New Zealand) (69%)
- English (USA)
- English (United Kingdom) (99%)
- Finnish (96%)
- French (100%)
- French (Canada) (96%)
- German (100%)
- German (Switzerland) (56%)
- Greek (63%)
- Hindi (100%)
- Italian (92%)
- Norwegian Bokmål (69%)
- Persian (fa_ARAB) (76%)
- Polish (100%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (94%)
- Slovak (67%)
- Spanish (100%)
- Swedish (88%)
- Telugu (77%)
- Turkish (89%)
- Ukrainian (79%)
- hyw_ARMN (generated) (hyw_ARMN) (70%)
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

The release team for Koha 22.11.20 is


- Release Manager: 

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 22.11.20
<div style="column-count: 2;">

- [Koha-Suomi Oy](https://koha-suomi.fi)
- Reserve Bank of New Zealand
</div>

We thank the following individuals who contributed patches to Koha 22.11.20
<div style="column-count: 2;">

- Aleisha Amohia (3)
- Tomás Cohen Arazi (3)
- Nick Clemens (1)
- David Cook (5)
- Chris Cormack (1)
- Amit Gupta (1)
- Marcel de Rooy (2)
- Emmi Takkinen (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.11.20
<div style="column-count: 2;">

- BigBallOfWax (1)
- [ByWater Solutions](https://bywatersolutions.com) (1)
- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha) (2)
- Catalyst Open Source Academy (1)
- Informatics Publishing Ltd (1)
- [Koha-Suomi Oy](https://koha-suomi.fi) (1)
- [Prosentient Systems](https://www.prosentient.com.au) (5)
- Rijksmuseum, Netherlands (2)
- [Theke Solutions](https://theke.io) (3)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (2)
- Pedro Amorim (1)
- Tomás Cohen Arazi (14)
- Nick Clemens (5)
- David Cook (5)
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
line is 22.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 13 Aug 2024 14:52:24.
