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
            [% link = BLOCK %]<a href="[% authidurl _ authid | url %]">[% heading | html %]</a>[% END %]
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
            <a href="[% authidurl | url %][% authid | uri %]">[% heading | html %]</a>
            [% ELSE %]
            <a href="[% searchurl | url %][% heading | uri %]">[% heading | html %]</a>
            [% END %]
        [% ELSE %]
            [% heading | html %]
        [% END %]
        </span>
        [% UNLESS ( type=='seefrom' || type=='seealso' ) %]
        <span class="type">
            [% SWITCH type %]
            [% CASE 'earlier' %]<span>(Earlier heading)</span>
            [% CASE 'later' %]<span>(Later heading)</span>
            [% CASE 'acronym' %]<span>(Acronym)</span>
            [% CASE 'musical' %]<span>(Musical composition)</span>
            [% CASE 'broader' %]<span>(Broader heading)</span>
            [% CASE 'narrower' %]<span>(Narrower heading)</span>
            [% CASE 'parent' %]<span>(Immediate parent body)</span>
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
            <span class="authorizedheading [% IF auth_preview %]authority_preview[% END %]">
                <a data-authid="[% authid | html %]" href="/cgi-bin/koha/authorities/detail.pl?authid=[% authid | uri %]">[% authorize.heading | html %]</a>
            </span>
            [% UNLESS loop.last %] | [% END %]
          [% END %]
        </div>
        [% IF summary.equalterm.size %]
            [% FOREACH term IN summary.equalterm %]
                <div class="equivalentheading">
                        <span class="label">=</span>
                        <span class="authorizedheading">[% term.heading | html %]</span>
                </div>
            [% END %]
        [% END %]
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
            [% IF summary.notes.size %]
                <div class="authres_notes">
                    [% PROCESS notesmodal notes=summary.notes authid=authid %]
                    <span><a href="#" data-toggle="modal" data-target="#notesModal_[% authid | html %]">Notes</a></span>
                </div>
            [% END %]
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
   [% CASE ['en', 'eng'] %]<span>English</span>
   [% CASE ['fr', 'fre'] %]<span>French</span>
   [% CASE ['it', 'ita'] %]<span>Italian</span>
   [% CASE ['de', 'ger', 'deu'] %]<span>German</span>
   [% CASE ['es', 'spa'] %]<span>Spanish</span>
   [% CASE ['heb'] %]<span>Hebrew</span>
   [% CASE ['ara'] %]<span>Arabic</span>
   [% CASE ['gre'] %]<span>Greek (modern)</span>
   [% CASE ['grc'] %]<span>Greek (to 1453)</span>
   [% CASE %]<span>[% lang | html %]</span>
  [% END %]
[% END %]

[% BLOCK notesmodal %]
<!-- notes modal -->
<div style='font-style:normal;' class="modal fade notesModal" id="notesModal_[% authid | html %]" tabindex="-1" role="dialog" aria-labelledby="notesModalLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="closebtn" data-dismiss="modal" aria-hidden="true">×</button>
                <h4 class="modal-title" id="notesModalLabel">Notes</h4>
            </div>
            <div class="modal-body">
                <ul>
                    [% FOREACH note IN notes %]
                        <li>[% note.note | html %]</li>
                    [% END %]
                </ul>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>
[% END %]
