[% BLOCK showreference %]
    [% IF marcflavour == 'UNIMARC' %]
        [% SWITCH type %]
        [% CASE 'broader' %]
            <span class="BT">[% heading | html %]</span> --
        [% CASE 'narrower' %]
            <span class="NT">[% heading | html %]</span> --
        [% CASE 'narrower' %]
            <span class="NT">[% heading | html %]</span> --
        [% CASE 'seefrom' %]
            <span class="UF">[% heading | html %]</span> --
        [% CASE 'seealso' %]
            <span class="RT">[% heading | html %]</span> --
        [% END %]
    [% ELSE %]
        [% IF ( label ) %]<span class="label">[% label | html %]</span>[% END %]
        <span class="heading">
        [% IF ( linkpath && search ) %]<a href="[% link | url %][% search | url %]">[% heading | html %]</a>
        [% ELSE %][% heading | html %][% END %]
        </span>
        [% UNLESS ( type=='seefrom' || type=='seealso' ) %]<span class="type">[% SWITCH type %]
        [% CASE 'earlier' %](Earlier heading)
        [% CASE 'later' %](Later heading)
        [% CASE 'acronym' %](Acronym)
        [% CASE 'musical' %](Musical composition)
        [% CASE 'broader' %](Broader heading)
        [% CASE 'narrower' %](Narrower heading)
        [% CASE 'parent' %](Immediate parent body)
        [% CASE %][% IF type %]([% type | html %])[% END %]
        [% END %]</span>[% END %]
    [% END %]
[% END %]
[% BLOCK authresult %]
    [% IF ( summary.summary ) %][% summary.summary | html %]:[% END %]
    [% UNLESS ( summary.summaryonly ) %]
        [% FOREACH authorize IN summary.authorized %]
            <span class="authorizedheading">[% authorize.heading | html %]</span>
        [% END %]
        [% IF ( marcflavour == 'UNIMARC' ) %]
            [% FOREACH note IN summary.notes %]
                <span class="note">[% note | html %]</span>
            [% END %]
            [% FOREACH seefro IN summary.seefrom %]
                [% PROCESS showreference heading=seefro.heading label="" type=seefro.type search='' %]
            [% END %]
        [% ELSE %]
            [% IF ( summary.seefrom ) %]
                [% FOREACH seefro IN summary.seefrom %]
                    <div class="seefrom authref">
                    [% PROCESS showreference heading=seefro.heading label="used for/see from:" type=seefro.type search='' %]
                    </div>
                [% END %]
            [% END %]
            [% IF ( summary.seealso ) %]
                [% FOREACH seeals IN summary.seealso %]
                    <div class="seealso authref">
                    [% PROCESS showreference heading=seeals.heading label="see also:" type=seeals.type linkpath=link search=seeals.search %]
                    </div>
                [% END %]
            [% END %]
        [% END %]
    [% END %]
[% END %]
