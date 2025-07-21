/**
 * Store global pour l'état d'authentification
 */
import { writable, derived } from 'svelte/store';
import { browser } from '$app/environment';

export interface AuthState {
	isAuthenticated: boolean;
	user: {
		id?: string;
		username?: string;
		email?: string;
	} | null;
	tokens: {
		access_token?: string;
		refresh_token?: string;
	} | null;
	lastCheck: Date | null;
}

const initialState: AuthState = {
	isAuthenticated: false,
	user: null,
	tokens: null,
	lastCheck: null
};

// Store principal d'authentification
export const authStore = writable<AuthState>(initialState);

// Store dérivé pour le statut de connexion
export const isAuthenticated = derived(
	authStore,
	($auth) => $auth.isAuthenticated
);

// Store dérivé pour l'utilisateur
export const currentUser = derived(
	authStore,
	($auth) => $auth.user
);

// Actions pour gérer l'authentification
export const authActions = {
	/**
	 * Connecte un utilisateur
	 */
	login(user: any, tokens: any) {
		authStore.update(state => ({
			...state,
			isAuthenticated: true,
			user,
			tokens,
			lastCheck: new Date()
		}));
		
		// Sauvegarder dans le localStorage si on est côté client
		if (browser) {
			localStorage.setItem('redriva_auth', JSON.stringify({ user, tokens }));
		}
	},

	/**
	 * Déconnecte l'utilisateur
	 */
	logout() {
		authStore.set(initialState);
		
		if (browser) {
			localStorage.removeItem('redriva_auth');
		}
	},

	/**
	 * Charge l'état d'authentification depuis le localStorage
	 */
	loadFromStorage() {
		if (!browser) return;
		
		try {
			const stored = localStorage.getItem('redriva_auth');
			if (stored) {
				const { user, tokens } = JSON.parse(stored);
				authStore.update(state => ({
					...state,
					isAuthenticated: true,
					user,
					tokens,
					lastCheck: new Date()
				}));
			}
		} catch (error) {
			console.error('Erreur lors du chargement de l\'état d\'auth:', error);
			// En cas d'erreur, nettoyer le localStorage
			localStorage.removeItem('redriva_auth');
		}
	},

	/**
	 * Met à jour les informations utilisateur
	 */
	updateUser(user: any) {
		authStore.update(state => ({
			...state,
			user: { ...state.user, ...user },
			lastCheck: new Date()
		}));
	},

	/**
	 * Vérifie la validité de l'authentification
	 */
	async checkAuth() {
		try {
			const response = await fetch('/api/auth/status');
			const result = await response.json();
			
			if (result.authenticated) {
				authStore.update(state => ({
					...state,
					isAuthenticated: true,
					lastCheck: new Date()
				}));
				return true;
			} else {
				this.logout();
				return false;
			}
		} catch (error) {
			console.error('Erreur lors de la vérification d\'auth:', error);
			return false;
		}
	}
};

// Initialiser lors du chargement si on est côté client
if (browser) {
	authActions.loadFromStorage();
}
