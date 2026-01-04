#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║                     REDRIVA - Application Manager                         ║
║                          Version 3.0 (Python)                             ║
║                                                                           ║
║         Gestionnaire d'Applications Docker avec Traefik + OAuth2          ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
"""

import os
import sys
import json
import subprocess
import shutil
from pathlib import Path
from typing import Dict, List, Optional, Tuple

# ============================================================================
# CONFIGURATION CHEMINS
# ============================================================================

class Paths:
    """Gestion des chemins"""
    
    # Dossier du projet
    PROJECT_HOME = Path(__file__).parent.parent
    
    # Dossier utilisateur (VISIBLE!)
    USER_HOME = Path.home() / "my_redriva"
    
    # Sous-dossiers
    CONFIG_DIR = USER_HOME / "config"
    DATA_DIR = USER_HOME / "data"
    STATE_DIR = USER_HOME / "state"
    
    # Fichiers de configuration
    CORE_ENV = CONFIG_DIR / "core.env"
    APPS_STATE = STATE_DIR / "apps.json"
    
    # Templates
    TEMPLATES_DIR = PROJECT_HOME / "templates"
    CORE_TEMPLATES = TEMPLATES_DIR / "core"
    APPS_TEMPLATES = TEMPLATES_DIR / "apps"

# ============================================================================
# COULEURS ET SYMBOLES
# ============================================================================

class Colors:
    """Codes couleurs ANSI"""
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    END = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

SYMBOLS = {
    'info': 'ℹ',
    'ok': '✓',
    'error': '✗',
    'warn': '⚠',
    'bullet': '•',
    'arrow': '→',
}

# ============================================================================
# LOGGER
# ============================================================================

class Logger:
    """Gestionnaire de logs avec couleurs"""
    
    @staticmethod
    def info(msg: str) -> None:
        print(f"{Colors.BLUE}{SYMBOLS['info']}{Colors.END} {msg}")
    
    @staticmethod
    def ok(msg: str) -> None:
        print(f"{Colors.GREEN}{SYMBOLS['ok']}{Colors.END} {msg}")
    
    @staticmethod
    def error(msg: str) -> None:
        print(f"{Colors.RED}{SYMBOLS['error']}{Colors.END} {msg}", file=sys.stderr)
    
    @staticmethod
    def warn(msg: str) -> None:
        print(f"{Colors.YELLOW}{SYMBOLS['warn']}{Colors.END} {msg}")
    
    @staticmethod
    def title(msg: str) -> None:
        print(f"\n{Colors.BOLD}{Colors.CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{Colors.END}")
        print(f"{Colors.BOLD}{Colors.CYAN}  {msg}{Colors.END}")
        print(f"{Colors.BOLD}{Colors.CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{Colors.END}")
    
    @staticmethod
    def bullet(msg: str) -> None:
        print(f"  {SYMBOLS['bullet']} {msg}")
    
    @staticmethod
    def section(msg: str) -> None:
        print(f"\n{Colors.BOLD}{Colors.CYAN}• {msg}{Colors.END}")

# ============================================================================
# INITIALISATION
# ============================================================================

class Initializer:
    """Initialisation du système"""
    
    @staticmethod
    def init_directories() -> bool:
        """Crée les répertoires nécessaires"""
        try:
            Paths.CONFIG_DIR.mkdir(parents=True, exist_ok=True)
            Paths.DATA_DIR.mkdir(parents=True, exist_ok=True)
            Paths.STATE_DIR.mkdir(parents=True, exist_ok=True)
            
            Logger.ok(f"Répertoires initialisés: {Paths.USER_HOME}")
            return True
        except Exception as e:
            Logger.error(f"Erreur création répertoires: {e}")
            return False
    
    @staticmethod
    def init_state() -> bool:
        """Initialise le fichier d'état"""
        try:
            if not Paths.APPS_STATE.exists():
                state = {
                    "apps": {},
                    "version": "3.0",
                    "last_update": None
                }
                with open(Paths.APPS_STATE, 'w') as f:
                    json.dump(state, f, indent=2)
                Logger.ok("Fichier d'état créé")
            return True
        except Exception as e:
            Logger.error(f"Erreur initialisation état: {e}")
            return False

# ============================================================================
# GESTION DOCKER
# ============================================================================

class Docker:
    """Opérations Docker"""
    
    @staticmethod
    def is_available() -> bool:
        """Vérifie que Docker est accessible"""
        try:
            result = subprocess.run(
                ["docker", "ps"],
                capture_output=True,
                timeout=5
            )
            return result.returncode == 0
        except Exception:
            return False
    
    @staticmethod
    def get_version() -> Optional[str]:
        """Retourne la version de Docker"""
        try:
            result = subprocess.run(
                ["docker", "--version"],
                capture_output=True,
                text=True,
                timeout=5
            )
            if result.returncode == 0:
                return result.stdout.strip()
            return None
        except Exception:
            return None
    
    @staticmethod
    def compose_up(path: Path) -> bool:
        """Démarre docker-compose"""
        try:
            result = subprocess.run(
                ["docker-compose", "-f", str(path), "up", "-d"],
                cwd=path.parent,
                capture_output=True,
                timeout=30
            )
            return result.returncode == 0
        except Exception as e:
            Logger.error(f"Erreur docker-compose: {e}")
            return False
    
    @staticmethod
    def compose_down(path: Path) -> bool:
        """Arrête docker-compose"""
        try:
            result = subprocess.run(
                ["docker-compose", "-f", str(path), "down"],
                cwd=path.parent,
                capture_output=True,
                timeout=30
            )
            return result.returncode == 0
        except Exception as e:
            Logger.error(f"Erreur docker-compose: {e}")
            return False
    
    @staticmethod
    def compose_logs(path: Path, follow: bool = False) -> None:
        """Affiche les logs"""
        cmd = ["docker-compose", "-f", str(path), "logs"]
        if follow:
            cmd.append("-f")
        
        try:
            subprocess.run(cmd, cwd=path.parent)
        except KeyboardInterrupt:
            print()
        except Exception as e:
            Logger.error(f"Erreur logs: {e}")

# ============================================================================
# REGISTRE APPLICATIONS
# ============================================================================

class AppRegistry:
    """Registre des applications"""
    
    APPS = {
        "radarr": {
            "name": "radarr",
            "description": "Gestionnaire de films",
            "icon": "🎬",
            "image": "linuxserver/radarr:latest",
            "port": 7878,
            "requires": ["traefik"],
            "env": ["PUID", "PGID", "TZ", "DOMAIN"]
        },
        "sonarr": {
            "name": "sonarr",
            "description": "Gestionnaire de séries TV",
            "icon": "📺",
            "image": "linuxserver/sonarr:latest",
            "port": 8989,
            "requires": ["traefik"],
            "env": ["PUID", "PGID", "TZ", "DOMAIN"]
        },
        "qbittorrent": {
            "name": "qbittorrent",
            "description": "Client torrent web",
            "icon": "⚡",
            "image": "linuxserver/qbittorrent:latest",
            "port": 6881,
            "requires": ["traefik"],
            "env": ["PUID", "PGID", "TZ", "DOMAIN"]
        },
        "plex": {
            "name": "plex",
            "description": "Serveur multimédia Plex",
            "icon": "🎥",
            "image": "plexinc/pms-docker:latest",
            "port": 32400,
            "requires": ["traefik"],
            "env": ["PUID", "PGID", "TZ", "DOMAIN", "PLEX_CLAIM"]
        }
    }
    
    @classmethod
    def get_app(cls, name: str) -> Optional[Dict]:
        """Retourne les infos d'une application"""
        return cls.APPS.get(name)
    
    @classmethod
    def list_apps(cls) -> Dict:
        """Retourne toutes les applications"""
        return cls.APPS
    
    @classmethod
    def get_app_compose_path(cls, name: str) -> Optional[Path]:
        """Retourne le chemin du docker-compose"""
        path = Paths.APPS_TEMPLATES / name / "docker-compose.yml"
        return path if path.exists() else None

# ============================================================================
# GESTIONNAIRE APPLICATIONS
# ============================================================================

class AppManager:
    """Gestionnaire des applications"""
    
    @staticmethod
    def list_command() -> None:
        """Commande: list"""
        Logger.info(f"Redriva home: {Paths.PROJECT_HOME}")
        Logger.info(f"User config: {Paths.USER_HOME}")
        
        # Initialisation
        Logger.title("Préparation des répertoires")
        if not Initializer.init_directories():
            sys.exit(1)
        
        if not Initializer.init_state():
            sys.exit(1)
        
        # Vérifier core.env
        if not Paths.CORE_ENV.exists():
            Logger.warn(f"Fichier {Paths.CORE_ENV} non trouvé")
            Logger.info("Exécutez: redriva setup-core")
        else:
            Logger.ok("Fichier de configuration trouvé")
        
        # Vérifier Docker
        if not Docker.is_available():
            Logger.error("Docker n'est pas accessible")
            sys.exit(1)
        
        docker_version = Docker.get_version()
        Logger.ok(f"Docker: {docker_version if docker_version else 'OK'}")
        
        # Lister les applications
        Logger.title("Applications disponibles")
        for name, info in AppRegistry.list_apps().items():
            icon = info.get('icon', '•')
            Logger.bullet(f"{Colors.BOLD}{icon} {name}{Colors.END} - {info['description']}")
    
    @staticmethod
    def info_command(app_name: str) -> None:
        """Commande: info <app>"""
        app = AppRegistry.get_app(app_name)
        
        if not app:
            Logger.error(f"Application '{app_name}' non trouvée")
            sys.exit(1)
        
        Logger.title(f"Informations: {app_name}")
        Logger.bullet(f"Description: {app['description']}")
        Logger.bullet(f"Image: {app['image']}")
        Logger.bullet(f"Port: {app['port']}")
        Logger.bullet(f"Prérequis: {', '.join(app['requires'])}")
        Logger.bullet(f"Variables: {', '.join(app['env'])}")
    
    @staticmethod
    def install_command(app_name: str) -> None:
        """Commande: install <app>"""
        app = AppRegistry.get_app(app_name)
        
        if not app:
            Logger.error(f"Application '{app_name}' non trouvée")
            sys.exit(1)
        
        Logger.title(f"Installation: {app_name}")
        
        # Vérifier core.env
        if not Paths.CORE_ENV.exists():
            Logger.error(f"Configuration core.env manquante")
            Logger.info("Exécutez: redriva setup-core")
            sys.exit(1)
        
        # Vérifier docker-compose
        compose_path = AppRegistry.get_app_compose_path(app_name)
        if not compose_path:
            Logger.error(f"docker-compose manquant pour {app_name}")
            sys.exit(1)
        
        Logger.info(f"Démarrage de {app_name}...")
        if Docker.compose_up(compose_path):
            Logger.ok(f"{app_name} démarré avec succès!")
            Logger.info(f"Accédez via: https://{app_name}.example.com")
        else:
            Logger.error(f"Erreur lors du démarrage de {app_name}")
            sys.exit(1)
    
    @staticmethod
    def logs_command(app_name: str) -> None:
        """Commande: logs <app>"""
        compose_path = AppRegistry.get_app_compose_path(app_name)
        
        if not compose_path:
            Logger.error(f"Application '{app_name}' non trouvée")
            sys.exit(1)
        
        Logger.title(f"Logs: {app_name}")
        Docker.compose_logs(compose_path)
    
    @staticmethod
    def help_command() -> None:
        """Commande: help"""
        Logger.title("REDRIVA - Gestionnaire d'Applications Docker")
        print(f"""
{Colors.BOLD}Usage:{Colors.END}
  redriva <commande> [options]

{Colors.BOLD}Commandes:{Colors.END}
  list              Lister les applications disponibles
  info <app>        Afficher les infos d'une application
  install <app>     Installer une application
  remove <app>      Supprimer une application
  status <app>      Voir le statut d'une application
  logs <app>        Voir les logs d'une application
  restart <app>     Redémarrer une application
  setup-core        Configurer le core (Traefik, OAuth2)
  help              Afficher cette aide

{Colors.BOLD}Exemples:{Colors.END}
  redriva list
  redriva info radarr
  redriva install radarr
  redriva logs radarr

{Colors.BOLD}Configuration:{Colors.END}
  {Paths.USER_HOME}/config/core.env

{Colors.BOLD}Documentation:{Colors.END}
  {Paths.PROJECT_HOME}/README.md
""")

# ============================================================================
# MAIN
# ============================================================================

def main() -> None:
    """Point d'entrée principal"""
    if len(sys.argv) < 2:
        AppManager.help_command()
        sys.exit(0)
    
    command = sys.argv[1]
    
    try:
        if command == "list":
            AppManager.list_command()
        elif command == "info":
            if len(sys.argv) < 3:
                Logger.error("Usage: redriva info <app>")
                sys.exit(1)
            AppManager.info_command(sys.argv[2])
        elif command == "install":
            if len(sys.argv) < 3:
                Logger.error("Usage: redriva install <app>")
                sys.exit(1)
            AppManager.install_command(sys.argv[2])
        elif command == "logs":
            if len(sys.argv) < 3:
                Logger.error("Usage: redriva logs <app>")
                sys.exit(1)
            AppManager.logs_command(sys.argv[2])
        elif command == "help":
            AppManager.help_command()
        else:
            Logger.error(f"Commande inconnue: {command}")
            AppManager.help_command()
            sys.exit(1)
    except KeyboardInterrupt:
        print()
        sys.exit(0)
    except Exception as e:
        Logger.error(f"Erreur: {e}")
        sys.exit(1)

# ============================================================================
# EXÉCUTION
# ============================================================================

if __name__ == "__main__":
    main()
