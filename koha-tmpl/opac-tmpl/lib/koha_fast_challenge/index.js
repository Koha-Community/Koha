document.addEventListener("DOMContentLoaded", event => {
    const timeout_base = 0;
    let timeout_incr = 250;

    if (navigator.webdriver){
        timeout_incr += 10000
    }
    if (navigator.plugins.length === 0){
        timeout_incr += 5000;
    }
    if (navigator.mimeTypes.length === 0){
        timeout_incr += 5000;
    }
    if (!navigator.languages || navigator.languages.length === 0){
        timeout_incr += 5000;
    }
    const timestamp1 = performance.now();
    requestAnimationFrame(() => {
        const delay = performance.now() - timestamp1;
        if (delay < 20){
            timeout_incr += 1000;
        }
    });

    let final_timeout = timeout_base + timeout_incr;
    setTimeout(() => {
        let koha_init_cookie = "KOHA_INIT=1; path=/; SameSite=Lax";
        if (location.protocol === 'https:'){
            koha_init_cookie += "; Secure";
        }
        document.cookie = koha_init_cookie;
        location.reload();
    }, final_timeout);
});
