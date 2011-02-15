<tfoot>
	<tr>
		<td colspan="5" style="text-align: right; font-weight:bold;">Totals:</td>
		<td><!-- TMPL_VAR NAME="totaldue" --></td>
		<td><!-- TMPL_VAR NAME="totalprice" --></td>
		<td colspan="2">
			<p>Renewal due date: <input type="text" size="8" id="newduedate" name="newduedate" value="<!-- TMPL_VAR Name="newduedate" -->" />
			<img src="<!-- TMPL_VAR Name="themelang" -->/lib/calendar/cal.gif" id="newduedate_button" alt="Show Calendar" />
			<script type="text/javascript"> //<![CDATA[
			//#TODO - ADD syspref (AllowPostDatedCheckouts).
			 Calendar.setup(
			      {
			         inputField : "newduedate",
			         ifFormat : "<!-- TMPL_VAR NAME="DHTMLcalendar_dateformat" -->",
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
