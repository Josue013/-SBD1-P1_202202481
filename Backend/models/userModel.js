const { getConnection } = require('../config/database');
const bcrypt = require('bcrypt');
const oracledb = require('oracledb');

class UserModel {
    static async createUser(userData) {
        let connection;
        try {
            connection = await getConnection();
            
            // Verificar si el DPI existe
            const checkDPI = await connection.execute(
                `SELECT id FROM clientes WHERE documento_identidad = :1`,
                [userData.documento_identidad]
            );
            
            if (checkDPI.rows.length > 0) {
                throw new Error('DPI already exists');
            }

            // Hash password
            const hashedPassword = await bcrypt.hash(userData.password, 10);

            // Insertar info_contacto usando secuencia
            const contactResult = await connection.execute(
                `INSERT INTO info_contacto_clientes (id, telefono, email, activo) 
                 VALUES (seq_info_contacto_clientes.NEXTVAL, :1, :2, 'T') 
                 RETURNING id INTO :3`,
                [
                    userData.telefono,
                    userData.email,
                    { type: oracledb.NUMBER, dir: oracledb.BIND_OUT }
                ]
            );

            const contactId = contactResult.outBinds[0][0];

            // Insertar cliente usando secuencia
            const clientResult = await connection.execute(
                `INSERT INTO clientes (id, documento_identidad, nombres, apellidos, password, info_contacto_id, email_confirmado) 
                 VALUES (seq_clientes.NEXTVAL, :1, :2, :3, :4, :5, 'T') 
                 RETURNING id INTO :6`,
                [
                    userData.documento_identidad,
                    userData.nombres,
                    userData.apellidos,
                    hashedPassword,
                    contactId,
                    { type: oracledb.NUMBER, dir: oracledb.BIND_OUT }
                ]
            );

            const userId = clientResult.outBinds[0][0];

            await connection.commit();
            
            return {
                message: 'User created successfully'
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
                `SELECT c.id, c.password, c.nombres, c.apellidos, ic.email, ic.telefono, c.created_at
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
                email: result.rows[0][4],
                telefono: result.rows[0][5],
                created_at: result.rows[0][6]
            };

            const validPassword = await bcrypt.compare(password, user.password);
            if (!validPassword) {
                throw new Error('Invalid credentials');
            }

            return {
                message: 'User authenticated successfully'
            };
        } finally {
            if (connection) {
                await connection.close();
            }
        }
    }

    static async getProfile(id) {
        let connection;
        try {
            connection = await getConnection();
            
            const result = await connection.execute(
                `SELECT c.id, c.nombres, c.apellidos, ic.email, ic.telefono, c.created_at
                 FROM clientes c
                 JOIN info_contacto_clientes ic ON c.info_contacto_id = ic.id
                 WHERE c.id = :1`,
                [id]
            );

            if (result.rows.length === 0) {
                throw new Error('User not found');
            }

            return {
                id: result.rows[0][0],
                nombres: result.rows[0][1],
                apellidos: result.rows[0][2],
                email: result.rows[0][3],
                telefono: result.rows[0][4],
                created_at: result.rows[0][5]
            };
        } finally {
            if (connection) {
                await connection.close();
            }
        }
    }

    static async updateUser(id, userData) {
        let connection;
        try {
            connection = await getConnection();

            // Obtener info_contacto_id
            const userResult = await connection.execute(
                `SELECT info_contacto_id FROM clientes WHERE id = :1`,
                [id]
            );

            if (userResult.rows.length === 0) {
                throw new Error('User not found');
            }

            const info_contacto_id = userResult.rows[0][0];

            // Actualizar info de contacto
            if (userData.email || userData.phone) {
                await connection.execute(
                    `UPDATE info_contacto_clientes 
                     SET email = NVL(:1, email),
                         telefono = NVL(:2, telefono)
                     WHERE id = :3`,
                    [userData.email, userData.phone, info_contacto_id]
                );
            }

            await connection.commit();
            return true;
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

    static async deleteUser(id) {
        let connection;
        try {
            connection = await getConnection();

            // Marcar como inactivo
            await connection.execute(
                `UPDATE info_contacto_clientes 
                 SET activo = 'F'
                 WHERE id = (SELECT info_contacto_id FROM clientes WHERE id = :1)`,
                [id]
            );

            await connection.commit();
            return true;
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
}

module.exports = UserModel;