/**
 * Store global pour l'état de l'application
 */
import { writable } from 'svelte/store';

export interface SystemStatus {
	cpu_percent: number;
	memory: {
		used: number;
		total: number;
		available: number;
	};
	disk: {
		used: number;
		total: number;
		free: number;
	};
	uptime: string;
	load_average?: number[];
	boot_time?: string;
	network?: {
		bytes_sent: number;
		bytes_recv: number;
	};
}

export interface AppState {
	isLoading: boolean;
	systemStatus: SystemStatus | null;
	lastUpdated: Date | null;
	error: string | null;
}

const initialState: AppState = {
	isLoading: false,
	systemStatus: null,
	lastUpdated: null,
	error: null
};

// Store principal de l'application
export const appStore = writable<AppState>(initialState);

// Actions pour gérer l'état de l'application
export const appActions = {
	/**
	 * Met l'application en état de chargement
	 */
	setLoading(isLoading: boolean) {
		appStore.update(state => ({
			...state,
			isLoading
		}));
	},

	/**
	 * Met à jour le statut système
	 */
	updateSystemStatus(systemStatus: SystemStatus) {
		appStore.update(state => ({
			...state,
			systemStatus,
			lastUpdated: new Date(),
			error: null
		}));
	},

	/**
	 * Définit une erreur
	 */
	setError(error: string) {
		appStore.update(state => ({
			...state,
			error,
			isLoading: false
		}));
	},

	/**
	 * Efface l'erreur
	 */
	clearError() {
		appStore.update(state => ({
			...state,
			error: null
		}));
	},

	/**
	 * Recharge les données système
	 */
	async refreshSystemStatus() {
		this.setLoading(true);
		
		try {
			const response = await fetch('/api/system');
			if (!response.ok) {
				throw new Error(`Erreur HTTP: ${response.status}`);
			}
			
			const systemStatus = await response.json();
			this.updateSystemStatus(systemStatus);
		} catch (error) {
			this.setError(error instanceof Error ? error.message : 'Erreur inconnue');
		} finally {
			this.setLoading(false);
		}
	}
};
