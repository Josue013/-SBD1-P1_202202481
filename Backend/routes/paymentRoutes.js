const express = require('express');
const PaymentController = require('../controllers/paymentController');
const router = express.Router();

router.post('/payments', PaymentController.createPayment);
router.get('/payments', PaymentController.getPayments);

module.exports = router;