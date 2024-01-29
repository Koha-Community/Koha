[% USE raw %]
<!-- Add cite modal -->
<div class="modal" id="citeModal" tabindex="-1" role="dialog" aria-labelledby="citeLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title" id="citeModalLabel">[% biblio.title | html %]</h3>
                <button type="button" class="closebtn" data-dismiss="modal" aria-label="Close">
                <span aria-hidden="true">&times;</span>
            </div>
            <div class="modal-body">
                [% FOREACH system IN cites.keys.sort %]
                <h3>[% system %]</h3>
                <p>[% cites.$system | html %]</p>
                [% END %]
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>
