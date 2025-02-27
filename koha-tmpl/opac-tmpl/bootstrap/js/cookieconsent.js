(function () {
    // Has the user previously consented, establish our
    // initial state
    let selected = [];
    let existingConsent = "";
    // The presence of a 'cookieConsent' local storage item indicates
    // that previous consent has been set. If the value is empty, then
    // no consent to non-essential cookies was given
    const hasStoredConsent = localStorage.getItem("cookieConsent");
    getExistingConsent();

    // The consent bar may not be in the DOM if it is not being used
    const consentBar = $("#cookieConsentBar");
    if (!consentBar) {
        return;
    }

    // Initialize the consent modal and prevent the modal
    // from being closed with anything but the buttons
    const cookieConsentModal = new bootstrap.Modal(
        document.getElementById("cookieConsentModal"),
        {
            backdrop: "static",
            keyboard: false,
            focus: true,
            show: true,
        }
    );

    if (hasStoredConsent === null) {
        showConsentBar();
    } else {
        showYourCookies();
    }
    addButtonHandlers();

    // When the modal is opened, populate our state based on currently
    // selected values
    const cookieConsentModalEl = document.getElementById("cookieConsentModal");
    cookieConsentModalEl.addEventListener("shown.bs.modal", () => {
        initialiseSelected();
    });

    $(window).on("scroll", function () {
        const consentBar = $("#cookieConsentBar");
        const langmenu = $("#changelanguage");
        const wrapper = $("#wrapper");
        if (langmenu) {
            const height = langmenu.height();
            if (
                $(window).scrollTop() >=
                wrapper.offset().top +
                    wrapper.outerHeight() -
                    window.innerHeight
            ) {
                consentBar.css("bottom", height);
            } else {
                consentBar.css("bottom", 0);
            }
        }
    });

    // Initialise existing consent based on local storage
    function getExistingConsent() {
        existingConsent = localStorage.getItem("cookieConsent")
            ? localStorage.getItem("cookieConsent")
            : [];
    }

    function showConsentBar() {
        const consentBar = $("#cookieConsentBar");
        consentBar.attr("aria-hidden", "false");
        consentBar.css("display", "flex");

        // Set focus to the first focusable element within the consent bar
        const firstFocusableElement = consentBar
            .find("a, button, input, select, textarea")
            .filter(":visible")
            .first();
        if (firstFocusableElement.length) {
            firstFocusableElement.focus();
        } else {
            // If no focusable elements exist, add tabindex to the bar itself to make it focusable
            consentBar.attr("tabindex", "-1").focus();
        }
    }

    function hideConsentBar() {
        const consentBar = $("#cookieConsentBar");
        consentBar.attr("aria-hidden", "true");
        consentBar.hide();

        // Remove focus from any currently focused element
        if (document.activeElement) {
            document.activeElement.blur();
        }

        // Set focus to the body, which effectively removes visible focus indicators
        // This allows the first Tab press to highlight the "Skip to main content" link
        document.body.focus();
        document.querySelector("body").setAttribute("tabindex", "-1");
        document.querySelector("body").focus();
        document.querySelector("body").removeAttribute("tabindex");
    }

    // Hides the appropriate consent container, depending on what
    // is currently visible
    function hideContainer() {
        if ($(cookieConsentModalEl).is(":visible")) {
            cookieConsentModal.hide();
        } else {
            hideConsentBar();
        }
    }

    // Show the unauthenticated user's "Your cookies" button
    function showYourCookies() {
        // If the user is unauthenticated, there will be a
        // cookieConsentsButton element in the DOM. The user
        // has previously consented, so we need to display this
        // button
        if ($("#cookieConsentButton").length > 0) {
            $("#cookieConsentDivider").show().attr("aria-hidden", "false");
            $("#cookieConsentLi").show().attr("aria-hidden", "false");
        }
    }

    // Initialise our state of selected item and enable/disable
    // the "Accept selected" button appropriately
    function initialiseSelected() {
        selected = [];
        $(".consentCheckbox").each(function () {
            const val = $(this).val();
            if (existingConsent.indexOf(val) > -1) {
                $(this).prop("checked", true);
                selected.push(val);
            } else {
                $(this).prop("checked", false);
            }
        });
        enableDisableSelectedButton();
    }

    // Maintain our state of selected items and enable/disable
    // the "Accept selected" button appropriately
    function maintainSelected() {
        selected = [];
        $(".consentCheckbox:checked").each(function () {
            selected.push($(this).val());
        });
        enableDisableSelectedButton();
    }

    // Set the enabled / disabled state of the
    // "Accept selected button based on the checkbox
    // states
    function enableDisableSelectedButton() {
        $("#consentAcceptSelected").prop("disabled", selected.length === 0);
    }

    function runConsentedCode() {
        getExistingConsent();
        $(".consentCode").each(function () {
            // The user has explicitly consented to this code, or the
            // code doesn't require consent in the OPAC
            if (
                existingConsent.indexOf($(this).data("consent-id")) > -1 ||
                !$(this).data("requires-consent")
            ) {
                const code = atob($(this).data("consent-code"));
                const func = Function(code);
                func();
            } else {
                // This code doesn't have consent to run, we may need to remove
                // any cookies it has previously set
                const matchPattern = $(this).data("consent-match-pattern");
                const cookieDomain = $(this).data("consent-cookie-domain");
                const cookiePath = $(this).data("consent-cookie-path");
                if (matchPattern.length > 0) {
                    const regex = new RegExp(matchPattern);
                    const allCookies = document.cookie.split("; ");
                    allCookies.forEach(function (cookie) {
                        const name = cookie.split("=")[0];
                        if (regex.test(name)) {
                            document.cookie =
                                name +
                                "=; expires=Thu, 01 Jan 1970 00:00:01 GMT; domain=" +
                                cookieDomain +
                                "; path=" +
                                cookiePath;
                        }
                    });
                }
            }
        });
    }

    function addButtonHandlers() {
        // "Accept all" handler
        $(".consentAcceptAll").on("click", function (e) {
            e.preventDefault();
            let toSave = [];
            $(".consentCheckbox").each(function () {
                const val = $(this).val();
                toSave.push(val);
            });
            localStorage.setItem("cookieConsent", toSave);
            hideContainer();
            runConsentedCode();
            showYourCookies();
        });

        // "Accept essential" handler
        $(".consentAcceptEssential").on("click", function (e) {
            e.preventDefault();
            localStorage.setItem("cookieConsent", []);
            hideContainer();
            runConsentedCode();
            showYourCookies();
        });

        // "Accept selected" handler
        $("#consentAcceptSelected").on("click", function (e) {
            e.preventDefault();
            const toSave = selected.length > 0 ? selected : [];
            localStorage.setItem("cookieConsent", toSave);
            hideContainer();
            runConsentedCode();
            showYourCookies();
        });

        // "Cancel" handler
        $(".consentCloseModal").on("click", function (e) {
            e.preventDefault();
            hideContainer();
            showConsentBar();
        });

        // "More information" handler
        $("#consentMoreInfo, #cookieConsentFooter, #cookieConsentButton").on(
            "click",
            function (e) {
                e.preventDefault();
                hideConsentBar();
                // Ensure we're up to date with the existing consent
                getExistingConsent();
                cookieConsentModal.show();
            }
        );
        $(".consentCheckbox").on("click", function () {
            maintainSelected();
        });
    }

    // On page load, run any code that has been given consent
    runConsentedCode();
})();
