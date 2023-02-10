[% USE Koha %]
<!-- snippet for form to set borrower and patron category messaging preferences -->

<script>
    var TalkingTechItivaPhoneNotification = [% Koha.Preference('TalkingTechItivaPhoneNotification') || 0 | html %];
    var PhoneNotification = [% Koha.Preference('PhoneNotification') || 0 | html %];
</script>
<input type="hidden" name="modify" value="yes" />
<input type="hidden" name="borrowernumber" value="[% borrowernumber | html %]" />
  <table>
    <tr><th></th>
        <th>Days in advance</th>
        [% IF Koha.Preference('SMSSendDriver') %]<th>SMS</th>[% END %]
        [% IF Koha.Preference('TalkingTechItivaPhoneNotification') || Koha.Preference('PhoneNotification') %]<th>Phone</th>[% END %]
        <th>Email</th>
        <th>Digests only <i id="info_digests" data-toggle="tooltip" title="You can ask for a digest to reduce the number of messages. Messages will be saved and sent as a single message." data-placement="right" class="fa fa-info-circle"></i></th>
        <!-- <th>RSS</th> -->
    </tr>
    [% FOREACH messaging_preference IN messaging_preferences %]
    [% NEXT IF !Koha.Preference( 'ILLModule' ) && messaging_preference.message_name.match('^Ill_') %]
    [% NEXT IF messaging_preference.Auto_Renewals && Koha.Preference('AutoRenewalNotices') != 'preferences' %]
    <tr id="[% messaging_preference.message_name _ "_message" | lower %]">
      <td>[% IF ( messaging_preference.Item_Due ) %]<span>Item due</span>
          [% ELSIF ( messaging_preference.Advance_Notice ) %]<span>Advance notice</span>
          [% ELSIF ( messaging_preference.Hold_Filled ) %]<span>Hold filled</span>
          [% ELSIF ( messaging_preference.Hold_Reminder ) %]<span>Hold reminder</span>
          [% ELSIF ( messaging_preference.Item_Check_in ) %]<span>Item check-in</span>
          [% ELSIF ( messaging_preference.Item_Checkout ) %]
            [% IF Koha.Preference( 'RenewalSendNotice' ) %]
                Item checkout and renewal
            [% ELSE %]
                Item checkout
            [% END %]
          [% ELSIF ( messaging_preference.Ill_ready ) %]Interlibrary loan ready
          [% ELSIF ( messaging_preference.Ill_unavailable ) %]Interlibrary loan unavailable
          [% ELSIF ( messaging_preference.Auto_Renewals ) %]Auto renewal
          [% ELSE %]Unknown [% END %]</td>
      [% IF ( messaging_preference.takes_days ) %]
      <td>
          [% IF ( messaging_form_inactive ) %]
            <select name="[% messaging_preference.message_attribute_id | html %]-DAYS" disabled="disabled">
          [% ELSE %]
            <select name="[% messaging_preference.message_attribute_id | html %]-DAYS">
          [% END %]
          [% FOREACH select_day IN messaging_preference.select_days %]
          [% IF ( select_day.selected ) %]<option value="[% select_day.day | html %]" selected="selected">[% select_day.day | html %]</option>[% ELSE %]
          <option value="[% select_day.day | html %]">[% select_day.day | html %]</option>
      [% END %]
          [% END %]
        </select>
      </td>
      [% ELSE %]
      <td>-</td>
      [% END %]

      [% IF Koha.Preference('SMSSendDriver') %]
        [% IF ( messaging_preference.transport_sms ) %]
          <td>
          [% IF ( messaging_form_inactive ) %]
              [% IF ( messaging_preference.transports_sms ) %]
                 <input type="checkbox"
                 id="sms[% messaging_preference.message_attribute_id | html %]"
                 name="[% messaging_preference.message_attribute_id | html %]"
                 value="sms" class="pmp_sms" checked="checked" disabled="disabled" />
              [% ELSE %]
                 <input type="checkbox"
                 id="sms[% messaging_preference.message_attribute_id | html %]"
                 name="[% messaging_preference.message_attribute_id | html %]"
                 value="sms" class="pmp_sms" disabled="disabled" />
              [% END %]
          [% ELSE %]
              [% IF ( messaging_preference.transports_sms ) %]
                 <input type="checkbox"
                 id="sms[% messaging_preference.message_attribute_id | html %]"
                 name="[% messaging_preference.message_attribute_id | html %]"
                 value="sms" checked="checked" class="pmp_sms active_notify" data-attr-id="[% messaging_preference.message_attribute_id | html %]" />
              [% ELSE %]
                 <input type="checkbox"
                 id="sms[% messaging_preference.message_attribute_id | html %]"
                 name="[% messaging_preference.message_attribute_id | html %]"
                 value="sms" class="pmp_sms active_notify" data-attr-id="[% messaging_preference.message_attribute_id | html %]" />
              [% END %]
          [% END %]
          </td>
        [% ELSE %]
          <td>-</td>
        [% END %]
      [% END %]

      [% IF Koha.Preference('TalkingTechItivaPhoneNotification') %]
        [% IF ( messaging_preference.transport_itiva ) %]
          <td>
          [% IF ( messaging_form_inactive ) %]
              [% IF ( messaging_preference.transports_itiva ) %]
                 <input type="checkbox"
                 id="itiva[% messaging_preference.message_attribute_id | html %]"
                 name="[% messaging_preference.message_attribute_id | html %]"
                 value="itiva" checked="checked" disabled="disabled" />
              [% ELSE %]
                 <input type="checkbox"
                 id="itiva[% messaging_preference.message_attribute_id | html %]"
                 name="[% messaging_preference.message_attribute_id | html %]"
                 value="itiva" disabled="disabled" />
              [% END %]
          [% ELSE %]
              [% IF ( messaging_preference.transports_itiva ) %]
                 <input type="checkbox"
                 id="itiva[% messaging_preference.message_attribute_id | html %]"
                 name="[% messaging_preference.message_attribute_id | html %]"
                 value="itiva" checked="checked" class="pmp_phone active_notify" data-attr-id="[% messaging_preference.message_attribute_id | html %]" />
              [% ELSE %]
                 <input type="checkbox"
                 id="itiva[% messaging_preference.message_attribute_id | html %]"
                 name="[% messaging_preference.message_attribute_id | html %]"
                 value="itiva" class="pmp_phone active_notify" data-attr-id="[% messaging_preference.message_attribute_id | html %]" />
              [% END %]
          [% END %]
          </td>
        [% ELSE %]
          <td>-</td>
        [% END %]
      [% ELSIF Koha.Preference('PhoneNotification') %]
        [% IF ( messaging_preference.transport_phone ) %]
          <td>
          [% IF ( messaging_form_inactive ) %]
              [% IF ( messaging_preference.transports_phone ) %]
                 <input type="checkbox"
                 id="phone[% messaging_preference.message_attribute_id | html %]"
                 name="[% messaging_preference.message_attribute_id | html %]"
                 value="phone" checked="checked" disabled="disabled" />
              [% ELSE %]
                 <input type="checkbox"
                 id="phone[% messaging_preference.message_attribute_id | html %]"
                 name="[% messaging_preference.message_attribute_id | html %]"
                 value="phone" disabled="disabled" />
              [% END %]
          [% ELSE %]
              [% IF ( messaging_preference.transports_phone ) %]
                 <input type="checkbox"
                 id="phone[% messaging_preference.message_attribute_id | html %]"
                 name="[% messaging_preference.message_attribute_id | html %]"
                 value="phone" checked="checked" class="pmp_phone active_notify" data-attr-id="[% messaging_preference.message_attribute_id | html %]" />
              [% ELSE %]
                 <input type="checkbox"
                 id="phone[% messaging_preference.message_attribute_id | html %]"
                 name="[% messaging_preference.message_attribute_id | html %]"
                 value="phone" class="pmp_phone active_notify" data-attr-id="[% messaging_preference.message_attribute_id | html %]" />
              [% END %]
          [% END %]
          </td>
        [% ELSE %]
          <td>-</td>
        [% END %]
      [% END %]

      [% IF ( messaging_preference.transport_email ) %]
      <td>
          [% IF ( messaging_form_inactive ) %]
              [% IF ( messaging_preference.transports_email ) %]
                <input type="checkbox"
                   id="email[% messaging_preference.message_attribute_id | html %]"
                   name="[% messaging_preference.message_attribute_id | html %]"
                   value="email" class="pmp_email" checked="checked" disabled="disabled" />
              [% ELSE %]
                <input type="checkbox"
                   id="email[% messaging_preference.message_attribute_id | html %]"
                   name="[% messaging_preference.message_attribute_id | html %]"
                   value="email" class="pmp_email" disabled="disabled" />
              [% END %]
          [% ELSE %]
              [% IF ( messaging_preference.transports_email ) %]
            <input type="checkbox"
                 id="email[% messaging_preference.message_attribute_id | html %]"
                 name="[% messaging_preference.message_attribute_id | html %]"
                 value="email" checked="checked" class="pmp_email active_notify" data-attr-id="[% messaging_preference.message_attribute_id | html %]" />
              [% ELSE %]
            <input type="checkbox"
                 id="email[% messaging_preference.message_attribute_id | html %]"
                 name="[% messaging_preference.message_attribute_id | html %]"
                 value="email" class="pmp_email active_notify" data-attr-id="[% messaging_preference.message_attribute_id | html %]" />
              [% END %]
          [% END %]
      </td>
      [% ELSE %]
      <td>-</td>
      [% END %]

      [% IF ( messaging_preference.has_digest ) %]
      <td>
          [% IF ( messaging_form_inactive ) %]
              [% IF ( messaging_preference.digest ) %]
                <input type="checkbox"
                     id="digest[% messaging_preference.message_attribute_id | html %]"
                     value="[% messaging_preference.message_attribute_id | html %]"
                     name="digest" class="pmp_digest" checked="checked" disabled="disabled" data-toggle="tooltip" title="You must select a digestible transport to select digests" />
              [% ELSE %]
                <input type="checkbox"
                     id="digest[% messaging_preference.message_attribute_id | html %]"
                     value="[% messaging_preference.message_attribute_id | html %]"
                     name="digest" class="pmp_digest" disabled="disabled" data-toggle="tooltip" title="You must select a digestible transport to select digests" />
              [% END %]
          [% ELSE %]
              [% IF ( messaging_preference.digest ) %]
                <input type="checkbox"
                     id="digest[% messaging_preference.message_attribute_id | html %]"
                     value="[% messaging_preference.message_attribute_id | html %]"
                     name="digest" checked="checked" class="pmp_digest active_notify" data-attr-id="[% messaging_preference.message_attribute_id | html %]" data-toggle="tooltip" title="You must select a digestible transport to select digests" />
              [% ELSE %]
                <input type="checkbox"
                     id="digest[% messaging_preference.message_attribute_id | html %]"
                     value="[% messaging_preference.message_attribute_id | html %]"
                     name="digest" class="pmp_digest active_notify" data-attr-id="[% messaging_preference.message_attribute_id | html %]" data-toggle="tooltip" title="You must select a digestible transport to select digests" />
              [% END %]
          [% END %]
      </td>
      [% ELSE %]
      <td>-</td>
      [% END %]

<!--       [% IF ( messaging_preference.transport_rss ) %]
      <td>
          [% IF ( messaging_form_inactive ) %]
            <input type="checkbox"
                 id="rss[% messaging_preference.message_attribute_id | html %]"
                 name="[% messaging_preference.message_attribute_id | html %]"
                 value="rss"   [% messaging_preference.transport_rss | html %] disabled="disabled" />
          [% ELSE %]
            <input type="checkbox"
                 id="rss[% messaging_preference.message_attribute_id | html %]"
                 name="[% messaging_preference.message_attribute_id | html %]"
                 value="rss"   [% messaging_preference.transport_rss | html %] class="active_notify" data-attr-id="[% messaging_preference.message_attribute_id | html %]" />
          [% END %]
      </td>
      [% ELSE %]
      <td>-</td>
      [% END %] -->

    </tr>
    [% END %]
  </table>
