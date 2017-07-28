# GLPI Updater
## Script de backup et mise à jour de GLPI
![CoverGLPIUpdater](https://goo.gl/pTixue)
### Présentation
Les mises à jour GLPI sont affichée dans le footer de la page, mais aucun système ne permet de l'automatiser ou au minimum de pouvoir le lancer via un script. J'ai donc pris quelques minutes pour pondre un petit script de mise à jour GLPI. 

Le script va générer un fichier de configuration sous /etc avec les informations nécessaires, et puiser de dans à chaque lancement.

* Vérification de la présence de mise à jour
* Génération d'un fichier de configuration sous ETC
* Création d'une sauvegarde des fichiers GLPI
* Dump de la base et compression
* Récupération de la dernière version (ou version de son choix) de GLPI
* Installation et mise à jour des droits sur les fichiers

### Utilisation
Pour utiliser ce script de mise à jour, commencez par clôner le repo :
```bash
git clone https://github.com/bilyboy785/glpi-updater.git /opt/glpi-updater
touch /root/glpiversion.txt
echo "{VOTRE-VERSION}" > /root/glpiversion.txt
```

Si besoin, créez un alias de la commande **bash /opt/glpi-updater/update-glpi.sh**.

### Automatisation
Le script vérifie la présence de mise à jour : si aucune n'est trouvée, rien ne se passe. Vous pouvez donc programmer ce script toutes les semaines sans risquer de mettre en rideau votre installation GLPI :
```bash
crontab -e
0 23 * * * bash /opt/glpi-updater/update-glpi.sh
```