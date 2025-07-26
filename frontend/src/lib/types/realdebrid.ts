/**
 * Types TypeScript pour l'intégration Real-Debrid
 * Basés sur les types RDM (Real-Debrid Manager)
 */

// Types de base Real-Debrid
export interface TorrentsResponse {
	added: string;
	bytes: number;
	ended: string | null | undefined;
	filename: string;
	original_filename?: string;
	hash: string;
	host: string;
	id: string;
	links: string[];
	progress: number | null | undefined;
	split: number;
	status: string;
}

export interface TorrentInfoFiles {
	id: number;
	path: string;
	bytes: number;
	selected: number;
}

export interface TorrentInfoResponse {
	id: string;
	filename: string;
	original_filename: string;
	hash: string;
	bytes: number;
	original_bytes: number;
	host: string;
	split: number;
	progress: number;
	status: string;
	added: string;
	files: TorrentInfoFiles[];
	links: string[];
	ended: string;
}

// Types étendus avec métadonnées (style RDM)
export interface ParsedTorrentsResponse extends TorrentsResponse {
	metadata?: {
		mediaType: 'movie' | 'tv';
		parsedData: any;
	};
}

// Configuration API
export interface APIResponse {
	success: boolean;
	status: number;
	error?: string;
	data?: any;
}

// Types de pagination (RDM-style)
export interface PaginationParams {
	limit: number;  // max 1000 par requête, 2500 total
	page: number;   // commence à 1
}

export interface PaginationMeta {
	currentPage: number;
	totalPages: number;
	totalItems: number;
	itemsPerPage: number;
	hasNextPage: boolean;
	hasPrevPage: boolean;
}

// Réponse paginée
export interface PaginatedResponse<T> {
	data: T[];
	meta: PaginationMeta;
}

// Configuration des limites (basée sur RDM)
export const API_LIMITS = {
	MAX_LIMIT_PER_REQUEST: 1000,
	MAX_TOTAL_LIMIT: 2500,
	DEFAULT_LIMIT: 25,
	PAGINATION_OPTIONS: [25, 50, 100, 250, 500, 1000]
} as const;

// Status des torrents Real-Debrid
export type TorrentStatus = 
	| 'magnet_error'
	| 'magnet_conversion'
	| 'waiting_files_selection'
	| 'queued'
	| 'downloading'
	| 'downloaded'
	| 'error'
	| 'virus'
	| 'compressing'
	| 'uploading'
	| 'dead';

// Filtres de recherche
export interface TorrentFilters {
	status?: TorrentStatus[];
	host?: string[];
	dateRange?: {
		start: string;
		end: string;
	};
	sizeRange?: {
		min: number;
		max: number;
	};
}

// Types pour les actions sur les torrents
export interface TorrentAction {
	id: string;
	action: 'delete' | 'restart' | 'select_files';
	params?: any;
}

export interface AddMagnetResponse {
	id: string;
	uri: string;
}

// Configuration Real-Debrid
export interface RealDebridConfig {
	baseUri: string;
	authUri: string;
	clientId: string;
	userAgent: string;
}

// Constantes de configuration (basées sur RDM)
// Configuration API Real-Debrid
export const RealDebridConfig = {
	baseUrl: 'https://api.real-debrid.com/rest/1.0',
	authUrl: 'https://api.real-debrid.com',
	maxLimitPerRequest: 1000,  // Limite par requête API
	maxTotalLimit: 2500        // Limite totale effective
};
