[% SWITCH identifier.source.lower %]
[% CASE 'orcid' %]
    <li>
        <span>ORCID: </span>
        <a href="https://orcid.org/[% identifier.number | url %]">[% identifier.number | html %]</a>
    </li>
[% CASE 'scopus' %]
    <li>
        <span>ScopusID: </span>
        <a href="https://www.scopus.com/authid/detail.uri?authorId=[% identifier.number | url %]">[% identifier.number | html %]</a>
    </li>
[% CASE 'loop' %]
    <li>
        <span>loop: </span>
        <a href="https://loop.frontiersin.org/people/[% identifier.number | url %]">[% identifier.number | html %]</a>
    </li>
[% CASE 'rid' %]
    <li>
        <span>Publons: </span>
        <a href="https://publons.com/researcher/[% identifier.number | url %]">[% identifier.number | html %]</a>
    </li>
[% CASE 'viaf' %]
    <li>
        <span>VIAF: </span>
        <a href="https://viaf.org/viaf/[% identifier.number | url %]">[% identifier.number | html %]</a>
    </li>
[% END %]
