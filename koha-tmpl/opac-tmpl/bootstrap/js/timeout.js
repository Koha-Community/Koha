class sc_timer {
    constructor(args) {
        const idle_timeout = args["idle_timeout"];
        const redirect_url = args["redirect_url"];
        if (idle_timeout) {
            this.idle_timeout = idle_timeout;
        }
        if (redirect_url) {
            this.redirect_url = redirect_url;
        }
        this.idle_time = 0;
    }

    start_timer() {
        const self = this;
        //Increment the idle time counter every 1 second
        const idle_interval = setInterval(function () {
            self._timer_increment();
        }, 1000);

        document.addEventListener("mousemove", function () {
            self.reset_timer();
        });
        document.addEventListener("keypress", function () {
            self.reset_timer();
        });
    }

    reset_timer() {
        this.idle_time = 0;
    }

    _timer_increment() {
        this.idle_time++;
        if (this.idle_time >= this.idle_timeout) {
            location.href = this.redirect_url;
        }
    }
}
