const { getConnection } = require('../config/database');

class PaymentModel {
    static async createPayment(ordenId, metodoPagoId) {
        let connection;
        try {
            connection = await getConnection();
            
            // Obtener clienteId y total de la orden
            const orderResult = await connection.execute(
                `SELECT o.cliente_id, SUM(op.cantidad * op.precio) as total
                 FROM ordenes o
                 JOIN ordenes_productos op ON o.id = op.orden_id
                 WHERE o.id = :1
                 GROUP BY o.cliente_id`,
                [ordenId]
            );
            
            if (orderResult.rows.length === 0) {
                throw new Error('Order not found');
            }
            
            const clienteId = orderResult.rows[0][0];
            
            // Crear pago
            const paymentResult = await connection.execute(
                `INSERT INTO pagos (cliente_id, metodo_pago_id)
                 VALUES (:1, :2)
                 RETURNING id INTO :3`,
                [clienteId, metodoPagoId, { type: connection.NUMBER, dir: connection.BIND_OUT }]
            );
            
            const pagoId = paymentResult.outBinds[0][0];
            
            // Crear relación pago-orden
            await connection.execute(
                `INSERT INTO pagos_ordenes (orden_id, metodo_pago_id, estado_id)
                 VALUES (:1, :2, :3)`,
                [ordenId, metodoPagoId, 1] // 1 = estado inicial del pago
            );
            
            await connection.commit();
            return pagoId;
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

    static async getPayments(clienteId = null) {
        let connection;
        try {
            connection = await getConnection();
            
            let query = `
                SELECT p.id, p.cliente_id, p.metodo_pago_id,
                       c.nombres || ' ' || c.apellidos as cliente,
                       mp.nombre as metodo_pago,
                       po.orden_id,
                       ep.nombre as estado,
                       p.created_at
                FROM pagos p
                JOIN clientes c ON p.cliente_id = c.id
                JOIN metodos_pago mp ON p.metodo_pago_id = mp.id
                JOIN pagos_ordenes po ON p.id = po.orden_id
                JOIN estados_pago ep ON po.estado_id = ep.id
            `;
            
            const params = [];
            if (clienteId) {
                query += ' WHERE p.cliente_id = :1';
                params.push(clienteId);
            }
            
            const result = await connection.execute(query, params);
            
            return result.rows.map(row => ({
                id: row[0],
                clienteId: row[1],
                metodoPagoId: row[2],
                cliente: row[3],
                metodoPago: row[4],
                ordenId: row[5],
                estado: row[6],
                fecha: row[7]
            }));
        } finally {
            if (connection) {
                await connection.close();
            }
        }
    }
}

module.exports = PaymentModel;