<script>
import { inject } from "vue";

export default {
    setup() {
        //global setup for all resource (list and show for now, but maybe others?) components here
        const { setConfirmationDialog, setMessage, setError } =
            inject("mainStore");
        return { setConfirmationDialog, setMessage, setError };
    },
    methods: {
        // goToResourceEdit: function () {},
    },
    name: "BaseResource",
};
</script>
