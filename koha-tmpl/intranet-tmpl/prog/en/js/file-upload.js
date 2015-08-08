function AjaxUpload ( input, progressbar, xtra, callback ) {
    // input and progressbar are jQuery objects
    // callback is the callback function for completion
    var formData= new FormData();
    $.each( input.prop('files'), function( dx, file ) {
        formData.append( "uploadfile", file );
    });
    var xhr= new XMLHttpRequest();
    var url= '/cgi-bin/koha/tools/upload-file.pl?' + xtra;
    progressbar.val( 0 );
    progressbar.next('.fileuploadpercent').text( '0' );
    xhr.open('POST', url, true);
    xhr.upload.onprogress = function (e) {
        var p = Math.round( (e.loaded/e.total) * 100 );
        progressbar.val( p );
        progressbar.next('.fileuploadpercent').text( p );
    }
    xhr.onload = function (e) {
        var data = JSON.parse( xhr.responseText );
        if( data.status == 'done' ) {
            progressbar.val( 100 );
            progressbar.next('.fileuploadpercent').text( '100' );
        }
        callback( data.status, data.fileid, data.errors );
    }
    xhr.onerror = function (e) {
        // Probably only fires for network failure
        alert('An error occurred while uploading.');
    }
    xhr.send( formData );
    return xhr;
}
