// composables/useFormatting.ts - Utilitaires de formatage réutilisés
export const useFormatting = () => {
  const formatTimestamp = (timestamp: string): string => {
    try {
      const date = new Date(timestamp)
      const now = new Date()
      const diffMs = now.getTime() - date.getTime()
      const diffMins = Math.floor(diffMs / 60000)
      
      if (diffMins < 1) return 'À l\'instant'
      if (diffMins < 60) return `Il y a ${diffMins} min`
      
      const diffHours = Math.floor(diffMins / 60)
      if (diffHours < 24) return `Il y a ${diffHours}h`
      
      const diffDays = Math.floor(diffHours / 24)
      if (diffDays < 7) return `Il y a ${diffDays}j`
      
      return date.toLocaleDateString()
    } catch {
      return timestamp
    }
  }

  const formatDate = (dateString: string): string => {
    try {
      return new Date(dateString).toLocaleDateString('fr-FR', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
    } catch {
      return dateString
    }
  }

  return {
    formatTimestamp,
    formatDate
  }
}
