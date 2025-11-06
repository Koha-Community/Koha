function verify_cover_images() {
    // Loop over each container in the template which contains covers
    $(".cover-slider").each(function (index) {
        let biblionumber = $(this).data("biblionumber");
        let booktitle = $(this).data("title");
        var lightbox_descriptions = [];
        $(this)
            .find(".cover-image")
            .each(function (index) {
                var div = $(this);
                // Find the image in the container
                var img = div.find("img")[0];
                if (img && $(img).length > 0) {
                    // All slides start hidden. If this is the first one, show it.
                    // Check if Amazon image is present
                    if (div.hasClass("amazon-coverimg")) {
                        let w = img.width;
                        let h = img.height;
                        if (w == 1 || h == 1) {
                            // Amazon returned single-pixel placeholder
                            // Remove the container
                            div.remove();
                        } else {
                            lightbox_descriptions.push(
                                _(
                                    "Amazon cover image (<a href='%s'>see the original image</a>)"
                                ).format($(img).data("link"))
                            );
                        }
                    } else if (div.hasClass("custom-coverimg")) {
                        if (
                            (img.complete != null && !img.complete) ||
                            img.naturalHeight == 0
                        ) {
                            // No image was loaded via the CustomCoverImages system preference
                            // Remove the container
                            div.remove();
                        } else {
                            lightbox_descriptions.push(_("Custom cover image"));
                        }
                    } else if (div.hasClass("syndetics-coverimg")) {
                        lightbox_descriptions.push(_("Image from Syndetics"));
                    } else if (div.hasClass("googlejacket-coverimg")) {
                        if (img.naturalHeight) {
                            lightbox_descriptions.push(
                                _(
                                    "Image from Google Books (<a href='%s'>see the original image</a>)"
                                ).format($(img).data("link"))
                            );
                        }
                    } else if (div.hasClass("openlibrary-coverimg")) {
                        lightbox_descriptions.push(
                            _(
                                "Image from OpenLibrary (<a href='%s'>see the original image</a>)"
                            ).format($(img).data("link"))
                        );
                    } else if (div.hasClass("coce-coverimg")) {
                        // Identify which service's image is being loaded by Coce
                        var coce_description;
                        let src = $(img).attr("src");
                        if (src.indexOf("amazon.com") >= 0) {
                            coce_description = _("Coce image from Amazon.com");
                        } else if (src.indexOf("google.com") >= 0) {
                            coce_description = _(
                                "Coce image from Google Books"
                            );
                        } else if (src.indexOf("openlibrary.org") >= 0) {
                            coce_description = _(
                                "Coce image from Open Library"
                            );
                        }
                        div.find(".hint").html(coce_description);
                        lightbox_descriptions.push(coce_description);
                    } else if (div.hasClass("bakertaylor-coverimg")) {
                        lightbox_descriptions.push(
                            _("Image from Baker &amp; Taylor")
                        );
                    } else if (div.hasClass("cover-image local-coverimg")) {
                        lightbox_descriptions.push(_("Local cover image"));
                    } else {
                        lightbox_descriptions.push(
                            _("Cover image source unknown")
                        );
                    }
                } else {
                    div.remove();
                }
            });

        // Lightbox for cover images
        Chocolat(this.querySelectorAll(".cover-image a"), {
            description: function () {
                return lightbox_descriptions[this.settings.currentImageIndex];
            },
        });
    });

    $(".cover-slider").each(function () {
        var coverSlide = this;
        var coverImages = $(this).find(".cover-image");
        if (coverImages.length > 1) {
            coverImages.each(function (index) {
                // If more that one image is present, add a navigation link
                // for activating the slide
                var covernav = $(
                    '<a href="#" data-num="' +
                        index +
                        '" class="cover-nav"></a>'
                );
                if (index == 0) {
                    // Set the first navigation link as active
                    $(covernav).addClass("nav-active");
                }
                $(covernav).html('<i class="fa fa-circle"></i>');
                $(coverSlide).append(covernav);
            });
        }

        $(coverSlide).find(".cover-image").eq(0).show();

        if ($(coverSlide).find(".cover-image").length < 1) {
            $(coverSlide).remove();
        } else {
            // This is a suboptimal workaround; we should do this via load, but
            // the image code is scattered all over now. We come here now after
            // window load and wait_for_images (so load completed).
            var check_complete = 1;
            $(coverSlide)
                .find("img")
                .each(function () {
                    if (!this.complete || this.naturalHeight == 0)
                        check_complete = 0;
                });
            if (check_complete) $(coverSlide).removeClass("cover-slides");
        }
    });

    $(".cover-slider").on("click", ".cover-nav", function (e) {
        e.preventDefault();
        var cover_slider = $(this).parent();
        // Adding click handler for cover image navigation links
        var num = $(this).data("num");
        $(cover_slider).find(".cover-nav").removeClass("nav-active");
        $(this).addClass("nav-active");
        $(cover_slider).find(".cover-image").hide();
        $(cover_slider).find(".cover-image").eq(num).show();
    });

    $("#editions img").each(function (i) {
        if (this.src.indexOf("amazon.com") >= 0) {
            let w = this.width;
            let h = this.height;
            if (w == 1 || h == 1) {
                this.src =
                    "https://images-na.ssl-images-amazon.com/images/G/01/x-site/icons/no-img-sm.gif";
            } else if (
                (this.complete != null && !this.complete) ||
                this.naturalHeight == 0
            ) {
                this.src =
                    "https://images-na.ssl-images-amazon.com/images/G/01/x-site/icons/no-img-sm.gif";
            }
        }
    });
} /* /verify_images */
