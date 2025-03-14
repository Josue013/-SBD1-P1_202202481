const { getConnection } = require('../config/database');
const oracledb = require('oracledb');

class OrderModel {
    static async createOrder(clienteId, items, sedeId) {
        let connection;
        try {
            connection = await getConnection();
            
            // Crear orden (sin estado_id)
            const orderResult = await connection.execute(
                `INSERT INTO ordenes (id, cliente_id, sede_id) 
                 VALUES (seq_ordenes.NEXTVAL, :1, :2)
                 RETURNING id INTO :3`,
                [
                    clienteId, 
                    sedeId, 
                    { type: oracledb.NUMBER, dir: oracledb.BIND_OUT }
                ]
            );
            
            const orderId = orderResult.outBinds[0][0];
            
            // Insertar productos de la orden
            for (const item of items) {
                await connection.execute(
                    `INSERT INTO ordenes_productos (id, orden_id, producto_id, cantidad, precio)
                     VALUES (seq_ordenes_productos.NEXTVAL, :1, :2, :3, :4)`,
                    [orderId, item.productoId, item.cantidad, item.precio]
                );
            }
            
            await connection.commit();
            return orderId;
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

    static async getOrders(clienteId = null) {
        let connection;
        try {
            connection = await getConnection();
            
            let query = `
                SELECT o.id as orderId,
                       o.cliente_id as userId,
                       o.created_at as createdAt,
                       SUM(op.cantidad * op.precio) as totalAmount
                FROM ordenes o
                JOIN ordenes_productos op ON o.id = op.orden_id
                ${clienteId ? 'WHERE o.cliente_id = :1' : ''}
                GROUP BY o.id, o.cliente_id, o.created_at
                ORDER BY o.created_at DESC
            `;
            
            const result = await connection.execute(
                query,
                clienteId ? [clienteId] : [],
                { outFormat: oracledb.OUT_FORMAT_OBJECT }
            );
    
            return {
                orders: result.rows.map(row => ({
                    orderId: row.ORDERID,
                    userId: row.USERID,
                    totalAmount: row.TOTALAMOUNT,
                    createdAt: row.CREATEDAT
                }))
            };
        } finally {
            if (connection) {
                await connection.close();
            }
        }
    }

    static async getOrderDetails(orderId) {
        let connection;
        try {
            connection = await getConnection();
            
            const orderResult = await connection.execute(
                `SELECT o.id, o.cliente_id, o.sede_id, 
                        c.nombres || ' ' || c.apellidos as cliente,
                        s.nombre as sede,
                        o.created_at
                 FROM ordenes o
                 JOIN clientes c ON o.cliente_id = c.id
                 JOIN sedes s ON o.sede_id = s.id
                 WHERE o.id = :1`,
                [orderId]
            );
            
            if (orderResult.rows.length === 0) {
                throw new Error('Order not found');
            }
            
            const productsResult = await connection.execute(
                `SELECT p.id, p.nombre, op.cantidad, op.precio,
                        (op.cantidad * op.precio) as subtotal
                 FROM ordenes_productos op
                 JOIN productos p ON op.producto_id = p.id
                 WHERE op.orden_id = :1`,
                [orderId]
            );
            
            const order = orderResult.rows[0];
            const products = productsResult.rows.map(row => ({
                productoId: row[0],
                nombre: row[1],
                cantidad: row[2],
                precio: row[3],
                subtotal: row[4]
            }));
            
            return {
                id: order[0],
                clienteId: order[1],
                sedeId: order[2],
                cliente: order[3],
                sede: order[4],
                fecha: order[5],
                productos: products,
                total: products.reduce((sum, p) => sum + p.subtotal, 0)
            };
        } finally {
            if (connection) {
                await connection.close();
            }
        }
    }
}

module.exports = OrderModel;