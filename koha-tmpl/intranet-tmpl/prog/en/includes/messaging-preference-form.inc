<!-- snippet for form to set borrower and patron category messaging preferences -->
<script type="text/javascript">//<![CDATA[
	$(document).ready(function(){
		$(".none").click(function(){
			if($(this).attr("checked")){
				var rowid = $(this).attr("id");
				newid = Number(rowid.replace("none","")) 
			  	$("#sms"+newid).attr("checked","");
			  	$("#email"+newid).attr("checked","");
			  	$("#digest"+newid).attr("checked","");
			  	$("#rss"+newid).attr("checked","");
			}
		});
	});
//]]>
</script>

<input type="hidden" name="modify" value="yes" />
<input type="hidden" name="borrowernumber" value="<!-- TMPL_VAR NAME="borrowernumber" -->" />
  <table>
    <tr><th></th>
        <th>Days in advance</th>
        <!-- TMPL_IF NAME="SMSSendDriver" --><th>SMS</th><!-- /TMPL_IF -->
        <th>Email</th><th>Digests only?</th>
        <!-- <th>RSS</th> -->
        <!-- TMPL_UNLESS NAME="messaging_form_inactive" --><th>Do not notify</th><!-- /TMPL_UNLESS -->
    </tr>
    <!-- TMPL_LOOP name="messaging_preferences" -->
    <tr>
      <td><!-- TMPL_VAR NAME="message_name" --></td>
      <!-- TMPL_IF NAME="takes_days" -->
      <td>
          <!-- TMPL_IF NAME="messaging_form_inactive" -->
            <select name="<!-- TMPL_VAR NAME="message_attribute_id" -->-DAYS" disabled="disabled">
          <!-- TMPL_ELSE -->
            <select name="<!-- TMPL_VAR NAME="message_attribute_id" -->-DAYS">
          <!-- /TMPL_IF -->
          <!-- TMPL_LOOP name="select_days" -->
          <!-- TMPL_IF NAME="selected" --><option value="<!-- TMPL_VAR NAME="day" -->" selected="selected"><!-- TMPL_VAR NAME="day" --></option><!-- TMPL_ELSE -->
          <option value="<!-- TMPL_VAR NAME="day" -->"><!-- TMPL_VAR NAME="day" --></option>
      <!-- /TMPL_IF -->
          <!-- /TMPL_LOOP -->
        </select>
      </td>
      <!-- TMPL_ELSE -->
      <td>-</td>
      <!-- /TMPL_IF -->
      <!-- TMPL_IF NAME="transport-sms" -->
      <!-- TMPL_IF NAME="SMSSendDriver" --><td>
          <!-- TMPL_IF NAME="messaging_form_inactive" -->
                 <input type="checkbox"
                 id="sms<!-- TMPL_VAR NAME="message_attribute_id" -->"
                 name="<!-- TMPL_VAR NAME="message_attribute_id" -->"
                 value="sms"   <!-- TMPL_VAR NAME="transport-sms" --> disabled="disabled" />
          <!-- TMPL_ELSE -->
                 <input type="checkbox"
                 id="sms<!-- TMPL_VAR NAME="message_attribute_id" -->"
                 name="<!-- TMPL_VAR NAME="message_attribute_id" -->"
                 value="sms"   <!-- TMPL_VAR NAME="transport-sms"   --> onclick = "$('#none'+'<!-- TMPL_VAR NAME="message_attribute_id" -->').attr('checked','');" />
          <!-- /TMPL_IF -->
      </td><!-- /TMPL_IF -->
      <!-- TMPL_ELSE -->
      <td>-</td>
      <!-- /TMPL_IF -->

      <!-- TMPL_IF NAME="transport-email" -->
      <td>
          <!-- TMPL_IF NAME="messaging_form_inactive" -->
            <input type="checkbox"
                 id="email<!-- TMPL_VAR NAME="message_attribute_id" -->"
                 name="<!-- TMPL_VAR NAME="message_attribute_id" -->"
                 value="email"   <!-- TMPL_VAR NAME="transport-email"   --> disabled="disabled" />
          <!-- TMPL_ELSE -->
            <input type="checkbox"
                 id="email<!-- TMPL_VAR NAME="message_attribute_id" -->"
                 name="<!-- TMPL_VAR NAME="message_attribute_id" -->"
                 value="email"   <!-- TMPL_VAR NAME="transport-email"   --> onclick = "$('#none'+'<!-- TMPL_VAR NAME="message_attribute_id" -->').attr('checked','');" />
          <!-- /TMPL_IF -->
      </td>
      <!-- TMPL_ELSE -->
      <td>-</td>
      <!-- /TMPL_IF -->

      <!-- TMPL_IF NAME="has_digest" -->
      <td>
          <!-- TMPL_IF NAME="messaging_form_inactive" -->
            <input type="checkbox"
                 id="digest<!-- TMPL_VAR NAME="message_attribute_id" -->"
                 value="<!-- TMPL_VAR NAME="message_attribute_id" -->"
                 name="digest"   <!-- TMPL_VAR NAME="digest"   --> disabled="disabled" />
          <!-- TMPL_ELSE -->
            <input type="checkbox"
                 id="digest<!-- TMPL_VAR NAME="message_attribute_id" -->"
                 value="<!-- TMPL_VAR NAME="message_attribute_id" -->"
                 name="digest"   <!-- TMPL_VAR NAME="digest"   --> onclick = "$('#none'+'<!-- TMPL_VAR NAME="message_attribute_id" -->').attr('checked','');" />
          <!-- /TMPL_IF -->
      </td>
      <!-- TMPL_ELSE -->
      <td>-</td>
      <!-- /TMPL_IF -->

<!--       <!-- TMPL_IF NAME="transport-rss" -->
      <td>
          <!-- TMPL_IF NAME="messaging_form_inactive" -->
            <input type="checkbox"
                 id="rss<!-- TMPL_VAR NAME="message_attribute_id" -->"
                 name="<!-- TMPL_VAR NAME="message_attribute_id" -->"
                 value="rss"   <!-- TMPL_VAR NAME="transport-rss"   --> disabled="disabled" />
          <!-- TMPL_ELSE -->
            <input type="checkbox"
                 id="rss<!-- TMPL_VAR NAME="message_attribute_id" -->"
                 name="<!-- TMPL_VAR NAME="message_attribute_id" -->"
                 value="rss"   <!-- TMPL_VAR NAME="transport-rss"   --> onclick = "$('#none'+'<!-- TMPL_VAR NAME="message_attribute_id" -->').attr('checked','');" />
          <!-- /TMPL_IF -->
      </td>
      <!-- TMPL_ELSE -->
      <td>-</td>
      <!-- /TMPL_IF --> -->

      <!-- TMPL_UNLESS NAME="messaging_form_inactive" -->
      <td><input type="checkbox" class="none" id="none<!-- TMPL_VAR NAME="message_attribute_id" -->" /></td>
      <!-- /TMPL_UNLESS -->
    </tr>
    <!-- /TMPL_LOOP -->
  </table>
