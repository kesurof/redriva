<!-- frontend/src/pages/SakaiDemo.vue -->
<template>
  <div class="grid">
    <div class="col-12">
      <Card>
        <template #title>
          <div class="flex justify-content-between align-items-center">
            <span class="text-xl font-bold">Démonstration du Template Sakai</span>
            <Tag value="Officiel" severity="success"></Tag>
          </div>
        </template>
        <template #subtitle>
          Aperçu des composants PrimeVue avec le style Sakai.
        </template>
        <template #content>
          <div class="grid">
            <div class="col-12 md:col-6">
              <div class="p-fluid">
                <h5>Formulaire</h5>
                <div class="field">
                  <label for="name">Nom</label>
                  <InputText id="name" type="text" />
                </div>
                <div class="field">
                  <label for="email">Email</label>
                  <InputText id="email" type="text" />
                </div>
              </div>
            </div>
            <div class="col-12 md:col-6">
              <h5>Boutons d'Action</h5>
              <div class="flex flex-wrap gap-2">
                <Button label="Principal" />
                <Button label="Secondaire" severity="secondary" outlined />
                <Button label="Danger" severity="danger" text />
                <Button icon="pi pi-check" rounded />
              </div>
            </div>
            <div class="col-12 p-mt-4">
              <h5>Tableau de Données</h5>
              <DataTable :value="products">
                <Column field="code" header="Code"></Column>
                <Column field="name" header="Nom"></Column>
                <Column field="category" header="Catégorie"></Column>
                <Column field="quantity" header="Quantité"></Column>
              </DataTable>
            </div>
          </div>
        </template>
        <template #footer>
          <div class="flex justify-content-end">
            <Button label="En savoir plus" icon="pi pi-arrow-right" iconPos="right" />
          </div>
        </template>
      </Card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const products = ref([
    { code: 'P100', name: 'Produit A', category: 'Électronique', quantity: 24 },
    { code: 'P101', name: 'Produit B', category: 'Vêtements', quantity: 50 },
    { code: 'P102', name: 'Produit C', category: 'Maison', quantity: 12 }
]);
</script>
