

const bcrypt = require('bcrypt');

const hashedPassword = "$2b$10$QKMEJhIA/6KOkC1VTkAVfeHcJkO1T4G/uMK52twVpv0.W9kLHK9rK"; // hash
const plainPassword = "tu_contraseña"; // La contraseña

bcrypt.compare(plainPassword, hashedPassword, (err, result) => {
    if (result) {
        console.log("¡Contraseña correcta!");
    } else {
        console.log("Contraseña incorrecta.");
    }
});
