// Types pour l'API Redriva
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
	cpu_usage: number;
	memory_usage: number;
	disk_usage: number;
	uptime: string;
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
