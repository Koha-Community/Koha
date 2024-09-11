<template>
    <h2>{{ $__("Contract(s)") }}</h2>
    <div class="dataTables_wrapper no-footer">
        <table id="contractst">
            <thead>
                <tr>
                    <th scope="col">{{ $__("Name") }}</th>
                    <th scope="col">{{ $__("Description") }}</th>
                    <th scope="col">{{ $__("Start date") }}</th>
                    <th scope="col">{{ $__("End date") }}</th>
                    <!-- PERMISSION CAN_user_acquisition_contracts_manage -->
                    <th v-if="false" scope="col" class="NoSort noExport">
                        {{ $__("Actions") }}
                    </th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="(contract, i) in vendor.contracts" :key="i">
                    <td>
                        <a
                            :href="`/cgi-bin/koha/admin/aqcontract.pl?op=add_form&contractnumber=${contract.contractnumber}&booksellerid=${contract.booksellerid}`"
                            >{{ contract.contractname }}</a
                        >
                    </td>
                    <td>{{ contract.contractdescription }}</td>
                    <td :data-order="contract.contractstartdate">
                        {{ contract.contractstartdate }}
                    </td>
                    <td :data-order="contract.contractenddate">
                        {{ contract.contractenddate }}
                    </td>
                    <!-- PERMISSION CAN_user_acquisition_contracts_manage -->
                    <td class="actions" v-if="false">
                        <a
                            class="btn btn-default btn-xs"
                            :href="`/cgi-bin/koha/admin/aqcontract.pl?op=add_form&contractnumber=${contract.contractnumber}&booksellerid=${contract.booksellerid}`"
                            ><i
                                class="fa-solid fa-pencil"
                                aria-hidden="true"
                            ></i>
                            {{ $__("Edit") }}</a
                        >
                        <a
                            class="btn btn-default btn-xs"
                            :href="`/cgi-bin/koha/admin/aqcontract.pl?op=delete_confirm&contractnumber=${contract.contractnumber}&booksellerid=${contract.booksellerid}`"
                            ><i class="fa fa-trash-can"></i>
                            {{ $__("Delete") }}</a
                        >
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</template>

<script>
export default {
    props: {
        vendor: Object,
    },
};
</script>

<style></style>
