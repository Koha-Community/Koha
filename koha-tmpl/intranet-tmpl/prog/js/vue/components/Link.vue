<template>
    <a v-if="action === 'add'" @click="onClick" class="btn btn-default"
        ><font-awesome-icon icon="plus" /> {{ title }}</a
    >
    <a v-else-if="action === 'delete'" @click="onClick" class="btn btn-default"
        ><font-awesome-icon icon="trash" /> {{ title }}</a
    >
    <a v-else-if="action === 'edit'" @click="onClick" class="btn btn-default"
        ><font-awesome-icon icon="pencil" /> {{ title }}</a
    >
    <a
        v-else-if="action === undefined && onClick"
        @click="onclick"
        class="btn btn-default"
        ><font-awesome-icon v-if="icon" :icon="icon" /> {{ title }}</a
    >
    <a
        v-else-if="callback"
        @click="typeof callback === 'string' ? redirect() : callback(this)"
        :class="cssClass"
        style="cursor: pointer"
    >
        <font-awesome-icon v-if="icon" :icon="icon" /> {{ title }}
    </a>
    <router-link v-else :to="to" :class="cssClass"
        ><font-awesome-icon v-if="icon" :icon="icon" /> {{ title }}</router-link
    >
</template>

<script>
export default {
    props: {
        action: {
            type: String,
            required: false,
        },
        to: {
            type: [String, Object],
            required: false,
        },
        icon: {
            type: String,
            required: false,
        },
        title: {
            type: String,
        },
        callback: {
            type: [String, Function],
            required: false,
        },
        cssClass: {
            type: String,
            default: "btn btn-default",
            required: false,
        },
        onClick: { type: Function, required: false },
    },
    methods: {
        redirect(url) {
            const redirectParams = url ? url : this.to;
            window.location.href = this.formatUrl(
                typeof redirectParams === "object"
                    ? this.handleQuery(redirectParams)
                    : redirectParams
            );
        },
        formatUrl(url) {
            if (url.includes("http://") || url.includes("https://")) return url;
            if (url.includes("cgi-bin/koha"))
                return `//${window.location.host}/${url}`;
            return `//${url}`;
        },
        handleQuery(query) {
            let url = this.to.path;
            if (this.to.hasOwnProperty("query")) {
                url +=
                    "?" +
                    Object.keys(this.to.query)
                        .map(
                            queryParam =>
                                `${queryParam}=${this.to.query[queryParam]}`
                        )
                        .join("&");
            }
            return url;
        },
    },
    emits: ["go-to-add-resource", "delete-resource", "go-to-edit-resource"],
    name: "Link",
};
</script>
