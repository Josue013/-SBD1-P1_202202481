const UserModel = require('../models/userModel');

class UserController {
    static async register(req, res) {
        try {
            const userData = req.body;
            const user = await UserModel.createUser(userData);
            
            res.status(201).json({
                status: 'success',
                data: user
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
            
            res.json({
                status: 'success',
                message: user.message
            });
        } catch (error) {
            res.status(401).json({
                status: 'error',
                message: error.message
            });
        }
    }

    static async getProfile(req, res) {
        try {
            const userId = req.params.id;
            const user = await UserModel.getProfile(userId);
            
            res.json({
                id: user.id,
                nombre: user.nombres,
                apellido: user.apellidos,
                email: user.email,
                telefono: user.telefono,
                fecha_creacion: user.created_at
            });
        } catch (error) {
            res.status(404).json({
                status: 'error',
                message: error.message
            });
        }
    }

    static async updateUser(req, res) {
        try {
            const userId = req.params.id;
            const userData = req.body;
            await UserModel.updateUser(userId, userData);
            
            res.json({
                status: 'success',
                message: 'User updated successfully'
            });
        } catch (error) {
            if (error.message === 'User not found') {
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

    static async deleteUser(req, res) {
        try {
            const userId = req.params.id;
            await UserModel.deleteUser(userId);
            
            res.json({
                status: 'success',
                message: 'Se inactivó el usuario correctamente'
            });
        } catch (error) {
            res.status(500).json({
                status: 'error',
                message: error.message
            });
        }
    }
}

module.exports = UserController;