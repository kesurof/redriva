<template>
  <div class="grid">
    <div class="col-12">
      <Card>
        <template #title>
          <i class="pi pi-cog mr-2"></i>
          Paramètres du Thème
        </template>
        <template #content>
          <div class="grid">
            <!-- Sélection du thème -->
            <div class="col-12 md:col-6">
              <h5>Thème Principal</h5>
              <div class="flex flex-column gap-2">
                <div 
                  v-for="theme in themes" 
                  :key="theme.key"
                  class="theme-option p-3 border-1 border-300 border-round cursor-pointer hover:border-primary transition-colors"
                  :class="{ 'border-primary bg-primary-50': selectedTheme === theme.key }"
                  @click="selectTheme(theme.key)"
                >
                  <div class="flex align-items-center justify-content-between">
                    <div>
                      <div class="font-medium text-900">{{ theme.name }}</div>
                      <div class="text-600 text-sm">{{ theme.description }}</div>
                    </div>
                    <div class="flex gap-1">
                      <div 
                        v-for="color in theme.colors" 
                        :key="color"
                        class="w-1rem h-1rem border-round"
                        :style="{ backgroundColor: color }"
                      ></div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Mode sombre/clair -->
            <div class="col-12 md:col-6">
              <h5>Mode d'affichage</h5>
              <div class="flex flex-column gap-3">
                <div class="flex align-items-center">
                  <ToggleSwitch v-model="isDarkMode" @change="toggleDarkMode" />
                  <label class="ml-2">Mode sombre</label>
                </div>

                <div class="p-3 border-1 border-300 border-round">
                  <h6 class="mt-0">Aperçu</h6>
                  <div class="flex gap-2 mb-2">
                    <Button label="Bouton primaire" size="small" />
                    <Button label="Secondaire" severity="secondary" size="small" />
                  </div>
                  <div class="flex gap-2">
                    <Badge value="Badge" />
                    <Tag value="Tag" />
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Personnalisation -->
          <Divider />
          
          <div class="grid">
            <div class="col-12">
              <h5>Personnalisation Avancée</h5>
              <p class="text-600 mb-4">
                Personnalisez les couleurs principales du thème sélectionné.
              </p>
              
              <div class="grid">
                <div class="col-12 md:col-4">
                  <label class="block text-900 font-medium mb-2">Couleur Primaire</label>
                  <ColorPicker 
                    v-model="customColors.primary" 
                    format="hex"
                    @change="updateThemeColors"
                  />
                  <InputText 
                    v-model="customColors.primary" 
                    class="w-full mt-2"
                    placeholder="#3B82F6"
                  />
                </div>
                
                <div class="col-12 md:col-4">
                  <label class="block text-900 font-medium mb-2">Couleur de Surface</label>
                  <ColorPicker 
                    v-model="customColors.surface" 
                    format="hex"
                    @change="updateThemeColors"
                  />
                  <InputText 
                    v-model="customColors.surface" 
                    class="w-full mt-2"
                    placeholder="#FFFFFF"
                  />
                </div>
                
                <div class="col-12 md:col-4">
                  <label class="block text-900 font-medium mb-2">Couleur de Texte</label>
                  <ColorPicker 
                    v-model="customColors.text" 
                    format="hex"
                    @change="updateThemeColors"
                  />
                  <InputText 
                    v-model="customColors.text" 
                    class="w-full mt-2"
                    placeholder="#1F2937"
                  />
                </div>
              </div>
            </div>
          </div>

          <!-- Actions -->
          <div class="flex gap-2 mt-4">
            <Button label="Réinitialiser" severity="secondary" @click="resetTheme" />
            <Button label="Exporter Configuration" severity="help" @click="exportConfig" />
          </div>
        </template>
      </Card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'

const selectedTheme = ref('aura')
const isDarkMode = ref(false)

const customColors = ref({
  primary: '#3B82F6',
  surface: '#FFFFFF', 
  text: '#1F2937'
})

const themes = ref([
  {
    key: 'aura',
    name: 'Aura',
    description: 'Thème moderne et épuré',
    colors: ['#3B82F6', '#EF4444', '#10B981', '#F59E0B']
  },
  {
    key: 'lara',
    name: 'Lara',
    description: 'Thème élégant et professionnel',
    colors: ['#6366F1', '#EC4899', '#06B6D4', '#84CC16']
  },
  {
    key: 'material',
    name: 'Material',
    description: 'Basé sur Material Design',
    colors: ['#1976D2', '#D32F2F', '#388E3C', '#F57C00']
  },
  {
    key: 'nora',
    name: 'Nora',
    description: 'Thème minimaliste',
    colors: ['#2563EB', '#DC2626', '#059669', '#D97706']
  }
])

const selectTheme = (themeKey: string) => {
  selectedTheme.value = themeKey
  // TODO: Implémenter le changement de thème dynamique
  console.log('Thème sélectionné:', themeKey)
}

const toggleDarkMode = () => {
  const html = document.documentElement
  if (isDarkMode.value) {
    html.classList.add('dark-mode')
  } else {
    html.classList.remove('dark-mode')
  }
}

const updateThemeColors = () => {
  // TODO: Implémenter la mise à jour des couleurs en temps réel
  console.log('Couleurs personnalisées:', customColors.value)
}

const resetTheme = () => {
  selectedTheme.value = 'aura'
  isDarkMode.value = false
  customColors.value = {
    primary: '#3B82F6',
    surface: '#FFFFFF',
    text: '#1F2937'
  }
  document.documentElement.classList.remove('dark-mode')
}

const exportConfig = () => {
  const config = {
    theme: selectedTheme.value,
    darkMode: isDarkMode.value,
    customColors: customColors.value
  }
  
  const blob = new Blob([JSON.stringify(config, null, 2)], { 
    type: 'application/json' 
  })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = 'redriva-theme-config.json'
  link.click()
  URL.revokeObjectURL(url)
}

onMounted(() => {
  // Charger les préférences sauvegardées
  const savedTheme = localStorage.getItem('redriva-theme')
  const savedDarkMode = localStorage.getItem('redriva-dark-mode')
  
  if (savedTheme) {
    selectedTheme.value = savedTheme
  }
  
  if (savedDarkMode === 'true') {
    isDarkMode.value = true
    document.documentElement.classList.add('dark-mode')
  }
})
</script>

<style scoped>
.theme-option {
  transition: all 0.2s ease;
}

.theme-option:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}
</style>
