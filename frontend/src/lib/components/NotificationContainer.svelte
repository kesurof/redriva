<script lang="ts">
  import { onMount } from 'svelte';
  import { notificationStore } from '../stores/notifications';
  import { X, CheckCircle, AlertCircle, Info, AlertTriangle } from 'lucide-svelte';

  $: notifications = $notificationStore.notifications;

  const iconMap = {
    success: CheckCircle,
    error: AlertCircle,
    warning: AlertTriangle,
    info: Info
  };

  const colorMap = {
    success: 'bg-green-50 border-green-200 text-green-800',
    error: 'bg-red-50 border-red-200 text-red-800',
    warning: 'bg-yellow-50 border-yellow-200 text-yellow-800',
    info: 'bg-blue-50 border-blue-200 text-blue-800'
  };

  function removeNotification(id: string) {
    notificationStore.update(state => ({
      ...state,
      notifications: state.notifications.filter(n => n.id !== id)
    }));
  }
</script>

<div class="fixed top-4 right-4 z-50 space-y-2 max-w-sm">
  {#each notifications as notification (notification.id)}
    <div
      class="p-4 rounded-lg border shadow-lg transition-all duration-300 {colorMap[notification.type]}"
    >
      <div class="flex items-start">
        <svelte:component 
          this={iconMap[notification.type]} 
          class="w-5 h-5 mr-3 mt-0.5 flex-shrink-0"
        />
        
        <div class="flex-1 min-w-0">
          <h4 class="font-semibold text-sm">{notification.title}</h4>
          {#if notification.message}
            <p class="text-sm mt-1 opacity-90">{notification.message}</p>
          {/if}
        </div>

        <button
          on:click={() => removeNotification(notification.id)}
          class="ml-2 p-1 rounded-full hover:bg-black/10 transition-colors"
        >
          <X class="w-4 h-4" />
        </button>
      </div>
    </div>
  {/each}
</div>
