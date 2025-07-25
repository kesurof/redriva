import api from './client';

export interface ServiceStatus {
  name: string;
  status: 'online' | 'offline' | 'error';
  lastCheck: string;
  responseTime?: number;
  version?: string;
}

export const servicesService = {
  async getStatus(): Promise<ServiceStatus[]> {
    const response = await api.get('/services/status');
    return response.data;
  },

  async checkService(serviceName: string): Promise<ServiceStatus> {
    const response = await api.post(`/services/${serviceName}/check`);
    return response.data;
  }
};
