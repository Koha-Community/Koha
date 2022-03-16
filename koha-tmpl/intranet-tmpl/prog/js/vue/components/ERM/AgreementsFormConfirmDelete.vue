<template>
    <h2>Delete agreement</h2>
    <div>
        <b-form @submit="onSubmit">
            <b-form-group
                id="agreement_name"
                label="Agreement name:"
                label-for="agreement_name"
                label-cols="4"
                label-cols-lg="2"
            >
                {{ agreement.name }}
            </b-form-group>
            <b-form-group
                id="agreement_vendor"
                label="Vendor:"
                label-for="agreement_vendor"
                label-cols="4"
                label-cols-lg="2"
            >
                {{ agreement.vendor_id }}
            </b-form-group>
            <b-form-group
                id="agreement_description"
                label="Description:"
                label-for="agreement_description"
                label-cols="4"
                label-cols-lg="2"
            >
                {{ agreement.description }}
            </b-form-group>
            <b-button type="submit" variant="primary">Submit</b-button>
            <a href="#" @click="$emit('switch-view', 'list')">Cancel</a>
        </b-form>
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
        onSubmit() {

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
