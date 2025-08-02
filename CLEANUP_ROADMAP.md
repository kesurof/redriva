# 🗑️ Roadmap - Cleanup des Torrents Real-Debrid

## 📋 Vue d'ensemble

Ajout d'une fonctionnalité de nettoyage automatique des torrents Real-Debrid inutilisés dans le **Symlink Manager** existant, basée sur l'analyse des montages Zurg et des liens symboliques.

### 🎯 **Objectif principal**
Identifier et supprimer automatiquement les torrents Real-Debrid qui ne sont plus référencés par des liens symboliques sur le serveur, permettant d'économiser de l'espace et des coûts.

## ✅ **STATUS : IMPLÉMENTATION TERMINÉE**

Cette roadmap a été **entièrement implémentée** selon les spécifications. Toutes les fonctionnalités décrites ci-dessous sont maintenant disponibles dans l'application.

## 🏗️ Architecture retenue

### **Option choisie : Extension du Symlink Manager**
- ✅ Nouvel onglet "Cleanup" dans l'interface existante
- ✅ Réutilisation de l'architecture Flask/SQLite/JavaScript
- ✅ Intégration avec l'API Real-Debrid déjà en place
- ✅ Interface cohérente avec le reste de l'application

## 📊 Analyse technique

### **Structure Zurg découverte :**
```
/home/kesurof/seedbox/zurg/__all__/
├── nom_du_torrent.mkv/
│   └── nom_du_torrent.mkv
├── serie.s01.episode/
│   ├── episode1.mkv
│   ├── episode2.mkv
│   └── ...
```

### **Stratégie de correspondance :**
- **Méthode** : Comparaison par nom de fichier/dossier normalisé
- **Source de vérité** : Présence dans `/home/kesurof/seedbox/zurg/__all__/`
- **Critères d'orphelin** : Torrent RD sans dossier correspondant dans Zurg

### **Critères de nettoyage définis :**
- ⏰ **Âge minimum** : 2 jours (éviter les torrents récents)
- 🔗 **Définition orphelin** : Aucun symlink ne pointe vers les fichiers du torrent
- 🛡️ **Sécurité** : Mode dry-run obligatoire avant suppression réelle

## 🚀 Plan de développement

### **Phase 1 : Infrastructure Backend** ✅ **TERMINÉ**

#### **1.1. Classe d'analyse (symlink_tool.py)** ✅
```python
class TorrentCleanupAnalyzer:
    def __init__(self):
        self.zurg_path = "/home/kesurof/seedbox/zurg/__all__"
        self.min_age_days = 2
        
    def scan_zurg_usage(self) -> Set[str]               # ✅ Implémenté
    def normalize_torrent_name(self, name: str) -> str  # ✅ Implémenté
    def find_unused_torrents(self) -> List[Dict]        # ✅ Implémenté
    def calculate_age_days(self, added_on: str) -> int  # ✅ Implémenté
    def delete_torrents_via_rd_api(self) -> Dict        # ✅ Implémenté
    def test_zurg_connection(self) -> Dict              # ✅ Implémenté
    def test_realdebrid_connection(self) -> Dict        # ✅ Implémenté
```

#### **1.2. Nouvelles routes API** ✅
```python
@app.route('/api/symlink/cleanup/analyze', methods=['POST'])      # ✅ Implémenté
def analyze_unused_torrents()

@app.route('/api/symlink/cleanup/delete', methods=['POST'])       # ✅ Implémenté
def cleanup_unused_torrents()

@app.route('/api/symlink/cleanup/config', methods=['GET'])        # ✅ Implémenté
def get_cleanup_config()

@app.route('/api/symlink/cleanup/config', methods=['POST'])       # ✅ Implémenté
def save_cleanup_config()

@app.route('/api/symlink/test/zurg', methods=['POST'])            # ✅ Implémenté
def test_zurg_connection()

@app.route('/api/symlink/test/realdebrid', methods=['POST'])      # ✅ Implémenté
def test_realdebrid_connection()
```

#### **1.3. Fonctionnalités backend** ✅
- ✅ Scanner les dossiers Zurg pour identifier les torrents utilisés
- ✅ Comparer avec la liste des torrents Real-Debrid via SQLite
- ✅ Normalisation des noms pour correspondance fiable
- ✅ Calcul des statistiques (nombre, taille, âge)
- ✅ Mode dry-run par défaut pour sécurité
- ✅ Intégration API Real-Debrid pour suppression

### **Phase 2 : Interface utilisateur** ✅ **TERMINÉ**

#### **2.1. Nouvel onglet "Cleanup" (symlink_tool.html)** ✅
```html
<div id="cleanup-tab" class="tab-pane">                          ✅ Implémenté
    <!-- Actions d'analyse -->
    <button onclick="analyzeUnusedTorrents(true)">               ✅ Implémenté
    <button onclick="analyzeUnusedTorrents(false)">              ✅ Implémenté
    
    <!-- Statistiques -->
    <div id="cleanup-stats">                                     ✅ Implémenté
        - Total torrents orphelins: X
        - Espace récupérable: X GB
        - Mode: DRY-RUN / RÉEL
    </div>
    
    <!-- Tableau de sélection (style similar aux torrents) -->
    <table class="table table-striped">                         ✅ Implémenté
        <th><input type="checkbox" id="selectAllCleanup">       ✅ Implémenté
        <tbody id="cleanup-torrents-list">                      ✅ Implémenté
    </table>
    
    <!-- Actions de sélection -->
    <div id="cleanup-selection-actions">                        ✅ Implémenté
        <button onclick="confirmCleanupDeletion()">             ✅ Implémenté
    </div>
</div>
```

#### **2.2. JavaScript frontend (symlink_tool.js)** ✅
```javascript
// Variables globales                                          ✅ Implémenté
let selectedCleanupTorrents = new Set();
let cleanupAnalysisData = null;

// Fonctions principales                                       ✅ Implémenté
async function analyzeUnusedTorrents(dryRun = true)           ✅ Implémenté
function displayCleanupResults(data)                          ✅ Implémenté
function updateCleanupSelection()                             ✅ Implémenté
function toggleSelectAllCleanup(checkbox)                     ✅ Implémenté
async function confirmCleanupDeletion()                       ✅ Implémenté
async function deleteSelectedCleanupTorrents()                ✅ Implémenté
async function testZurgConnection()                           ✅ Implémenté
async function testRealDebridConnection()                     ✅ Implémenté
function resetToDefaults()                                    ✅ Implémenté
```

### **Phase 3 : Configuration complète** ✅ **TERMINÉ**

#### **3.1. Extension de la page Settings** ✅

**Configuration Zurg & Médias** ✅
```html
<div class="settings-section">                               ✅ Implémenté
    <h4>🗑️ Configuration Cleanup Torrents</h4>
    <input type="checkbox" id="cleanup-enabled">             ✅ Implémenté
    <input id="zurg-path" placeholder="/home/.../zurg/__all__"> ✅ Implémenté
    <input id="cleanup-min-age" min="1" max="365" value="2"> ✅ Implémenté
    <input id="cleanup-min-size" min="0" value="0">          ✅ Implémenté
    <input id="organized-media-path" placeholder="/app/medias"> ✅ Implémenté
    <input type="checkbox" id="cleanup-dry-run-default" checked> ✅ Implémenté
    <button onclick="testZurgConnection()">                   ✅ Implémenté
</div>
```

**Configuration Real-Debrid API** ✅
```html
<div class="settings-section">                               ✅ Implémenté
    <h4>🔑 Configuration Real-Debrid</h4>
    <input type="password" id="rd-api-key">                  ✅ Implémenté
    <input id="cleanup-batch-limit" min="1" max="100" value="20"> ✅ Implémenté
    <input id="cleanup-delay" min="100" max="5000" value="1000"> ✅ Implémenté
    <button onclick="testRealDebridConnection()">             ✅ Implémenté
</div>
```

**Configuration avancée** ✅
```html
<div class="settings-section">                               ✅ Implémenté
    <h4>⚙️ Configuration avancée Cleanup</h4>
    <input id="cleanup-ignore-extensions" value=".nfo,.txt,..."> ✅ Implémenté
    <textarea id="cleanup-whitelist" rows="3">                ✅ Implémenté
    <input id="cleanup-match-threshold" min="50" max="100" value="80"> ✅ Implémenté
    <input id="cleanup-max-workers" min="1" max="10" value="4"> ✅ Implémenté
    <input type="checkbox" id="cleanup-preserve-recent">      ✅ Implémenté
    <input type="checkbox" id="cleanup-detailed-logs">       ✅ Implémenté
    <input type="checkbox" id="cleanup-auto-schedule">       ✅ Implémenté
</div>
```

#### **3.2. Extension de la base de données** ✅
```python
# Extension de la table symlink_config                       ✅ Implémenté
cleanup_columns = [
    'cleanup_enabled BOOLEAN DEFAULT 0',                     ✅ Implémenté
    'zurg_path TEXT DEFAULT "/home/kesurof/seedbox/zurg/__all__"', ✅ Implémenté
    'cleanup_min_age_days INTEGER DEFAULT 2',                ✅ Implémenté
    'cleanup_min_size_mb INTEGER DEFAULT 0',                 ✅ Implémenté
    'organized_media_path TEXT DEFAULT "/app/medias"',        ✅ Implémenté
    'cleanup_dry_run_default BOOLEAN DEFAULT 1',             ✅ Implémenté
    'rd_api_key TEXT DEFAULT ""',                            ✅ Implémenté
    'cleanup_batch_limit INTEGER DEFAULT 20',                ✅ Implémenté
    'cleanup_delay_ms INTEGER DEFAULT 1000',                 ✅ Implémenté
    'cleanup_ignore_extensions TEXT DEFAULT ".nfo,.txt,.srt,.jpg,.png,.xml"', ✅ Implémenté
    'cleanup_whitelist TEXT DEFAULT ""',                     ✅ Implémenté
    'cleanup_match_threshold INTEGER DEFAULT 80',            ✅ Implémenté
    'cleanup_max_workers INTEGER DEFAULT 4',                 ✅ Implémenté
    'cleanup_preserve_recent BOOLEAN DEFAULT 1',             ✅ Implémenté
    'cleanup_detailed_logs BOOLEAN DEFAULT 0',               ✅ Implémenté
    'cleanup_auto_schedule BOOLEAN DEFAULT 0'                ✅ Implémenté
]
```

#### **3.3. JavaScript Configuration** ✅
```javascript
async function saveCleanupConfiguration()                    ✅ Implémenté
async function loadCleanupConfiguration()                    ✅ Implémenté
function populateCleanupConfigForm(config)                   ✅ Implémenté
```

## 🎯 Workflow utilisateur final

### **Cas d'usage principal :**
1. **Ouverture** → Accès au Symlink Manager, onglet "Cleanup"
2. **Analyse initiale** → Clic "🔍 Analyser (Dry-Run)"
3. **Visualisation** → Tableau des torrents orphelins avec statistiques
4. **Sélection** → Cases à cocher pour sélection individuelle ou groupée
5. **Validation** → Aperçu de l'espace récupérable et confirmation
6. **Suppression** → Exécution avec progression en temps réel
7. **Rapport** → Résumé des suppressions effectuées

### **Interface type :**
```
🗑️ Cleanup Torrents

[📊 Statistiques]
- Total torrents RD: 1,247
- Torrents utilisés: 1,156  
- Torrents orphelins: 91
- Espace récupérable: ~45 GB

[🔍 Actions]
[Analyser les orphelins]  [Actualiser]

[📋 Résultats]
☑️ TorrentName1.mkv (2.1 GB, ajouté il y a 15 jours)
☑️ TorrentName2.mkv (1.8 GB, ajouté il y a 8 jours)
☐ TorrentName3.mkv (4.2 GB, ajouté il y a 2 jours) [RÉCENT]

[Supprimer sélectionnés (2 torrents, 3.9 GB)]
```

## ⚡ Implémentation technique

### **Algorithme de détection :**
```python
def find_unused_torrents(self):
    # 1. Scanner Zurg pour les torrents utilisés
    used_torrents = scan_zurg_usage()
    
    # 2. Récupérer tous les torrents RD depuis SQLite
    rd_torrents = fetch_rd_torrents_from_db()
    
    # 3. Comparer et identifier les orphelins
    unused = []
    for torrent in rd_torrents:
        normalized_name = normalize_torrent_name(torrent.name)
        is_used = any(used_name in normalized_name 
                     for used_name in used_torrents)
        
        if not is_used and torrent.age_days >= self.min_age_days:
            unused.append(torrent)
    
    return unused
```

### **Normalisation des noms :**
```python
def normalize_torrent_name(self, name: str) -> str:
    # Supprimer extensions
    name = re.sub(r'\.(mkv|mp4|avi)$', '', name, flags=re.IGNORECASE)
    # Normaliser espaces/tirets
    name = re.sub(r'[.\-_]+', ' ', name)
    # Supprimer espaces multiples
    name = re.sub(r'\s+', ' ', name.strip())
    return name.lower()
```

## 🛡️ Sécurité et validation

### **Mesures de sécurité :**
- ✅ **Dry-run obligatoire** en première utilisation
- ✅ **Double confirmation** avant suppression réelle
- ✅ **Seuil d'âge** pour éviter la suppression de torrents récents
- ✅ **Validation des correspondances** via plusieurs critères
- ✅ **Historique des actions** pour traçabilité
- ✅ **Rollback impossible** → Avertissement explicite

### **Tests de validation :**
- [x] Test de correspondance des noms normalisés
- [x] Test de détection des faux positifs
- [x] Test de performance sur grandes listes
- [x] Test d'intégration API Real-Debrid
- [x] Test de l'interface utilisateur (sélections, confirmations)

## ⚙️ Configuration et Paramètres

### **Nouvelle section Settings pour le Cleanup**

Le nouvel onglet "Cleanup" nécessite une extension complète de la page Settings avec des paramètres spécifiques :

#### **3.1. Configuration Zurg & Médias**
```html
<!-- Configuration Cleanup Real-Debrid -->
<div class="settings-section">
    <h4>🗑️ Configuration Cleanup Torrents</h4>
    <div class="checkbox-group">
        <input type="checkbox" id="cleanup-enabled">
        <label for="cleanup-enabled">Activer le nettoyage automatique des torrents</label>
    </div>
    <div class="form-group">
        <label>Chemin de montage Zurg</label>
        <input type="text" class="form-control" id="zurg-path" placeholder="/home/kesurof/seedbox/zurg/__all__">
        <small class="form-text text-muted">Chemin vers le répertoire de montage Zurg contenant tous les torrents</small>
    </div>
    <div class="form-row">
        <div class="form-group">
            <label>Âge minimum (jours)</label>
            <input type="number" class="form-control" id="cleanup-min-age" min="1" max="365" value="2">
            <small class="form-text text-muted">Âge minimum avant qu'un torrent puisse être supprimé</small>
        </div>
        <div class="form-group">
            <label>Taille minimum (MB)</label>
            <input type="number" class="form-control" id="cleanup-min-size" min="0" value="0">
            <small class="form-text text-muted">Taille minimum pour considérer un torrent (0 = pas de limite)</small>
        </div>
    </div>
    <div class="form-group">
        <label>Chemin des médias organisés</label>
        <input type="text" class="form-control" id="organized-media-path" placeholder="/app/medias">
        <small class="form-text text-muted">Répertoire contenant vos médias organisés avec liens symboliques</small>
    </div>
    <div class="checkbox-group">
        <input type="checkbox" id="cleanup-dry-run-default" checked>
        <label for="cleanup-dry-run-default">Mode Dry-Run par défaut</label>
        <small class="form-text text-muted">Toujours démarrer en mode simulation pour la sécurité</small>
    </div>
    <button type="button" class="btn btn-info" onclick="testZurgConnection()">
        🔍 Tester l'accès Zurg
    </button>
</div>
```

#### **3.2. Configuration Real-Debrid API**
```html
<!-- Configuration Real-Debrid API -->
<div class="settings-section">
    <h4>🔑 Configuration Real-Debrid</h4>
    <div class="alert alert-info">
        <strong>Info:</strong> Ces paramètres réutilisent la configuration Real-Debrid existante de Redriva.
    </div>
    <div class="form-group">
        <label>API Key Real-Debrid</label>
        <input type="password" class="form-control" id="rd-api-key" placeholder="Clé API Real-Debrid">
        <small class="form-text text-muted">Utilisée pour supprimer les torrents orphelins</small>
    </div>
    <div class="form-row">
        <div class="form-group">
            <label>Limite de suppression par session</label>
            <input type="number" class="form-control" id="cleanup-batch-limit" min="1" max="100" value="20">
            <small class="form-text text-muted">Nombre maximum de torrents à supprimer en une fois</small>
        </div>
        <div class="form-group">
            <label>Délai entre suppressions (ms)</label>
            <input type="number" class="form-control" id="cleanup-delay" min="100" max="5000" value="1000">
            <small class="form-text text-muted">Délai pour respecter les limites API Real-Debrid</small>
        </div>
    </div>
    <button type="button" class="btn btn-info" onclick="testRealDebridConnection()">
        🔍 Tester la connexion Real-Debrid
    </button>
</div>
```

#### **3.3. Configuration avancée**
```html
<!-- Configuration avancée -->
<div class="settings-section">
    <h4>⚙️ Configuration avancée Cleanup</h4>
    <div class="form-group">
        <label>Extensions de fichiers à ignorer</label>
        <input type="text" class="form-control" id="cleanup-ignore-extensions" value=".nfo,.txt,.srt,.jpg,.png,.xml">
        <small class="form-text text-muted">Extensions séparées par des virgules</small>
    </div>
    <div class="form-group">
        <label>Whitelist de torrents (IDs ou noms partiels)</label>
        <textarea class="form-control" id="cleanup-whitelist" rows="3" placeholder="Entrez les IDs ou noms de torrents à ne jamais supprimer, un par ligne"></textarea>
        <small class="form-text text-muted">Torrents protégés contre la suppression automatique</small>
    </div>
    <div class="form-row">
        <div class="form-group">
            <label>Seuil de correspondance (%)</label>
            <input type="number" class="form-control" id="cleanup-match-threshold" min="50" max="100" value="80">
            <small class="form-text text-muted">Pourcentage de similarité requis pour correspondance nom/fichier</small>
        </div>
        <div class="form-group">
            <label>Threads parallèles</label>
            <input type="number" class="form-control" id="cleanup-max-workers" min="1" max="10" value="4">
            <small class="form-text text-muted">Nombre de threads pour l'analyse parallèle</small>
        </div>
    </div>
    <div class="checkbox-group">
        <input type="checkbox" id="cleanup-preserve-recent">
        <label for="cleanup-preserve-recent">Préserver les torrents récents même s'ils semblent inutilisés</label>
    </div>
    <div class="checkbox-group">
        <input type="checkbox" id="cleanup-detailed-logs">
        <label for="cleanup-detailed-logs">Logs détaillés pour le debugging</label>
    </div>
    <div class="checkbox-group">
        <input type="checkbox" id="cleanup-auto-schedule">
        <label for="cleanup-auto-schedule">Programmer des nettoyages automatiques</label>
    </div>
</div>
```

### **Backend - Extension de la table de configuration**

```python
# Extension de la table symlink_config
def extend_symlink_config_table():
    """Ajoute les colonnes pour la configuration cleanup"""
    conn = sqlite3.connect(SYMLINK_DB_PATH)
    cursor = conn.cursor()
    
    # Nouvelles colonnes pour le cleanup
    cleanup_columns = [
        'cleanup_enabled BOOLEAN DEFAULT 0',
        'zurg_path TEXT DEFAULT "/home/kesurof/seedbox/zurg/__all__"',
        'cleanup_min_age_days INTEGER DEFAULT 2',
        'cleanup_min_size_mb INTEGER DEFAULT 0',
        'organized_media_path TEXT DEFAULT "/app/medias"',
        'cleanup_dry_run_default BOOLEAN DEFAULT 1',
        'rd_api_key TEXT DEFAULT ""',
        'cleanup_batch_limit INTEGER DEFAULT 20',
        'cleanup_delay_ms INTEGER DEFAULT 1000',
        'cleanup_ignore_extensions TEXT DEFAULT ".nfo,.txt,.srt,.jpg,.png,.xml"',
        'cleanup_whitelist TEXT DEFAULT ""',
        'cleanup_match_threshold INTEGER DEFAULT 80',
        'cleanup_max_workers INTEGER DEFAULT 4',
        'cleanup_preserve_recent BOOLEAN DEFAULT 1',
        'cleanup_detailed_logs BOOLEAN DEFAULT 0',
        'cleanup_auto_schedule BOOLEAN DEFAULT 0'
    ]
    
    for column in cleanup_columns:
        try:
            cursor.execute(f'ALTER TABLE symlink_config ADD COLUMN {column}')
        except sqlite3.OperationalError:
            # Colonne déjà existante
            pass
    
    conn.commit()
    conn.close()
```

### **JavaScript - Fonctions de configuration**

```javascript
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
```

### **Paramètres de configuration essentiels :**

#### **🔧 Paramètres principaux :**
- **Chemin Zurg** : `/home/kesurof/seedbox/zurg/__all__`
- **Chemin médias** : `/app/medias` (symlinks organisés)
- **Âge minimum** : 2 jours
- **Mode dry-run** : Activé par défaut
- **API Real-Debrid** : Réutilise la config existante

#### **⚙️ Paramètres avancés :**
- **Limite de suppression** : 20 torrents max par session
- **Délai API** : 1000ms entre les appels
- **Seuil de correspondance** : 80% de similarité
- **Extensions ignorées** : `.nfo,.txt,.srt,.jpg,.png,.xml`
- **Whitelist** : Protection torrents spécifiques
- **Threads parallèles** : 4 workers max

#### **🛡️ Sécurités intégrées :**
- **Validation chemins** : Vérification existence Zurg/médias
- **Test connexions** : Boutons de test pour chaque service
- **Préservation récents** : Protection torrents < âge minimum
- **Logs détaillés** : Mode debug optionnel
- **Auto-scheduling** : Nettoyage programmé (futur)

## 📈 Métriques de succès

### **KPIs techniques :**
- 🎯 **Précision** : > 95% de correspondances correctes
- ⚡ **Performance** : Analyse < 30 secondes pour 1000+ torrents
- 🛡️ **Sécurité** : 0 faux positifs en production
- 💾 **Économies** : Mesure de l'espace libéré

### **KPIs utilisateur :**
- 👤 **Facilité d'usage** : Interface intuitive avec confirmations claires
- 🔄 **Fiabilité** : Intégration stable avec l'écosystème existant
- 📊 **Transparence** : Statistiques et reporting détaillés

## 🗓️ Timeline de développement

### **Sprint 1 : Backend Core (3-5 jours)**
- [x] Classe TorrentCleanupAnalyzer
- [x] Routes API d'analyse et suppression
- [x] Extension base de données pour configuration cleanup
- [x] Routes API de configuration et tests de connexion
- [x] Logique de correspondance Zurg ↔ RD
- [x] Tests unitaires et validation

### **Sprint 2 : Interface utilisateur (2-3 jours)**
- [x] Nouvel onglet "Cleanup" dans symlink_tool.html
- [x] Extension page Settings avec paramètres cleanup
- [x] JavaScript pour interaction et affichage
- [x] Fonctions de test des connexions (Zurg, Real-Debrid)
- [x] Intégration avec l'UI existante
- [x] Tests d'interface

### **Sprint 3 : Intégration et finition (1-2 jours)**
- [x] Tests d'intégration complets
- [x] Documentation utilisateur
- [x] Déploiement et validation en production

## 📝 Notes d'implémentation

### **Décisions architecturales :**
- **Réutilisation maximale** : S'appuyer sur l'existant (Flask, SQLite, JS)
- **Sécurité first** : Dry-run par défaut, confirmations multiples
- **Interface cohérente** : Même UX que le gestionnaire de torrents
- **Performance** : Traitement asynchrone pour grandes listes

### **Limitations connues :**
- **Correspondance par nom** : Peut avoir des faux positifs sur les noms similaires
- **Dépendance Zurg** : Nécessite que Zurg soit monté et accessible
- **API Rate limits** : Respecter les limites Real-Debrid pour les suppressions

### **Extensions futures possibles :**
- 🤖 **Automatisation** : Scheduling automatique du nettoyage
- 📱 **Notifications** : Alertes pour les torrents inactifs
- 📈 **Analytics** : Tableaux de bord d'usage et tendances
- 🔌 **Intégrations** : Webhook pour autres outils de l'écosystème

---

**🎯 Cette roadmap constitue le plan détaillé pour implémenter une fonctionnalité de nettoyage robuste, sécurisée et intégrée dans l'écosystème Redriva existant.**
