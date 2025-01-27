<tfoot>
    <tr>
        <td colspan="15" style="text-align: right; font-weight:bold;">Totals:</td>
        <td id="totaldue" style="text-align: right;"></td>
        <td id="totalfine" style="text-align: right;"></td>
        <td id="totalprice" style="text-align: right;"></td>
        [% IF Koha.Preference('ExportCircHistory') %]
            [% SET td_colspan = 4 %]
        [% ELSE %]
            [% SET td_colspan = 3 %]
        [% END %]
        <td colspan="[% td_colspan | html %]">
            <div class="date-select">
                <p><label for="newduedate">Renewal due date:</label> <input type="text" size="20" id="newduedate" name="newduedate" value="" class="flatpickr" data-flatpickr-enable-time="true" /></p>
                <p id="newonholdduedate"
                    ><label for="newonholdduedatefield">On hold due date:</label> <input type="text" size="20" name="newonholdduedate" value="" id="newonholdduedatefield" class="flatpickr" data-flatpickr-enable-time="true"
                /></p>
                <p><label for="exemptfine">Forgive fines on return:</label> <input type="checkbox" id="exemptfine" name="exemptfine" value="1" /></p>
            </div>
        </td>
    </tr>
</tfoot>
