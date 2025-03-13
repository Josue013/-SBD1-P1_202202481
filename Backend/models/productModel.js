const { getConnection } = require('../config/database');

class ProductModel {
    static async getProducts() {
        let connection;
        try {
            connection = await getConnection();
            
            const result = await connection.execute(
                `SELECT p.id, p.sku, p.nombre, p.descripcion, p.precio, p.slug,
                        c.nombre as categoria, p.activo
                 FROM productos p
                 JOIN categorias_producto c ON p.categoria_id = c.id
                 WHERE p.activo = 'T'
                 ORDER BY p.id`
            );

            return result.rows.map(row => ({
                id: row[0],
                sku: row[1],
                nombre: row[2],
                descripcion: row[3],
                precio: row[4],
                slug: row[5],
                categoria: row[6],
                activo: row[7]
            }));
        } finally {
            if (connection) {
                await connection.close();
            }
        }
    }

    static async getProductById(id) {
        let connection;
        try {
            connection = await getConnection();
            
            const result = await connection.execute(
                `SELECT p.id, p.sku, p.nombre, p.descripcion, p.precio, p.slug,
                        c.nombre as categoria, p.activo
                 FROM productos p
                 JOIN categorias_producto c ON p.categoria_id = c.id
                 WHERE p.id = :1 AND p.activo = 'T'`,
                [id]
            );

            if (result.rows.length === 0) {
                throw new Error('Product not found');
            }

            const row = result.rows[0];
            return {
                id: row[0],
                sku: row[1],
                nombre: row[2],
                descripcion: row[3],
                precio: row[4],
                slug: row[5],
                categoria: row[6],
                activo: row[7]
            };
        } finally {
            if (connection) {
                await connection.close();
            }
        }
    }
}

module.exports = ProductModel;