<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="resources_show">
        <Toolbar>
            <ToolbarButton
                action="edit"
                @go-to-edit-resource="goToResourceEdit(resource)"
            />
            <ToolbarButton
                action="delete"
                @delete-resource="doResourceDelete(resource)"
            />
        </Toolbar>

        <h2>
            {{ i18n.displayName + " #" + resource[idAttr] }}
        </h2>
        <div>
            <fieldset class="rows">
                <ol>
                    <li
                        v-for="(attr, index) in resourceAttrs.filter(
                            attr => attr.showElement?.type !== 'relationship'
                        )"
                        v-bind:key="index"
                    >
                        <ShowElement
                            :resource="resource"
                            :attr="attr"
                            :index="index"
                        />
                    </li>
                </ol>
            </fieldset>
            <template
                v-for="(attr, index) in resourceAttrs.filter(
                    attr => attr.showElement?.type === 'relationship'
                )"
                v-bind:key="'rel-' + index"
            >
                <ShowElement :resource="resource" :attr="attr" />
            </template>
            <fieldset class="action">
                <router-link
                    :to="{ name: listComponent }"
                    role="button"
                    class="cancel"
                    >{{ $__("Close") }}</router-link
                >
            </fieldset>
        </div>
    </div>
</template>

<script>
import Toolbar from "./Toolbar.vue";
import ToolbarButton from "./ToolbarButton.vue";
import ShowElement from "./ShowElement.vue";

export default {
    data() {
        return {
            initialized: false,
        };
    },
    props: {
        idAttr: String,
        apiClient: Object,
        i18n: Object,
        resourceAttrs: Array,
        listComponent: String,
        goToResourceEdit: Function,
        doResourceDelete: Function,
    },
    created() {
        this.getResource(this.$route.params[this.idAttr]);
    },
    beforeRouteUpdate(to, from) {
        this.resource = this.getResource(to.params[this.idAttr]);
    },
    methods: {
        async getResource(resourceId) {
            this.apiClient.get(resourceId).then(
                resource => {
                    this.resource = resource;
                    this.initialized = true;
                },
                error => {}
            );
        },
    },
    components: { Toolbar, ToolbarButton, ShowElement },
    name: "ResourceShow",
};
</script>
