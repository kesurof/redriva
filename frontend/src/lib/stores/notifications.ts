/**
 * Store global pour les notifications
 */
import { writable } from 'svelte/store';

export interface Notification {
	id: string;
	type: 'success' | 'error' | 'warning' | 'info';
	title: string;
	message: string;
	duration?: number; // en millisecondes, undefined = permanente
	timestamp: Date;
}

// Store des notifications
export const notificationsStore = writable<Notification[]>([]);

// Actions pour gérer les notifications
export const notificationActions = {
	/**
	 * Ajoute une nouvelle notification
	 */
	add(notification: Omit<Notification, 'id' | 'timestamp'>) {
		const newNotification: Notification = {
			...notification,
			id: crypto.randomUUID(),
			timestamp: new Date()
		};

		notificationsStore.update(notifications => [...notifications, newNotification]);

		// Auto-suppression si durée spécifiée
		if (newNotification.duration) {
			setTimeout(() => {
				notificationActions.remove(newNotification.id);
			}, newNotification.duration);
		}

		return newNotification.id;
	},

	/**
	 * Supprime une notification
	 */
	remove(id: string) {
		notificationsStore.update(notifications => 
			notifications.filter(n => n.id !== id)
		);
	},

	/**
	 * Vide toutes les notifications
	 */
	clear() {
		notificationsStore.set([]);
	},

	/**
	 * Notifications de raccourci
	 */
	success(title: string, message: string, duration: number = 5000) {
		return this.add({ type: 'success', title, message, duration });
	},

	error(title: string, message: string, duration?: number) {
		return this.add({ type: 'error', title, message, duration });
	},

	warning(title: string, message: string, duration: number = 7000) {
		return this.add({ type: 'warning', title, message, duration });
	},

	info(title: string, message: string, duration: number = 5000) {
		return this.add({ type: 'info', title, message, duration });
	}
};
