# Logiciel de gestion de file d’attente Redriva
# Limite le nombre de téléchargements simultanés et gère les priorités

import sqlite3
import time
import threading

DB_PATH = "data/redriva.db"
MAX_ACTIVE = 2  # Nombre de téléchargements simultanés autorisés


def get_db():
    return sqlite3.connect(DB_PATH)


def get_next_pending():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("SELECT id, torrent_id FROM queue WHERE status = 'pending' ORDER BY priority ASC, added_at ASC LIMIT 1")
    row = cur.fetchone()
    conn.close()
    return row


def count_active():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) FROM queue WHERE status = 'active'")
    n = cur.fetchone()[0]
    conn.close()
    return n


def set_status(queue_id, status):
    conn = get_db()
    cur = conn.cursor()
    cur.execute("UPDATE queue SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?", (status, queue_id))
    conn.commit()
    conn.close()


def worker_loop():
    while True:
        if count_active() < MAX_ACTIVE:
            next_item = get_next_pending()
            if next_item:
                queue_id, torrent_id = next_item
                set_status(queue_id, 'active')
                # Ici, lancer le téléchargement réel (appel API RD, etc.)
                # Pour la démo, on simule un téléchargement
                print(f"[QUEUE] Lancement du téléchargement {torrent_id} (queue_id={queue_id})")
                threading.Thread(target=simulate_download, args=(queue_id,)).start()
        time.sleep(5)


def simulate_download(queue_id):
    # Simule un téléchargement de 20s
    time.sleep(20)
    set_status(queue_id, 'completed')
    print(f"[QUEUE] Téléchargement terminé pour queue_id={queue_id}")


if __name__ == "__main__":
    print("[QUEUE] Gestionnaire de file d’attente démarré")
    worker_loop()
