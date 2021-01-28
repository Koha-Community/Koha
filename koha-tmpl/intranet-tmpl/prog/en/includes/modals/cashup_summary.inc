<!-- Cashup summary modal -->
<div class="modal printable" id="cashupSummaryModal" tabindex="-1" role="dialog" aria-labelledby="cashupSummaryLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="closebtn" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="cashupSummaryLabel">Cashup summary</h4>
            </div>
            <div class="modal-body">
                <ul>
                    <li>Cash register: <span id="register_description"></span></li>
                    <li>Period: <span id="from_date"></span> to <span id="to_date"></span></li>
                </ul>
                <table>
                    <thead>
                        <tr>
                            <th>Type</th>
                            <th>Total</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                    <tfoot>
                    </tfoot>
                </table>
            </div> <!-- /.modal-body -->
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                <button type="button" class="printModal btn btn-primary"><i class="fa fa-print"></i> Print</button>
            </div> <!-- /.modal-footer -->
        </div> <!-- /.modal-content -->
    </div> <!-- /.modal-dialog -->
</div> <!-- /#cashupSummaryModal -->
