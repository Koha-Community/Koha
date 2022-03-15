<template>
    <h2>Delete agreement</h2>
    <div>
        <form @submit="onSubmit($event)">
            <fieldset class="rows">
                <ol>
                    <li>
                        Agreement name:
                        {{ agreement.name }}
                    </li>
                    <li>Vendor:{{ agreement.vendor_id }}</li>
                    <li>
                        Description:
                        {{ agreement.description }}
                    </li>
                </ol>
            </fieldset>
            <fieldset class="action">
                <input type="submit" variant="primary" value="Yes, delete" />
                <a href="#" class="cancel" @click="$emit('switch-view', 'list')">No, do not delete</a>
            </fieldset>
        </form>
    </div>
</template>

<script>

export default {
    data() {
        return {
            agreement: {},
        }
    },
    created() {
        const apiUrl = '/api/v1/erm/agreements/' + this.agreement_id

        fetch(apiUrl)
            .then(res => res.json())
            .then(
                (result) => {
                    this.agreement = result
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

            let apiUrl = '/api/v1/erm/agreements/' + this.agreement_id

            const myHeaders = new Headers()
            myHeaders.append('Content-Type', 'application/json')

            const options = {
                method: 'DELETE',
                myHeaders
            }

            fetch(apiUrl, options)
                .then(
                    (response) => {
                        if (response.status == 204) {
                            this.$emit('agreement-deleted')
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
    emits: ['agreement-deleted', 'set-error', 'switch-view'],
    props: {
        agreement_id: Number
    },
    name: "AgreementsFormConfirmDelete",
}
</script>
