
---
---
---

<h1 align="center">MANUAL USUARIO</h1>
  <p align="center"><strong>NOMBRE:</strong> JOSUÉ NABÍ HURTARTE PINTO</p>
  <p align="center"><strong>CARNET:</strong> 202202481</p>
  <p align="center">LAB. REDES DE COMPUTADORAS 1</p>
  <p align="center"><strong>SECCIÓN:</strong> "A"</p>


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
 - Endpoint: /api/users 
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

- Endpoint: /api/users/login 
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

- Endpoint: /api/users/:id 
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

- Endpoint: /api/users/:id 
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

- Endpoint: /api/users/:id 
- Descripción: Elimina un usuario o lo marca como inactivo. 
- Response (JSON): 
```json
{ 
  "status": "success", 
  "message": "Se inactivó el usuario correctamente"
} 

