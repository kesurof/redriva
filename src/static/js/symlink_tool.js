/**
 * Symlink Tool JavaScript - Logique frontend pour le gestionnaire de symlink
 * Gestion des onglets, appels API, progression temps réel
 */

// Variables globales
let currentScanId = null;
let scanPollingInterval = null;
let currentConfig = {};
let loadedDirectories = [];

// Variables globales pour le cleanup
let selectedCleanupTorrents = new Set();
let cleanupAnalysisData = null;

// ═══════════════════════════════════════════════════════════════════════════════
// GESTION DES ONGLETS
// ═══════════════════════════════════════════════════════════════════════════════

function switchTab(tabName, buttonElement) {
    // Masquer tous les onglets
    document.querySelectorAll('.tab-pane').forEach(pane => {
        pane.classList.remove('active');
    });
    
    // Masquer tous les boutons d'onglets
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    
    // Afficher l'onglet sélectionné
    const targetTab = document.getElementById(tabName + '-tab');
    if (targetTab) {
        targetTab.classList.add('active');
    }
    
    // Activer le bouton d'onglet si fourni
    if (buttonElement && buttonElement.classList) {
        buttonElement.classList.add('active');
    }
    
    // Charger les données selon l'onglet
    switch(tabName) {
        case 'dashboard':
            loadDashboard();
            break;
        case 'scanner':
            loadScanner();
            break;
        case 'cleanup':
            loadCleanup();
            break;
        case 'settings':
            loadConfiguration();
            break;
    }
    
    // Sauvegarder l'état dans le localStorage
    localStorage.setItem('symlink_active_tab', tabName);
}

// ═══════════════════════════════════════════════════════════════════════════════
// GESTION DES APPELS API
// ═══════════════════════════════════════════════════════════════════════════════

async function apiCall(url, options = {}) {
    try {
        const response = await fetch(url, {
            headers: {
                'Content-Type': 'application/json',
                ...options.headers
            },
            ...options
        });
        
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        
        return await response.json();
    } catch (error) {
        console.error('Erreur API:', error);
        showToast('Erreur de communication avec le serveur', 'error');
        throw error;
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ONGLET DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════

async function loadDashboard() {
    try {
        // Charger l'historique des scans
        const response = await apiCall('/api/symlink/scans/history');
        
        if (response.success) {
            displayHistory(response.scans);
        }
    } catch (error) {
        console.error('Erreur chargement dashboard:', error);
    }
}

function displayHistory(scans) {
    const tbody = document.getElementById('history-body');
    
    if (!scans || scans.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="9" style="text-align: center; color: #6c757d; padding: 30px;">
                    Aucun scan effectué
                </td>
            </tr>
        `;
        return;
    }
    
    tbody.innerHTML = scans.map(scan => `
        <tr>
            <td>${formatDate(scan.date)}</td>
            <td>${scan.mode === 'dry-run' ? '🔍 Dry-run' : '🗑️ Réel'}</td>
            <td>${scan.verification_depth === 'basic' ? '⚡ Basique' : '🔬 Complète'}</td>
            <td>${scan.total_analyzed || 0}</td>
            <td>${scan.total_problems || 0}</td>
            <td>${scan.files_deleted || 0}</td>
            <td>${formatDuration(scan.duration)}</td>
            <td>${getStatusBadge(scan.status)}</td>
            <td>
                <button class="btn btn-sm btn-primary" onclick="rerunScan('${scan.id}')">
                    🔄 Relancer
                </button>
            </td>
        </tr>
    `).join('');
}

function formatDate(dateStr) {
    return new Date(dateStr).toLocaleString('fr-FR');
}

function formatDuration(seconds) {
    if (!seconds) return 'N/A';
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}m${secs}s`;
}

function getStatusBadge(status) {
    const badges = {
        'completed': '<span class="badge badge-success">✅ Terminé</span>',
        'running': '<span class="badge badge-warning">⏳ En cours</span>',
        'cancelled': '<span class="badge badge-secondary">❌ Annulé</span>',
        'error': '<span class="badge badge-danger">⚠️ Erreur</span>'
    };
    return badges[status] || status;
}

// ═══════════════════════════════════════════════════════════════════════════════
// ONGLET SCANNER
// ═══════════════════════════════════════════════════════════════════════════════

async function loadScanner() {
    // Vérifier s'il y a un scan en cours
    checkRunningScans();
}

async function loadDirectories() {
    try {
        showLoading('Chargement des répertoires...');
        
        const response = await apiCall('/api/symlink/directories');
        hideLoading();
        
        if (response.success) {
            loadedDirectories = response.directories;
            displayDirectories(response.directories);
        } else {
            showToast(response.error, 'error');
        }
    } catch (error) {
        hideLoading();
        console.error('Erreur chargement répertoires:', error);
    }
}

function displayDirectories(directories) {
    const container = document.getElementById('directory-list');
    
    if (!directories || directories.length === 0) {
        container.innerHTML = `
            <div style="text-align: center; color: #6c757d; padding: 20px;">
                Aucun répertoire contenant des liens symboliques trouvé
            </div>
        `;
        return;
    }
    
    container.innerHTML = directories.map((dir, index) => `
        <div class="directory-item">
            <input type="checkbox" id="dir-${index}" value="${dir.path}">
            <div class="directory-path">${dir.name}</div>
            <div class="symlink-count">${dir.symlink_count}</div>
        </div>
    `).join('');
}

function selectAllDirectories() {
    document.querySelectorAll('#directory-list input[type="checkbox"]').forEach(cb => {
        cb.checked = true;
    });
}

function clearSelection() {
    document.querySelectorAll('#directory-list input[type="checkbox"]').forEach(cb => {
        cb.checked = false;
    });
}

async function startScan() {
    // Vérifier la sélection
    const selectedPaths = Array.from(
        document.querySelectorAll('#directory-list input[type="checkbox"]:checked')
    ).map(cb => cb.value);
    
    if (selectedPaths.length === 0) {
        showToast('Veuillez sélectionner au moins un répertoire', 'warning');
        return;
    }
    
    const mode = document.getElementById('scan-mode').value;
    const depth = document.getElementById('verification-depth').value;
    
    // Confirmation pour le mode réel
    if (mode === 'real') {
        const confirmed = await showConfirmDialog(
            'Confirmation suppression',
            `Vous êtes sur le point de lancer un scan en mode RÉEL qui supprimera définitivement les fichiers problématiques détectés dans ${selectedPaths.length} répertoire(s).\n\nÊtes-vous sûr de vouloir continuer ?`
        );
        
        if (!confirmed) return;
    }
    
    try {
        const response = await apiCall('/api/symlink/scan/start', {
            method: 'POST',
            body: JSON.stringify({
                selected_paths: selectedPaths,
                mode: mode,
                verification_depth: depth
            })
        });
        
        if (response.success) {
            currentScanId = response.scan_id;
            showScanInProgress();
            startScanPolling();
            showToast('Scan démarré avec succès', 'success');
        } else {
            showToast(response.error, 'error');
        }
    } catch (error) {
        console.error('Erreur démarrage scan:', error);
    }
}

function showScanInProgress() {
    document.getElementById('progress-container').style.display = 'block';
    document.getElementById('results-container').style.display = 'none';
    document.getElementById('cancel-btn').style.display = 'inline-block';
    
    // Mettre à jour le statut de service
    const statusEl = document.getElementById('service-status');
    if (statusEl) {
        statusEl.className = 'status-indicator status-running';
        statusEl.textContent = 'Scan en cours...';
    }
}

function startScanPolling() {
    if (scanPollingInterval) {
        clearInterval(scanPollingInterval);
    }
    
    scanPollingInterval = setInterval(async () => {
        if (!currentScanId) return;
        
        try {
            const response = await apiCall(`/api/symlink/scan/status/${currentScanId}`);
            
            if (response.success) {
                updateScanProgress(response.status);
                
                if (!response.status.running) {
                    // Scan terminé
                    stopScanPolling();
                    onScanCompleted(response.status);
                }
            }
        } catch (error) {
            console.error('Erreur polling scan:', error);
            stopScanPolling();
        }
    }, 2000); // Polling toutes les 2 secondes
}

function stopScanPolling() {
    if (scanPollingInterval) {
        clearInterval(scanPollingInterval);
        scanPollingInterval = null;
    }
}

function updateScanProgress(status) {
    const progress = status.progress || {};
    const stats = progress.stats || {};
    
    // Mise à jour de la barre de progression
    const progressFill = document.getElementById('progress-fill');
    const progressValue = stats.progress || 0;
    progressFill.style.width = progressValue + '%';
    progressFill.textContent = progressValue + '%';
    
    // Mise à jour du message
    document.getElementById('progress-message').textContent = progress.message || 'En cours...';
    
    // Mise à jour des statistiques
    document.getElementById('stat-ok').textContent = stats.phase1_ok || 0;
    document.getElementById('stat-broken').textContent = stats.phase1_broken || 0;
    document.getElementById('stat-inaccessible').textContent = stats.phase1_inaccessible || 0;
    document.getElementById('stat-corrupted').textContent = stats.phase2_corrupted || 0;
}

function onScanCompleted(status) {
    currentScanId = null;
    document.getElementById('cancel-btn').style.display = 'none';
    
    // Mettre à jour le statut de service
    const statusEl = document.getElementById('service-status');
    if (statusEl) {
        statusEl.className = 'status-indicator status-ready';
        statusEl.textContent = 'Prêt';
    }
    
    // Afficher les résultats si disponibles
    if (status.results) {
        displayScanResults(status.results);
    }
    
    showToast('Scan terminé', 'success');
    
    // Recharger l'historique du dashboard
    if (document.getElementById('dashboard-tab').classList.contains('active')) {
        loadDashboard();
    }
}

function displayScanResults(results) {
    const container = document.getElementById('results-container');
    const tbody = document.getElementById('results-body');
    const summary = document.getElementById('results-summary');
    
    const problems = results.problems || [];
    const deleted = results.deleted || [];
    
    // Résumé
    summary.innerHTML = `
        <div class="alert alert-info">
            <strong>Résultats:</strong> ${problems.length} problème(s) détecté(s), 
            ${deleted.length} fichier(s) supprimé(s)
        </div>
    `;
    
    // Tableau des résultats
    if (problems.length > 0) {
        tbody.innerHTML = problems.map(problem => `
            <tr>
                <td>${getTypeIcon(problem.type)} ${problem.type}</td>
                <td style="word-break: break-all;">${problem.path}</td>
                <td style="word-break: break-all;">${problem.target}</td>
                <td>${problem.reason}</td>
            </tr>
        `).join('');
    } else {
        tbody.innerHTML = `
            <tr>
                <td colspan="4" style="text-align: center; color: #6c757d;">
                    Aucun problème détecté
                </td>
            </tr>
        `;
    }
    
    container.style.display = 'block';
}

function getTypeIcon(type) {
    const icons = {
        'broken_link': '🔗💔',
        'inaccessible': '🚫',
        'empty_file': '📄',
        'io_error': '⚠️',
        'corrupted_media': '📺💥'
    };
    return icons[type] || '❓';
}

async function cancelScan() {
    if (!currentScanId) return;
    
    try {
        const response = await apiCall(`/api/symlink/scan/cancel/${currentScanId}`, {
            method: 'POST'
        });
        
        if (response.success) {
            showToast('Scan annulé', 'info');
            stopScanPolling();
            currentScanId = null;
            document.getElementById('cancel-btn').style.display = 'none';
            document.getElementById('progress-container').style.display = 'none';
        }
    } catch (error) {
        console.error('Erreur annulation scan:', error);
    }
}

async function checkRunningScans() {
    // Vérifier s'il y a un scan en cours au chargement de la page
    // TODO: Implémenter si nécessaire
}

// ═══════════════════════════════════════════════════════════════════════════════
// ONGLET SETTINGS
// ═══════════════════════════════════════════════════════════════════════════════

async function loadConfiguration() {
    try {
        const response = await apiCall('/api/symlink/config');
        
        if (response.success) {
            currentConfig = response.config;
            populateConfigForm(response.config);
        }
        
        // Charger aussi la configuration cleanup
        await loadCleanupConfiguration();
    } catch (error) {
        console.error('Erreur chargement configuration:', error);
    }
}

async function loadCleanupConfiguration() {
    try {
        const response = await apiCall('/api/symlink/cleanup/config');
        
        if (response.success) {
            populateCleanupConfigForm(response.config);
        }
    } catch (error) {
        console.error('Erreur chargement configuration cleanup:', error);
    }
}

function populateConfigForm(config) {
    document.getElementById('media-path').value = config.media_path || '/app/medias';
    document.getElementById('max-workers').value = config.max_workers || 6;
    
    // Sonarr
    document.getElementById('sonarr-enabled').checked = config.sonarr_enabled || false;
    document.getElementById('sonarr-host').value = config.sonarr_host || '';
    document.getElementById('sonarr-port').value = config.sonarr_port || 8989;
    document.getElementById('sonarr-api-key').value = config.sonarr_api_key || '';
    
    // Radarr
    document.getElementById('radarr-enabled').checked = config.radarr_enabled || false;
    document.getElementById('radarr-host').value = config.radarr_host || '';
    document.getElementById('radarr-port').value = config.radarr_port || 7878;
    document.getElementById('radarr-api-key').value = config.radarr_api_key || '';
}

function populateCleanupConfigForm(config) {
    if (!config) return;
    
    // Configuration principale cleanup
    document.getElementById('cleanup-enabled').checked = config.cleanup_enabled || false;
    document.getElementById('zurg-path').value = config.zurg_path || '/home/kesurof/seedbox/zurg/__all__';
    document.getElementById('cleanup-min-age').value = config.cleanup_min_age_days || 2;
    document.getElementById('cleanup-min-size').value = config.cleanup_min_size_mb || 0;
    document.getElementById('organized-media-path').value = config.organized_media_path || '/app/medias';
    document.getElementById('cleanup-dry-run-default').checked = config.cleanup_dry_run_default !== undefined ? config.cleanup_dry_run_default : true;
    
    // Configuration Real-Debrid
    document.getElementById('rd-api-key').value = config.rd_api_key || '';
    document.getElementById('cleanup-batch-limit').value = config.cleanup_batch_limit || 20;
    document.getElementById('cleanup-delay').value = config.cleanup_delay_ms || 1000;
    
    // Configuration avancée
    document.getElementById('cleanup-ignore-extensions').value = config.cleanup_ignore_extensions || '.nfo,.txt,.srt,.jpg,.png,.xml';
    document.getElementById('cleanup-whitelist').value = config.cleanup_whitelist || '';
    document.getElementById('cleanup-match-threshold').value = config.cleanup_match_threshold || 80;
    document.getElementById('cleanup-max-workers').value = config.cleanup_max_workers || 4;
    document.getElementById('cleanup-preserve-recent').checked = config.cleanup_preserve_recent !== undefined ? config.cleanup_preserve_recent : true;
    document.getElementById('cleanup-detailed-logs').checked = config.cleanup_detailed_logs || false;
    document.getElementById('cleanup-auto-schedule').checked = config.cleanup_auto_schedule || false;
}

async function saveConfiguration() {
    try {
        // Configuration générale et services
        const config = {
            media_path: document.getElementById('media-path').value,
            max_workers: parseInt(document.getElementById('max-workers').value),
            sonarr_enabled: document.getElementById('sonarr-enabled').checked,
            sonarr_host: document.getElementById('sonarr-host').value,
            sonarr_port: parseInt(document.getElementById('sonarr-port').value),
            sonarr_api_key: document.getElementById('sonarr-api-key').value,
            radarr_enabled: document.getElementById('radarr-enabled').checked,
            radarr_host: document.getElementById('radarr-host').value,
            radarr_port: parseInt(document.getElementById('radarr-port').value),
            radarr_api_key: document.getElementById('radarr-api-key').value
        };
        
        const response = await apiCall('/api/symlink/config', {
            method: 'POST',
            body: JSON.stringify(config)
        });
        
        if (response.success) {
            currentConfig = config;
            
            // Sauvegarder aussi la configuration cleanup
            await saveCleanupConfiguration();
            
            showToast('Configuration sauvegardée', 'success');
        } else {
            showToast(response.error, 'error');
        }
    } catch (error) {
        console.error('Erreur sauvegarde configuration:', error);
    }
}

async function saveCleanupConfiguration() {
    try {
        const cleanupConfig = {
            cleanup_enabled: document.getElementById('cleanup-enabled').checked,
            zurg_path: document.getElementById('zurg-path').value,
            cleanup_min_age_days: parseInt(document.getElementById('cleanup-min-age').value),
            cleanup_min_size_mb: parseInt(document.getElementById('cleanup-min-size').value),
            organized_media_path: document.getElementById('organized-media-path').value,
            cleanup_dry_run_default: document.getElementById('cleanup-dry-run-default').checked,
            rd_api_key: document.getElementById('rd-api-key').value,
            cleanup_batch_limit: parseInt(document.getElementById('cleanup-batch-limit').value),
            cleanup_delay_ms: parseInt(document.getElementById('cleanup-delay').value),
            cleanup_ignore_extensions: document.getElementById('cleanup-ignore-extensions').value,
            cleanup_whitelist: document.getElementById('cleanup-whitelist').value,
            cleanup_match_threshold: parseInt(document.getElementById('cleanup-match-threshold').value),
            cleanup_max_workers: parseInt(document.getElementById('cleanup-max-workers').value),
            cleanup_preserve_recent: document.getElementById('cleanup-preserve-recent').checked,
            cleanup_detailed_logs: document.getElementById('cleanup-detailed-logs').checked,
            cleanup_auto_schedule: document.getElementById('cleanup-auto-schedule').checked
        };
        
        const response = await apiCall('/api/symlink/cleanup/config', {
            method: 'POST',
            body: JSON.stringify(cleanupConfig)
        });
        
        if (!response.success) {
            showToast('Erreur sauvegarde config cleanup: ' + response.error, 'error');
        }
    } catch (error) {
        console.error('Erreur sauvegarde configuration cleanup:', error);
    }
}

async function testService(service) {
    try {
        const testData = {
            [`test_${service}`]: true
        };
        
        if (service === 'sonarr') {
            testData.sonarr_host = document.getElementById('sonarr-host').value;
            testData.sonarr_port = parseInt(document.getElementById('sonarr-port').value);
            testData.sonarr_api_key = document.getElementById('sonarr-api-key').value;
        } else {
            testData.radarr_host = document.getElementById('radarr-host').value;
            testData.radarr_port = parseInt(document.getElementById('radarr-port').value);
            testData.radarr_api_key = document.getElementById('radarr-api-key').value;
        }
        
        showLoading(`Test de connexion ${service}...`);
        
        const response = await apiCall('/api/symlink/test/services', {
            method: 'POST',
            body: JSON.stringify(testData)
        });
        
        hideLoading();
        
        if (response.success && response.results[service]) {
            const result = response.results[service];
            showToast(
                `${service}: ${result.message}`, 
                result.success ? 'success' : 'error'
            );
        }
    } catch (error) {
        hideLoading();
        console.error(`Erreur test ${service}:`, error);
    }
}

async function detectServices() {
    try {
        showLoading('Auto-détection des services Docker...');
        
        const response = await apiCall('/api/symlink/services/detect', {
            method: 'POST'
        });
        
        hideLoading();
        
        if (response.success) {
            const services = response.services;
            let detected = false;
            
            if (services.sonarr) {
                document.getElementById('sonarr-host').value = services.sonarr.host;
                document.getElementById('sonarr-port').value = services.sonarr.port;
                
                // ✅ AJOUT : Pré-remplir l'API key si détectée
                if (services.sonarr.api_key) {
                    document.getElementById('sonarr-api-key').value = services.sonarr.api_key;
                }
                
                // ✅ AJOUT : Activer le service automatiquement
                document.getElementById('sonarr-enabled').checked = true;
                detected = true;
            }
            
            if (services.radarr) {
                document.getElementById('radarr-host').value = services.radarr.host;
                document.getElementById('radarr-port').value = services.radarr.port;
                
                // ✅ AJOUT : Pré-remplir l'API key si détectée  
                if (services.radarr.api_key) {
                    document.getElementById('radarr-api-key').value = services.radarr.api_key;
                }
                
                // ✅ AJOUT : Activer le service automatiquement
                document.getElementById('radarr-enabled').checked = true;
                detected = true;
            }
            
            if (detected) {
                showToast('Services détectés et configurés automatiquement (IP + API keys)', 'success');
                
                // ✅ AJOUT : Proposition de sauvegarde automatique
                if (confirm('Voulez-vous sauvegarder automatiquement cette configuration détectée ?')) {
                    await saveConfiguration();
                }
            } else {
                showToast('Aucun service détecté', 'info');
            }
        }
    } catch (error) {
        hideLoading();
        showToast('Erreur lors de la détection automatique', 'error');
        console.error('Erreur détection:', error);
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FONCTIONS UTILITAIRES
// ═══════════════════════════════════════════════════════════════════════════════

function showToast(message, type = 'info') {
    const container = document.getElementById('toast-container');
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.innerHTML = `
        <div style="font-weight: 500;">${message}</div>
    `;
    
    container.appendChild(toast);
    
    setTimeout(() => {
        toast.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => toast.remove(), 300);
    }, 4000);
}

function showLoading(message) {
    const existing = document.getElementById('loading-overlay');
    if (existing) existing.remove();
    
    const overlay = document.createElement('div');
    overlay.id = 'loading-overlay';
    overlay.style.cssText = `
        position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        background: rgba(0,0,0,0.5); z-index: 3000;
        display: flex; align-items: center; justify-content: center;
    `;
    overlay.innerHTML = `
        <div style="background: white; padding: 20px; border-radius: 8px; text-align: center;">
            <div style="margin-bottom: 10px;">⏳</div>
            <div>${message}</div>
        </div>
    `;
    document.body.appendChild(overlay);
}

function hideLoading() {
    const overlay = document.getElementById('loading-overlay');
    if (overlay) overlay.remove();
}

function showConfirmDialog(title, message) {
    return new Promise((resolve) => {
        const modal = document.getElementById('confirmModal');
        document.getElementById('confirm-title').textContent = title;
        document.getElementById('confirm-message').textContent = message;
        
        const confirmBtn = document.getElementById('confirm-action');
        confirmBtn.onclick = () => {
            modal.style.display = 'none';
            resolve(true);
        };
        
        modal.style.display = 'block';
        
        // Fermer avec Escape ou clic extérieur
        const closeHandler = (e) => {
            if (e.key === 'Escape' || e.target === modal) {
                modal.style.display = 'none';
                document.removeEventListener('keydown', closeHandler);
                resolve(false);
            }
        };
        document.addEventListener('keydown', closeHandler);
        modal.onclick = closeHandler;
    });
}

function closeModal(modalId) {
    document.getElementById(modalId).style.display = 'none';
}

async function rerunScan(scanId) {
    // TODO: Implémenter la relance d'un scan avec les mêmes paramètres
    showToast('Fonctionnalité bientôt disponible', 'info');
}

// ═══════════════════════════════════════════════════════════════════════════════
// FONCTIONS CLEANUP DES TORRENTS
// ═══════════════════════════════════════════════════════════════════════════════

function loadCleanup() {
    console.log('📄 Chargement de l\'onglet cleanup');
    // Réinitialiser l'interface cleanup
    const statsDiv = document.getElementById('cleanup-stats');
    const resultsDiv = document.getElementById('cleanup-results');
    
    if (statsDiv) statsDiv.style.display = 'none';
    if (resultsDiv) resultsDiv.style.display = 'none';
    
    // Réinitialiser les sélections
    selectedCleanupTorrents.clear();
    cleanupAnalysisData = null;
    
    // Masquer le bouton d'analyse réelle
    const realAnalyzeBtn = document.getElementById('real-analyze-btn');
    if (realAnalyzeBtn) realAnalyzeBtn.style.display = 'none';
}

async function analyzeUnusedTorrents(dryRun = true) {
    try {
        showLoading('Analyse des torrents inutilisés...');
        
        const response = await apiCall('/api/symlink/cleanup/analyze', {
            method: 'POST',
            body: JSON.stringify({ dry_run: dryRun })
        });
        
        hideLoading();
        
        if (response.success) {
            cleanupAnalysisData = response;
            displayCleanupResults(response);
            
            // Afficher le bouton de suppression réelle après un dry-run réussi
            if (dryRun && response.unused_torrents.length > 0) {
                document.getElementById('real-analyze-btn').style.display = 'inline-block';
            }
            
            showToast(`✅ Analyse terminée: ${response.stats.total_unused} torrents orphelins trouvés`, 'success');
        } else {
            showToast('❌ Erreur lors de l\'analyse: ' + response.error, 'error');
        }
    } catch (error) {
        hideLoading();
        showToast('❌ Erreur réseau lors de l\'analyse', 'error');
        console.error('Erreur analyse cleanup:', error);
    }
}

function displayCleanupResults(data) {
    // Afficher les statistiques
    const statsDiv = document.getElementById('cleanup-stats');
    statsDiv.innerHTML = `
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px;">
            <div class="stat-item">
                <div class="stat-number">${data.stats.total_unused}</div>
                <div class="stat-label">Torrents orphelins</div>
            </div>
            <div class="stat-item">
                <div class="stat-number">${data.stats.total_size_formatted}</div>
                <div class="stat-label">Espace récupérable</div>
            </div>
            <div class="stat-item">
                <div class="stat-number">${data.dry_run ? 'DRY-RUN' : 'RÉEL'}</div>
                <div class="stat-label">Mode d'analyse</div>
            </div>
        </div>
    `;
    statsDiv.style.display = 'block';
    
    // Afficher la liste des torrents
    const tbody = document.getElementById('cleanup-torrents-list');
    tbody.innerHTML = '';
    
    data.unused_torrents.forEach(torrent => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>
                <input type="checkbox" class="cleanup-torrent-checkbox" 
                       value="${torrent.id}" onchange="updateCleanupSelection()">
            </td>
            <td>
                <div style="max-width: 400px; overflow: hidden; text-overflow: ellipsis;" 
                     title="${torrent.name}">
                    ${torrent.name}
                </div>
            </td>
            <td>${torrent.size_formatted}</td>
            <td>${torrent.age_days} jours</td>
            <td>
                ${torrent.best_match_score > 0 ? 
                    `<span title="Meilleure correspondance: ${torrent.best_match}">${torrent.best_match_score}%</span>` :
                    'Aucune'
                }
            </td>
            <td>
                <span class="badge ${torrent.status === 'downloaded' ? 'badge-success' : 'badge-secondary'}">
                    ${torrent.status || 'unknown'}
                </span>
            </td>
        `;
        tbody.appendChild(row);
    });
    
    document.getElementById('cleanup-results').style.display = 'block';
    
    // Réinitialiser la sélection
    selectedCleanupTorrents.clear();
    updateCleanupSelection();
}

function updateCleanupSelection() {
    const checkboxes = document.querySelectorAll('.cleanup-torrent-checkbox');
    const selectAllCheckbox = document.getElementById('selectAllCleanup');
    
    // Mettre à jour le Set des sélectionnés
    selectedCleanupTorrents.clear();
    let totalSize = 0;
    
    checkboxes.forEach(cb => {
        if (cb.checked) {
            selectedCleanupTorrents.add(cb.value);
            // Calculer la taille totale
            if (cleanupAnalysisData) {
                const torrent = cleanupAnalysisData.unused_torrents.find(t => t.id === cb.value);
                if (torrent && torrent.size) {
                    totalSize += torrent.size;
                }
            }
        }
    });
    
    // Mettre à jour la case "tout sélectionner"
    const checkedCount = selectedCleanupTorrents.size;
    selectAllCheckbox.checked = checkedCount > 0 && checkedCount === checkboxes.length;
    selectAllCheckbox.indeterminate = checkedCount > 0 && checkedCount < checkboxes.length;
    
    // Afficher/masquer les actions
    const actionsDiv = document.getElementById('cleanup-selection-actions');
    const countSpan = document.getElementById('cleanup-selection-count');
    const sizeSpan = document.getElementById('cleanup-selection-size');
    
    if (checkedCount > 0) {
        actionsDiv.style.display = 'block';
        countSpan.textContent = checkedCount;
        sizeSpan.textContent = formatSize(totalSize);
    } else {
        actionsDiv.style.display = 'none';
    }
}

function toggleSelectAllCleanup(checkbox) {
    const torrentCheckboxes = document.querySelectorAll('.cleanup-torrent-checkbox');
    torrentCheckboxes.forEach(cb => {
        cb.checked = checkbox.checked;
    });
    updateCleanupSelection();
}

function clearCleanupSelection() {
    selectedCleanupTorrents.clear();
    document.querySelectorAll('.cleanup-torrent-checkbox').forEach(cb => cb.checked = false);
    document.getElementById('selectAllCleanup').checked = false;
    updateCleanupSelection();
}

async function confirmCleanupDeletion() {
    if (selectedCleanupTorrents.size === 0) {
        showToast('❌ Aucun torrent sélectionné', 'error');
        return;
    }
    
    const count = selectedCleanupTorrents.size;
    const selectedTorrents = cleanupAnalysisData.unused_torrents.filter(t => 
        selectedCleanupTorrents.has(t.id)
    );
    const totalSize = selectedTorrents.reduce((sum, t) => sum + (t.size || 0), 0);
    const sizeFormatted = formatSize(totalSize);
    
    const message = `Supprimer ${count} torrents de Real-Debrid ?\n\nEspace libéré: ${sizeFormatted}\n\nCette action est irréversible.`;
    
    if (confirm(message)) {
        await deleteSelectedCleanupTorrents();
    }
}

async function deleteSelectedCleanupTorrents() {
    try {
        showLoading('Suppression des torrents en cours...');
        
        const response = await apiCall('/api/symlink/cleanup/delete', {
            method: 'POST',
            body: JSON.stringify({
                torrent_ids: Array.from(selectedCleanupTorrents),
                dry_run: false
            })
        });
        
        hideLoading();
        
        if (response.success) {
            showToast(`✅ ${response.deleted_count} torrents supprimés avec succès`, 'success');
            
            // Relancer l'analyse pour actualiser la liste
            setTimeout(() => analyzeUnusedTorrents(true), 2000);
        } else {
            showToast('❌ Erreur lors de la suppression: ' + response.error, 'error');
        }
    } catch (error) {
        hideLoading();
        showToast('❌ Erreur réseau lors de la suppression', 'error');
        console.error('Erreur suppression cleanup:', error);
    }
}

// Nouvelles fonctions pour la configuration cleanup
async function testZurgConnection() {
    try {
        const zurgPath = document.getElementById('zurg-path').value;
        
        const response = await apiCall('/api/symlink/test/zurg', {
            method: 'POST',
            body: JSON.stringify({ zurg_path: zurgPath })
        });
        
        if (response.success) {
            showToast(`✅ Zurg accessible: ${response.torrents_found} torrents trouvés`, 'success');
        } else {
            showToast(`❌ Erreur Zurg: ${response.error}`, 'error');
        }
    } catch (error) {
        showToast('❌ Erreur test Zurg', 'error');
    }
}

async function testRealDebridConnection() {
    try {
        const apiKey = document.getElementById('rd-api-key').value;
        
        const response = await apiCall('/api/symlink/test/realdebrid', {
            method: 'POST',
            body: JSON.stringify({ api_key: apiKey })
        });
        
        if (response.success) {
            showToast(`✅ Real-Debrid connecté: ${response.user_info}`, 'success');
        } else {
            showToast(`❌ Erreur Real-Debrid: ${response.error}`, 'error');
        }
    } catch (error) {
        showToast('❌ Erreur test Real-Debrid', 'error');
    }
}

function resetToDefaults() {
    if (confirm('Remettre tous les paramètres aux valeurs par défaut ?')) {
        // Réinitialiser tous les champs de configuration cleanup
        document.getElementById('zurg-path').value = '/home/kesurof/seedbox/zurg/__all__';
        document.getElementById('cleanup-min-age').value = '2';
        document.getElementById('cleanup-min-size').value = '0';
        document.getElementById('organized-media-path').value = '/app/medias';
        document.getElementById('cleanup-dry-run-default').checked = true;
        document.getElementById('cleanup-batch-limit').value = '20';
        document.getElementById('cleanup-delay').value = '1000';
        document.getElementById('cleanup-ignore-extensions').value = '.nfo,.txt,.srt,.jpg,.png,.xml';
        document.getElementById('cleanup-whitelist').value = '';
        document.getElementById('cleanup-match-threshold').value = '80';
        document.getElementById('cleanup-max-workers').value = '4';
        document.getElementById('cleanup-preserve-recent').checked = true;
        document.getElementById('cleanup-detailed-logs').checked = false;
        document.getElementById('cleanup-auto-schedule').checked = false;
        
        showToast('✅ Configuration réinitialisée', 'success');
    }
}

function formatSize(bytes) {
    if (!bytes) return "0 B";
    
    const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
    const i = Math.floor(Math.log(bytes) / Math.log(1024));
    return Math.round(bytes / Math.pow(1024, i) * 100) / 100 + ' ' + sizes[i];
}

// ═══════════════════════════════════════════════════════════════════════════════
// INITIALISATION
// ═══════════════════════════════════════════════════════════════════════════════

document.addEventListener('DOMContentLoaded', function() {
    console.log('🔗 Symlink Tool JavaScript initialisé');
    
    // Restaurer l'onglet actif depuis le localStorage
    const savedTab = localStorage.getItem('symlink_active_tab');
    if (savedTab && document.getElementById(savedTab + '-tab')) {
        // Simuler le clic sur l'onglet sauvegardé
        const tabBtn = document.querySelector(`[onclick*="switchTab('${savedTab}')"]`);
        if (tabBtn) {
            switchTab(savedTab, tabBtn);
        } else {
            switchTab(savedTab);
        }
    } else {
        // Charger le dashboard par défaut
        switchTab('dashboard');
    }
    
    // Vérifier s'il y a des scans en cours
    checkRunningScans();
});

// Nettoyage avant fermeture
window.addEventListener('beforeunload', function() {
    stopScanPolling();
});
