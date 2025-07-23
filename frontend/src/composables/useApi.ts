// composables/useApi.ts - Wrapper pour le client API
import { ref } from 'vue'
import { api } from '@/services/api'

export const useApi = () => {
  const apiClient = api

  return {
    apiClient
  }
}
