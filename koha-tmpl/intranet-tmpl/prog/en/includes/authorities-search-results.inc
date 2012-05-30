[% BLOCK showreference %]
    [% IF marcflavour == 'UNIMARC' %]
        [% SWITCH type %]
        [% CASE 'broader' %]
            <span class="BT">[% heading %]</span> --
        [% CASE 'narrower' %]
            <span class="NT">[% heading %]</span> --
        [% CASE 'narrower' %]
            <span class="NT">[% heading %]</span> --
        [% CASE 'seefrom' %]
            <span class="UF">[% heading %]</span> --
        [% CASE 'seealso' %]
            <span class="RT">[% heading %]</span> --
        [% END %]
    [% ELSE %]
        [% IF ( label ) %]<span class="label">[% label %]</span>[% END %]
        <span class="heading">[% heading %]</span>
        [% UNLESS ( type=='seefrom' || type=='seealso' ) %]<span class="type">[% SWITCH type %]
        [% CASE 'earlier' %](Earlier heading)
        [% CASE 'later' %](Later heading)
        [% CASE 'acronym' %](Acronym)
        [% CASE 'musical' %](Musical composition)
        [% CASE 'broader' %](Broader heading)
        [% CASE 'narrower' %](Narrower heading)
        [% CASE %]([% type %])
        [% END %]</span>[% END %]
    [% END %]
[% END %]
[% BLOCK authresult %]
    [% IF ( summary.summary ) %][% summary.summary %]:[% END %]
    [% UNLESS ( summary.summaryonly ) %]
        [% FOREACH authorize IN summary.authorized %]
            <span class="authorizedheading">[% authorize %]</span>
        [% END %]
        [% IF ( marcflavour == 'UNIMARC' ) %]
            [% FOREACH note IN summary.notes %]
                <span class="note">[% note %]</span>
            [% END %]
            [% FOREACH seefro IN summary.seefrom %]
                [% PROCESS showreference heading=seefro.heading label="" type=seefro.type %]
            [% END %]
        [% ELSE %]
            [% IF ( summary.seefrom ) %]
                [% FOREACH seefro IN summary.seefrom %]
                    <div class="seefrom authref">
                    [% PROCESS showreference heading=seefro.heading label="used for/see from:" type=seefro.type %]
                    </div>
                [% END %]
            [% END %]
            [% IF ( summary.seealso ) %]
                [% FOREACH seeals IN summary.seealso %]
                    <div class="seealso authref">
                    [% PROCESS showreference heading=seeals.heading label="see also:" type=seeals.type %]
                    </div>
                [% END %]
            [% END %]
        [% END %]
    [% END %]
[% END %]
