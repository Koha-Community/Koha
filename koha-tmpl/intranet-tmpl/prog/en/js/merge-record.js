/*
 * Merging 2 source records into a destination record
 */

function build_target_record($sources) {
  var target_record = {};

  $sources.find('.record input[type="checkbox"].fieldpick:checked').each(function() {
    var $checkbox = $(this);
    var $li = $checkbox.parent();
    var field = $checkbox.parent().find("span.field").text();

    if (!(field in target_record)) {
      target_record[field] = [];
    }
    target_record[field].push({
      'id' : $li.attr('id'),
      'tag' : field,
      'subfields' : []
    });
  });

  $sources.find('.record input[type="checkbox"].subfieldpick:checked').each(function() {
    var $checkbox = $(this);
    var $li = $checkbox.parent();
    var $field_li = $li.parents('li');
    var field = $field_li.find('span.field').text();
    var subfield = $li.find('span.subfield').text();

    var target_field;
    if (field in target_record) {
      for (i in target_record[field]) {
        if (target_record[field][i].id == $field_li.attr('id')) {
          target_field = target_record[field][i];
        }
      }
      if (!target_field) {
        target_field = target_record[field][0];
      }
    }
    if (target_field) {
      target_field.subfields.push({
        'id' : $li.attr('id'),
        'code' : subfield
      });
    } else {
      $field_li.find('input.fieldpick').prop('checked', true);
      target_record[field] = [{
        'id' : $field_li.attr('id'),
        'tag' : field,
        'subfields' : [{
          'id' : $li.attr('id'),
          'code' : subfield
        }]
      }];
    }
  });

  return target_record;
}

function field_can_be_added($sources, $li) {
  target_record = build_target_record($sources);

  var tag = $li.find('span.field').text();
  var repeatable = true;
  if (tag in tagslib) {
    repeatable = (tagslib[tag].repeatable != 0) ? true : false;
  }

  if ((!repeatable) && (tag in target_record)) {
    alert(MSG_MERGEREC_ALREADY_EXISTS);
    return false;
  }

  return true;
}

function subfield_can_be_added($sources, $li) {
  target_record = build_target_record($sources);

  var $field_li = $li.parents('li');
  var tag = $field_li.find('span.field').text();
  var code = $li.find('span.subfield').text();

  var repeatable = true;
  if (tag in tagslib && code in tagslib[tag]) {
    repeatable = (tagslib[tag][code].repeatable != 0) ? true : false;
  }

  if (!repeatable) {
    var target_field;
    if (tag in target_record) {
      for (i in target_record[tag]) {
        if (target_record[tag][i].id == $field_li.attr('id')) {
          target_field = target_record[tag][i];
        }
      }
      if (!target_field) {
        target_field = target_record[tag][0];
      }
    }
    if (target_field) {
      for (i in target_field.subfields) {
        var subfield = target_field.subfields[i];
        if (code == subfield.code) {
          alert(MSG_MERGEREC_SUBFIELD_ALREADY_EXISTS);
          return false;
        }
      }
    }
  }

  return true;
}

function rebuild_target($sources, $target) {
  target_record = build_target_record($sources);

  $target.empty();
  var keys = $.map(target_record, function(elem, idx) { return idx }).sort();
  for (k in keys) {
    var tag = keys[k];
    var fields = target_record[tag];
    for (i in fields) {
      var field = fields[i];
      if (parseInt(tag) < 10) {
        var $field_clone = $('#' + field.id).clone();
        $field_clone.find('.fieldpick').remove();
        $target.append($field_clone);
      } else if (field.subfields.length > 0) {
        var $field_clone = $('#' + field.id).clone();
        $field_clone.find('ul').empty();
        $field_clone.find('.fieldpick').remove();
        $target.append($field_clone);

        for (j in field.subfields) {
          var subfield = field.subfields[j];
          var $subfield_clone = $('#' + subfield.id).clone();
          $subfield_clone.find('.subfieldpick').remove();
          $field_clone.find('ul').append($subfield_clone);
        }
      } else {
        $('#' + field.id).find('input.fieldpick').prop('checked', false);
      }
    }
  }
}

/*
 * Add actions on field and subfields checkboxes
 */
$(document).ready(function(){
    // When a field is checked / unchecked
    $('input.fieldpick').click(function() {
        var ischecked = this.checked;
        if (ischecked) {
          $(this).prop('checked', false);
          if (!field_can_be_added($('#tabs'), $(this).parent())) {
            return false;
          }
          $(this).prop('checked', true);
        }

        // (un)check all subfields
        $(this).parent().find("input.subfieldpick").each(function() {
            this.checked = ischecked;
        });
        rebuild_target($('#tabs'), $('#resultul'));
    });

    // When a field or subfield is checked / unchecked
    $("input.subfieldpick").click(function() {
      var ischecked = this.checked;
      if (ischecked) {
        $(this).prop('checked', false);
        if (!subfield_can_be_added($('#tabs'), $(this).parent())) {
          return false;
        }
        $(this).prop('checked', true);
      }
      rebuild_target($('#tabs'), $('#resultul'));
    });
});
