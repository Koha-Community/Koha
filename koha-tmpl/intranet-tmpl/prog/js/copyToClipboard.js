(() => {
    const copyToClipboardButtons = document.querySelectorAll(
        "[data-copy-to-clipboard]"
    );
    if (copyToClipboardButtons.length) {
        const copyToClipboard = e => {
            const target = e.target;
            if (!(target instanceof HTMLButtonElement)) {
                return;
            }
            const { value } = target.dataset;
            if (!value) {
                return;
            }

            navigator.clipboard.writeText(value);
        };

        copyToClipboardButtons.forEach(copyToClipboardButton => {
            copyToClipboardButton.addEventListener("click", copyToClipboard);
        });
    }
})();
