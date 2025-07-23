<template>
  <v-container fluid class="pa-6">
    <div class="d-flex flex-column gap-6">
      <!-- En-tête -->
      <div class="text-center">
        <h1 class="text-h3 font-weight-bold mb-2">Démonstration des Composants Vue</h1>
        <p class="text-body-1 text-medium-emphasis">
          Test des composants Vue équivalents aux composants Skeleton UI
        </p>
      </div>

      <!-- Section StatCard -->
      <section>
        <h2 class="text-h4 mb-4">StatCard - Cartes de Statistiques</h2>
        <v-row>
          <v-col cols="12" sm="6" md="3">
            <StatCard
              title="Téléchargements"
              value="1.2 To"
              icon="download"
              variant="primary"
              trend="up"
              trend-value="+12%"
            />
          </v-col>
          <v-col cols="12" sm="6" md="3">
            <StatCard
              title="CPU"
              :value="45"
              subtitle="Utilisation"
              icon="cpu"
              variant="success"
              :progress="45"
            />
          </v-col>
          <v-col cols="12" sm="6" md="3">
            <StatCard
              title="Mémoire"
              value="8.2 GB"
              subtitle="sur 16 GB"
              icon="memory"
              variant="warning"
              trend="down"
              trend-value="-5%"
              :progress="51"
            />
          </v-col>
          <v-col cols="12" sm="6" md="3">
            <StatCard
              title="Stockage"
              value="256 GB"
              subtitle="disponible"
              icon="storage"
              variant="error"
              :progress="85"
              size="sm"
            />
          </v-col>
        </v-row>

        <v-row class="mt-4">
          <v-col cols="12" md="6">
            <StatCard
              title="Files d'attente"
              :value="42"
              subtitle="éléments actifs"
              icon="queue"
              variant="info"
              trend="stable"
              trend-value="0%"
              size="lg"
            />
          </v-col>
          <v-col cols="12" md="6">
            <StatCard
              title="Données transférées"
              value="2.8 TB"
              subtitle="ce mois"
              icon="data"
              variant="secondary"
              trend="up"
              trend-value="+28%"
              size="lg"
            />
          </v-col>
        </v-row>
      </section>

      <!-- Section ServiceCard -->
      <section>
        <h2 class="text-h4 mb-4">ServiceCard - Cartes de Services</h2>
        <v-row>
          <v-col cols="12" md="6" lg="4">
            <ServiceCard
              name="Real-Debrid"
              description="Service de téléchargement premium"
              status="online"
              url="https://real-debrid.com"
              version="API v2"
              last-check="2025-07-23T10:30:00Z"
              :response-time="145"
              @test="handleServiceTest"
            />
          </v-col>
          <v-col cols="12" md="6" lg="4">
            <ServiceCard
              name="Plex Server"
              description="Serveur média local"
              status="warning"
              url="http://localhost:32400"
              version="1.32.5"
              last-check="2025-07-23T10:25:00Z"
              :response-time="1250"
              @test="handleServiceTest"
            />
          </v-col>
          <v-col cols="12" md="6" lg="4">
            <ServiceCard
              name="Service Hors Ligne"
              description="Service indisponible"
              status="offline"
              version="1.0.0"
              last-check="2025-07-23T09:45:00Z"
              @test="handleServiceTest"
            />
          </v-col>
        </v-row>

        <v-row class="mt-2">
          <v-col cols="12" md="6">
            <ServiceCard
              name="Radarr"
              description="Gestionnaire de films automatisé"
              status="maintenance"
              url="http://localhost:7878"
              version="4.7.5"
              last-check="2025-07-23T10:00:00Z"
              :response-time="89"
              @test="handleServiceTest"
            />
          </v-col>
          <v-col cols="12" md="6">
            <ServiceCard
              name="Sonarr"
              description="Gestionnaire de séries automatisé"
              status="online"
              url="http://localhost:8989"
              version="3.0.10"
              last-check="2025-07-23T10:32:00Z"
              :response-time="67"
              @test="handleServiceTest"
            />
          </v-col>
        </v-row>
      </section>

      <!-- Section TorrentCard -->
      <section>
        <h2 class="text-h4 mb-4">TorrentCard - Cartes de Torrents</h2>
        <v-row>
          <v-col cols="12" lg="6">
            <TorrentCard
              id="torrent-1"
              name="Film.Epic.2024.1080p.BluRay.x264-GROUP"
              status="downloading"
              :progress="67"
              size="8.5 GB"
              download-speed="15.2 MB/s"
              upload-speed="2.1 MB/s"
              eta="12 min"
              :seeders="45"
              :leechers="12"
              priority="high"
              @pause="handleTorrentAction"
              @resume="handleTorrentAction"
              @open="handleTorrentAction"
              @delete="handleTorrentAction"
            />
          </v-col>
          <v-col cols="12" lg="6">
            <TorrentCard
              id="torrent-2"
              name="Serie.Awesome.S01E01.720p.WEB.h264-TEAM"
              status="completed"
              :progress="100"
              size="1.2 GB"
              :seeders="125"
              :leechers="8"
              @pause="handleTorrentAction"
              @resume="handleTorrentAction"
              @open="handleTorrentAction"
              @delete="handleTorrentAction"
            />
          </v-col>
        </v-row>

        <v-row class="mt-2">
          <v-col cols="12" lg="6">
            <TorrentCard
              id="torrent-3"
              name="Game.Collection.Ultimate.Edition-REPACK"
              status="paused"
              :progress="23"
              size="45.8 GB"
              :seeders="8"
              :leechers="3"
              priority="low"
              @pause="handleTorrentAction"
              @resume="handleTorrentAction"
              @open="handleTorrentAction"
              @delete="handleTorrentAction"
            />
          </v-col>
          <v-col cols="12" lg="6">
            <TorrentCard
              id="torrent-4"
              name="Software.Professional.v2024.Multilingual-ISO"
              status="error"
              :progress="0"
              size="3.7 GB"
              @pause="handleTorrentAction"
              @resume="handleTorrentAction"
              @open="handleTorrentAction"
              @delete="handleTorrentAction"
            />
          </v-col>
        </v-row>

        <v-row class="mt-2">
          <v-col cols="12" lg="6">
            <TorrentCard
              id="torrent-5"
              name="Documentary.Nature.4K.HDR.2024-NatGeo"
              status="waiting"
              :progress="0"
              size="12.1 GB"
              :seeders="2"
              :leechers="15"
              priority="normal"
              @pause="handleTorrentAction"
              @resume="handleTorrentAction"
              @open="handleTorrentAction"
              @delete="handleTorrentAction"
            />
          </v-col>
        </v-row>
      </section>

      <!-- Section SettingCard -->
      <section>
        <h2 class="text-h4 mb-4">SettingCard - Cartes de Paramètres</h2>
        <v-row>
          <v-col cols="12" lg="6">
            <SettingCard
              title="Token API Real-Debrid"
              description="Clé d'authentification pour l'API Real-Debrid"
              category="Sécurité"
              type="password"
              :value="apiToken"
              placeholder="Entrez votre token API"
              icon="api"
              :required="true"
              @update:value="apiToken = $event"
              @change="handleSettingChange"
            />
          </v-col>
          <v-col cols="12" lg="6">
            <SettingCard
              title="Téléchargements automatiques"
              description="Activer le téléchargement automatique des torrents"
              category="Automatisation"
              type="toggle"
              :value="autoDownload"
              icon="download"
              @update:value="autoDownload = $event"
              @change="handleSettingChange"
            />
          </v-col>
        </v-row>

        <v-row class="mt-2">
          <v-col cols="12" lg="6">
            <SettingCard
              title="Limite de bande passante"
              description="Limite de téléchargement en Mo/s"
              category="Réseau"
              type="number"
              :value="bandwidthLimit"
              :min="1"
              :max="1000"
              placeholder="100"
              icon="network"
              @update:value="bandwidthLimit = $event"
              @change="handleSettingChange"
            />
          </v-col>
          <v-col cols="12" lg="6">
            <SettingCard
              title="Dossier de téléchargement"
              description="Chemin vers le dossier de téléchargement"
              category="Stockage"
              type="input"
              :value="downloadFolder"
              placeholder="/home/user/Downloads"
              icon="folder"
              @update:value="downloadFolder = $event"
              @change="handleSettingChange"
            />
          </v-col>
        </v-row>

        <v-row class="mt-2">
          <v-col cols="12" lg="6">
            <SettingCard
              title="Qualité préférée"
              description="Qualité de téléchargement par défaut"
              category="Média"
              type="select"
              :value="preferredQuality"
              :options="qualityOptions"
              icon="settings"
              @update:value="preferredQuality = $event"
              @change="handleSettingChange"
            />
          </v-col>
          <v-col cols="12" lg="6">
            <SettingCard
              title="Notes personnelles"
              description="Commentaires et notes sur la configuration"
              category="Documentation"
              type="textarea"
              :value="personalNotes"
              placeholder="Entrez vos notes ici..."
              icon="user"
              @update:value="personalNotes = $event"
              @change="handleSettingChange"
            />
          </v-col>
        </v-row>
      </section>

      <!-- Actions de test -->
      <section>
        <h2 class="text-h4 mb-4">Actions de Test</h2>
        <div class="d-flex flex-wrap gap-2">
          <v-btn 
            color="primary" 
            prepend-icon="mdi-plus"
            @click="addRandomTorrent"
          >
            Ajouter un Torrent
          </v-btn>
          <v-btn 
            color="warning" 
            prepend-icon="mdi-pause"
            @click="pauseAllTorrents"
          >
            Tout Suspendre
          </v-btn>
          <v-btn 
            color="success" 
            prepend-icon="mdi-play"
            @click="resumeAllTorrents"
          >
            Tout Reprendre
          </v-btn>
          <v-btn 
            color="info" 
            prepend-icon="mdi-refresh"
            @click="refreshStats"
          >
            Actualiser Stats
          </v-btn>
        </div>
      </section>
    </div>
  </v-container>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import StatCard from '@/components/StatCard.vue'
import ServiceCard from '@/components/ServiceCard.vue'
import TorrentCard from '@/components/TorrentCard.vue'
import SettingCard from '@/components/SettingCard.vue'
import { useNotificationStore } from '@/composables'

const { success, info, warning, error } = useNotificationStore()

// État des paramètres pour la démo
const apiToken = ref('')
const autoDownload = ref(true)
const bandwidthLimit = ref(100)
const downloadFolder = ref('/home/user/Downloads')
const preferredQuality = ref('1080p')
const personalNotes = ref('Configuration par défaut pour Redriva.')

const qualityOptions = [
  { label: '4K (2160p)', value: '2160p' },
  { label: 'Full HD (1080p)', value: '1080p' },
  { label: 'HD (720p)', value: '720p' },
  { label: 'SD (480p)', value: '480p' }
]

// Gestionnaires d'événements
const handleServiceTest = (serviceName: string) => {
  info('Test de service', `Test du service ${serviceName} en cours...`)
  
  // Simuler un test
  setTimeout(() => {
    const isSuccess = Math.random() > 0.3
    if (isSuccess) {
      success('Test réussi', `Le service ${serviceName} répond correctement`)
    } else {
      error('Test échoué', `Le service ${serviceName} ne répond pas`)
    }
  }, 2000)
}

const handleTorrentAction = (action: string, id: string) => {
  switch (action) {
    case 'pause':
      info('Torrent en pause', `Torrent ${id} mis en pause`)
      break
    case 'resume':
      success('Torrent repris', `Torrent ${id} repris`)
      break
    case 'open':
      info('Ouverture du dossier', `Ouverture du dossier pour ${id}`)
      break
    case 'delete':
      warning('Torrent supprimé', `Torrent ${id} supprimé`)
      break
  }
}

// Gestionnaire pour les changements de paramètres
const handleSettingChange = (event: { value: any }) => {
  info('Paramètre modifié', `Nouvelle valeur: ${event.value}`)
}

// Actions de test
const addRandomTorrent = () => {
  success('Nouveau torrent', 'Un nouveau torrent a été ajouté à la liste')
}

const pauseAllTorrents = () => {
  warning('Torrents suspendus', 'Tous les téléchargements ont été suspendus')
}

const resumeAllTorrents = () => {
  success('Torrents repris', 'Tous les téléchargements ont été repris')
}

const refreshStats = () => {
  info('Actualisation', 'Mise à jour des statistiques en cours...')
}
</script>
