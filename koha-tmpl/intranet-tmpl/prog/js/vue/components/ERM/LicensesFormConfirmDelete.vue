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
                <a
                    role="button"
                    class="cancel"
                    @click="this.setCurrentView('list')"
                    >No, do not delete</a
                >
            </fieldset>
        </form>
    </div>
</template>

<script>
import { useMainStore } from "../../stores/main"

export default {
    setup() {
        const mainStore = useMainStore()
        const { setMessage, setError, setCurrentView } = mainStore
        return {
            setMessage, setError, setCurrentView,
        }
    },
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
                    this.license = result
                },
            ).catch(
                (error) => {
                    this.setError(error)
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
                            this.setMessage("License deleted")
                            this.setCurrentView('list')
                        } else {
                            this.setError(response.message || response.statusText)
                        }
                    }
                ).catch(
                    (error) => {
                        this.setError(error)
                    }
                )
        }
    },
    props: {
        license_id: Number
    },
    name: "LicensesFormConfirmDelete",
}
</script>
