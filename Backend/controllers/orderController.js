const OrderModel = require('../models/orderModel');

class OrderController {
    static async createOrder(req, res) {
        try {
            const { clienteId, items, sedeId } = req.body;
            const orderId = await OrderModel.createOrder(clienteId, items, sedeId);
            
            res.status(201).json({
                status: 'success',
                data: {
                    orderId: orderId
                }
            });
        } catch (error) {
            res.status(400).json({
                status: 'error',
                message: error.message
            });
        }
    }

    static async getOrders(req, res) {
        try {
            const { clienteId } = req.query;
            const orders = await OrderModel.getOrders(clienteId);
            
            res.json({
                status: 'success',
                data: orders
            });
        } catch (error) {
            res.status(500).json({
                status: 'error',
                message: error.message
            });
        }
    }

    static async getOrderDetails(req, res) {
        try {
            const orderId = req.params.id;
            const order = await OrderModel.getOrderDetails(orderId);
            
            res.json({
                status: 'success',
                data: order
            });
        } catch (error) {
            res.status(404).json({
                status: 'error',
                message: error.message
            });
        }
    }
}

module.exports = OrderController;