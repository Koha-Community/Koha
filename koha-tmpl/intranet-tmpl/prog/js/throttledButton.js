(() => {
    const DEFAULT_TIMEOUT = 3000;
    const pendingTimeouts = new WeakMap();

    const toggleButton = element => {
        const isDisabled = element.hasAttribute("disabled");
        const readyIcon = element.querySelector(".button-icon-ready");
        const runningIcon = element.querySelector(".button-icon-running");

        if (!readyIcon || !runningIcon) {
            return;
        }

        if (!isDisabled) {
            element.setAttribute("disabled", "disabled");
            element.setAttribute("aria-busy", "true");
            element.classList.add("disabled");
            element.dataset.state = "running";
            readyIcon.style.display = "none";
            runningIcon.style.display = "";
        } else {
            element.removeAttribute("disabled");
            element.removeAttribute("aria-busy");
            element.classList.remove("disabled");
            element.dataset.state = "ready";
            readyIcon.style.display = "";
            runningIcon.style.display = "none";
        }
    };

    // Use event delegation to handle both static and dynamically created links
    document.addEventListener("click", event => {
        const link = event.target.closest("a[data-throttled-button]");
        if (link) {
            event.preventDefault();
            const href = link.getAttribute("href");

            toggleButton(link);
            window.location.href = href;
        }
    });

    // Handle button elements within forms
    document.addEventListener("submit", event => {
        const submitter = event.submitter;
        if (submitter && submitter.hasAttribute("data-throttled-button")) {
            const timeoutValue = parseInt(
                submitter.dataset.throttleTimeout,
                10
            );
            const timeout = isNaN(timeoutValue)
                ? DEFAULT_TIMEOUT
                : timeoutValue;

            requestAnimationFrame(() => {
                toggleButton(submitter);
                const timeoutId = setTimeout(
                    () => toggleButton(submitter),
                    timeout
                );
                pendingTimeouts.set(submitter, timeoutId);
            });
        }
    });

    // Reset button state when page is restored from bfcache
    window.addEventListener("pageshow", event => {
        if (event.persisted) {
            document
                .querySelectorAll("[data-throttled-button][disabled]")
                .forEach(button => {
                    const timeoutId = pendingTimeouts.get(button);
                    if (timeoutId) {
                        clearTimeout(timeoutId);
                        pendingTimeouts.delete(button);
                    }
                    if (!button.hasAttribute("data-throttle-persist")) {
                        toggleButton(button);
                    } else {
                        const runningIcon = button.querySelector(
                            ".button-icon-running"
                        );
                        const doneIcon =
                            button.querySelector(".button-icon-done");
                        if (runningIcon) {
                            runningIcon.style.display = "none";
                        }
                        if (doneIcon) {
                            doneIcon.style.display = "";
                        }
                        button.dataset.state = "done";
                    }
                });
        }
    });
})();
