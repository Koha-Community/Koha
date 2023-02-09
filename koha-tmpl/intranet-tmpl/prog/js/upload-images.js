/* global __ interface theme biblionumber */

$(document).ready(function(){
    $("html").on("drop", function(e) {
        e.preventDefault();
        e.stopPropagation();
    });

    $("#zipfile").on("click", function(){
        $("biblionumber_entry").hide();
    });

    $("#image").on("click", function(){
        $("#biblionumber_entry").show();
    });

    $("#uploadfile").validate({
        submitHandler: function() {
            StartUpload();
            return false;
        }
    });

    $("#filedrag").on("click", ".cancel_image", function(){
        $("#click_to_select").show();
        $("#messages").html("");
        $("#fileToUpload").prop( "disabled", false );
        $("#process_images, #fileuploadstatus").hide();
        return false;
    }).on("click", ".save_image", function(e){
        e.preventDefault();
        $("#processfile").submit();
    });

    $("html").on("drop", function(e) {
        /* Prevent the default browser action when image is dropped */
        /* i.e. don't navigate to a view of the local image */
        e.preventDefault();
        e.stopPropagation();
    });

    $('#filedrag').on('dragenter dragover dragleave', function (e) {
        /* Handle various drag and drop events in "Drop files" area */
        /* If event type is "dragover," add the "hover" class */
        /* otherwise set no class name */
        e.stopPropagation();
        e.preventDefault();
        e.target.className = (e.type == "dragover" ? "hover" : "");
    });

    $("#filedrag").on("click", function(){
        /* Capture a click inside the drag and drop area */
        /* Trigger the <input type="file"> action */
        $("#fileToUpload").click();
    });

    // Drop
    $('#filedrag').on('drop', function (e) {
        e.stopPropagation();
        e.preventDefault();
        prepUpLoad(e);
    });

    // file selected
    $("#fileToUpload").on("change", function(){
        prepUpLoad();
    });

    $('.thumbnails .remove').on("click", function(e) {
        e.preventDefault();
        var result = confirm(__("Are you sure you want to delete this cover image?"));
        var imagenumber = $(this).data("coverimg");
        if ( result == true ) {
            removeLocalImage(imagenumber);
        }
    });
});

function prepUpLoad( event ){
    $("#click_to_select,#upload_results").hide();
    $("#messages").html("");
    var file;
    if( event ){
        file = event.originalEvent.dataTransfer.files[0];
    } else {
        file = $('#fileToUpload')[0].files[0];
    }

    $("#fileuploadstatus, #upload_options").show();
    var fd = new FormData();
    fd.append('file', file);
    if( ParseFile( file ) ){
        StartUpload( fd );
    }
}

function StartUpload( fd ) {
    $('#uploadform button.submit').prop('disabled',true);
    $("#uploadedfileid").val('');
    AjaxUpload( fd, $('#fileuploadprogress'), 'temp=1', cbUpload );
}

function cbUpload( status, fileid, errors ) {
    if( status=='done' ) {
        $("#uploadedfileid").val( fileid );
        $('#fileToUpload').prop('disabled',true);
        $("#process_images").show();
    } else {
        var errMsgs = [ __("Error code 0 not used"), __("File already exists"), __("Directory is not writeable"), __("Root directory for uploads not defined"), __("Temporary directory for uploads not defined") ];
        var errCode = errors[$('#fileToUpload').prop('files')[0].name].code;
        $("#fileuploadstatus").hide();
        $("#fileuploadfailed").show();
        $("#fileuploadfailed").text( __("Upload status: ") +
            ( status=='failed'? __("Failed") + " - (" + errCode + ") " + errMsgs[errCode]:
                ( status=='denied'? __("Denied"): status ))
        );
        $("#processfile").hide();
    }
}

function AjaxUpload ( formData, progressbar, xtra, callback ) {
    var xhr= new XMLHttpRequest();
    var url= '/cgi-bin/koha/tools/upload-file.pl?' + xtra;
    progressbar.val( 0 );
    progressbar.next('.fileuploadpercent').text( '0' );
    xhr.open('POST', url, true);
    xhr.upload.onprogress = function (e) {
        var p = Math.round( (e.loaded/e.total) * 100 );
        progressbar.val( p );
        progressbar.next('.fileuploadpercent').text( p );
    };
    xhr.onload = function () {
        var data = JSON.parse( xhr.responseText );
        if( data.status == 'done' ) {
            progressbar.val( 100 );
            progressbar.next('.fileuploadpercent').text( '100' );
        }
        callback( data.status, data.fileid, data.errors );
    };
    xhr.onerror = function () {
        // Probably only fires for network failure
        alert(__("An error occurred while uploading.") );
    };
    xhr.send( formData );
    return xhr;
}

// output file information
function ParseFile(file) {
    var valid = true;
    if (file.type.indexOf("image") == 0) {
        /* If the uploaded file is an image, show it */
        var reader = new FileReader();
        reader.onload = function(e) {
            Output(
                '<p><img class="cover_preview" src="' + e.target.result + '" /></p>'
            );
        };
        $("#biblionumber_entry").show().find("input,label").addClass("required").prop("required", true );
        $("#image").prop("checked", true ).change();
        $("#zipfile").prop("checked", false );
        reader.readAsDataURL(file);
    } else if( file.type.indexOf("zip") > 0) {
        Output(
            '<p><i class="fa-solid fa-zipper" aria-hidden="true"></i></p>'
        );
        $("#biblionumber_entry").hide();
        $("#image").prop("checked", false );
        $("#zipfile").prop("checked", true );
    } else {
        Output(
            '<div class="dialog alert"><strong>' + __("Error:") + ' </strong> ' + __("This tool only accepts ZIP files or GIF, JPEG, PNG, or XPM images.") + '</div>'
        );
        valid = false;
        resetForm();
    }

    Output(
        "<p>" + __("File name:") + " <strong>" + file.name + "</strong><br />" +
            __("File type:") + " <strong>" + file.type + "</strong><br />" +
            __("File size:") + " <strong>" + convertSize( file.size ) + "</strong>"
    );
    return valid;
}

// output information
function Output(msg) {
    var m = document.getElementById("messages");
    m.innerHTML = msg + m.innerHTML;
}

// Bytes conversion
function convertSize(size) {
    var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
    if (size == 0) return '0 Byte';
    var i = parseInt(Math.floor(Math.log(size) / Math.log(1024)));
    return Math.round(size / Math.pow(1024, i), 2) + ' ' + sizes[i];
}

function removeLocalImage(imagenumber) {
    var thumbnail = $("#imagenumber-" + imagenumber );
    var copy = thumbnail.html();
    thumbnail.find("img").css("opacity", ".2");
    thumbnail.find("a.remove").html("<img style='display:inline-block' src='" + interface + "/" + theme + "/img/spinner-small.gif' alt='' />");

    $.ajax({
        url: "/cgi-bin/koha/svc/cover_images?action=delete&biblionumber=" + biblionumber + "&imagenumber=" + imagenumber,
        success: function(data) {
            $(data).each( function() {
                if ( this.deleted == 1 ) {
                    location.href="/cgi-bin/koha/tools/upload-cover-image.pl?biblionumber=" + biblionumber;
                } else {
                    thumbnail.html( copy );
                    alert(__("An error occurred on deleting this image"));
                }
            });
        },
        error: function() {
            thumbnail.html( copy );
            alert(__("An error occurred on deleting this image"));
        }
    });
}

function resetForm(){
    $("#uploadpanel,#upload_options,#process_images").hide();
    $("#click_to_select").show();
}
