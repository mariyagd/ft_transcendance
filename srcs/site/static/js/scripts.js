document.addEventListener('DOMContentLoaded', () => {
    const form = document.getElementById('registrationForm');

    form.addEventListener('submit', async (event) => {
        event.preventDefault(); // Empêche l'envoi normal du formulaire

        // Récupérer les données du formulaire
        const formData = new FormData(form);
        const data = Object.fromEntries(formData.entries());

        try {
            console.log('Envoi des données:', data);

            // Requête POST vers ton backend pour l'inscription
            const response = await fetch('https://localhost:8000/api/user/register/', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                mode: 'cors', // Nécessaire pour les requêtes cross-origin
                body: JSON.stringify(data), // Convertir les données en JSON
            });

            if (!response.ok) {
                const errorText = await response.text();
                throw new Error(`Erreur HTTP: ${response.status} ${errorText}`);
            }

            const result = await response.json();
            alert('Inscription réussie !');
            console.log('Réponse du serveur:', result);
        } catch (error) {
            console.error('Erreur:', error);
            alert('Une erreur s\'est produite. Vérifiez la console pour plus de détails.');
        }
    });
});

