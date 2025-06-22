# Chirp the friendly X-Clone
## Der Auftrag
Wir möchten eine chat app analog twitter/x erstellen und erweitern

### Sammle Features
Erstelle eine Liste von Funktionen, die eine solche App deiner Meinung nach haben sollte.

### Zeichnung der App
Erstelle eine ungefähre, schematische Zeichnung deiner App und deren Funktionen.

## Weiterführende Aufträge

### Username anstatt email addresse
über jedem post wird aktuell die mail adresse angezeigt, es sollte jedoch der username mit einem '@' als prefix dargestellt werden. z.B. '@user1'
stichwörter: user.ex, user, email, username

### Löschen von bestehenden Posts
es soll ein Icon zum löschen neben jenem zum ändern von posts dargestellt werden, beim Klick soll der post gelöscht werden.
stichwörter: delete, edit, handle_event

### Live Updates für alle User
neue und gelöschte Posts müssen für jeden User, der die app offen hat sofort ersichtlich sein, rsp. verschwinden.
stichwörter: timeline, PubSub, subscribe, publish

### Deployment und Zugriff übers WWW
um die app für alle benutzer erreichbar zu machen, müssen wir sie deployen. Nutze dazu den befehl `fly deploy` im terminal.
stichwörter: fly.io, deployment

### color and fun
gestalte die seite nach deinem geschmack oder füge funktionen hinzu, die du gerne möchtest. Deploye deine Änderungen ins WWW.
