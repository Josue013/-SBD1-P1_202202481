const { getConnection } = require('../config/database');
const oracledb = require('oracledb');

class ProductModel {
    static async getProducts() {
        let connection;
        try {
            connection = await getConnection();
            
            const result = await connection.execute(
                `SELECT p.id, p.nombre, p.precio, 
                        COALESCE(SUM(i.cantidad), 0) as stock
                 FROM productos p
                 LEFT JOIN inventario i ON p.id = i.producto_id
                 WHERE p.activo = 'T'
                 GROUP BY p.id, p.nombre, p.precio
                 ORDER BY p.id`
            );
    
            return result.rows.map(row => ({
                id: row[0],
                name: row[1],
                price: row[2],
                stock: row[3]
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
            
            // Configurar el tipo de datos para CLOB
            await connection.execute(`ALTER SESSION SET nls_length_semantics='CHAR'`);
            
            const result = await connection.execute(
                `SELECT p.id, p.nombre, 
                        TO_CHAR(p.descripcion) as descripcion, 
                        p.precio, c.nombre as categoria,
                        (SELECT COALESCE(SUM(cantidad), 0) 
                         FROM inventario 
                         WHERE producto_id = p.id) as stock
                 FROM productos p
                 JOIN categorias_producto c ON p.categoria_id = c.id
                 WHERE p.id = :1 AND p.activo = 'T'`,
                [id],
                { 
                    outFormat: oracledb.OUT_FORMAT_OBJECT,
                    fetchInfo: { 
                        "DESCRIPCION": { type: oracledb.STRING } 
                    } 
                }
            );
    
            if (result.rows.length === 0) {
                throw new Error('Product not found');
            }
    
            const row = result.rows[0];
            return {
                id: row.ID,
                name: row.NOMBRE,
                description: row.DESCRIPCION || '',
                price: row.PRECIO,
                category: row.CATEGORIA,
                stock: row.STOCK
            };
        } finally {
            if (connection) {
                await connection.close();
            }
        }
    }
    
    static async createProduct(productData) {
        let connection;
        try {
            connection = await getConnection();
            
            // Verificar categoría
            const categoryResult = await connection.execute(
                `SELECT id FROM categorias_producto WHERE nombre = :1`,
                [productData.category]
            );
            
            if (categoryResult.rows.length === 0) {
                throw new Error('Category not found');
            }
            
            const categoryId = categoryResult.rows[0][0];
            
            // Generar SKU
            const generateRandomSKU = () => {
                const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
                const chars = Array.from({length: 3}, () => letters.charAt(Math.floor(Math.random() * letters.length))).join('');
                const numbers = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
                return `${chars}${numbers}`;
            };
    
            let sku;
            let skuExists;
            do {
                sku = generateRandomSKU();
                const checkSku = await connection.execute(
                    `SELECT 1 FROM productos WHERE sku = :1`,
                    [sku]
                );
                skuExists = checkSku.rows.length > 0;
            } while (skuExists);
            
            // Insertar producto
            const result = await connection.execute(
                `INSERT INTO productos 
                 (id, sku, nombre, descripcion, precio, categoria_id, slug, activo) 
                 VALUES 
                 (seq_productos.NEXTVAL, :1, :2, :3, :4, :5, :6, 'T')
                 RETURNING id INTO :7`,
                [
                    sku,
                    productData.name,
                    productData.description,
                    productData.price,
                    categoryId,
                    productData.name.toLowerCase().replace(/ /g, '-'),
                    { type: oracledb.NUMBER, dir: oracledb.BIND_OUT }
                ]
            );
    
            const productId = result.outBinds[0][0];
    
            // Insertar stock inicial en inventario
            if (productData.stock > 0) {
                await connection.execute(
                    `INSERT INTO inventario (id, producto_id, sede_id, cantidad)
                     VALUES (seq_inventario.NEXTVAL, :1, 1, :2)`,
                    [productId, productData.stock]
                );
            }
    
            await connection.commit();
            return productId;
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
    
    static async updateProduct(id, productData) {
        let connection;
        try {
            connection = await getConnection();
            
            if (productData.price) {
                await connection.execute(
                    `UPDATE productos 
                     SET precio = :1
                     WHERE id = :2 AND activo = 'T'`,
                    [productData.price, id]
                );
            }
    
            if (productData.stock !== undefined) {
                const inventoryResult = await connection.execute(
                    `SELECT id FROM inventario WHERE producto_id = :1 AND sede_id = 1`,
                    [id]
                );
    
                if (inventoryResult.rows.length > 0) {
                    await connection.execute(
                        `UPDATE inventario 
                         SET cantidad = :1
                         WHERE producto_id = :2 AND sede_id = 1`,
                        [productData.stock, id]
                    );
                } else {
                    await connection.execute(
                        `INSERT INTO inventario (id, producto_id, sede_id, cantidad)
                         VALUES (seq_inventario.NEXTVAL, :1, 1, :2)`,
                        [id, productData.stock]
                    );
                }
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

    static async deleteProduct(id) {
        let connection;
        try {
            connection = await getConnection();
            
            const result = await connection.execute(
                `UPDATE productos SET activo = 'F' WHERE id = :1`,
                [id]
            );
            
            if (result.rowsAffected === 0) {
                throw new Error('Product not found');
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

}

module.exports = ProductModel;