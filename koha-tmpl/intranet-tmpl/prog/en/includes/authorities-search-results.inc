[% USE raw %]
[% BLOCK showreference %]
[%# Parameters: %]
[%# heading: the heading itself %]
[%# linkType: currently 'seefrom' or 'seealso', controls the label for the entry type: %]
[%# authid: if it is a linked authority, its authid %]

    [% SET authidurl = '/cgi-bin/koha/authorities/detail.pl?authid=' %]
    [% SET searchurl = '/cgi-bin/koha/authorities/authorities-home.pl?op=do_search&type=intranet&marclist=any&operator=contains&orderby=HeadingAsc&value=' %]

    [% IF marcflavour == 'UNIMARC' %]
        [% IF authid %]
            [% link = BLOCK %]<a href="[% authidurl _ authid | $raw %]">[% heading | html %]</a>[% END %]
        [% ELSE %]
            [% link = BLOCK %][% heading | html %][% END %]
        [% END %]
        [% SWITCH type %]
        [% CASE 'broader' %]
            <span class="BT"><abbr title="Broader Term">BT</abbr>: [% link | $raw %]</span>
        [% CASE 'narrower' %]
            <span class="NT"><abbr title="Narrower Term">NT</abbr>: [% link | $raw %]</span>
        [% CASE 'seefrom' %]
            <span class="UF"><abbr title="Used For">UF</abbr>: [% link | $raw %]</span>
        [% CASE 'seealso' %]
            <span class="RT"><abbr title="Related Term">RT</abbr>: [% link | $raw %]</span>
        [% END %]
    [% ELSE %]
        <span class="heading">
        [% IF ( linkType=='seealso' ) %]
            [% IF ( authid ) %]
            <a href="[% authidurl | url %][% authid | url %]">[% heading | html %]</a>
            [% ELSE %]
            <a href="[% searchurl | url %][% heading | html %]">[% heading | html %]</a>
            [% END %]
        [% ELSE %]
            [% heading | html %]
        [% END %]
        </span>
        [% UNLESS ( type=='seefrom' || type=='seealso' ) %]
        <span class="type">
            [% SWITCH type %]
            [% CASE 'earlier' %](Earlier heading)
            [% CASE 'later' %](Later heading)
            [% CASE 'acronym' %](Acronym)
            [% CASE 'musical' %](Musical composition)
            [% CASE 'broader' %](Broader heading)
            [% CASE 'narrower' %](Narrower heading)
            [% CASE 'parent' %](Immediate parent body)
            [% CASE %][% IF type %]([% type | html %])
            [% END %]
        [% END %]
        </span>
        [% END %]
    [% END %]
[% END %]
[% BLOCK authresult %]
    [% IF ( summary.label ) %][% summary.label | html %]:[% END %]
    [% IF summary.summary %]
      <div class="authority-summary">
        [% summary.summary | html %]
      </div>
    [% END %]
    [% UNLESS ( summary.summaryonly ) %]
        <div class="authorizedheading">
          [% FOREACH authorize IN summary.authorized %]
            <span class="authorizedheading">[% authorize.heading | html %]</span>
            [% UNLESS loop.last %] | [% END %]
          [% END %]
        </div>
        [% IF ( marcflavour == 'UNIMARC' ) %]
          [% IF summary.notes %]
           <div class="authres_notes">
           [% FOREACH note IN summary.notes %]
             <span>[% note.note | html %]</span>
           [% END %]
           </div>
          [% END %]
          [% IF summary.seefrom %]
            <div class="authres_seefrom">
            [% FOREACH see IN summary.seefrom %]
              [% PROCESS showreference heading=see.heading linkType="" type=see.type authid=see.authid %]
              [% IF ! loop.last %] ; [% END %]
            [% END %]
            </div>
          [% END %]
            [% IF summary.seealso %]
              <div class="authres_seealso">
              [% FOREACH see IN summary.seealso %]
                 [% PROCESS showreference heading=see.heading linkType="" type=see.type authid=see.authid %]
                 [% IF ! loop.last %] ; [% END %]
              [% END %]
              </div>
            [% END %]
            [% IF summary.otherscript %]
              <div class="authres_otherscript">
              [% FOREACH other IN summary.otherscript %]
                [% PROCESS language lang=other.lang | trim %]:
                [% other.term | html %]
                [% IF ! loop.last %] ; [% END %]
              [% END %]
              </div>
            [% END %]
        [% ELSE %]
            [% IF ( summary.seefrom.size >= 1 ) %]
            <div class="seefrom">
                <span class="seefrom">used for/see from:</span>
                [% FOREACH seefro IN summary.seefrom %]
                    <div class="authref">
                    [%# Following on one line for translatability %]
                    [% PROCESS showreference heading=seefro.heading linkType='seefrom' type=seefro.type authid=seefro.authid %]
                    </div>
                [% END %]
            </div>
            [% END %]
            [% IF ( summary.seealso.size >= 1 ) %]
            <div class="seealso">
                <span class="seealso">see also:</span>
                [% FOREACH seeals IN summary.seealso %]
                    <div class="authref">
                    [%# Following on one line for translatability %]
                    [% PROCESS showreference heading=seeals.heading linkType='seealso' type=seeals.type authid=seeals.authid %]
                    </div>
                [% END %]
            </div>
            [% END %]
        [% END %]
    [% END %]
[% END %]
[% BLOCK language %]
  [% SWITCH lang %]
   [% CASE ['en', 'eng'] %]English
   [% CASE ['fr', 'fre'] %]French
   [% CASE ['it', 'ita'] %]Italian
   [% CASE ['de', 'ger', 'deu'] %]German
   [% CASE ['es', 'spa'] %]Spanish
   [% CASE ['heb'] %]Hebrew
   [% CASE ['ara'] %]Arabic
   [% CASE ['gre'] %]Greek (modern)
   [% CASE ['grc'] %]Greek (to 1453)
   [% CASE %][% lang | html %]
  [% END %]
[% END %]
