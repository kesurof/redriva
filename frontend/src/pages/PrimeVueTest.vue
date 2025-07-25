<template>
  <div class="prime-test-page">
    <div class="p-4">
      <h1>Test PrimeVue - Importation Automatique</h1>
      
      <!-- Test des Boutons -->
      <div class="test-section">
        <h2>Boutons</h2>
        <div class="p-d-flex p-flex-wrap p-gap-2">
          <Button label="Bouton Principal" />
          <Button label="Succès" severity="success" />
          <Button label="Danger" severity="danger" />
          <Button label="Outlined" variant="outlined" />
          <Button label="Text" variant="text" />
          <Button icon="pi pi-check" label="Avec Icône" />
          <Button icon="pi pi-spin pi-spinner" label="Loading" loading />
        </div>
      </div>

      <!-- Test des Inputs -->
      <div class="test-section">
        <h2>Champs de Saisie</h2>
        <div class="p-fluid">
          <div class="p-field">
            <label for="text-input">Texte</label>
            <InputText id="text-input" v-model="textValue" placeholder="Saisissez du texte" />
          </div>
          
          <div class="p-field">
            <label for="dropdown">Liste déroulante</label>
            <Dropdown 
              id="dropdown"
              v-model="selectedCity" 
              :options="cities" 
              optionLabel="name"
              placeholder="Sélectionnez une ville" 
            />
          </div>
          
          <div class="p-field">
            <label for="calendar">Date</label>
            <Calendar id="calendar" v-model="date" placeholder="Sélectionnez une date" />
          </div>
        </div>
      </div>

      <!-- Test des Cartes -->
      <div class="test-section">
        <h2>Cartes</h2>
        <div class="p-grid">
          <div class="p-col-12 p-md-6">
            <Card>
              <template #title>
                Titre de la carte
              </template>
              <template #content>
                <p>Contenu de la carte avec du texte d'exemple. PrimeVue est maintenant configuré correctement avec l'importation automatique.</p>
              </template>
              <template #footer>
                <Button label="Action" class="p-mr-2" />
                <Button label="Annuler" variant="outlined" />
              </template>
            </Card>
          </div>
        </div>
      </div>

      <!-- Test des Messages -->
      <div class="test-section">
        <h2>Messages</h2>
        <div class="p-d-flex p-flex-column p-gap-2">
          <Message severity="success" text="Configuration PrimeVue réussie !" />
          <Message severity="info" text="Importation automatique activée" />
          <Message severity="warn" text="Version de développement" />
        </div>
      </div>

      <!-- Test du DataTable -->
      <div class="test-section">
        <h2>Tableau de Données</h2>
        <DataTable :value="products" responsiveLayout="scroll">
          <Column field="code" header="Code"></Column>
          <Column field="name" header="Nom"></Column>
          <Column field="category" header="Catégorie"></Column>
          <Column field="quantity" header="Quantité"></Column>
        </DataTable>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

// États réactifs pour les tests
const textValue = ref('')
const selectedCity = ref()
const date = ref()

// Données de test
const cities = ref([
  { name: 'Paris', code: 'PAR' },
  { name: 'Lyon', code: 'LYN' },
  { name: 'Marseille', code: 'MAR' },
  { name: 'Toulouse', code: 'TOU' }
])

const products = ref([
  { code: 'P001', name: 'Produit 1', category: 'Électronique', quantity: 12 },
  { code: 'P002', name: 'Produit 2', category: 'Vêtements', quantity: 8 },
  { code: 'P003', name: 'Produit 3', category: 'Livres', quantity: 25 },
  { code: 'P004', name: 'Produit 4', category: 'Maison', quantity: 5 }
])
</script>

<style scoped>
.prime-test-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

.test-section {
  margin-bottom: 3rem;
  padding: 1.5rem;
  border: 1px solid #dee2e6;
  border-radius: 6px;
  background: #fff;
}

.test-section h2 {
  margin-top: 0;
  margin-bottom: 1rem;
  color: #495057;
}

.dark-theme .test-section {
  background: #1f2937;
  border-color: #374151;
}

.dark-theme .test-section h2 {
  color: #f9fafb;
}
</style>
