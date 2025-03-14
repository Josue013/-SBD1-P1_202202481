
---
---
---

<h1 align="center">MANUAL USUARIO</h1>
  <p align="center"><strong>NOMBRE:</strong> JOSUÉ NABÍ HURTARTE PINTO</p>
  <p align="center"><strong>CARNET:</strong> 202202481</p>
  <p align="center">LAB. SISTEMAS DE BASES DE DATOS 1</p>
  <p align="center"><strong>SECCIÓN:</strong> "B"</p>


---
---
---

## <a name="indice">📅 INDICE

|     | Titulo                                             | Link         |
| --- | -------------------------------------------------- | ------------ |
| 1   | `Introducción`                                     | [IR](#intro) |
| 2   | `Requerimientos minimos del entorno de desarrollo` | [IR](#req)   |
| 3   | `Correr proyecto`                                  | [IR](#run)   |
| 4   | `Consumir api`                                     | [IR](#api)   |

## <a name="intro">📄 Introducción
<p align="justify">
El siguiente proyecto consiste en el diseño y desarrollo de una base de datos relacional eficiente y normalizada para la gestión de una empresa de ventas y distribución en línea. Se implementarán procesos de normalización, carga masiva de datos desde archivos CSV e integración con una API. 
</p>

## <a name="req">⚙️ Requerimientos minimos del entorno de desarrollo

> [!IMPORTANT]
> Necesitarás:
> - Node.js 14.x o superior
> - Docker Desktop
> - Oracle Instant Client
> - Editor de código (recomendado VS Code)
> - Gestor de paquetes npm
> - Git (opcional, para control de versiones)

### 1. Configurar Oracle en Docker

```
// Buscar la imagen oficial de Oracle en Docker Hub
docker search oracle/database 
// Descargar la imagen
docker pull gvenzl/oracle-xe 
// Crear y ejecutar un contenedor de Oracle
docker run -d --name oracle-xe -p 1521:1521 -p 5500:5500 -e ORACLE_PASSWORD=your_password gvenzl/oracle-xe 
```

### 2. Conectar a la base de datos

En mi caso me conecte a la base de datos usando datagript.

Los datos para conectarse:

- **Host:** localhost
- **Puerto:** 1521
- **SID:** XE
- **Usuario:** SYSTEM
- **Contraseña:** La que especificaste en `ORACLE_PASSWORD`.

### 3. Configurar Backend

1. Instala las dependencias:
```sh
cd Backend
npm install
```

2. Configura las variables de entorno:
```sh
# Crea archivo .env con estas variables
ORACLE_USER=system
ORACLE_PASSWORD=oracle123
ORACLE_DSN=localhost:1521/XE
```

3. Inicia el servidor:
```sh
npm start
```

### 4. Verificar instalación

Puedes probar que todo funcione haciendo una petición GET a:
```
http://localhost:3000/api/test-connection
```

Si recibes el timestamp actual de la base de datos, ¡todo está funcionando correctamente!

> [!NOTE]
> Para detener todo:
> 1. Detén el servidor Node con Ctrl+C
> 2. Detén el contenedor: `docker stop oracle_db`
> 3. Para reiniciar posteriormente: `docker start oracle_db`

## <a name="api">📅 Consumir api

Endpoints Funcionales de la API

### 1 Gestión de Usuarios

> 1.1 Crear Usuario (Registro) (POST)
 - Endpoint: `/api/users` 
 - Descripción: Crea un nuevo usuario en la plataforma. 
 - Request (JSON): 
```json
{
  "documento_identidad": "3128365900101",
  "nombres": "Josue",
  "apellidos": "Hurtarte",
  "password": "tu_contraseña",
  "email": "josue013@email.com",
  "telefono": "55511111"
}
```
- Response (JSON):
```json
{
  "status": "success",
  "message": "User created successfully"
}
```

> 1.2 Iniciar Sesión (Login) (POST) 

- Endpoint: `/api/users/login` 
- Descripción: Autentica un usuario comparando la contraseña con el hash 
almacenado. 
- Request (JSON):

```json
{
  "email": "moy@email.com",
  "password": "tu_contraseña"
}
```
- Response (JSON):
```json
{
  "status": "success",
  "message": "User authenticated successfully"
}
```

> 1.3 Obtener Perfil de Usuario (GET)

- Endpoint: `/api/users/:id` 
- Descripción: Obtiene la información de un usuario específico (datos básicos, sin exponer contraseña).
- Request: 
   - Parámetro :id en la URL. 
- Response (JSON):
```json
{
  "id": 3,
  "nombre": "Pedro",
  "apellido": "López",
  "email": "pedro.lopez@mail.com",
  "telefono": "55533333",
  "fecha_creacion": "2025-03-13T10:17:03.488Z"
}
```

> 1.4 Actualizar Usuario (PUT)

- Endpoint: `/api/users/:id` 
- Descripción: Modifica los datos de un usuario (excepto la contraseña, que podría ser otro endpoint separado). 
- Request (JSON) (campos a actualizar):
```json
{ 
  "phone": "87654321", 
  "email": "john@example.com" 
} 
```

Response (JSON):
```json
{ 
  "status": "success", 
  "message": "User updated successfully"
} 
```

> 1.5 Eliminar Usuario (DELETE)

- Endpoint: `/api/users/:id` 
- Descripción: Elimina un usuario o lo marca como inactivo. 
- Response (JSON): 
```json
{ 
  "status": "success", 
  "message": "Se inactivó el usuario correctamente"
} 
```

### 2 Gestión de Productos

> 2.1 Listar Productos (GET)

- Endpoint: `/api/products`
- Descripción: Retorna la lista de productos activos con su stock.
- Response (JSON):
```json
{
  "products": [
    {
      "id": 1,
      "name": "Laptop HP",
      "price": 5000.00,
      "stock": 10
    },
    {
      "id": 2,
      "name": "Smartphone Samsung",
      "price": 2500.00,
      "stock": 20
    }
  ]
}
```

> 2.2 Detalle de Producto (GET)

- Endpoint: `/api/products/:id`
- Descripción: Obtiene el detalle completo de un producto específico.
- Request: Parámetro :id en la URL
- Response (JSON):
```json
{
  "id": 1,
  "name": "Laptop HP",
  "description": "Laptop de alto rendimiento",
  "price": 5000.00,
  "category": "Electrónicos",
  "stock": 10
}
```

> 2.3 Crear Producto (POST)

- Endpoint: `/api/products`
- Descripción: Crea un nuevo producto en el sistema.
- Request (JSON):
```json
{
  "name": "Laptop X",
  "description": "Laptop de alto rendimiento",
  "price": 750.00,
  "category": "Electrónicos"
}
```
- Response (JSON):
```json
{
  "status": "success",
  "message": "Product created successfully",
  "productId": 1
}
```

> 2.4 Actualizar Producto (PUT)

- Endpoint: `/api/products/:id`
- Descripción: Actualiza el precio de un producto existente.
- Request (JSON):
```json
{
  "price": 700.00,
  "stock": 15
}
```
- Response (JSON):
```json
{
  "status": "success",
  "message": "Product updated successfully"
}
```

> 2.5 Eliminar Producto (DELETE)

- Endpoint: `/api/products/:id`
- Descripción: Marca un producto como inactivo.
- Response (JSON):
```json
{
  "status": "success",
  "message": "Product deleted successfully"
}
```


### 3 Gestión de Órdenes

> 3.1 Crear Orden (POST)

- Endpoint: `/api/orders`
- Descripción: Crea una nueva orden de compra.
- Request (JSON):
```json
{
  "clienteId": 1,
  "sedeId": 1,
  "items": [
    {
      "productoId": 1,
      "cantidad": 2,
      "precio": 5000.00
    },
    {
      "productoId": 2,
      "cantidad": 1,
      "precio": 2500.00
    }
  ]
}
```

- Response (JSON):
```json
{
  "status": "success",
  "data": {
    "orderId": 1
  }
}
```

> 3.2 Listar Órdenes (GET)

- Endpoint: `/api/orders`
- Descripción: Obtiene la lista de órdenes.
- Query Parameters: `clienteId` (opcional)
- Response (JSON):
```json
{
  "orders": [
    {
      "orderId": 11,
      "userId": 1,
      "totalAmount": 12500,
      "createdAt": "2025-03-14T20:39:37.219Z"
    },
    {
      "orderId": 9,
      "userId": 9,
      "totalAmount": 600,
      "createdAt": "2025-03-13T10:30:49.887Z"
    }
  ]
}
```

> 3.3 Detalle de Orden (GET)

- Endpoint: `/api/orders/:id`
- Descripción: Obtiene el detalle completo de una orden.
- Response (JSON):
```json
{
  "status": "success",
  "data": {
    "id": 2,
    "clienteId": 2,
    "sedeId": 1,
    "cliente": "María García",
    "sede": "Sede Central Guatemala",
    "fecha": "2025-03-13T10:30:49.587Z",
    "productos": [
      {
        "productoId": 3,
        "nombre": "Tablet Lenovo",
        "cantidad": 2,
        "precio": 1800,
        "subtotal": 3600
      }
    ],
    "total": 3600
  }
}
```

### 4 Gestión de Pagos 

> 4.1 Registrar Pago (POST)

- Endpoint: `/api/payments`
- Descripción: Registra un pago para una orden.
- Request (JSON):
```json
{
  "ordenId": 1,
  "metodoPagoId": 1
}
```
- Response (JSON):
```json
{
  "status": "success",
  "data": {
    "paymentId": 1
  }
}
```
> 4.2 Listar Pagos (GET)

- Endpoint: `/api/payments`
- Descripción: Obtiene la lista de pagos realizados.
- Query Parameters: `clienteId` (opcional)
- Response (JSON):
```json
{
  "payments": [
    {
      "id": 1,
      "clienteId": 1,
      "metodoPagoId": 1,
      "cliente": "Juan Pérez",
      "metodoPago": "CREDIT VISA",
      "ordenId": 1,
      "estado": "PAID",
      "fecha": "2025-03-13T10:30:50.643Z"
    },
    {
      "id": 1,
      "clienteId": 1,
      "metodoPagoId": 1,
      "cliente": "Juan Pérez",
      "metodoPago": "CREDIT VISA",
      "ordenId": 1,
      "estado": "PAID",
      "fecha": "2025-03-13T10:30:50.643Z"
    }
  ]
}
```
