import axios from 'axios';
import { get } from 'svelte/store';
import { authStore } from '../stores/auth';

// Configuration de base d'axios
const api = axios.create({
  baseURL: '/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Intercepteur pour ajouter le token d'authentification
api.interceptors.request.use(
  (config) => {
    const auth = get(authStore);
    if (auth.token) {
      config.headers.Authorization = `Bearer ${auth.token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Intercepteur pour gérer les erreurs de réponse
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Token expiré ou invalide - déconnecter l'utilisateur
      authStore.set({
        isAuthenticated: false,
        token: null,
        user: null
      });
    }
    return Promise.reject(error);
  }
);

export default api;
