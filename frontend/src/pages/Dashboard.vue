<template>
  <div class="dashboard">
    <div class="p-4">
      <h1>Dashboard Redriva</h1>
      <p>Tableau de bord principal avec PrimeVue</p>
      
      <div class="p-grid">
        <div class="p-col-12">
          <Card>
            <template #title>
              Bienvenue sur Redriva
            </template>
            <template #content>
              <p>Interface modernisée avec PrimeVue et importation automatique des composants.</p>
              <div class="p-mt-3">
                <Button label="Aller au test PrimeVue" @click="$router.push('/test-primevue')" />
              </div>
            </template>
          </Card>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// Dashboard principal
</script>

<style scoped>
.dashboard {
  max-width: 1200px;
  margin: 0 auto;
}
</style>
