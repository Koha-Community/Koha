import { defineStore } from 'pinia'

export const useVendorStore = defineStore('vendors', {
  state: () => ({
    vendors: [],
  }),
})