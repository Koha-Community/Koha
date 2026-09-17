<template>
    <fieldset class="rows" id="trigger-edit-form-context">
        <legend>
            {{ $__("Circulation rules for this context (summarised)") }}
        </legend>
        <div class="page-section bg-info">
            <table>
                <thead>
                    <tr>
                        <th>
                            {{ $__("Loan period") }}
                        </th>
                        <th>
                            {{ $__("Unit") }}
                        </th>
                        <th>
                            {{ $__("Decreased loan period for high holds") }}
                        </th>
                        <th>
                            {{ $__("Fine amount") }}
                        </th>
                        <th>
                            {{ $__("Fine charging interval") }}
                        </th>
                        <th>
                            {{ $__("Renewals allowed") }}
                        </th>
                        <th>
                            {{ $__("Automatic renewal") }}
                        </th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            {{ ruleSetInfo.issuelength }}
                        </td>
                        <td>
                            {{ ruleSetInfo.lengthunit }}
                        </td>
                        <td>
                            {{ ruleSetInfo.decreaseloanholds }}
                        </td>
                        <td>
                            {{ ruleSetInfo.fine }}
                        </td>
                        <td>
                            {{ ruleSetInfo.chargeperiod }}
                        </td>
                        <td>
                            {{ ruleSetInfo.renewalsallowed }}
                        </td>
                        <td>
                            {{
                                ruleSetInfo.auto_renew ? $__("Yes") : $__("No")
                            }}
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </fieldset>
</template>

<script>
export default {
    props: ["ruleSetInfo"],
};
</script>

<style scoped>
table {
    margin: auto;
    width: fit-content;
}
</style>
