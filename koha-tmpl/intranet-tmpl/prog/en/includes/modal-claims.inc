[% USE Koha %]
<!-- modal-claims.inc -->

[% BLOCK 'modal-claims-display' %]
    <!-- Claims Returned Modal -->
    <div class="modal fade" id="claims-returned-modal" tabindex="-1" role="dialog" aria-labelledby="claims-returned-modal-label">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title" id="claims-returned-modal-label">Claim returned</h4>
                </div>
                <div class="modal-body">

                    <div class="form-group">
                        <label for="claims-returned-notes" class="control-label">Notes</label>
                        <div>
                        <textarea id="claims-returned-notes" class="form-control" rows="3"></textarea>
                        </div>
                    </div>

                    [% IF Koha.Preference('ClaimReturnedChargeFee') == 'ask' %]
                        <div class="form-group">
                        <div class="checkbox">
                            <label for="claims-returned-charge-lost-fee">
                            <input id="claims-returned-charge-lost-fee" type="checkbox" value="1">
                            Charge lost fee
                            </label>
                        </div>
                        </div>
                    [% END %]

                    <input type="hidden" id="claims-returned-itemnumber" />
                </div>
                <div class="modal-footer">
                    <button id="claims-returned-modal-btn-submit" type="button" class="btn btn-primary"><i class="fa fa-exclamation-circle"></i> Make claim</button>
                    <button class="btn btn-default deny cancel" href="#" data-dismiss="modal" aria-hidden="true"><i class="fa fa-times"></i> Cancel</button>
                </div>
            </div>
        </div>
    </div>
[% END %]

[% BLOCK 'modal-claims-js' %]
<script>

    // Verify if the syspref is defined
    var ClaimReturnedLostValue = "[% Koha.Preference('ClaimReturnedLostValue') | html %]";

    var logged_in_user_borrowernumber = "[% logged_in_user.borrowernumber | html %]";
    var interface = "[% interface | html %]";
    var theme = "[% theme | html %]";

    // Handle return claims
    $(document).on("click", '.claim-returned-btn', function(e){
        e.preventDefault();
        itemnumber = $(this).data('itemnumber');

        $('#claims-returned-itemnumber').val(itemnumber);
        $('#claims-returned-notes').val("");
        $('#claims-returned-charge-lost-fee').attr('checked', false);
        $('#claims-returned-modal').modal();
    });
    $(document).on("click", '#claims-returned-modal-btn-submit', function(e){
        let itemnumber = $('#claims-returned-itemnumber').val();
        let notes = $('#claims-returned-notes').val();
        let fee = $('#claims-returned-charge-lost-fee').attr('checked') ? true : false;

        $('#claims-returned-modal').modal('hide');

        const button = $('.claim-returned-btn[data-itemnumber="' + itemnumber + '"]');
        const img = '<img id="return_claim_spinner_' + itemnumber + '" src="' + interface + '/' + theme + '/img/spinner-small.gif" />';
        button.replaceWith(img);

        params = {
            item_id: itemnumber,
            notes: notes,
            charge_lost_fee: fee,
            created_by: logged_in_user_borrowernumber,
        };

        $.post( '/api/v1/return_claims', JSON.stringify(params), function( data ) {

            id = "#return_claim_spinner_" + data.item_id;

            let formated_date = $datetime(data.created_on);

            let content = "";
            if ( data.claim_id ) {
                content = '<span class="badge">' + formated_date + '</span>';
                $(id).parent().parent().addClass('ok');
            } else {
                content = _("Unable to claim as returned");
                $(id).parent().parent().addClass('warn');
            }

            $(id).replaceWith( content );

            $('body').trigger('refreshClaimModal');
        }, "json")
    });
</script>
[% END %]
