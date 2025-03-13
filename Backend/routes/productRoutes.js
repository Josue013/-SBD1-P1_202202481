const express = require('express');
const ProductController = require('../controllers/productController');

const router = express.Router();

// Ruta para obtener todos los productos
router.get('/products', ProductController.getProducts);

// Ruta para obtener un producto por ID
router.get('/products/:id', ProductController.getProductById);

module.exports = router;
