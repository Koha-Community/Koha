function clear_inputs(node, new_node) {
    var selects = $(node).find("select");
    $(selects).each(function(i) {
        var select = this;
        $(new_node).find("select").eq(i).val($(select).val());
    });
    var inputs = $(node).find("input");
    $(inputs).each(function(i) {
        var input = this;
        $(new_node).find("input").eq(i).val($(input).val());
    });
}

function remove_block_action( link ) {
    var blocks = $(link).parent().parent();
    if( $(blocks).find(".block").length > 2 ) {
        $(blocks).find("a.remove_block").show();
    } else {
        $(blocks).find("a.remove_block").hide();
    }
    $(link).parent().remove();
}

function remove_rule_action( link ) {
    if( $("#rules").find(".rule").length < 2 ) {
            $("#rules").hide();
            $("#norules").show();
    }
    $(link).parent().parent().remove();
    update_rule_count();
}

function clone_block(block) {
    var new_block = $(block).clone(1);
    clear_inputs(block, new_block);
    $(new_block).find('a.remove_block').show();
    var blocks = $(block).parent();
    $(blocks).append(new_block);
    $(blocks).find('a.remove_block').click(function(){
        remove_block_action($(this));
    }).show();
}

function update_rule_count(){
    rules = $(".rulecount");
    rules.each( function( i ){
        $(this).text( i + 1 );
    });
}

$(document).ready(function() {
    $("#new_rule .remove_rule").hide();
    $("#new_rule a.remove_block").hide();
    $("#rules a.remove_block").click(function(e){
        e.preventDefault();
        remove_block_action($(this));
    });
    $("#rules .remove_rule").click(function(e){
        e.preventDefault();
        remove_rule_action($(this));
    });

    var unique_id = $(".rule").length + 1;
    $(".add_rule").click(function(e){
        e.preventDefault();
        var rule = $("#new_rule");
        var rules = $("#rules");
        var new_rule = rule.clone(1);
        new_rule.removeAttr('id');
        new_rule.attr('class', 'rule');
        clear_inputs(rule, new_rule);
        new_rule.find("select[name='condition_field']").attr('name', 'condition_field_' + unique_id);
        new_rule.find("select[name='substitution_field']").attr('name', 'substitution_field_' + unique_id);
        new_rule.find("input[name='condition_value']").attr('name', 'condition_value_' + unique_id);
        new_rule.find("input[name='substitution_value']").attr('name', 'substitution_value_' + unique_id);
        new_rule.find("input[name='age']").attr('name', 'age_' + unique_id);
        new_rule.find("input[name='unique_id']").val(unique_id);

        $("#rules").append(new_rule);
        update_rule_count();
        var scrollToPoint = new_rule.position();
        window.scroll(0, scrollToPoint.top - $("#toolbar").height() );

        if( $("#rules").find(".rule").length > 0 ) {
                $("#rules").show();
                $("#norules").hide();
        }
        if( $("#rules").find(".conditions > .condition").length > 1 ) {

        }
        if( $("#rules").find(".conditions > .condition").length > 1 ) {

        }
        new_rule.find('.remove_rule').click(function(){
            remove_rule_action( $(this) );
        }).show();
        new_rule.find('.add_rule').remove();
        unique_id++;
    });

    $("a.add_block").click(function(e){
        e.preventDefault();
        clone_block( $(this).parent() );
    });

    if( $("#rules").find(".rule").length < 1 ) {
            $("#rules").hide();
            $("#norules").show();
    }

    $("#rules .rule .blocks").each(function(){
        if ( $(this).find(".block").length == 1 ) {
            $(this).find("a.remove_block").hide();
        }
    });

    jQuery.validator.addClassRules("age", {
        required: true,
        digits: true
    });

    $("#rules_form").validate();
});
