/* global __ */
/* exported startup */

/* Adapted from Mozilla's article "Taking still photos with WebRTC"
 * https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API/Taking_still_photos
 */

var width = 480; // We will scale the photo width to this
var height = 0; // This will be computed based on the input stream

// |streaming| indicates whether or not we're currently streaming
// video from the camera. Obviously, we start at false.

var streaming = false;

// The various HTML elements we need to configure or control. These
// will be set by the startup() function.

var video = null;
var canvas = null;
var photo = null;
var takebutton = null;
var retakebutton = null;
var downloadbutton = null;
var savebutton = null;
var output = null;
var camera = null;
var uploadfiletext = null;

/**
 * Initiate the camera and add some click handlers
 */

function startup() {
    video = document.getElementById("viewfinder");
    canvas = document.getElementById("canvas");
    photo = document.getElementById("photo");
    takebutton = document.getElementById("takebutton");
    retakebutton = document.getElementById("retakebutton");
    downloadbutton = document.getElementById("downloadbutton");
    savebutton = document.getElementById("savebutton");
    output = document.getElementById("output");
    camera = document.getElementById("camera");
    uploadfiletext = document.getElementById("uploadfiletext");

    if (!video) {
        //If there is no video element, don't try to start up camera
        return;
    }

    try {
        navigator.mediaDevices
            .getUserMedia({
                video: true,
                audio: false,
            })
            .then(function (stream) {
                video.srcObject = stream;
                video.play();
            })
            .catch(function (err) {
                $("#capture-patron-image").hide();
                $("#camera-error").css("display", "flex");
                $("#camera-error-message").text(showMediaErrors(err));
            });
    } catch (err) {
        $("#capture-patron-image").hide();
        $("#camera-error").css("display", "flex");
        $("#camera-error-message").text(showMediaErrors(err));
    }

    video.addEventListener(
        "canplay",
        function () {
            if (!streaming) {
                height = video.videoHeight / (video.videoWidth / width);

                // Firefox currently has a bug where the height can't be read from
                // the video, so we will make assumptions if this happens.

                if (isNaN(height)) {
                    height = width / (4 / 3);
                }

                video.setAttribute("width", width);
                video.setAttribute("height", height);
                canvas.setAttribute("width", width);
                canvas.setAttribute("height", height);
                photo.setAttribute("width", width);
                photo.setAttribute("height", height);
                streaming = true;
            }
        },
        false
    );

    takebutton.addEventListener(
        "click",
        function (ev) {
            takepicture();
            ev.preventDefault();
        },
        false
    );

    retakebutton.addEventListener(
        "click",
        function (ev) {
            ev.preventDefault();
            retakephoto();
        },
        false
    );

    clearphoto();
}

function showMediaErrors(err) {
    // Example error: "NotAllowedError: Permission denied"
    var errorcode = err.toString().split(":");
    var output;
    switch (errorcode[0]) {
        case "NotFoundError":
        case "DevicesNotFoundError":
            output = __("No camera detected.");
            break;
        case "NotReadableError":
        case "TrackStartError":
            output = __("Could not access camera.");
            break;
        case "NotAllowedError":
        case "PermissionDeniedError":
            output = __("Access to camera denied.");
            break;
        case "TypeError":
            output = __(
                "This feature is available only in secure contexts (HTTPS)."
            );
            break;
        default:
            output = __("An unknown error occurred: ") + err;
            break;
    }
    return output;
}

/**
 * Clear anything passed to the canvas element and the corresponding image.
 */

function clearphoto() {
    var context = canvas.getContext("2d");
    context.fillStyle = "#AAA";
    context.fillRect(0, 0, canvas.width, canvas.height);

    var data = canvas.toDataURL("image/jpeg", 1.0);
    photo.setAttribute("src", data);
}

/**
 * Reset the interface to hide download and save buttons.
 * Redisplay camera "shutter" button.
 */

function retakephoto() {
    downloadbutton.href = "";
    downloadbutton.style.display = "none";
    takebutton.style.display = "inline-block";
    retakebutton.style.display = "none";
    savebutton.style.display = "none";
    output.style.display = "none";
    photo.src = "";
    camera.style.display = "block";
    uploadfiletext.value = "";
}

/**
 * Capture the data from the user's camera and write it to the canvas element.
 * The canvas data is converted to a data-url, and that URL set as the src
 * attribute of an image.
 * Display two controls for the captured photo: Download (to save to the
 * user's computer) and Upload (save to the patron's record in Koha).
 */

function takepicture() {
    var context = canvas.getContext("2d");
    var cardnumber = document.getElementById("cardnumber").value;
    camera.style.display = "none";
    downloadbutton.style.display = "";
    output.style.display = "block";
    takebutton.style.display = "none";
    retakebutton.style.display = "inline-block";
    savebutton.style.display = "inline-block";
    if (width && height) {
        canvas.width = width;
        canvas.height = height;
        context.drawImage(video, 0, 0, width, height);

        var data = canvas.toDataURL("image/jpeg", 1.0);
        photo.setAttribute("src", data);
        if (cardnumber !== "") {
            // Download a file which the patrons card number as its name
            downloadbutton.download = cardnumber + ".jpg";
        } else {
            downloadbutton.download = "patron-photo.jpg";
        }
        downloadbutton.href = data;
        uploadfiletext.value = data;
    } else {
        clearphoto();
    }
}
