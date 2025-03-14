-- Tablas Catálogo/Estados
CREATE TABLE estados_orden (
    id NUMBER PRIMARY KEY,
    nombre VARCHAR2(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE estados_devolucion (
    id NUMBER PRIMARY KEY,
    nombre VARCHAR2(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE estados_movimiento (
    id NUMBER PRIMARY KEY,
    nombre VARCHAR2(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE estados_pago (
    id NUMBER PRIMARY KEY,
    nombre VARCHAR2(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tablas Auxiliares
CREATE TABLE departamentos (
    id NUMBER PRIMARY KEY,
    nombre VARCHAR2(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE companias_envio (
    id NUMBER PRIMARY KEY,
    nombre VARCHAR2(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE metodos_pago (
    id NUMBER PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE categorias_producto (
    id NUMBER PRIMARY KEY,
    nombre VARCHAR2(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE info_direccion (
    id NUMBER PRIMARY KEY,
    calle VARCHAR2(255) NOT NULL,
    ciudad VARCHAR2(100) NOT NULL,
    estado VARCHAR2(2) NOT NULL,
    codigo_postal VARCHAR2(5) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sedes (
    id NUMBER PRIMARY KEY,
    nombre VARCHAR2(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tablas Principales
CREATE TABLE info_contacto_clientes (
    id NUMBER PRIMARY KEY,
    telefono VARCHAR2(50),
    email VARCHAR2(100) NOT NULL UNIQUE,
    activo VARCHAR2(1) DEFAULT 'F' CHECK (activo IN ('F','T')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE clientes (
    id NUMBER PRIMARY KEY,
    documento_identidad VARCHAR2(15) NOT NULL UNIQUE,
    nombres VARCHAR2(100) NOT NULL,
    apellidos VARCHAR2(100) NOT NULL,
    password VARCHAR2(100) NOT NULL,
    info_contacto_id NUMBER NOT NULL,
    email_confirmado VARCHAR2(1) DEFAULT 'F' CHECK (email_confirmado IN ('F','T')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cliente_info_contacto FOREIGN KEY (info_contacto_id) REFERENCES info_contacto_clientes(id)
);

CREATE TABLE info_contacto_trabajadores (
    id NUMBER PRIMARY KEY,
    telefono VARCHAR2(50),
    email VARCHAR2(100) NOT NULL UNIQUE,
    location_id NUMBER NOT NULL,
    activo VARCHAR2(1) DEFAULT 'F' CHECK (activo IN ('F','T')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_info_contacto_location FOREIGN KEY (location_id) REFERENCES sedes(id)
);

CREATE TABLE trabajadores (
    id NUMBER PRIMARY KEY,
    documento_identidad VARCHAR2(50) NOT NULL UNIQUE,
    nombres VARCHAR2(100) NOT NULL,
    apellidos VARCHAR2(100) NOT NULL,
    job VARCHAR2(100) NOT NULL,
    departamento_id NUMBER NOT NULL,
    info_contacto_id NUMBER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_trabajador_depto FOREIGN KEY (departamento_id) REFERENCES departamentos(id),
    CONSTRAINT fk_trabajador_info_contacto FOREIGN KEY (info_contacto_id) REFERENCES info_contacto_trabajadores(id)
);

CREATE TABLE productos (
    id NUMBER PRIMARY KEY,
    sku VARCHAR2(50) NOT NULL UNIQUE,
    nombre VARCHAR2(255) NOT NULL,
    descripcion CLOB,
    precio NUMBER(10,2) NOT NULL CHECK (precio > 0),
    slug VARCHAR2(255) UNIQUE,
    categoria_id NUMBER NOT NULL,
    activo VARCHAR2(1) DEFAULT 'F' CHECK (activo IN ('F','T')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_producto_categoria FOREIGN KEY (categoria_id) REFERENCES categorias_producto(id)
);

CREATE TABLE direcciones_cliente (
    id NUMBER PRIMARY KEY,
    cliente_id NUMBER NOT NULL,
    direccion_id NUMBER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_direccion_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    CONSTRAINT fk_direccion_info FOREIGN KEY (direccion_id) REFERENCES info_direccion(id)
);

CREATE TABLE imagenes_producto (
    id NUMBER PRIMARY KEY,
    producto_id NUMBER NOT NULL,
    url_imagen VARCHAR2(500) NOT NULL,
    orden NUMBER DEFAULT 1, -- borar --
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_imagen_producto FOREIGN KEY (producto_id) REFERENCES productos(id)
);

CREATE TABLE inventario (
    id NUMBER PRIMARY KEY,
    producto_id NUMBER NOT NULL,
    sede_id NUMBER NOT NULL,
    cantidad NUMBER NOT NULL CHECK (cantidad >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_inventario_producto FOREIGN KEY (producto_id) REFERENCES productos(id),
    CONSTRAINT fk_inventario_sede FOREIGN KEY (sede_id) REFERENCES sedes(id),
    CONSTRAINT uk_producto_sede UNIQUE (producto_id, sede_id)
);

CREATE TABLE ordenes (
    id NUMBER PRIMARY KEY,
    cliente_id NUMBER NOT NULL,
    sede_id NUMBER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_orden_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    CONSTRAINT fk_orden_sede FOREIGN KEY (sede_id) REFERENCES sedes(id)
);

CREATE TABLE ordenes_productos (
    id NUMBER PRIMARY KEY,
    orden_id NUMBER NOT NULL,
    producto_id NUMBER NOT NULL,
    cantidad NUMBER NOT NULL CHECK (cantidad > 0),
    precio NUMBER(10,2) NOT NULL CHECK (precio > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_orden_producto_orden FOREIGN KEY (orden_id) REFERENCES ordenes(id),
    CONSTRAINT fk_orden_producto_producto FOREIGN KEY (producto_id) REFERENCES productos(id)
);

CREATE TABLE ordenes_entregadas (
    id NUMBER PRIMARY KEY,
    orden_id NUMBER NOT NULL,
    compania_envio_id NUMBER NOT NULL,
    direccion_id NUMBER NOT NULL,
    numero_guia VARCHAR2(100) NOT NULL,
    estado_id NUMBER NOT NULL,
    fecha_entrega TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_entrega_orden FOREIGN KEY (orden_id) REFERENCES ordenes(id),
    CONSTRAINT fk_entrega_compania FOREIGN KEY (compania_envio_id) REFERENCES companias_envio(id),
    CONSTRAINT fk_entrega_direccion FOREIGN KEY (direccion_id) REFERENCES info_direccion(id),
    CONSTRAINT fk_entrega_estado FOREIGN KEY (estado_id) REFERENCES estados_orden(id)
);

CREATE TABLE pagos (
    id NUMBER PRIMARY KEY,
    cliente_id NUMBER NOT NULL,
    metodo_pago_id NUMBER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pago_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    CONSTRAINT fk_pago_metodo FOREIGN KEY (metodo_pago_id) REFERENCES metodos_pago(id)
);

CREATE TABLE pagos_ordenes (
    id NUMBER PRIMARY KEY,
    orden_id NUMBER NOT NULL,
    metodo_pago_id NUMBER NOT NULL,
    estado_id NUMBER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pago_orden_orden FOREIGN KEY (orden_id) REFERENCES ordenes(id),
    CONSTRAINT fk_pago_orden_metodo FOREIGN KEY (metodo_pago_id) REFERENCES metodos_pago(id),
    CONSTRAINT fk_pago_orden_estado FOREIGN KEY (estado_id) REFERENCES estados_pago(id)

);

CREATE TABLE devoluciones_productos (
    id NUMBER PRIMARY KEY,
    orden_producto_id NUMBER NOT NULL,
    descripcion CLOB,
    estado_id NUMBER NOT NULL,
    fecha_solicitud TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_devolucion_orden_producto FOREIGN KEY (orden_producto_id) REFERENCES ordenes_productos(id),
    CONSTRAINT fk_devolucion_estado FOREIGN KEY (estado_id) REFERENCES estados_devolucion(id)
);

CREATE TABLE movimientos (
    id NUMBER PRIMARY KEY,
    sede_origen_id NUMBER NOT NULL,
    sede_destino_id NUMBER NOT NULL,
    estado_id NUMBER NOT NULL,
    fecha_estimada_llegada TIMESTAMP,
    fecha_solicitud TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_movimiento_origen FOREIGN KEY (sede_origen_id) REFERENCES sedes(id),
    CONSTRAINT fk_movimiento_destino FOREIGN KEY (sede_destino_id) REFERENCES sedes(id),
    CONSTRAINT fk_movimiento_estado FOREIGN KEY (estado_id) REFERENCES estados_movimiento(id),
    CONSTRAINT chk_sedes_diferentes CHECK (sede_origen_id != sede_destino_id)
);

CREATE TABLE movimientos_productos (
    id NUMBER PRIMARY KEY,
    movimiento_id NUMBER NOT NULL,
    producto_id NUMBER NOT NULL,
    cantidad NUMBER NOT NULL CHECK (cantidad > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_movimiento_producto_mov FOREIGN KEY (movimiento_id) REFERENCES movimientos(id),
    CONSTRAINT fk_movimiento_producto_prod FOREIGN KEY (producto_id) REFERENCES productos(id)
);


-- ************ INSERTANDO 10 DATOS ************* --

-- Departamentos
INSERT INTO departamentos (id, nombre) VALUES (1, 'Ventas');
INSERT INTO departamentos (id, nombre) VALUES (2, 'Almacén');
INSERT INTO departamentos (id, nombre) VALUES (3, 'Logística');
INSERT INTO departamentos (id, nombre) VALUES (4, 'Atención al Cliente');
INSERT INTO departamentos (id, nombre) VALUES (5, 'Recursos Humanos');
INSERT INTO departamentos (id, nombre) VALUES (6, 'Contabilidad');
INSERT INTO departamentos (id, nombre) VALUES (7, 'Marketing');
INSERT INTO departamentos (id, nombre) VALUES (8, 'Sistemas');
INSERT INTO departamentos (id, nombre) VALUES (9, 'Mantenimiento');
INSERT INTO departamentos (id, nombre) VALUES (10, 'Gerencia');

-- Compañías de envío
INSERT INTO companias_envio (id, nombre) VALUES (1, 'Guatex');
INSERT INTO companias_envio (id, nombre) VALUES (2, 'DHL Guatemala');
INSERT INTO companias_envio (id, nombre) VALUES (3, 'Cargo Expreso');
INSERT INTO companias_envio (id, nombre) VALUES (4, 'FedEx Guatemala');
INSERT INTO companias_envio (id, nombre) VALUES (5, 'UPS Guatemala');
INSERT INTO companias_envio (id, nombre) VALUES (6, 'Sertran');
INSERT INTO companias_envio (id, nombre) VALUES (7, 'Blue Express');
INSERT INTO companias_envio (id, nombre) VALUES (8, 'King Express');
INSERT INTO companias_envio (id, nombre) VALUES (9, 'Flash Delivery');
INSERT INTO companias_envio (id, nombre) VALUES (10, 'Rapid Transit');

-- Categorías de producto
INSERT INTO categorias_producto (id, nombre) VALUES (1, 'Electrónicos');
INSERT INTO categorias_producto (id, nombre) VALUES (2, 'Ropa');
INSERT INTO categorias_producto (id, nombre) VALUES (3, 'Hogar');
INSERT INTO categorias_producto (id, nombre) VALUES (4, 'Deportes');
INSERT INTO categorias_producto (id, nombre) VALUES (5, 'Juguetes');
INSERT INTO categorias_producto (id, nombre) VALUES (6, 'Libros');
INSERT INTO categorias_producto (id, nombre) VALUES (7, 'Alimentos');
INSERT INTO categorias_producto (id, nombre) VALUES (8, 'Belleza');
INSERT INTO categorias_producto (id, nombre) VALUES (9, 'Mascotas');
INSERT INTO categorias_producto (id, nombre) VALUES (10, 'Jardín');

-- Info dirección
INSERT INTO info_direccion (id, calle, ciudad, estado, codigo_postal) VALUES (1, '6a Avenida 13-54', 'Guatemala', 'GT', '01001');
INSERT INTO info_direccion (id, calle, ciudad, estado, codigo_postal) VALUES (2, '7a Calle 15-23', 'Guatemala', 'GT', '01002');
INSERT INTO info_direccion (id, calle, ciudad, estado, codigo_postal) VALUES (3, 'Calzada Roosevelt 25-63', 'Guatemala', 'GT', '01003');
INSERT INTO info_direccion (id, calle, ciudad, estado, codigo_postal) VALUES (4, 'Boulevard Los Próceres 18-76', 'Guatemala', 'GT', '01004');
INSERT INTO info_direccion (id, calle, ciudad, estado, codigo_postal) VALUES (5, 'Avenida Petapa 42-51', 'Guatemala', 'GT', '01005');
INSERT INTO info_direccion (id, calle, ciudad, estado, codigo_postal) VALUES (6, '4a Calle 8-42', 'Mixco', 'GT', '01006');
INSERT INTO info_direccion (id, calle, ciudad, estado, codigo_postal) VALUES (7, 'Calzada San Juan 10-45', 'Mixco', 'GT', '01007');
INSERT INTO info_direccion (id, calle, ciudad, estado, codigo_postal) VALUES (8, 'Avenida Reforma 12-34', 'Guatemala', 'GT', '01008');
INSERT INTO info_direccion (id, calle, ciudad, estado, codigo_postal) VALUES (9, 'Diagonal 6 13-01', 'Guatemala', 'GT', '01009');
INSERT INTO info_direccion (id, calle, ciudad, estado, codigo_postal) VALUES (10, 'Calzada Atanasio 24-56', 'Villa Nueva', 'GT', '01010');

-- Sedes
INSERT INTO sedes (id, nombre) VALUES (1, 'Sede Central Guatemala');
INSERT INTO sedes (id, nombre) VALUES (2, 'Sede Zona 10');
INSERT INTO sedes (id, nombre) VALUES (3, 'Sede Zona 9');
INSERT INTO sedes (id, nombre) VALUES (4, 'Sede Mixco');
INSERT INTO sedes (id, nombre) VALUES (5, 'Sede Villa Nueva');
INSERT INTO sedes (id, nombre) VALUES (6, 'Sede Antigua Guatemala');
INSERT INTO sedes (id, nombre) VALUES (7, 'Sede Escuintla');
INSERT INTO sedes (id, nombre) VALUES (8, 'Sede Chimaltenango');
INSERT INTO sedes (id, nombre) VALUES (9, 'Sede Xela');
INSERT INTO sedes (id, nombre) VALUES (10, 'Sede Puerto Barrios');

-- Departamentos
INSERT INTO departamentos (id, nombre) VALUES (1, 'Ventas');
INSERT INTO departamentos (id, nombre) VALUES (2, 'Almacén');
INSERT INTO departamentos (id, nombre) VALUES (3, 'Logística');
INSERT INTO departamentos (id, nombre) VALUES (4, 'Atención al Cliente');
INSERT INTO departamentos (id, nombre) VALUES (5, 'Recursos Humanos');
INSERT INTO departamentos (id, nombre) VALUES (6, 'Contabilidad');
INSERT INTO departamentos (id, nombre) VALUES (7, 'Marketing');
INSERT INTO departamentos (id, nombre) VALUES (8, 'Sistemas');
INSERT INTO departamentos (id, nombre) VALUES (9, 'Mantenimiento');
INSERT INTO departamentos (id, nombre) VALUES (10, 'Gerencia');

-- Compañías de envío
INSERT INTO companias_envio (id, nombre) VALUES (1, 'Guatex');
INSERT INTO companias_envio (id, nombre) VALUES (2, 'DHL Guatemala');
INSERT INTO companias_envio (id, nombre) VALUES (3, 'Cargo Expreso');
INSERT INTO companias_envio (id, nombre) VALUES (4, 'FedEx Guatemala');
INSERT INTO companias_envio (id, nombre) VALUES (5, 'UPS Guatemala');
INSERT INTO companias_envio (id, nombre) VALUES (6, 'Sertran');
INSERT INTO companias_envio (id, nombre) VALUES (7, 'Blue Express');
INSERT INTO companias_envio (id, nombre) VALUES (8, 'King Express');
INSERT INTO companias_envio (id, nombre) VALUES (9, 'Flash Delivery');
INSERT INTO companias_envio (id, nombre) VALUES (10, 'Rapid Transit');

-- Categorías de producto
INSERT INTO categorias_producto (id, nombre) VALUES (1, 'Electrónicos');
INSERT INTO categorias_producto (id, nombre) VALUES (2, 'Ropa');
INSERT INTO categorias_producto (id, nombre) VALUES (3, 'Hogar');
INSERT INTO categorias_producto (id, nombre) VALUES (4, 'Deportes');
INSERT INTO categorias_producto (id, nombre) VALUES (5, 'Juguetes');
INSERT INTO categorias_producto (id, nombre) VALUES (6, 'Libros');
INSERT INTO categorias_producto (id, nombre) VALUES (7, 'Alimentos');
INSERT INTO categorias_producto (id, nombre) VALUES (8, 'Belleza');
INSERT INTO categorias_producto (id, nombre) VALUES (9, 'Mascotas');
INSERT INTO categorias_producto (id, nombre) VALUES (10, 'Jardín');

-- Info dirección
INSERT INTO info_direccion (id, calle, ciudad, estado, codigo_postal) VALUES (1, '6a Avenida 13-54', 'Guatemala', 'GT', '01001');
INSERT INTO info_direccion (id, calle, ciudad, estado, codigo_postal) VALUES (2, '7a Calle 15-23', 'Guatemala', 'GT', '01002');
INSERT INTO info_direccion (id, calle, ciudad, estado, codigo_postal) VALUES (3, 'Calzada Roosevelt 25-63', 'Guatemala', 'GT', '01003');
INSERT INTO info_direccion (id, calle, ciudad, estado, codigo_postal) VALUES (4, 'Boulevard Los Próceres 18-76', 'Guatemala', 'GT', '01004');
INSERT INTO info_direccion (id, calle, ciudad, estado, codigo_postal) VALUES (5, 'Avenida Petapa 42-51', 'Guatemala', 'GT', '01005');
INSERT INTO info_direccion (id, calle, ciudad, estado, codigo_postal) VALUES (6, '4a Calle 8-42', 'Mixco', 'GT', '01006');
INSERT INTO info_direccion (id, calle, ciudad, estado, codigo_postal) VALUES (7, 'Calzada San Juan 10-45', 'Mixco', 'GT', '01007');
INSERT INTO info_direccion (id, calle, ciudad, estado, codigo_postal) VALUES (8, 'Avenida Reforma 12-34', 'Guatemala', 'GT', '01008');
INSERT INTO info_direccion (id, calle, ciudad, estado, codigo_postal) VALUES (9, 'Diagonal 6 13-01', 'Guatemala', 'GT', '01009');
INSERT INTO info_direccion (id, calle, ciudad, estado, codigo_postal) VALUES (10, 'Calzada Atanasio 24-56', 'Villa Nueva', 'GT', '01010');

-- Sedes
INSERT INTO sedes (id, nombre) VALUES (1, 'Sede Central Guatemala');
INSERT INTO sedes (id, nombre) VALUES (2, 'Sede Zona 10');
INSERT INTO sedes (id, nombre) VALUES (3, 'Sede Zona 9');
INSERT INTO sedes (id, nombre) VALUES (4, 'Sede Mixco');
INSERT INTO sedes (id, nombre) VALUES (5, 'Sede Villa Nueva');
INSERT INTO sedes (id, nombre) VALUES (6, 'Sede Antigua Guatemala');
INSERT INTO sedes (id, nombre) VALUES (7, 'Sede Escuintla');
INSERT INTO sedes (id, nombre) VALUES (8, 'Sede Chimaltenango');
INSERT INTO sedes (id, nombre) VALUES (9, 'Sede Xela');
INSERT INTO sedes (id, nombre) VALUES (10, 'Sede Puerto Barrios');

-- Info contacto clientes
INSERT INTO info_contacto_clientes (id, telefono, email, activo) VALUES (1, '55511111', 'juan.perez@mail.com', 'T');
INSERT INTO info_contacto_clientes (id, telefono, email, activo) VALUES (2, '55522222', 'maria.garcia@mail.com', 'T');
INSERT INTO info_contacto_clientes (id, telefono, email, activo) VALUES (3, '55533333', 'pedro.lopez@mail.com', 'T');
INSERT INTO info_contacto_clientes (id, telefono, email, activo) VALUES (4, '55544444', 'ana.martinez@mail.com', 'T');
INSERT INTO info_contacto_clientes (id, telefono, email, activo) VALUES (5, '55555555', 'luis.gonzalez@mail.com', 'T');
INSERT INTO info_contacto_clientes (id, telefono, email, activo) VALUES (6, '55566666', 'carmen.rodriguez@mail.com', 'T');
INSERT INTO info_contacto_clientes (id, telefono, email, activo) VALUES (7, '55577777', 'jose.sanchez@mail.com', 'T');
INSERT INTO info_contacto_clientes (id, telefono, email, activo) VALUES (8, '55588888', 'laura.diaz@mail.com', 'T');
INSERT INTO info_contacto_clientes (id, telefono, email, activo) VALUES (9, '55599999', 'carlos.torres@mail.com', 'T');
INSERT INTO info_contacto_clientes (id, telefono, email, activo) VALUES (10, '55500000', 'sofia.ruiz@mail.com', 'T');

-- Clientes
INSERT INTO clientes (id, documento_identidad, nombres, apellidos, password, info_contacto_id, email_confirmado) VALUES (1, '2474589650101', 'Juan', 'Pérez', 'hash1', 1, 'T');
INSERT INTO clientes (id, documento_identidad, nombres, apellidos, password, info_contacto_id, email_confirmado) VALUES (2, '3157894560101', 'María', 'García', 'hash2', 2, 'T');
INSERT INTO clientes (id, documento_identidad, nombres, apellidos, password, info_contacto_id, email_confirmado) VALUES (3, '3079894560101', 'Pedro', 'López', 'hash3', 3, 'T');
INSERT INTO clientes (id, documento_identidad, nombres, apellidos, password, info_contacto_id, email_confirmado) VALUES (4, '2474580050101', 'Ana', 'Martínez', 'hash4', 4, 'T');
INSERT INTO clientes (id, documento_identidad, nombres, apellidos, password, info_contacto_id, email_confirmado) VALUES (5, '3157894410101', 'Luis', 'González', 'hash5', 5, 'T');
INSERT INTO clientes (id, documento_identidad, nombres, apellidos, password, info_contacto_id, email_confirmado) VALUES (6, '3029894410101', 'Carmen', 'Rodríguez', 'hash6', 6, 'T');
INSERT INTO clientes (id, documento_identidad, nombres, apellidos, password, info_contacto_id, email_confirmado) VALUES (7, '3029123410101', 'José', 'Sánchez', 'hash7', 7, 'T');
INSERT INTO clientes (id, documento_identidad, nombres, apellidos, password, info_contacto_id, email_confirmado) VALUES (8, '3029123442101', 'Laura', 'Díaz', 'hash8', 8, 'T');
INSERT INTO clientes (id, documento_identidad, nombres, apellidos, password, info_contacto_id, email_confirmado) VALUES (9, '2229123442101', 'Carlos', 'Torres', 'hash9', 9, 'T');
INSERT INTO clientes (id, documento_identidad, nombres, apellidos, password, info_contacto_id, email_confirmado) VALUES (10, '3079811110101', 'Sofia', 'Ruiz', 'hash10', 10, 'T');

-- Info contacto trabajadores
INSERT INTO info_contacto_trabajadores (id, telefono, email, location_id, activo) VALUES (1, '44411111', 'emp1@empresa.com', 1, 'T');
INSERT INTO info_contacto_trabajadores (id, telefono, email, location_id, activo) VALUES (2, '44422222', 'emp2@empresa.com', 2, 'T');
INSERT INTO info_contacto_trabajadores (id, telefono, email, location_id, activo) VALUES (3, '44433333', 'emp3@empresa.com', 3, 'T');
INSERT INTO info_contacto_trabajadores (id, telefono, email, location_id, activo) VALUES (4, '44444444', 'emp4@empresa.com', 4, 'T');
INSERT INTO info_contacto_trabajadores (id, telefono, email, location_id, activo) VALUES (5, '44455555', 'emp5@empresa.com', 5, 'T');
INSERT INTO info_contacto_trabajadores (id, telefono, email, location_id, activo) VALUES (6, '44466666', 'emp6@empresa.com', 1, 'T');
INSERT INTO info_contacto_trabajadores (id, telefono, email, location_id, activo) VALUES (7, '44477777', 'emp7@empresa.com', 2, 'T');
INSERT INTO info_contacto_trabajadores (id, telefono, email, location_id, activo) VALUES (8, '44488888', 'emp8@empresa.com', 3, 'T');
INSERT INTO info_contacto_trabajadores (id, telefono, email, location_id, activo) VALUES (9, '44499999', 'emp9@empresa.com', 4, 'T');
INSERT INTO info_contacto_trabajadores (id, telefono, email, location_id, activo) VALUES (10, '44400000', 'emp10@empresa.com', 5, 'T');

-- Trabajadores
INSERT INTO trabajadores (id, documento_identidad, nombres, apellidos, job, departamento_id, info_contacto_id) VALUES (1, '2857469130101', 'Roberto', 'Méndez', 'Gerente de Ventas', 1, 1);
INSERT INTO trabajadores (id, documento_identidad, nombres, apellidos, job, departamento_id, info_contacto_id) VALUES (2, '2964581470101', 'Ana', 'López', 'Jefe de Almacén', 2, 2);
INSERT INTO trabajadores (id, documento_identidad, nombres, apellidos, job, departamento_id, info_contacto_id) VALUES (3, '3017852360101', 'Carlos', 'García', 'Coordinador de Logística', 3, 3);
INSERT INTO trabajadores (id, documento_identidad, nombres, apellidos, job, departamento_id, info_contacto_id) VALUES (4, '2789456120101', 'María', 'Torres', 'Supervisora de Atención', 4, 4);
INSERT INTO trabajadores (id, documento_identidad, nombres, apellidos, job, departamento_id, info_contacto_id) VALUES (5, '2654789310101', 'Juan', 'Pérez', 'Director de RRHH', 5, 5);
INSERT INTO trabajadores (id, documento_identidad, nombres, apellidos, job, departamento_id, info_contacto_id) VALUES (6, '2987456320101', 'Laura', 'Sánchez', 'Vendedora Senior', 1, 6);
INSERT INTO trabajadores (id, documento_identidad, nombres, apellidos, job, departamento_id, info_contacto_id) VALUES (7, '3124567890101', 'Pedro', 'Ramírez', 'Asistente de Almacén', 2, 7);
INSERT INTO trabajadores (id, documento_identidad, nombres, apellidos, job, departamento_id, info_contacto_id) VALUES (8, '2897456140101', 'Carmen', 'Díaz', 'Analista de Logística', 3, 8);
INSERT INTO trabajadores (id, documento_identidad, nombres, apellidos, job, departamento_id, info_contacto_id) VALUES (9, '3045678920101', 'Luis', 'González', 'Ejecutivo de Servicio', 4, 9);
INSERT INTO trabajadores (id, documento_identidad, nombres, apellidos, job, departamento_id, info_contacto_id) VALUES (10, '2756489320101', 'Sofia', 'Martínez', 'Analista de RRHH', 5, 10);


-- Productos
INSERT INTO productos (id, sku, nombre, descripcion, precio, categoria_id, activo) VALUES (1, 'SKU001', 'Laptop HP', 'Laptop HP 15 pulgadas Core i5', 5000.00, 1, 'T');
INSERT INTO productos (id, sku, nombre, descripcion, precio, categoria_id, activo) VALUES (2, 'SKU002', 'Smartphone Samsung', 'Samsung Galaxy A53', 2500.00, 1, 'T');
INSERT INTO productos (id, sku, nombre, descripcion, precio, categoria_id, activo) VALUES (3, 'SKU003', 'Tablet Lenovo', 'Tablet Lenovo 10 pulgadas', 1800.00, 1, 'T');
INSERT INTO productos (id, sku, nombre, descripcion, precio, categoria_id, activo) VALUES (4, 'SKU004', 'Smart TV LG', 'TV LED 50 pulgadas 4K', 4500.00, 1, 'T');
INSERT INTO productos (id, sku, nombre, descripcion, precio, categoria_id, activo) VALUES (5, 'SKU005', 'Impresora Epson', 'Impresora multifuncional', 1200.00, 1, 'T');
INSERT INTO productos (id, sku, nombre, descripcion, precio, categoria_id, activo) VALUES (6, 'SKU006', 'Monitor Dell', 'Monitor 27 pulgadas 4K', 2800.00, 1, 'T');
INSERT INTO productos (id, sku, nombre, descripcion, precio, categoria_id, activo) VALUES (7, 'SKU007', 'Teclado mecánico', 'Teclado gaming RGB', 450.00, 1, 'T');
INSERT INTO productos (id, sku, nombre, descripcion, precio, categoria_id, activo) VALUES (8, 'SKU008', 'Mouse Logitech', 'Mouse inalámbrico', 200.00, 1, 'T');
INSERT INTO productos (id, sku, nombre, descripcion, precio, categoria_id, activo) VALUES (9, 'SKU009', 'Webcam HD', 'Webcam 1080p con micrófono', 350.00, 1, 'T');
INSERT INTO productos (id, sku, nombre, descripcion, precio, categoria_id, activo) VALUES (10, 'SKU010', 'Audífonos Sony', 'Audífonos bluetooth', 600.00, 1, 'T');

-- Direcciones cliente
INSERT INTO direcciones_cliente (id, cliente_id, direccion_id) VALUES (1, 1, 1);
INSERT INTO direcciones_cliente (id, cliente_id, direccion_id) VALUES (2, 2, 2);
INSERT INTO direcciones_cliente (id, cliente_id, direccion_id) VALUES (3, 3, 3);
INSERT INTO direcciones_cliente (id, cliente_id, direccion_id) VALUES (4, 4, 4);
INSERT INTO direcciones_cliente (id, cliente_id, direccion_id) VALUES (5, 5, 5);
INSERT INTO direcciones_cliente (id, cliente_id, direccion_id) VALUES (6, 6, 6);
INSERT INTO direcciones_cliente (id, cliente_id, direccion_id) VALUES (7, 7, 7);
INSERT INTO direcciones_cliente (id, cliente_id, direccion_id) VALUES (8, 8, 8);
INSERT INTO direcciones_cliente (id, cliente_id, direccion_id) VALUES (9, 9, 9);
INSERT INTO direcciones_cliente (id, cliente_id, direccion_id) VALUES (10, 10, 10);

-- Imágenes producto
INSERT INTO imagenes_producto (id, producto_id, url_imagen) VALUES (1, 1, 'https://storage.com/laptop-hp-1.jpg');
INSERT INTO imagenes_producto (id, producto_id, url_imagen) VALUES (2, 1, 'https://storage.com/laptop-hp-2.jpg');
INSERT INTO imagenes_producto (id, producto_id, url_imagen) VALUES (3, 2, 'https://storage.com/samsung-1.jpg');
INSERT INTO imagenes_producto (id, producto_id, url_imagen) VALUES (4, 2, 'https://storage.com/samsung-2.jpg');
INSERT INTO imagenes_producto (id, producto_id, url_imagen) VALUES (5, 3, 'https://storage.com/tablet-1.jpg');
INSERT INTO imagenes_producto (id, producto_id, url_imagen) VALUES (6, 4, 'https://storage.com/tv-lg-1.jpg');
INSERT INTO imagenes_producto (id, producto_id, url_imagen) VALUES (7, 5, 'https://storage.com/impresora-1.jpg');
INSERT INTO imagenes_producto (id, producto_id, url_imagen) VALUES (8, 6, 'https://storage.com/monitor-1.jpg');
INSERT INTO imagenes_producto (id, producto_id, url_imagen) VALUES (9, 7, 'https://storage.com/teclado-1.jpg');
INSERT INTO imagenes_producto (id, producto_id, url_imagen) VALUES (10, 8, 'https://storage.com/mouse-1.jpg');

-- Inventario
INSERT INTO inventario (id, producto_id, sede_id, cantidad) VALUES (1, 1, 1, 50);
INSERT INTO inventario (id, producto_id, sede_id, cantidad) VALUES (2, 2, 1, 100);
INSERT INTO inventario (id, producto_id, sede_id, cantidad) VALUES (3, 3, 2, 75);
INSERT INTO inventario (id, producto_id, sede_id, cantidad) VALUES (4, 4, 2, 30);
INSERT INTO inventario (id, producto_id, sede_id, cantidad) VALUES (5, 5, 3, 60);
INSERT INTO inventario (id, producto_id, sede_id, cantidad) VALUES (6, 6, 3, 40);
INSERT INTO inventario (id, producto_id, sede_id, cantidad) VALUES (7, 7, 4, 90);
INSERT INTO inventario (id, producto_id, sede_id, cantidad) VALUES (8, 8, 4, 120);
INSERT INTO inventario (id, producto_id, sede_id, cantidad) VALUES (9, 9, 5, 45);
INSERT INTO inventario (id, producto_id, sede_id, cantidad) VALUES (10, 10, 5, 80);

-- Ordenes
INSERT INTO ordenes (id, cliente_id, sede_id) VALUES (1, 1, 1);
INSERT INTO ordenes (id, cliente_id, sede_id) VALUES (2, 2, 1);
INSERT INTO ordenes (id, cliente_id, sede_id) VALUES (3, 3, 2);
INSERT INTO ordenes (id, cliente_id, sede_id) VALUES (4, 4, 2);
INSERT INTO ordenes (id, cliente_id, sede_id) VALUES (5, 5, 3);
INSERT INTO ordenes (id, cliente_id, sede_id) VALUES (6, 6, 3);
INSERT INTO ordenes (id, cliente_id, sede_id) VALUES (7, 7, 4);
INSERT INTO ordenes (id, cliente_id, sede_id) VALUES (8, 8, 4);
INSERT INTO ordenes (id, cliente_id, sede_id) VALUES (9, 9, 5);
INSERT INTO ordenes (id, cliente_id, sede_id) VALUES (10, 10, 5);

-- Ordenes productos
INSERT INTO ordenes_productos (id, orden_id, producto_id, cantidad, precio) VALUES (1, 1, 1, 1, 5000.00);
INSERT INTO ordenes_productos (id, orden_id, producto_id, cantidad, precio) VALUES (2, 1, 2, 1, 2500.00);
INSERT INTO ordenes_productos (id, orden_id, producto_id, cantidad, precio) VALUES (3, 2, 3, 2, 1800.00);
INSERT INTO ordenes_productos (id, orden_id, producto_id, cantidad, precio) VALUES (4, 3, 4, 1, 4500.00);
INSERT INTO ordenes_productos (id, orden_id, producto_id, cantidad, precio) VALUES (5, 4, 5, 1, 1200.00);
INSERT INTO ordenes_productos (id, orden_id, producto_id, cantidad, precio) VALUES (6, 5, 6, 1, 2800.00);
INSERT INTO ordenes_productos (id, orden_id, producto_id, cantidad, precio) VALUES (7, 6, 7, 2, 450.00);
INSERT INTO ordenes_productos (id, orden_id, producto_id, cantidad, precio) VALUES (8, 7, 8, 3, 200.00);
INSERT INTO ordenes_productos (id, orden_id, producto_id, cantidad, precio) VALUES (9, 8, 9, 1, 350.00);
INSERT INTO ordenes_productos (id, orden_id, producto_id, cantidad, precio) VALUES (10, 9, 10, 1, 600.00);

-- Ordenes entregadas
INSERT INTO ordenes_entregadas (id, orden_id, compania_envio_id, direccion_id, numero_guia, estado_id) VALUES (1, 1, 1, 1, 'GUIDE001', 1);
INSERT INTO ordenes_entregadas (id, orden_id, compania_envio_id, direccion_id, numero_guia, estado_id) VALUES (2, 2, 2, 2, 'GUIDE002', 2);
INSERT INTO ordenes_entregadas (id, orden_id, compania_envio_id, direccion_id, numero_guia, estado_id) VALUES (3, 3, 3, 3, 'GUIDE003', 3);
INSERT INTO ordenes_entregadas (id, orden_id, compania_envio_id, direccion_id, numero_guia, estado_id) VALUES (4, 4, 4, 4, 'GUIDE004', 1);
INSERT INTO ordenes_entregadas (id, orden_id, compania_envio_id, direccion_id, numero_guia, estado_id) VALUES (5, 5, 5, 5, 'GUIDE005', 2);
INSERT INTO ordenes_entregadas (id, orden_id, compania_envio_id, direccion_id, numero_guia, estado_id) VALUES (6, 6, 1, 6, 'GUIDE006', 3);
INSERT INTO ordenes_entregadas (id, orden_id, compania_envio_id, direccion_id, numero_guia, estado_id) VALUES (7, 7, 2, 7, 'GUIDE007', 1);
INSERT INTO ordenes_entregadas (id, orden_id, compania_envio_id, direccion_id, numero_guia, estado_id) VALUES (8, 8, 3, 8, 'GUIDE008', 2);
INSERT INTO ordenes_entregadas (id, orden_id, compania_envio_id, direccion_id, numero_guia, estado_id) VALUES (9, 9, 4, 9, 'GUIDE009', 3);
INSERT INTO ordenes_entregadas (id, orden_id, compania_envio_id, direccion_id, numero_guia, estado_id) VALUES (10, 10, 5, 10, 'GUIDE010', 1);

-- Pagos
INSERT INTO pagos (id, cliente_id, metodo_pago_id) VALUES (1, 1, 1);
INSERT INTO pagos (id, cliente_id, metodo_pago_id) VALUES (2, 2, 2);
INSERT INTO pagos (id, cliente_id, metodo_pago_id) VALUES (3, 3, 3);
INSERT INTO pagos (id, cliente_id, metodo_pago_id) VALUES (4, 4, 4);
INSERT INTO pagos (id, cliente_id, metodo_pago_id) VALUES (5, 5, 5);
INSERT INTO pagos (id, cliente_id, metodo_pago_id) VALUES (6, 6, 1);
INSERT INTO pagos (id, cliente_id, metodo_pago_id) VALUES (7, 7, 2);
INSERT INTO pagos (id, cliente_id, metodo_pago_id) VALUES (8, 8, 3);
INSERT INTO pagos (id, cliente_id, metodo_pago_id) VALUES (9, 9, 4);
INSERT INTO pagos (id, cliente_id, metodo_pago_id) VALUES (10, 10, 5);

-- Pagos ordenes
INSERT INTO pagos_ordenes (id, orden_id, metodo_pago_id, estado_id) VALUES (1, 1, 1, 1);
INSERT INTO pagos_ordenes (id, orden_id, metodo_pago_id, estado_id) VALUES (2, 2, 2, 2);
INSERT INTO pagos_ordenes (id, orden_id, metodo_pago_id, estado_id) VALUES (3, 3, 3, 3);
INSERT INTO pagos_ordenes (id, orden_id, metodo_pago_id, estado_id) VALUES (4, 4, 4, 1);
INSERT INTO pagos_ordenes (id, orden_id, metodo_pago_id, estado_id) VALUES (5, 5, 5, 2);
INSERT INTO pagos_ordenes (id, orden_id, metodo_pago_id, estado_id) VALUES (6, 6, 1, 3);
INSERT INTO pagos_ordenes (id, orden_id, metodo_pago_id, estado_id) VALUES (7, 7, 2, 1);
INSERT INTO pagos_ordenes (id, orden_id, metodo_pago_id, estado_id) VALUES (8, 8, 3, 2);
INSERT INTO pagos_ordenes (id, orden_id, metodo_pago_id, estado_id) VALUES (9, 9, 4, 3);
INSERT INTO pagos_ordenes (id, orden_id, metodo_pago_id, estado_id) VALUES (10, 10, 5, 1);

-- Devoluciones productos
INSERT INTO devoluciones_productos (id, orden_producto_id, descripcion, estado_id, fecha_solicitud) VALUES (1, 1, 'Producto dañado', 1, CURRENT_TIMESTAMP);
INSERT INTO devoluciones_productos (id, orden_producto_id, descripcion, estado_id, fecha_solicitud) VALUES (2, 2, 'Color incorrecto', 2, CURRENT_TIMESTAMP);
INSERT INTO devoluciones_productos (id, orden_producto_id, descripcion, estado_id, fecha_solicitud) VALUES (3, 3, 'Talla incorrecta', 3, CURRENT_TIMESTAMP);
INSERT INTO devoluciones_productos (id, orden_producto_id, descripcion, estado_id, fecha_solicitud) VALUES (4, 4, 'No funciona', 4, CURRENT_TIMESTAMP);
INSERT INTO devoluciones_productos (id, orden_producto_id, descripcion, estado_id, fecha_solicitud) VALUES (5, 5, 'Producto equivocado', 1, CURRENT_TIMESTAMP);
INSERT INTO devoluciones_productos (id, orden_producto_id, descripcion, estado_id, fecha_solicitud) VALUES (6, 6, 'Defectuoso', 2, CURRENT_TIMESTAMP);
INSERT INTO devoluciones_productos (id, orden_producto_id, descripcion, estado_id, fecha_solicitud) VALUES (7, 7, 'No cumple expectativas', 3, CURRENT_TIMESTAMP);
INSERT INTO devoluciones_productos (id, orden_producto_id, descripcion, estado_id, fecha_solicitud) VALUES (8, 8, 'Empaque dañado', 4, CURRENT_TIMESTAMP);
INSERT INTO devoluciones_productos (id, orden_producto_id, descripcion, estado_id, fecha_solicitud) VALUES (9, 9, 'Fallas técnicas', 1, CURRENT_TIMESTAMP);
INSERT INTO devoluciones_productos (id, orden_producto_id, descripcion, estado_id, fecha_solicitud) VALUES (10, 10, 'Arrepentimiento', 2, CURRENT_TIMESTAMP);

-- Movimientos
INSERT INTO movimientos (id, sede_origen_id, sede_destino_id, estado_id, fecha_solicitud) VALUES (1, 1, 2, 1, CURRENT_TIMESTAMP);
INSERT INTO movimientos (id, sede_origen_id, sede_destino_id, estado_id, fecha_solicitud) VALUES (2, 2, 3, 2, CURRENT_TIMESTAMP);
INSERT INTO movimientos (id, sede_origen_id, sede_destino_id, estado_id, fecha_solicitud) VALUES (3, 3, 4, 3, CURRENT_TIMESTAMP);
INSERT INTO movimientos (id, sede_origen_id, sede_destino_id, estado_id, fecha_solicitud) VALUES (4, 4, 5, 4, CURRENT_TIMESTAMP);
INSERT INTO movimientos (id, sede_origen_id, sede_destino_id, estado_id, fecha_solicitud) VALUES (5, 5, 6, 1, CURRENT_TIMESTAMP);
INSERT INTO movimientos (id, sede_origen_id, sede_destino_id, estado_id, fecha_solicitud) VALUES (6, 6, 7, 2, CURRENT_TIMESTAMP);
INSERT INTO movimientos (id, sede_origen_id, sede_destino_id, estado_id, fecha_solicitud) VALUES (7, 7, 8, 3, CURRENT_TIMESTAMP);
INSERT INTO movimientos (id, sede_origen_id, sede_destino_id, estado_id, fecha_solicitud) VALUES (8, 8, 9, 4, CURRENT_TIMESTAMP);
INSERT INTO movimientos (id, sede_origen_id, sede_destino_id, estado_id, fecha_solicitud) VALUES (9, 9, 10, 1, CURRENT_TIMESTAMP);
INSERT INTO movimientos (id, sede_origen_id, sede_destino_id, estado_id, fecha_solicitud) VALUES (10, 10, 1, 2, CURRENT_TIMESTAMP);

-- Movimientos productos
INSERT INTO movimientos_productos (id, movimiento_id, producto_id, cantidad) VALUES (1, 1, 1, 10);
INSERT INTO movimientos_productos (id, movimiento_id, producto_id, cantidad) VALUES (2, 2, 2, 15);
INSERT INTO movimientos_productos (id, movimiento_id, producto_id, cantidad) VALUES (3, 3, 3, 20);
INSERT INTO movimientos_productos (id, movimiento_id, producto_id, cantidad) VALUES (4, 4, 4, 5);
INSERT INTO movimientos_productos (id, movimiento_id, producto_id, cantidad) VALUES (5, 5, 5, 8);
INSERT INTO movimientos_productos (id, movimiento_id, producto_id, cantidad) VALUES (6, 6, 6, 12);
INSERT INTO movimientos_productos (id, movimiento_id, producto_id, cantidad) VALUES (7, 7, 7, 25);
INSERT INTO movimientos_productos (id, movimiento_id, producto_id, cantidad) VALUES (8, 8, 8, 30);
INSERT INTO movimientos_productos (id, movimiento_id, producto_id, cantidad) VALUES (9, 9, 9, 18);
INSERT INTO movimientos_productos (id, movimiento_id, producto_id, cantidad) VALUES (10, 10, 10, 22);

-- Agregando info faltante --
UPDATE productos SET slug = 'laptop-hp' WHERE id = 1;
UPDATE productos SET slug = 'smartphone-samsung' WHERE id = 2;
UPDATE productos SET slug = 'tablet-lenovo' WHERE id = 3;
UPDATE productos SET slug = 'smart-tv-lg' WHERE id = 4;
UPDATE productos SET slug = 'impresora-epson' WHERE id = 5;
UPDATE productos SET slug = 'monitor-dell' WHERE id = 6;
UPDATE productos SET slug = 'teclado-mecanico' WHERE id = 7;
UPDATE productos SET slug = 'mouse-logitech' WHERE id = 8;
UPDATE productos SET slug = 'webcam-hd' WHERE id = 9;
UPDATE productos SET slug = 'audifonos-sony' WHERE id = 10;

-- ******** SECUENCIAS ******** --

-- Secuencias para tablas auxiliares
CREATE SEQUENCE seq_departamentos START WITH 11 INCREMENT BY 1;
CREATE SEQUENCE seq_companias_envio START WITH 11 INCREMENT BY 1;
CREATE SEQUENCE seq_metodos_pago START WITH 11 INCREMENT BY 1;
CREATE SEQUENCE seq_categorias_producto START WITH 11 INCREMENT BY 1;
CREATE SEQUENCE seq_info_direccion START WITH 11 INCREMENT BY 1;
CREATE SEQUENCE seq_sedes START WITH 11 INCREMENT BY 1;

-- Secuencias para tablas principales
CREATE SEQUENCE seq_info_contacto_clientes START WITH 11 INCREMENT BY 1;
CREATE SEQUENCE seq_clientes START WITH 11 INCREMENT BY 1;
CREATE SEQUENCE seq_info_contacto_trabajadores START WITH 11 INCREMENT BY 1;
CREATE SEQUENCE seq_trabajadores START WITH 11 INCREMENT BY 1;
CREATE SEQUENCE seq_productos START WITH 11 INCREMENT BY 1;
CREATE SEQUENCE seq_direcciones_cliente START WITH 11 INCREMENT BY 1;
CREATE SEQUENCE seq_imagenes_producto START WITH 11 INCREMENT BY 1;
CREATE SEQUENCE seq_inventario START WITH 11 INCREMENT BY 1;
CREATE SEQUENCE seq_ordenes START WITH 11 INCREMENT BY 1;
CREATE SEQUENCE seq_ordenes_productos START WITH 11 INCREMENT BY 1;
CREATE SEQUENCE seq_ordenes_entregadas START WITH 11 INCREMENT BY 1;
CREATE SEQUENCE seq_pagos START WITH 11 INCREMENT BY 1;
CREATE SEQUENCE seq_pagos_ordenes START WITH 11 INCREMENT BY 1;
CREATE SEQUENCE seq_devoluciones_productos START WITH 11 INCREMENT BY 1;
CREATE SEQUENCE seq_movimientos START WITH 11 INCREMENT BY 1;
CREATE SEQUENCE seq_movimientos_productos START WITH 11 INCREMENT BY 1;
