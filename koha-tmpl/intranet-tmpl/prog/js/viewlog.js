function tickAll(section){
    $("input[name='" + section + "']").prop("checked", true);
    $("#" + section.slice(0,-1) + "ALL").prop("checked", true);
    $("input[name='" + section + "']").prop("disabled", true);
    $("#" + section.slice(0,-1) + "ALL").prop("disabled", false);
}

function untickAll(section){
    $("input[name='" + section + "']").prop("checked", false);
    $("input[name='" + section + "']").prop("disabled", false);
}

$(document).ready(function(){

    if ( $('input[name="modules"]:checked').length == 0 ) {
        tickAll('modules');
    }
    $("#moduleALL").change(function(){
        if ( this.checked == true ){
            tickAll('modules');
        } else {
            untickAll('modules');
        }
    });
    $("input[name='modules']").change(function(){
        if ( $("input[name='modules']:checked").length == $("input[name='modules']").length - 1 ){
            tickAll('modules');
        }
    });

    if ( $('input[name="actions"]:checked').length == 0 ) {
        tickAll('actions');
    }
    $("#actionALL").change(function(){
        if ( this.checked == true ){
            tickAll('actions');
        } else {
            untickAll('actions');
        }

    });
    $("input[name='actions']").change(function(){
        if ( $("input[name='actions']:checked").length == $("input[name='actions']").length - 1 ){
            tickAll('actions');
        }
    });

    if ( $('input[name="interfaces"]:checked').length == 0 ) {
        tickAll('interfaces');
    }
    $("#interfaceALL").change(function(){
        if ( this.checked == true ){
            tickAll('interfaces');
        } else {
            untickAll('interfaces');
        }

    });
    $("input[name='interfaces']").change(function(){
        if ( $("input[name='interfaces']:checked").length == $("input[name='interfaces']").length - 1 ){
            tickAll('interfaces');
        }
    });
});
