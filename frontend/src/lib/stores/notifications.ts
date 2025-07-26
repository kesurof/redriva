import { writable } from 'svelte/store';

export interface NotificationState {
  notifications: Array<{
    id: string;
    type: 'info' | 'success' | 'warning' | 'error';
    title: string;
    message?: string;
    duration?: number;
  }>;
}

const initialState: NotificationState = {
  notifications: []
};

export const notificationStore = writable(initialState);

export const addNotification = (notification: Omit<NotificationState['notifications'][0], 'id'>) => {
  // Notifications désactivées - ne fait rien
  return '';
};

export const removeNotification = (id: string) => {
  notificationStore.update(state => ({
    ...state,
    notifications: state.notifications.filter(n => n.id !== id)
  }));
};

export const clearNotifications = () => {
  notificationStore.update(state => ({
    ...state,
    notifications: []
  }));
};
