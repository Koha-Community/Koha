[% FOREACH info IN information %]
    [% SWITCH info_type %]
    [% CASE 'activity' %]
        <li>
            <span>
                Field of activity: [% info.field_of_activity | html %]
                [% IF info.start_period || info.end_period %]
                    (
                    [%~ IF info.start_period %]from: [% info.start_period | html %][% END %]
                    [% IF info.end_period %]until: [% info.end_period | html %][% END ~%]
                    )
                [% END %]
            </span>
        </li>
    [% CASE 'address' %]
        <li>
            <span>Address: [% info.address | html %] [% info.postal_code | html %] [% info.city | html %] [% info.country | html %]</span>
        </li>
    [% CASE 'associated_group' %]
        <li>
            <span>
                Associated group: [% info.associated_group | html %]
                [% IF info.start_period || info.end_period %]
                    (
                    [%~ IF info.start_period %]from: [% info.start_period | html %][% END %]
                    [% IF info.end_period %]until: [% info.end_period | html %][% END ~%]
                    )
                [% END %]
                [% IF info.uri %]<p>URI: [% info.uri | html %]</p>[% END %]
                [% IF info.source_of_information %]<p>Source of information: [% info.source_of_information | html %]</p> [% END %]
                [% IF info.authority_record_number %]<p>Authority record control number or standard number: [% info.authority_record_number | html %]</p>[% END %]
            </span>
        </li>
    [% CASE 'email_address' %]
        <li>
            <span>
                Email address: [% info.email_address | html %]
            </span>
        </li>
    [% CASE 'occupation' %]
        <li>
            <span>
                Occupation: [% info.occupation | html %]
                [% IF info.start_period || info.end_period %]
                    (
                    [%~ IF info.start_period %]from: [% info.start_period | html %][% END %]
                    [% IF info.end_period %]until: [% info.end_period | html %][% END ~%]
                    )
                [% END %]
                [% IF info.uri %]<p>URI: [% info.uri | html %]</p>[% END %]
                [% IF info.source_of_information %]<p>Source of information: [% info.source_of_information | html %]</p> [% END %]
                [% IF info.authority_record_number %]<p>Authority record control number or standard number: [% info.authority_record_number | html %]</p>[% END %]
            </span>
        </li>
    [% CASE 'place_of_birth' %]
        <li>
            <span>
                Place of birth: [% info.place_of_birth | html %]
            </span>
        </li>
    [% CASE 'place_of_death' %]
        <li>
            <span>
                Place of death: [% info.place_of_death | html %]
            </span>
        </li>
    [% CASE 'uri' %]
        <li>
            <span>
                URI: [% info.uri | $raw | html %]
            </span>
        </li>
    [% END %]
[% END %]
