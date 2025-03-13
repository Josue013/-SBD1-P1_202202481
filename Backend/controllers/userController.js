const UserModel = require('../models/userModel');
const jwt = require('jsonwebtoken');

class UserController {
    static async register(req, res) {
        try {
            const userData = req.body;
            const user = await UserModel.createUser(userData);
            
            const token = jwt.sign(
                { id: user.id, email: user.email },
                process.env.SECRET_KEY,
                { expiresIn: '24h' }
            );

            res.status(201).json({
                status: 'success',
                data: { ...user, token }
            });
        } catch (error) {
            res.status(400).json({
                status: 'error',
                message: error.message
            });
        }
    }

    static async login(req, res) {
        try {
            const { email, password } = req.body;
            const user = await UserModel.loginUser(email, password);
            
            const token = jwt.sign(
                { id: user.id, email: user.email },
                process.env.SECRET_KEY,
                { expiresIn: '24h' }
            );

            res.json({
                status: 'success',
                data: { ...user, token }
            });
        } catch (error) {
            res.status(401).json({
                status: 'error',
                message: error.message
            });
        }
    }
}

module.exports = UserController;