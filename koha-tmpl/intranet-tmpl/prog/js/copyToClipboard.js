(() => {
    const copyToClipboardButtons = document.querySelectorAll(
        "[data-copy-to-clipboard]"
    );
    if (copyToClipboardButtons.length) {
        const copyToClipboard = async e => {
            const target = e.target;
            if (!(target instanceof HTMLButtonElement)) {
                return;
            }
            const { value } = target.dataset;
            if (!value) {
                return;
            }

            try {
                await navigator.clipboard.writeText(value);
            } catch (_) {
                return;
            }

            target.title = __("Copied to clipboard");
            const tooltip = bootstrap.Tooltip.getOrCreateInstance(target);
            tooltip.show();
            setTimeout(() => {
                tooltip.dispose();
                target.title = "";
            }, 3000);
        };

        copyToClipboardButtons.forEach(copyToClipboardButton => {
            copyToClipboardButton.addEventListener("click", copyToClipboard);
        });
    }
})();
