document.addEventListener("htmx:afterSwap", function (event) {
    if (event.target.id === "login-modal") {
        const createAccountForm = document.querySelector("#createAccountForm");

        createAccountForm.addEventListener("submit", async function(event) {
            event.preventDefault();

            const username = document.getElementById("username").value;

            try {
                const credentialCreationOptions = await fetchCredentialCreationOptions(username);
                const registrationCredential = await navigator.credentials.create({ publicKey: credentialCreationOptions });
                await registerNewCredential(registrationCredential);
                location.href = "/users/profile";
            } catch (error) {
                console.log(error);

                // Make a DELETE request to clean up the server-side data
                await deleteCredential();
            }
        });
    }
});

async function fetchCredentialCreationOptions(username) {
    const makeCredentialsResponse = await fetch("/users", {
        method: "POST",
        credentials: "include",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify({
            email: username,
        }),
    });
    if (makeCredentialsResponse.status == 409) {
        throw new Error("Username is already taken");
    } else if (!makeCredentialsResponse.status == 200) {
        throw new Error("Signup request failed");
    }

    let credentialCreationOptions = await makeCredentialsResponse.json();
    credentialCreationOptions.challenge = bufferDecode(credentialCreationOptions.challenge);
    credentialCreationOptions.user.id = bufferDecode(credentialCreationOptions.user.id);

    return credentialCreationOptions;
}

async function registerNewCredential(newCredential) {
    // Move data into Arrays incase it is super long
    const attestationObject = new Uint8Array(newCredential.response.attestationObject);
    const clientDataJSON = new Uint8Array(newCredential.response.clientDataJSON);
    const rawId = new Uint8Array(newCredential.rawId);

    const registerResponse = await fetch('/users/makeCredential', {
        method: 'POST',
        credentials: "include",
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            credential: {
                id: newCredential.id,
                rawId: bufferEncode(rawId),
                type: newCredential.type,
                response: {
                    attestationObject: bufferEncode(attestationObject),
                    clientDataJSON: bufferEncode(clientDataJSON),
                },
            },
            clientID: "aPrincipalEngineerWeb",
        })
    });

    if (registerResponse.status != 200) {
        throw new Error("makeCredential request failed");
    }
}

async function deleteCredential() {
    try {
        const response = await fetch('/users/makeCredential', {
            method: 'DELETE',
            credentials: "include"});
    } catch (error) {
        console.error("Error during cleanup:", error);
    }
}
