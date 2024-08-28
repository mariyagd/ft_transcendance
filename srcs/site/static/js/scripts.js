// Inscription
document.getElementById("register_form").addEventListener("submit", function(event) {
    event.preventDefault();

    const username = document.getElementById("username").value;
    const email = document.getElementById("email").value;
    const first_name = document.getElementById("first_name").value;
    const last_name = document.getElementById("last_name").value;
    const password = document.getElementById("password").value;

    fetch('/api/register/', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            username: username,
            email: email,
            first_name: first_name,
            last_name: last_name,
            password: password
        })
    })
        .then(response => {
            console.log(response); // Voir ce que le serveur renvoie
            const contentType = response.headers.get('content-type');
            if (contentType && contentType.includes('application/json')) {
                return response.json(); // Si c'est du JSON, le parser
            } else {
                return response.text(); // Sinon, renvoyer du texte brut pour diagnostiquer
            }
        })
        .then(data => {
            if (typeof data === 'string') {
                console.log('Réponse non-JSON reçue:', data);
                alert('Erreur inattendue : ' + data);
            } else if (data.success) {
                alert('Inscription réussie, vous pouvez maintenant vous connecter.');
                window.location.href = '/login';
            } else {
                console.error('Erreur lors de l\'inscription:', data.error);
                alert('Erreur lors de l\'inscription : ' + data.error);
            }
        })
        .catch(error => {
            console.error('Erreur lors de l\'inscription:', error);
            alert('Erreur lors de l\'inscription : ' + error.message);
        });
});

// Connexion
document.getElementById("login_form").addEventListener("submit", function(event) {
    event.preventDefault();

    const username = document.getElementById("login_username").value;
    const password = document.getElementById("login_password").value;

    fetch('/api/token/', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            username: username,
            password: password
        })
    })
        .then(response => {
            const contentType = response.headers.get('content-type');
            if (contentType && contentType.includes('application/json')) {
                return response.json(); // Si c'est du JSON, le parser
            } else {
                return response.text(); // Sinon, renvoyer du texte brut pour diagnostiquer
            }
        })
        .then(data => {
            if (typeof data === 'string') {
                console.log('Réponse non-JSON reçue:', data);
                alert('Erreur inattendue : ' + data);
            } else if (data.access) {
                localStorage.setItem('jwtToken', data.access); // Stocker le token JWT
                alert('Connexion réussie.');
                window.location.href = '/protected-page';  // Redirection après la connexion
            } else {
                console.error('Erreur lors de la connexion:', data);
                alert('Erreur lors de la connexion : ' + data.detail);
            }
        })
        .catch(error => {
            console.error('Erreur lors de la connexion:', error);
            alert('Erreur lors de la connexion : ' + error.message);
        });
});
