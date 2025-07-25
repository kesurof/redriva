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
  const id = Math.random().toString(36).substr(2, 9);
  const newNotification = {
    ...notification,
    id,
    duration: notification.duration || 5000
  };

  notificationStore.update(state => ({
    ...state,
    notifications: [...state.notifications, newNotification]
  }));

  // Auto-remove notification après la durée spécifiée
  if (newNotification.duration > 0) {
    setTimeout(() => {
      removeNotification(id);
    }, newNotification.duration);
  }

  return id;
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
