const { getConnection } = require('../config/database');
const bcrypt = require('bcrypt');

class UserModel {
    static async createUser(userData) {
        let connection;
        try {
            connection = await getConnection();
            
            // Verificar si el email existe
            const checkEmail = await connection.execute(
                `SELECT id FROM info_contacto_clientes WHERE email = :1`,
                [userData.email]
            );
            
            if (checkEmail.rows.length > 0) {
                throw new Error('Email already exists');
            }

            // Hash password
            const hashedPassword = await bcrypt.hash(userData.password, 10);

            // Insertar info_contacto
            const contactResult = await connection.execute(
                `INSERT INTO info_contacto_clientes (email, telefono, activo) 
                 VALUES (:1, :2, 'T') 
                 RETURNING id INTO :3`,
                [userData.email, userData.phone, { type: connection.NUMBER, dir: connection.BIND_OUT }]
            );

            const contactId = contactResult.outBinds[0][0];

            // Insertar cliente
            const clientResult = await connection.execute(
                `INSERT INTO clientes (documento_identidad, nombres, apellidos, password, info_contacto_id, email_confirmado) 
                 VALUES (:1, :2, :3, :4, :5, 'T') 
                 RETURNING id INTO :6`,
                [userData.dpi, userData.nombres, userData.apellidos, hashedPassword, contactId, 
                 { type: connection.NUMBER, dir: connection.BIND_OUT }]
            );

            await connection.commit();
            
            return {
                id: clientResult.outBinds[0][0],
                email: userData.email
            };
        } catch (error) {
            if (connection) {
                await connection.rollback();
            }
            throw error;
        } finally {
            if (connection) {
                await connection.close();
            }
        }
    }

    static async loginUser(email, password) {
        let connection;
        try {
            connection = await getConnection();
            
            const result = await connection.execute(
                `SELECT c.id, c.password, c.nombres, c.apellidos, ic.email
                 FROM clientes c
                 JOIN info_contacto_clientes ic ON c.info_contacto_id = ic.id
                 WHERE ic.email = :1`,
                [email]
            );

            if (result.rows.length === 0) {
                throw new Error('Invalid credentials');
            }

            const user = {
                id: result.rows[0][0],
                password: result.rows[0][1],
                nombres: result.rows[0][2],
                apellidos: result.rows[0][3],
                email: result.rows[0][4]
            };

            const validPassword = await bcrypt.compare(password, user.password);
            if (!validPassword) {
                throw new Error('Invalid credentials');
            }

            return {
                id: user.id,
                email: user.email,
                nombres: user.nombres,
                apellidos: user.apellidos
            };
        } finally {
            if (connection) {
                await connection.close();
            }
        }
    }
}

module.exports = UserModel;