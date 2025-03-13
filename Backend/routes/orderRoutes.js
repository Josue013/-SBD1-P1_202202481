const express = require('express');
const OrderController = require('../controllers/orderController');
const router = express.Router();

router.post('/orders', OrderController.createOrder);
router.get('/orders', OrderController.getOrders);
router.get('/orders/:id', OrderController.getOrderDetails);

module.exports = router;