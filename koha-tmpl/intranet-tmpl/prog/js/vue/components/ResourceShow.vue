<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else :id="`${resourceNamePlural}_show`">
        <slot
            name="toolbar"
            :resource="resource"
            :componentPropData="{ ...$props, ...$data }"
        />
        <h2>
            {{ i18n.displayName + " #" + resource[idAttr] }}
        </h2>
        <div>
            <fieldset
                class="rows"
                v-for="(group, counter) in getFieldGroupings('Show', resource)"
                v-bind:key="counter"
            >
                <legend v-if="group.name">{{ group.name }}</legend>
                <ol>
                    <li
                        v-for="(attr, index) in group.fields"
                        v-bind:key="index"
                    >
                        <ShowElement :resource="resource" :attr="attr" />
                    </li>
                </ol>
            </fieldset>
            <fieldset
                class="rows"
                v-for="(item, counter) in appendToShow(this)"
                v-bind:key="counter"
            >
                <legend v-if="item.name">{{ item.name }}</legend>
                <ShowElement :resource="resource" :attr="item" />
            </fieldset>
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
import ShowElement from "./ShowElement.vue";

export default {
    inheritAttrs: false,
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
        resourceNamePlural: String,
        getFieldGroupings: Function,
        appendToShow: Function,
        getToolbarButtons: Function,
        afterResourceFetch: Function,
        getResource: Function,
    },
    created() {
        this.getResource(this.$route.params[this.idAttr], this, "show");
    },
    components: { Toolbar, ShowElement },
    name: "ResourceShow",
};
</script>
