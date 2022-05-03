<template>
    <h2>Delete license</h2>
    <div>
        <form @submit="onSubmit($event)">
            <fieldset class="rows">
                <ol>
                    <li>
                        License name:
                        {{ license.name }}
                    </li>
                    <li>
                        Description:
                        {{ license.description }}
                    </li>
                </ol>
            </fieldset>
            <fieldset class="action">
                <input type="submit" variant="primary" value="Yes, delete" />
                <a role="button" class="cancel" @click="$emit('switch-view', 'list')"
                    >No, do not delete</a
                >
            </fieldset>
        </form>
    </div>
</template>

<script>

export default {
    data() {
        return {
            license: {},
        }
    },
    created() {
        const apiUrl = '/api/v1/erm/licenses/' + this.license_id

        fetch(apiUrl)
            .then(res => res.json())
            .then(
                (result) => {
                    this.license= result
                },
            ).catch(
                (error) => {
                    this.$emit('set-error', error)
                }
            )
    },
    methods: {
        onSubmit(e) {
            e.preventDefault()

            let apiUrl = '/api/v1/erm/licenses/' + this.license_id

            const options = {
                method: 'DELETE',
                headers: {
                    'Content-Type': 'application/json;charset=utf-8'
                },
            }

            fetch(apiUrl, options)
                .then(
                    (response) => {
                        if (response.status == 204) {
                            this.$emit('license-deleted')
                        } else {
                            this.$emit('set-error', response.message || response.statusText)
                        }
                    }
                ).catch(
                    (error) => {
                        this.$emit('set-error', error)
                    }
                )
        }
    },
    emits: ['license-deleted', 'set-error', 'switch-view'],
    props: {
        license_id: Number
    },
    name: "LicensesFormConfirmDelete",
}
</script>
