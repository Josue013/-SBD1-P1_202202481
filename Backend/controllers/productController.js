const ProductModel = require('../models/productModel');

class ProductController {
    static async getProducts(req, res) {
        try {
            const products = await ProductModel.getProducts();
            res.json({
                status: 'success',
                data: products
            });
        } catch (error) {
            res.status(500).json({
                status: 'error',
                message: error.message
            });
        }
    }

    static async getProductById(req, res) {
        try {
            const product = await ProductModel.getProductById(req.params.id);
            res.json({
                status: 'success',
                data: product
            });
        } catch (error) {
            res.status(404).json({
                status: 'error',
                message: error.message
            });
        }
    }
}

module.exports = ProductController;