<template>
  <div class="symlink-page">
    <!-- Header -->
    <div class="page-header">
      <div class="page-header-content">
        <div class="page-title-wrapper">
          <i class="pi pi-link page-icon"></i>
          <div>
            <h1 class="page-title">Symlink Manager</h1>
            <p class="page-description">Gérez vos liens symboliques et répertoires</p>
          </div>
        </div>
        <div class="page-actions">
          <Button icon="pi pi-plus" label="Nouveau Symlink" class="p-button-primary" />
          <Button icon="pi pi-refresh" label="Actualiser" class="p-button-outlined" />
        </div>
      </div>
    </div>

    <!-- Stats Cards -->
    <div class="stats-grid">
      <Card class="stat-card">
        <template #content>
          <div class="stat-content">
            <div class="stat-icon primary">
              <i class="pi pi-link"></i>
            </div>
            <div class="stat-details">
              <span class="stat-value">0</span>
              <span class="stat-label">Symlinks Actifs</span>
            </div>
          </div>
        </template>
      </Card>

      <Card class="stat-card">
        <template #content>
          <div class="stat-content">
            <div class="stat-icon success">
              <i class="pi pi-check-circle"></i>
            </div>
            <div class="stat-details">
              <span class="stat-value">0</span>
              <span class="stat-label">Liens Valides</span>
            </div>
          </div>
        </template>
      </Card>

      <Card class="stat-card">
        <template #content>
          <div class="stat-content">
            <div class="stat-icon warning">
              <i class="pi pi-exclamation-triangle"></i>
            </div>
            <div class="stat-details">
              <span class="stat-value">0</span>
              <span class="stat-label">Liens Cassés</span>
            </div>
          </div>
        </template>
      </Card>

      <Card class="stat-card">
        <template #content>
          <div class="stat-content">
            <div class="stat-icon info">
              <i class="pi pi-folder"></i>
            </div>
            <div class="stat-details">
              <span class="stat-value">0</span>
              <span class="stat-label">Répertoires</span>
            </div>
          </div>
        </template>
      </Card>
    </div>

    <!-- Main Content Area -->
    <Card class="content-card">
      <template #header>
        <div class="card-header">
          <h3>Liste des Symlinks</h3>
          <div class="header-actions">
            <InputText placeholder="Rechercher..." class="search-input" />
            <Dropdown 
              placeholder="Filtrer par statut" 
              :options="filterOptions" 
              option-label="label"
              class="filter-dropdown"
            />
          </div>
        </div>
      </template>
      
      <template #content>
        <div class="empty-state">
          <div class="empty-icon">
            <i class="pi pi-link"></i>
          </div>
          <h3>Aucun symlink configuré</h3>
          <p>Commencez par créer votre premier lien symbolique pour organiser vos fichiers.</p>
          <Button label="Créer un Symlink" icon="pi pi-plus" class="p-button-primary" />
        </div>
      </template>
    </Card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

// Options pour le dropdown de filtrage
const filterOptions = ref([
  { label: 'Tous', value: 'all' },
  { label: 'Actifs', value: 'active' },
  { label: 'Cassés', value: 'broken' }
])
</script>

<style scoped>
.symlink-page {
  padding: 0;
}

/* Page Header */
.page-header {
  margin-bottom: 2rem;
}

.page-header-content {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 2rem;
  flex-wrap: wrap;
}

.page-title-wrapper {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.page-icon {
  font-size: 2.5rem;
  color: #6366f1;
}

.page-title {
  font-size: 2.25rem;
  font-weight: 700;
  color: #1e293b;
  margin: 0 0 0.5rem 0;
}

.page-description {
  color: #64748b;
  margin: 0;
  font-size: 1.1rem;
}

.page-actions {
  display: flex;
  gap: 1rem;
  align-items: center;
}

/* Stats Grid */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.stat-card {
  background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
  border: none;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 0.5rem;
}

.stat-icon {
  width: 3.5rem;
  height: 3.5rem;
  border-radius: 1rem;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  color: white;
}

.stat-icon.primary {
  background: linear-gradient(135deg, #6366f1, #8b5cf6);
}

.stat-icon.success {
  background: linear-gradient(135deg, #10b981, #059669);
}

.stat-icon.warning {
  background: linear-gradient(135deg, #f59e0b, #d97706);
}

.stat-icon.info {
  background: linear-gradient(135deg, #3b82f6, #1d4ed8);
}

.stat-details {
  display: flex;
  flex-direction: column;
}

.stat-value {
  font-size: 2rem;
  font-weight: 700;
  color: #1e293b;
  line-height: 1;
}

.stat-label {
  color: #64748b;
  font-size: 0.875rem;
  font-weight: 500;
  margin-top: 0.25rem;
}

/* Content Card */
.content-card {
  background: white;
  border: none;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 2rem;
  flex-wrap: wrap;
  padding: 1rem 1.5rem;
  border-bottom: 1px solid #e2e8f0;
}

.card-header h3 {
  margin: 0;
  color: #1e293b;
  font-weight: 600;
}

.header-actions {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.search-input {
  min-width: 200px;
}

.filter-dropdown {
  min-width: 160px;
}

/* Empty State */
.empty-state {
  text-align: center;
  padding: 4rem 2rem;
}

.empty-icon {
  font-size: 4rem;
  color: #cbd5e1;
  margin-bottom: 1.5rem;
}

.empty-state h3 {
  color: #475569;
  font-size: 1.5rem;
  margin-bottom: 1rem;
}

.empty-state p {
  color: #64748b;
  font-size: 1.1rem;
  margin-bottom: 2rem;
  max-width: 400px;
  margin-left: auto;
  margin-right: auto;
}

/* Dark mode */
:global(.layout-dark) .page-title {
  color: #f1f5f9;
}

:global(.layout-dark) .page-description {
  color: #94a3b8;
}

:global(.layout-dark) .stat-card {
  background: linear-gradient(135deg, #1e293b 0%, #334155 100%);
}

:global(.layout-dark) .stat-value {
  color: #f1f5f9;
}

:global(.layout-dark) .stat-label {
  color: #94a3b8;
}

:global(.layout-dark) .content-card {
  background: #1e293b;
}

:global(.layout-dark) .card-header {
  border-bottom-color: #334155;
}

:global(.layout-dark) .card-header h3 {
  color: #f1f5f9;
}

:global(.layout-dark) .empty-state h3 {
  color: #cbd5e1;
}

:global(.layout-dark) .empty-state p {
  color: #94a3b8;
}
</style>
