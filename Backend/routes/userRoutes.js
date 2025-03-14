
const express = require('express');
const UserController = require('../controllers/userController');

const router = express.Router();

router.post('/users', UserController.register);
router.post('/users/login', UserController.login);
router.get('/users/:id', UserController.getProfile);
router.put('/users/:id', UserController.updateUser);
router.delete('/users/:id', UserController.deleteUser);

module.exports = router;