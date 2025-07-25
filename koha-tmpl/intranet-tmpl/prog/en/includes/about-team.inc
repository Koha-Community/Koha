[%- BLOCK role -%]
    [% matches = role.key.match('(\w+):?(.*)?') %]
    [% ro = matches.0 %]
    [% ex = matches.1 %]
    [%- SWITCH ro -%]

    [%- CASE 'manager' -%]
        <span>Release manager</span>
    [%- CASE 'manager_assistant' -%]
        <span>Release manager assistant</span>
    [%- CASE 'manager_assistants' -%]
        <span>Release manager assistants</span>
    [%- CASE 'manager_mentor' -%]
        <span>Release manager mentor</span>
    [%- CASE 'qa_manager' -%]
        <span>Quality assurance manager</span>
    [%- CASE 'qa' -%]
        <span>Quality assurance team</span>
    [%- CASE 'documentation' -%]
        <span>Documentation manager</span>
    [%- CASE 'documentation_team' -%]
        <span>Documentation team</span>
    [%- CASE 'translation' -%]
        <span>Translation manager</span>
    [%- CASE 'translations' -%]
        <span>Translation managers</span>
    [%- CASE 'translation_assistant' -%]
        <span>Translation manager assistant</span>
    [%- CASE 'te' -%]
        <span>Topic expert</span>
    [%- CASE 'bugwrangler' -%]
        <span>Bug wrangler</span>
    [%- CASE 'maintainer' -%]
        <span>Release maintainer</span>
    [%- CASE 'maintainer_assistant' -%]
        <span>Release maintainer assistant</span>
    [%- CASE 'maintainer_assistants' -%]
        <span>Release maintainer assistants</span>
    [%- CASE 'maintainer_mentor' -%]
        <span>Release maintainer mentor</span>
    [%- CASE 'maintainer_mentors' -%]
        <span>Release maintainer mentors</span>
    [%- CASE 'wiki' -%]
        <span>Wiki curator</span>
    [%- CASE 'ci' -%]
        <span>Continuous integration manager</span>
    [%- CASE 'packaging' -%]
        <span>Packaging manager</span>
    [%- CASE 'packaging_assistant' -%]
        <span>Packaging manager assistant</span>
    [%- CASE 'chairperson' -%]
        <span>Meetings chairperson</span>
    [%- CASE 'newsletter' -%]
        <span>Newsletter editor</span>
    [%- CASE 'mm' -%]
        <span>Module maintainer</span>
    [%- CASE 'vm' -%]
        <span>Virtual machine maintainer</span>
    [%- CASE 'database' -%]
        <span>Documentation specialist</span>
    [%- CASE 'live_cd' -%]
        <span>Live CD maintainer</span>
    [%- CASE 'accessibility_advocate' -%]
        <span>Accessibility advocate</span>
    [%- CASE 'accessibility_advocates' -%]
        <span>Accessibility advocates</span>
    [%- CASE 'meeting_facilitator' -%]
        <span>Meeting facilitator</span>
    [%- CASE 'ktd' -%]
        <span>Developer tooling</span>
    [%- CASE 'website' -%]
        <span>Website administrator</span>
    [%- CASE 'social_media' -%]
        <span>Social media manager</span>
    [%- CASE 'security_manager' -%]
        <span>Security release manager</span>
    [%- CASE -%]
        <span>MISSING MAP FOR ROLE: [% role.key | html %]</span>
    [%- END -%]
    [%- IF ex %]- [% ex | html %][% END -%]
[%- END -%]

[%- BLOCK person -%]
    [% IF p.openhub %]<a href="[% p.openhub | url %]">[% p.name | html %]</a>[% ELSE %][% p.name | html %][% END %]
[%- END -%]

[%- BLOCK contributions -%]
    [%- IF p.roles || p.notes -%]
        <ul>
            [% FOREACH r IN p.roles %]
                [% SET sorted_versions = r.value.sort.reverse %]
                <li>
                    [% INCLUDE role role=r %]
                    ([% IF sorted_versions.size <= 2 %]
                        [% sorted_versions.join(', ') | html %]
                    [% ELSE %]
                        [% sorted_versions.slice(0,1).join(', ') | html %]<span class="version-ellipsis" data-bs-toggle="tooltip" title="[% sorted_versions.slice(2, -1).join(', ') | html %]">, ...</span>
                    [% END %])
                </li>
            [% END %]
            [% IF p.notes %]<li>[% p.notes | html %]</li>[% END %]
        </ul>
    [%- END -%]
[%- END -%]

[%- BLOCK team -%]
    <ul>
        [% IF v == 'release' %]
            <p>This is the team who were responsible for the initial release of your currently installed Koha version.</p>

            <li
                ><strong>Release manager:</strong>
                [% INCLUDE person p=t.manager %]
            </li>

            [% IF t.manager_assistants %]
                <li
                    ><strong>Release manager assistants:</strong>
                    <ul>
                        [% FOREACH a IN t.manager_assistants %]
                            <li>[% INCLUDE person p=a %]</li>
                        [% END %]
                    </ul>
                </li>
            [% ELSIF t.manager_assistant %]
                <li
                    ><strong>Release manager assistant:</strong>
                    [% INCLUDE person p=t.manager_assistant %]
                </li>
            [% END %]
        [% ELSE %]
            <p
                >This is the team who are responsible for the next release of Koha and the ongoing maintenance of your currently installed Koha version. They will be in these roles up until
                <strong>[% t.release_date | $KohaDates %]</strong>, when the next team will be elected.</p
            >

            [% FOREACH s IN t.security_manager %]
                <li
                    ><strong>Security release manager:</strong>
                    [% INCLUDE person p=s %]
                </li>
            [% END %]

            [% FOREACH m IN t.maintainer %]
                [% IF m.version == ( v ) %]
                    <li
                        ><strong>Release maintainer:</strong>
                        [% INCLUDE person p=m %]
                    </li>
                [% END %]
            [% END %]

            [% IF t.maintainer_assistants %]
                [% FOREACH m IN t.maintainer_assistants %]
                    [% IF m.version == ( v ) %]
                        <ul
                            ><li><strong>Assistant:</strong> [% INCLUDE person p=m %]</li></ul
                        >
                    [% END %]
                [% END %]
            [% END %]

            [% IF t.maintainer_mentors %]
                [% FOREACH m IN t.maintainer_mentors %]
                    [% IF m.version == ( v ) %]
                        <ul
                            ><li><strong>Mentor:</strong> [% INCLUDE person p=m %]</li></ul
                        >
                    [% END %]
                [% END %]
            [% END %]
        [% END %]

        [% IF t.qa_manager %]
            <li
                ><strong>Quality assurance manager:</strong>
                [% INCLUDE person p=t.qa_manager %]
            </li>
        [% END %]

        [% IF t.qa %]
            <li
                ><strong>Quality assurance team:</strong>
                <ul>
                    [% FOREACH qa IN t.qa %]
                        <li>[% INCLUDE person p=qa %]</li>
                    [% END %]
                </ul>
            </li>
        [% END %]

        [% IF t.documentation %]
            [%- IF t.documentation.list.size == 1 %]
                <li
                    ><strong>Documentation manager:</strong>
                    [% INCLUDE person p=t.documentation %]
                </li>
            [% ELSE %]
                <li
                    ><strong>Documentation managers:</strong>
                    <ul>
                        [% FOREACH doc_manager IN t.documentation %]
                            <li>[% INCLUDE person p=doc_manager %]</li>
                        [% END %]
                    </ul>
                </li>
            [% END %]
        [% END %]

        [% IF t.documentation_team %]
            <li
                ><strong>Documentation team:</strong>
                <ul>
                    [% FOREACH doc_member IN t.documentation_team %]
                        <li>[% INCLUDE person p=doc_member %]</li>
                    [% END %]
                </ul>
            </li>
        [% END %]

        [% IF t.translation %]
            <li
                ><strong>Translation manager:</strong>
                [% INCLUDE person p=t.translation %]
            </li>
        [% END %]

        [% IF t.translations %]
            <li
                ><strong>Translation managers:</strong>
                <ul>
                    [% FOREACH translation_manager IN t.translations %]
                        <li>[% INCLUDE person p=translation_manager %]</li>
                    [% END %]
                </ul>
            </li>
        [% END %]

        [% IF t.packaging %]
            [% IF t.packaging.size / 2 == 1 %]
                <li
                    ><strong>Packaging manager:</strong>
                    [% INCLUDE person p=t.packaging %]
                </li>
            [% ELSE %]
                <li
                    ><strong>Packaging team:</strong>
                    <ul>
                        [% FOREACH pa IN t.packaging %]
                            <li>[% INCLUDE person p = pa %]</li>
                        [% END %]
                    </ul>
                </li>
            [% END %]
        [% END %]

        [% IF t.packaging_assistant %]
            [% IF t.packaging_assistant.size / 2 == 1 %]
                <li
                    ><strong>Packaging assistant:</strong>
                    [% INCLUDE person p=t.packaging_assistant %]
                </li>
            [% ELSE %]
                <li
                    ><strong>Packaging assistants:</strong>
                    <ul>
                        [% FOREACH pa IN t.packaging_assistant %]
                            <li>[% INCLUDE person p = pa %]</li>
                        [% END %]
                    </ul>
                </li>
            [% END %]
        [% END %]

        [% IF t.ci %]
            [% IF t.ci.size == 1 %]
                <li
                    ><strong>Continuous integration maintainer:</strong>
                    [% INCLUDE person p=t.ci.0 %]
                </li>
            [% ELSE %]
                <li
                    ><strong>Continuous integration maintainers:</strong>
                    <ul>
                        [% FOREACH j IN t.ci %]
                            <li>[% INCLUDE person p=j %] </li>
                        [% END %]
                    </ul>
                </li>
            [% END %]
        [% END %]

        [% IF t.ktd %]
            [% IF t.ktd.size == 1 %]
                <li
                    ><strong><a href="https://gitlab.com/koha-community/koha-testing-docker">KTD</a> maintainer:</strong>
                    [% INCLUDE person p=t.ktd.0 %]
                </li>
            [% ELSE %]
                <li
                    ><strong><a href="https://gitlab.com/koha-community/koha-testing-docker">KTD</a> maintainers:</strong>
                    <ul>
                        [% FOREACH j IN t.ktd %]
                            <li>[% INCLUDE person p=j %] </li>
                        [% END %]
                    </ul>
                </li>
            [% END %]
        [% END %]

        [% IF t.bugwrangler %]
            <li
                ><strong>Bug wranglers:</strong>
                <ul>
                    [% FOREACH bugwrangler IN t.bugwrangler %]
                        <li>[% INCLUDE person p=bugwrangler %]</li>
                    [% END %]
                </ul>
            </li>
        [% END %]

        [% IF t.accessibility_advocates %]
            <li
                ><strong>Accessibility advocates:</strong>
                <ul>
                    [% FOREACH a IN t.accessibility_advocates %]
                        <li>[% INCLUDE person p=a %]</li>
                    [% END %]
                </ul>
            </li>
        [% ELSIF t.accessibility_advocate %]
            <li
                ><strong>Accessibility advocate:</strong>
                [% INCLUDE person p=t.accessibility_advocate %]
            </li>
        [% END %]

        [% IF t.newsletter %]
            <li
                ><strong>Newsletter editor:</strong>
                [% INCLUDE person p=t.newsletter %]
            </li>
        [% END %]

        [% IF t.website %]
            <li
                ><strong>Website maintainer:</strong>
                [% INCLUDE person p=t.website %]
            </li>
        [% END %]

        [% IF t.social_media %]
            <li
                ><strong>Social media manager:</strong>
                [% INCLUDE person p=t.social_media %]
            </li>
        [% END %]

        [% IF t.wiki %]
            [% IF t.wiki.size == 1 %]
                <li
                    ><strong>Wiki manager:</strong>
                    [% INCLUDE person p=t.wiki %]
                </li>
            [% ELSE %]
                <li
                    ><strong>Wiki team:</strong>
                    <ul>
                        [% FOREACH wi IN t.wiki %]
                            <li>[% INCLUDE person p = wi %]</li>
                        [% END %]
                    </ul>
                </li>
            [% END %]
        [% END %]

        [% IF t.meeting_facilitator %]
            <li
                ><strong>Meeting facilitator:</strong>
                [% INCLUDE person p=t.meeting_facilitator %]
            </li>
        [% END %]

        [% IF t.chairperson %]
            <li
                ><strong>Meetings chairperson:</strong>
                [% INCLUDE person p=t.chairperson %]
            </li>
        [% END %]

        [% IF t.database %]
            <li
                ><strong>Documentation specialist:</strong>
                [% INCLUDE person p=t.database %]
            </li>
        [% END %]

        [% IF t.live_cd %]
            <li
                ><strong>Live CD maintainer:</strong>
                [% INCLUDE person p=t.live_cd %]
            </li>
        [% END %]

        [% IF t.vm %]
            <li
                ><strong>Virtual machine maintainer:</strong>
                [% INCLUDE person p=t.vm %]
            </li>
        [% END %]

        [% IF t.translation_assistant %]
            <li
                ><strong>Translation manager assistant:</strong>
                [% INCLUDE person p=t.translation_assistant %]
            </li>
        [% END %]

        [% IF v != 'release' %]
            <li
                ><strong>Release manager:</strong>
                [% INCLUDE person p=t.manager %]
            </li>

            [% IF t.manager_assistants %]
                <li
                    ><strong>Release manager assistants:</strong>
                    <ul>
                        [% FOREACH a IN t.manager_assistants %]
                            <li>[% INCLUDE person p=a %]</li>
                        [% END %]
                    </ul>
                </li>
            [% ELSIF t.manager_assistant %]
                <li
                    ><strong>Release manager assistant:</strong>
                    [% INCLUDE person p=t.manager_assistant %]
                </li>
            [% END %]
        [% ELSE %]
            <li
                ><strong>Release maintainers:</strong>
                <ul>
                    [% FOREACH m IN t.maintainer %]
                        <li>[% m.version | html %] - [% INCLUDE person p=m %]</li>
                        [% IF t.maintainer_assistants %]
                            [% FOREACH ma IN t.maintainer_assistants %]
                                [% IF ma.version == ( m.version ) %]
                                    <ul
                                        ><li><strong>Assistant:</strong> [% INCLUDE person p=ma %]</li></ul
                                    >
                                [% END %]
                            [% END %]
                        [% END %]

                        [% IF t.maintainer_mentors %]
                            [% FOREACH mm IN t.maintainer_mentors %]
                                [% IF m.version == ( mm.version ) %]
                                    <ul
                                        ><li><strong>Mentor:</strong> [% INCLUDE person p=mm %]</li></ul
                                    >
                                [% END %]
                            [% END %]
                        [% END %]
                    [% END %]
                </ul>
            </li>
        [% END %]
    </ul>
[%- END -%]
