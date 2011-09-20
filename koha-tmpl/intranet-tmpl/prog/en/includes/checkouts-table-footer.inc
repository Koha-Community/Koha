<tfoot>
	<tr>
        <td colspan="6" style="text-align: right; font-weight:bold;">Totals:</td>
		<td>[% totaldue %]</td>
		<td>[% totalprice %]</td>
		<td colspan="2">
			<p>Renewal due date: <input type="text" size="8" id="newduedate" name="newduedate" value="[% newduedate %]" />
			<img src="[% themelang %]/lib/calendar/cal.gif" id="newduedate_button" alt="Show Calendar" />
			<script type="text/javascript"> //<![CDATA[
			//#TODO - ADD syspref (AllowPostDatedCheckouts).
			 Calendar.setup(
			      {
			         inputField : "newduedate",
			         ifFormat : "[% DHTMLcalendar_dateformat %]",
			         button : "newduedate_button",
			         disableFunc : validate1,
			         dateStatusFunc : validate1
			       }
			    );
			//]]>
			</script></p>
			<p><label>Forgive fines on return: <input type="checkbox" name="exemptfine" value="1" /></label></p>
		</td>
	</tr>
</tfoot>
