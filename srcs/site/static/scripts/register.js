document.getElementById("register_form").addEventListener("submit", function(event) {
    event.preventDefault(); // Empêche la soumission par défaut

    // Récupère les données du formulaire
    const data = {
        username: document.getElementById("username").value,
        email: document.getElementById("email").value,
        first_name: document.getElementById("first_name").value,
        last_name: document.getElementById("last_name").value,
        password: document.getElementById("password").value,
        password2: document.getElementById("password2").value
    };

    // Vérifier que les mots de passe correspondent avant d'envoyer la requête
    if (data.password !== data.password2) {
        document.getElementById("message").textContent = "Les mots de passe ne correspondent pas.";
        return;
    }

    // Effectue la requête fetch vers l'API d'enregistrement
    fetch('http://localhost:8000/api/user/register/', { // Remplacez par l'URL de votre API
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data) // Convertit les données en JSON pour l'API
    })
        .then(response => {
            if (!response.ok) {
                return response.json().then(err => { throw new Error(err); });
            }
            return response.json(); // Parse la réponse en JSON
        })
        .then(data => {
            // Si l'inscription est réussie
            document.getElementById("message").textContent = "Inscription réussie, vous pouvez maintenant vous connecter.";
            setTimeout(() => {
                window.location.href = '/login.html'; // Redirection vers la page de connexion
            }, 2000); // Attendre 2 secondes avant de rediriger
        })
        .catch(error => {
            console.error('Erreur lors de l\'inscription:', error);
            document.getElementById("message").textContent = 'Erreur lors de l\'inscription : ' + (error.message || 'Erreur inconnue');
        });
});
