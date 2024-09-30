#!/bin/sh

# Démarrer le serveur SSH Dropbear
/usr/sbin/dropbear -s -E -F -m -R &

# Exécuter la commande spécifiée dans CMD
exec "$@"