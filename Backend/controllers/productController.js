const ProductModel = require('../models/productModel');

class ProductController {
    static async getProducts(req, res) {
        try {
            const products = await ProductModel.getProducts();
            res.json({
                products: products
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
                id: product.id,
                name: product.name,
                description: product.description,
                price: product.price,
                category: product.category,
                stock: product.stock
            });
        } catch (error) {
            res.status(404).json({
                status: 'error',
                message: error.message
            });
        }
    }

    static async createProduct(req, res) {
        try {
            const productId = await ProductModel.createProduct(req.body);
            res.status(201).json({
                status: 'success',
                message: 'Product created successfully',
                productId: productId
            });
        } catch (error) {
            res.status(400).json({
                status: 'error',
                message: error.message
            });
        }
    }

    static async updateProduct(req, res) {
        try {
            await ProductModel.updateProduct(req.params.id, req.body);
            res.json({
                status: 'success',
                message: 'Product updated successfully'
            });
        } catch (error) {
            if (error.message === 'Product not found') {
                res.status(404).json({
                    status: 'error',
                    message: error.message
                });
            } else {
                res.status(400).json({
                    status: 'error',
                    message: error.message
                });
            }
        }
    }

    static async deleteProduct(req, res) {
        try {
            await ProductModel.deleteProduct(req.params.id);
            res.json({
                status: 'success',
                message: 'Product deleted successfully'
            });
        } catch (error) {
            if (error.message === 'Product not found') {
                res.status(404).json({
                    status: 'error',
                    message: error.message
                });
            } else {
                res.status(500).json({
                    status: 'error',
                    message: error.message
                });
            }
        }
    }

}

module.exports = ProductController;