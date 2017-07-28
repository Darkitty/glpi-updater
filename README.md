# GLPI Updater
## Script de backup et mise à jour de GLPI
![CoverGLPIUpdater](https://goo.gl/pTixue)
### Présentation
Les mises à jour GLPI sont affichée dans le footer de la page, mais aucun système ne permet de l'automatiser ou au minimum de pouvoir le lancer via un script. J'ai donc pris quelques minutes pour pondre un petit script de mise à jour GLPI. 

Le script va générer un fichier de configuration sous /etc avec les informations nécessaires, et puiser de dans à chaque lancement.

* Génération d'un fichier de configuration sous ETC