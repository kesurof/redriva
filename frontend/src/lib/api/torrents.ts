import api from './client';

export interface TorrentItem {
  id: string;
  name: string;
  size: number;
  progress: number;
  status: 'waiting' | 'downloading' | 'completed' | 'error';
  addedAt: string;
  completedAt?: string;
  downloadUrl?: string;
}

export const torrentService = {
  async getAll(): Promise<TorrentItem[]> {
    const response = await api.get('/torrents');
    return response.data;
  },

  async getById(id: string): Promise<TorrentItem> {
    const response = await api.get(`/torrents/${id}`);
    return response.data;
  },

  async add(magnetUrl: string): Promise<TorrentItem> {
    const response = await api.post('/torrents', { magnet_url: magnetUrl });
    return response.data;
  },

  async delete(id: string): Promise<void> {
    await api.delete(`/torrents/${id}`);
  },

  async getDownloadUrl(id: string): Promise<string> {
    const response = await api.get(`/torrents/${id}/download`);
    return response.data.download_url;
  }
};
