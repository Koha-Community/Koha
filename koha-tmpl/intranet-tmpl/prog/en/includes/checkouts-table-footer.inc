<tfoot>
	<tr>
        <td colspan="11" style="text-align: right; font-weight:bold;">Totals:</td>
        <td id="totaldue" style="text-align: right;">[% totaldue | html %]</td>
        <td id="totalfine" style="text-align: right;">[% finetotal | html %]</td>
        <td id="totalprice" style="text-align: right;">[% totalprice | html %]</td>
                <td colspan="3"><div class="date-select">
            <p><label for="newduedate">Renewal due date:</label> <input type="text" size="12" id="newduedate" name="newduedate" value="[% newduedate | html %]" />
</p>
            <p><label for="exemptfine">Forgive fines on return: <input type="checkbox" id="exemptfine" name="exemptfine" value="1" /></label></p></div>
		</td>
	</tr>
</tfoot>
