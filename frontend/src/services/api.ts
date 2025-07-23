// Types pour l'API Redriva - RÉUTILISÉ 100% IDENTIQUE
export interface Torrent {
	id: string;
	name: string;
	title: string;
	size: string;
	status: 'downloading' | 'queued' | 'seeding' | 'error' | 'completed';
	state: 'active' | 'paused' | 'stopped';
	progress: number;
	speed: string;
	category: string;
	seeders: number;
	added_date: string;
	hash: string;
	magnet_url: string;
}

export interface QueueItem {
	id: number;
	status: string;
	created_at: string;
	updated_at: string;
	data: any;
}

export interface SystemInfo {
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
	load_average: number[];
	boot_time: string;
	network: {
		bytes_sent: number;
		bytes_recv: number;
	};
}

export interface Service {
	name: string;
	status: 'online' | 'offline';
	description: string;
	url: string;
	version: string;
	lastCheck: string;
	responseTime: number | null;
	uptime: string | null;
	cpu_usage: number | null;
	memory_usage: number | null;
	port: number;
}

export interface ApiResponse<T> {
	success: boolean;
	data?: T;
	message?: string;
	error?: string;
}

// Configuration de l'API
const API_BASE_URL = '/api';

class ApiClient {
	private async request<T>(
		endpoint: string,
		options: RequestInit = {}
	): Promise<ApiResponse<T>> {
		const url = `${API_BASE_URL}${endpoint}`;
		
		const config: RequestInit = {
			headers: {
				'Content-Type': 'application/json',
				...options.headers
			},
			...options
		};

		try {
			const response = await fetch(url, config);
			
			if (!response.ok) {
				throw new Error(`HTTP error! status: ${response.status}`);
			}
			
			const data = await response.json();
			return { success: true, data };
		} catch (error) {
			return {
				success: false,
				error: error instanceof Error ? error.message : 'Unknown error'
			};
		}
	}

	// Torrents
	async getTorrents(): Promise<ApiResponse<Torrent[]>> {
		return this.request<Torrent[]>('/torrents');
	}

	async addTorrent(torrentData: { name: string; magnet_url?: string }): Promise<ApiResponse<Torrent>> {
		return this.request<Torrent>('/torrents', {
			method: 'POST',
			body: JSON.stringify(torrentData)
		});
	}

	async deleteTorrent(torrentId: string): Promise<ApiResponse<void>> {
		return this.request<void>(`/torrents/${torrentId}`, {
			method: 'DELETE'
		});
	}

	async reinsertTorrent(torrentId: string): Promise<ApiResponse<void>> {
		return this.request<void>(`/torrents/${torrentId}/reinsert`, {
			method: 'POST'
		});
	}

	// Queue
	async getQueue(): Promise<ApiResponse<QueueItem[]>> {
		return this.request<QueueItem[]>('/queue');
	}

	async addToQueue(data: any): Promise<ApiResponse<QueueItem>> {
		return this.request<QueueItem>('/queue', {
			method: 'POST',
			body: JSON.stringify(data)
		});
	}

	async deleteFromQueue(queueId: number): Promise<ApiResponse<void>> {
		return this.request<void>(`/queue/${queueId}`, {
			method: 'DELETE'
		});
	}

	// System
	async getSystemInfo(): Promise<ApiResponse<SystemInfo>> {
		return this.request<SystemInfo>('/system');
	}

	async getServices(): Promise<ApiResponse<Service[]>> {
		return this.request<Service[]>('/services');
	}

	async getLogs(): Promise<ApiResponse<string[]>> {
		return this.request<string[]>('/logs');
	}

	async ping(): Promise<ApiResponse<{ status: string }>> {
		return this.request<{ status: string }>('/ping');
	}

	// Admin
	async updateTorrents(): Promise<ApiResponse<void>> {
		return this.request<void>('/admin/update-torrents', {
			method: 'POST'
		});
	}

	async syncWithRealDebrid(): Promise<ApiResponse<void>> {
		return this.request<void>('/admin/sync', {
			method: 'POST'
		});
	}
}

export const api = new ApiClient();

// Fonctions utilitaires réutilisées
export function bytesToGB(bytes: number): string {
	return (bytes / (1024 ** 3)).toFixed(2);
}

export function formatSize(bytes: number): string {
	if (bytes < 1024) return `${bytes} B`;
	if (bytes < 1024 ** 2) return `${(bytes / 1024).toFixed(1)} KB`;
	if (bytes < 1024 ** 3) return `${(bytes / (1024 ** 2)).toFixed(1)} MB`;
	return `${bytesToGB(bytes)} GB`;
}

export function calculatePercentage(used: number, total: number): number {
	return Math.round((used / total) * 100);
}
