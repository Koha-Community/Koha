[% FOREACH info IN information %]
    [% SWITCH info_type %]
    [% CASE 'identifiers' %]
        [% SWITCH info.source.lower %]
        [% CASE 'orcid' %]
            <li class="identifier_[% info.source.lower | html %]">
                <span>ORCID: </span>
                <a href="https://orcid.org/[% info.number | url %]">[% info.number | html %]</a>
            </li>
        [% CASE 'scopus' %]
            <li class="identifier_[% info.source.lower | html %]">
                <span>ScopusID: </span>
                <a href="https://www.scopus.com/authid/detail.uri?authorId=[% info.number | url %]">[% info.number | html %]</a>
            </li>
        [% CASE 'loop' %]
            <li class="identifier_[% info.source.lower | html %]">
                <span>Loop ID: </span>
                <a href="https://loop.frontiersin.org/people/[% info.number | url %]">[% info.number | html %]</a>
            </li>
        [% CASE 'rid' %]
            <li class="identifier_[% info.source.lower | html %]">
                <span>Publons ID: </span>
                <a href="https://publons.com/researcher/[% info.number | url %]">[% info.number | html %]</a>
            </li>
        [% CASE 'viaf' %]
            <li class="identifier_[% info.source.lower | html %]">
                <span>VIAF ID: </span>
                <a href="https://viaf.org/viaf/[% info.number | url %]">[% info.number | html %]</a>
            </li>
        [% CASE 'isni' %]
            <li class="identifier_[% info.source.lower | html %]">
                <span>ISNI ID: </span>
                <a href="https://isni.org/isni/[% info.number | url %]">[% info.number | html %]</a>
            </li>
        [% CASE 'wikidata' %]
            <li class="identifier_[% info.source.lower | html %]">
                <span>WIKIDATA ID: </span>
                <a href="http://www.wikidata.org/entity/[% info.number | url %]">[% info.number | html %]</a>
            </li>
        [% END %]
    [% CASE 'activity' %]
        [% IF info.field_of_activity %]
            <li>
                <span>
                    Field of activity: [% info.field_of_activity | html %]
                    [% IF info.start_period || info.end_period %]
                        ( [%~ IF info.start_period %]from: [% info.start_period | html %][% END %]
                        [% IF info.end_period %]until: [% info.end_period | html %][% END ~%]
                        )
                    [% END %]
                </span>
            </li>
        [% END %]
    [% CASE 'address' %]
        [% IF info.address %]
            <li>
                <span>Address: [% info.address | html %] [% info.postal_code | html %] [% info.city | html %] [% info.country | html %]</span>
            </li>
        [% END %]
    [% CASE 'associated_group' %]
        [% IF info.associated_group %]
            <li>
                <span>
                    Associated group: [% info.associated_group | html %]
                    [% IF info.start_period || info.end_period %]
                        ( [%~ IF info.start_period %]from: [% info.start_period | html %][% END %]
                        [% IF info.end_period %]until: [% info.end_period | html %][% END ~%]
                        )
                    [% END %]
                    [% IF info.uri %]<p style="margin-bottom: 0;">URI: [% info.uri | html %]</p>[% END %]
                    [% IF info.source_of_information %]<p style="margin-bottom: 0;">Source of information: [% info.source_of_information | html %]</p>[% END %]
                    [% IF info.authority_record_number %]<p style="margin-bottom: 0;">Authority record control number or standard number: [% info.authority_record_number | html %]</p>[% END %]
                </span>
            </li>
        [% END %]
    [% CASE 'email_address' %]
        [% IF info.email_address %]
            <li>
                <span> Email address: [% info.email_address | html %] </span>
            </li>
        [% END %]
    [% CASE 'occupation' %]
        [% IF info.occupation %]
            <li>
                <span>
                    Occupation: [% info.occupation | html %]
                    [% IF info.start_period || info.end_period %]
                        ( [%~ IF info.start_period %]from: [% info.start_period | html %][% END %]
                        [% IF info.end_period %]until: [% info.end_period | html %][% END ~%]
                        )
                    [% END %]
                    [% IF info.uri %]<p style="margin-bottom: 0;">URI: [% info.uri | html %]</p>[% END %]
                    [% IF info.source_of_information %]<p style="margin-bottom: 0;">Source of information: [% info.source_of_information | html %]</p>[% END %]
                    [% IF info.authority_record_number %]<p style="margin-bottom: 0;">Authority record control number or standard number: [% info.authority_record_number | html %]</p>[% END %]
                </span>
            </li>
        [% END %]
    [% CASE 'place_of_birth' %]
        [% IF info.place_of_birth %]
            <li>
                <span> Place of birth: [% info.place_of_birth | html %] </span>
            </li>
        [% END %]
    [% CASE 'place_of_death' %]
        [% IF info.place_of_death %]
            <li>
                <span> Place of death: [% info.place_of_death | html %] </span>
            </li>
        [% END %]
    [% CASE 'uri' %]
        [% IF info.uri %]
            <li>
                <span> URI: [% info.uri | $raw | html %] </span>
            </li>
        [% END %]
    [% END %]
[% END %]
