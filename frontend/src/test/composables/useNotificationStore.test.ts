import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { useNotificationStore } from '@/composables/useNotificationStore'

describe('useNotificationStore', () => {
  let store: ReturnType<typeof useNotificationStore>

  beforeEach(() => {
    // Create a fresh store instance and reset state
    store = useNotificationStore()
    store.clear() // Reset notifications to empty array
    
    // Use fake timers for testing auto-removal
    vi.useFakeTimers()
  })

  afterEach(() => {
    vi.useRealTimers()
  })

  describe('Initial State', () => {
    it('should initialize with empty notifications', () => {
      expect(store.notifications.value).toEqual([])
      expect(store.hasNotifications.value).toBe(false)
      expect(store.errorNotifications.value).toEqual([])
      expect(store.successNotifications.value).toEqual([])
    })
  })

  describe('Adding Notifications', () => {
    it('should add notification with auto-generated id and timestamp', () => {
      const beforeAdd = new Date()
      
      const id = store.add({
        type: 'info',
        title: 'Test Title',
        message: 'Test message'
      })

      expect(id).toBeDefined()
      expect(typeof id).toBe('string')
      expect(store.notifications.value).toHaveLength(1)
      
      const notification = store.notifications.value[0]
      expect(notification.id).toBe(id)
      expect(notification.type).toBe('info')
      expect(notification.title).toBe('Test Title')
      expect(notification.message).toBe('Test message')
      expect(notification.timestamp).toBeInstanceOf(Date)
      expect(notification.timestamp.getTime()).toBeGreaterThanOrEqual(beforeAdd.getTime())
    })

    it('should add notification with duration', () => {
      const id = store.add({
        type: 'success',
        title: 'Success',
        message: 'Operation completed',
        duration: 3000
      })

      expect(store.notifications.value).toHaveLength(1)
      expect(store.notifications.value[0].duration).toBe(3000)
    })

    it('should auto-remove notification after specified duration', () => {
      store.add({
        type: 'info',
        title: 'Auto Remove',
        message: 'This will disappear',
        duration: 2000
      })

      expect(store.notifications.value).toHaveLength(1)

      // Fast-forward time by 2 seconds
      vi.advanceTimersByTime(2000)

      expect(store.notifications.value).toHaveLength(0)
    })

    it('should not auto-remove notification without duration', () => {
      store.add({
        type: 'error',
        title: 'Permanent',
        message: 'This stays until manually removed'
      })

      expect(store.notifications.value).toHaveLength(1)

      // Fast-forward time significantly
      vi.advanceTimersByTime(10000)

      expect(store.notifications.value).toHaveLength(1)
    })
  })

  describe('Shortcut Methods', () => {
    it('should add success notification with default duration', () => {
      const id = store.success('Success!', 'Operation was successful')

      expect(store.notifications.value).toHaveLength(1)
      const notification = store.notifications.value[0]
      expect(notification.type).toBe('success')
      expect(notification.title).toBe('Success!')
      expect(notification.message).toBe('Operation was successful')
      expect(notification.duration).toBe(5000)
    })

    it('should add error notification without default duration', () => {
      const id = store.error('Error!', 'Something went wrong')

      expect(store.notifications.value).toHaveLength(1)
      const notification = store.notifications.value[0]
      expect(notification.type).toBe('error')
      expect(notification.title).toBe('Error!')
      expect(notification.message).toBe('Something went wrong')
      expect(notification.duration).toBeUndefined()
    })

    it('should add error notification with custom duration', () => {
      const id = store.error('Error!', 'Temporary error', 3000)

      expect(store.notifications.value).toHaveLength(1)
      const notification = store.notifications.value[0]
      expect(notification.type).toBe('error')
      expect(notification.duration).toBe(3000)
    })

    it('should add warning notification with default duration', () => {
      const id = store.warning('Warning!', 'Please be careful')

      expect(store.notifications.value).toHaveLength(1)
      const notification = store.notifications.value[0]
      expect(notification.type).toBe('warning')
      expect(notification.title).toBe('Warning!')
      expect(notification.message).toBe('Please be careful')
      expect(notification.duration).toBe(7000)
    })

    it('should add info notification with default duration', () => {
      const id = store.info('Info', 'Just so you know')

      expect(store.notifications.value).toHaveLength(1)
      const notification = store.notifications.value[0]
      expect(notification.type).toBe('info')
      expect(notification.title).toBe('Info')
      expect(notification.message).toBe('Just so you know')
      expect(notification.duration).toBe(5000)
    })
  })

  describe('Removing Notifications', () => {
    it('should remove notification by id', () => {
      const id1 = store.add({ type: 'info', title: 'First', message: 'First message' })
      const id2 = store.add({ type: 'success', title: 'Second', message: 'Second message' })

      expect(store.notifications.value).toHaveLength(2)

      store.remove(id1)

      expect(store.notifications.value).toHaveLength(1)
      expect(store.notifications.value[0].id).toBe(id2)
    })

    it('should handle removing non-existent notification gracefully', () => {
      store.add({ type: 'info', title: 'Test', message: 'Test message' })
      
      expect(store.notifications.value).toHaveLength(1)
      
      store.remove('non-existent-id')
      
      expect(store.notifications.value).toHaveLength(1)
    })

    it('should clear all notifications', () => {
      store.add({ type: 'info', title: 'First', message: 'First message' })
      store.add({ type: 'success', title: 'Second', message: 'Second message' })
      store.add({ type: 'error', title: 'Third', message: 'Third message' })

      expect(store.notifications.value).toHaveLength(3)

      store.clear()

      expect(store.notifications.value).toHaveLength(0)
      expect(store.hasNotifications.value).toBe(false)
    })
  })

  describe('Computed Properties', () => {
    beforeEach(() => {
      store.add({ type: 'success', title: 'Success 1', message: 'Success message 1' })
      store.add({ type: 'error', title: 'Error 1', message: 'Error message 1' })
      store.add({ type: 'warning', title: 'Warning 1', message: 'Warning message 1' })
      store.add({ type: 'success', title: 'Success 2', message: 'Success message 2' })
      store.add({ type: 'error', title: 'Error 2', message: 'Error message 2' })
    })

    it('should track total notifications count', () => {
      expect(store.notifications.value).toHaveLength(5)
      expect(store.hasNotifications.value).toBe(true)
    })

    it('should filter error notifications', () => {
      expect(store.errorNotifications.value).toHaveLength(2)
      expect(store.errorNotifications.value.every(n => n.type === 'error')).toBe(true)
    })

    it('should filter success notifications', () => {
      expect(store.successNotifications.value).toHaveLength(2)
      expect(store.successNotifications.value.every(n => n.type === 'success')).toBe(true)
    })

    it('should update computed properties when notifications change', () => {
      expect(store.hasNotifications.value).toBe(true)
      
      store.clear()
      
      expect(store.hasNotifications.value).toBe(false)
      expect(store.errorNotifications.value).toHaveLength(0)
      expect(store.successNotifications.value).toHaveLength(0)
    })
  })

  describe('Complex Scenarios', () => {
    it('should handle multiple notifications with different durations', () => {
      // Add permanent notification
      store.error('Permanent Error', 'This stays')
      
      // Add short-lived notification
      store.success('Quick Success', 'Gone in 1 second', 1000)
      
      // Add medium-lived notification
      store.warning('Medium Warning', 'Gone in 2 seconds', 2000)

      expect(store.notifications.value).toHaveLength(3)

      // After 1 second, only success should be gone
      vi.advanceTimersByTime(1000)
      expect(store.notifications.value).toHaveLength(2)
      expect(store.notifications.value.some(n => n.type === 'success')).toBe(false)

      // After 2 seconds total, warning should also be gone
      vi.advanceTimersByTime(1000)
      expect(store.notifications.value).toHaveLength(1)
      expect(store.notifications.value[0].type).toBe('error')
    })

    it('should generate unique IDs for concurrent notifications', () => {
      const ids = []
      for (let i = 0; i < 10; i++) {
        ids.push(store.add({
          type: 'info',
          title: `Test ${i}`,
          message: `Message ${i}`
        }))
      }

      // All IDs should be unique
      const uniqueIds = new Set(ids)
      expect(uniqueIds.size).toBe(10)
    })

    it('should maintain correct order of notifications', () => {
      const id1 = store.add({ type: 'info', title: 'First', message: 'First added' })
      const id2 = store.add({ type: 'success', title: 'Second', message: 'Second added' })
      const id3 = store.add({ type: 'error', title: 'Third', message: 'Third added' })

      expect(store.notifications.value[0].id).toBe(id1)
      expect(store.notifications.value[1].id).toBe(id2)
      expect(store.notifications.value[2].id).toBe(id3)
    })
  })
})
