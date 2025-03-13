const PaymentModel = require('../models/paymentModel');

class PaymentController {
    static async createPayment(req, res) {
        try {
            const { ordenId, metodoPagoId } = req.body;
            const paymentId = await PaymentModel.createPayment(ordenId, metodoPagoId);
            
            res.status(201).json({
                status: 'success',
                data: {
                    paymentId: paymentId
                }
            });
        } catch (error) {
            res.status(400).json({
                status: 'error',
                message: error.message
            });
        }
    }

    static async getPayments(req, res) {
        try {
            const { clienteId } = req.query;
            const payments = await PaymentModel.getPayments(clienteId);
            
            res.json({
                status: 'success',
                data: payments
            });
        } catch (error) {
            res.status(500).json({
                status: 'error',
                message: error.message
            });
        }
    }
}

module.exports = PaymentController;