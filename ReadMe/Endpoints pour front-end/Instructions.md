- Télécharger le projet
    
    [https://github.com/mariyagd/trans-test](https://github.com/mariyagd/trans-test)
    
    Normalement on peut télécharger en format zip.
    
    Donner ton github compte pour que je l’ajoute dans le projet.
    
- Makefile
    
    **J’utilise le plus souvent `make all, make fclean`, et `make ref`**
    
    - `make up`
        - `docker-compose -f $(COMPOSE_FILE) up --build -d`
        - reconstruit les images (si nécessaire) et **ensuite démarre** les conteneurs en arrière-plan.
    - `make all`
        - fait `make up`
        - crée le dossier de la database dans `/home/postgres/data`
        - donne les permissions et le ownership de ce dossier à l’utilisateur courant avec `whoami`
    - `make down`
        - `docker-compose -f $(COMPOSE_FILE) down`
        - arrête les conteneurs **et supprime** les conteneurs et les networks
    - `make clean`
        - fait `make down`
    - `make down-rmi`
        - `docker-compose -f $(COMPOSE_FILE) down --rmi all --volumes`
        - arrête les conteneurs **et supprime** les conteneurs, networks, **images et volumes** utilisés par les services
    - `make fclean`
        - fait `down-rmi`
        - supprime le dossier `/home/postgres/data` avec sudo login
        - réattribue le ownership des dossier `./srcs/site/media` et `./srcs/site/static` à `whoami` avec sudo login
    - `make ref` → fait `fclean` et `all`
    - `make re` → fait `clean` et `all`
    
    Autre utiles:
    
    - `make build`
        - `docker-compose -f $(COMPOSE_FILE) build`
        - Reconstruit uniquement les images **sans** démarrer les conteneurs.
    - `make start`
        - `docker-compose -f $(COMPOSE_FILE) start`
        - démarre les conteneurs
    - `make stop`
        - `docker-compose -f $(COMPOSE_FILE) stop`
        - arrête les conteneurs en cours d’exécution sans les supprimer
    - `make logs` → voir les logs
    - `make ps` →
    - `make image` → voir toutes les images
    - `make network` → voir tous les networks
    - `make dangling-images`
    - `make dangling-networks`
    - `make dangling-volumes`
    - `make dangling` → fait les trois derniers
- Instructions
    
    - Attribuer le nom du domain au localhost
        
        ```python
        sudo nano /etc/hosts
        
        # ajouter la ligne:
        127.0.0.1       pong.42lausanne.ch
        ```
        
    - Ne pas supprimer `default-user-profile-photo.jpg` du dossier `./src/site/media/images` . C’est la photo par défaut des users.
        
    - Placer les fichiers du site dans `./src/site/media` et `./src/site/static`
        
    - Faire `make all`
        
    - Sur le web browser aller au site `pong.42lausanne.ch`
        
    - Pour pouvoir modifier les fichiers du site depuis la machine hôte et visualiser les modifications en temps réel suivre les étapes suivants: (à faire **après** le premier `make all):`
        
        - Voir si le group `www-data` a été crée avec la commande:
            
            ```python
            cat /etc/group | grep "www-data"
            ```
            
        - Ajouter le user courant dans le group `www-data` avec la commande:
            
            ```python
            sudo usermod -aG www-data $(whoami)
            ```
            
        - Appliquer les modifications et vérifier si l’attribution du group a bien eu lieu avec:
            
            ```python
            newgrp www-data
            
            # vérifier que le group à été ajouté à l'user courant
            groups $whoami
            
            exit
            
            sudo reboot
            
            # Après reconnexion, revérifier que le group à été ajouté à l'user courant
            groups $whoami
            ```
            
        - Vérifier que tous les conteneurs sont up et running
            
            ```python
            make ps
            ```
            
        - Normalement après tout ça, tu pourrais faire des modifications des fichiers html sur la machine hôte, et voir les modifications dans le site `pong.42lausanne.ch`
            
        - Ouvrir le fichier `index.html` et essayer de faire un modification.
            
        - Si tu travaille sur vim ou neovim et s’il y a un message d’erreur `Can't delete backup files` suivre les instructions:
            
            - Sur la machine hôte:
                
                ```python
                mkdir -p ~/.vim/backup ~/.vim/swap
                ```
                
            - Dans le fichier de configuration de vim ajouter:
                
                ```python
                set backupdir=~/.vim/backup//
                set directory=~/.vim/swap//
                ```
                
            - Tester si la modification marche sans le message d’erreur.
                
- Django admin
    
    ```python
    <http://localhost:8000/admin>
    ```
    
    **Seulement http**. https doesn’t work.
    
    username: django
    
    email: [django@gmail.com](mailto:django@gmail.com)
    
    password: django
    
- Tester API endpoints
    
    Installer [postman](https://www.postman.com/) desktop app
    
- Endpoint: Register (l’enregistrement d’un nouvel user)
    
    - **Endpoint**:
        
        ```python
        <http://localhost:8000/api/user/register/>
        ```
        
    - **Requêtes** HTTP: POST
        
    - **Token**: sans token, ne génére pas de token
        
    - **Format**
        
        - tous les champs sont **required sauf `profile_photo` qui peut être omis**
        
        ```python
        {
            "username"     : "mariya",
            "email"        : "mariya@gmail.com",
            "password"     : "mariya1Dancheva1!",
            "password2"    : "mariya1Dancheva1!",
            "first_name"   : "mariya",
            "last_name"    : "mariya"
            # "profile_photo : "path/to/profile/photo.jpg" # optional
        }
        ```
        
        - Si aucune photo n’est uploadé, une photo par défaut est automatiquement envoyé: `default-user-profile-photo.jpg`
            
        - Les photos uploadés apparaissent dans les trois conteneurs:
            
            - nginx: `/var/www/html/media/images`
            - auth: `./media/images`
            - postgres:
            
            ```python
            docker exec -ti postgres /bin/bash
            
            psql -U pong pong
            
            password: pong
            
            SELECT * FROM pong_app_user;
            ```
            
        - Voir dans django admin si le user est enregisté: `http://localhost:8000/admin`. **La photo de profile n’est pas visible ici.**
            
    - **Validateurs**: auth conteneur exécute les validateurs suivants:
        
        - `password` : Required. **Password Validations**
            
            - It must contain at least 12 characters.
            - Can’t be a common word.
            - Can’t be entirely numeric.
            - Can’t be your e-mail, first name, last name or user name → **ne fonctionne pas**
            - Must contain at least 1 uppercase, 1 lowercase, 1 numeric and 1 special caracter
        - `password2` : Required. Must match `password`
            
        - `username` : Required. 150 characters or fewer. Usernames may contain alphanumeric, `_`, `@`, `+`, `.` and `-` characters.
            
        - `first_name` : Required. 150 characters or fewer.
            
        - `last_name` : Required. 150 characters or fewer.
            
        - `email` : Required. Email address. (Vérifie s’il y a `@` et `.` dans l’adresse e-mail)
            
            An `EmailValidator` ensures that a value looks like an email, and raises a `ValidationError` with `message` and `code` if it doesn’t. Values longer than 320 characters are always considered invalid.
            
            The error message used by `ValidationError` if validation fails. Defaults to `"Enter a valid email address"`.
            
            The error code used by `ValidationError` if validation fails. Defaults to `"invalid"`.
            
            _Pour l’instant on peut utiliser `localhost` comme domain de l’adresse email, mais je dois voir comment le supprimer. P.ex. `mariya@localhost` est validé._
            
        - `profile_photo` : Optional. image
            
        - Chaque adresse e-mail et username sont être uniques.
            
        - En cas d’erreur envoie 400 Bad Request
            
    - **Valeurs retournées**
        
        - `username`
        - `first_name`
        - `last_name`
        - `email`
        - `profile_photo`
        - `is_active` : Boolean.
            - Marks this user account as active on registration.
            - We recommend that you set this flag to `false` instead of deleting accounts.
            - _En gros ici ce qu’on peut faire, au lieu de supprimer un compte utilisateur avec DELETE, on peut mettre is_active=false et le garder dans la base de données pour permettre que l’utilisateur se reconnecte en restaurant toute l’historique des ses activités. Donc c’est encore à réfléchir._
        - `last_login` : A datetime of the user’s last login.
            - `null` si l’utilisateur ne s’est jamais loggé
            - Format `"*25 Oct 2006* 12:47:17"`, `'%d %b %Y %H:%M:%S'`
        - `date_joined` : The date/time when the account was created.
            - Créé automatiquement lors de l’enregistrement du nouvel utilisateur
            - Format `"*25 Oct 2006* 12:47:17"`, `'%d %b %Y %H:%M:%S'`