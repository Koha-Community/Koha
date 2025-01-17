import { defineStore } from "pinia";

export const usePermissionsStore = defineStore("permissions", {
    state: () => ({
        userPermissions: null,
    }),
    actions: {
        isUserPermitted(operation, permissions) {
            const userPermissions = permissions
                ? permissions
                : this.userPermissions;
            if (!operation) return true;
            if (!userPermissions) return false;

            return (
                userPermissions.hasOwnProperty(operation) &&
                userPermissions[operation]
            );
        },
    },
});
