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
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
);

-- Tablas Principales
CREATE TABLE info_contacto_clientes (
    id NUMBER PRIMARY KEY,
    telefono VARCHAR2(50),
    email VARCHAR2(100) NOT NULL UNIQUE,
    activo VARCHAR2(1) DEFAULT '1' CHECK (activo IN ('0','1')),
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
    email_confirmado VARCHAR2(1) DEFAULT '0' CHECK (email_confirmado IN ('0','1')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cliente_info_contacto FOREIGN KEY (info_contacto_id) REFERENCES info_contacto_clientes(id)
);

CREATE TABLE info_contacto_trabajadores (
    id NUMBER PRIMARY KEY,
    telefono VARCHAR2(50),
    email VARCHAR2(100) NOT NULL UNIQUE,
    location_id NUMBER NOT NULL,
    activo VARCHAR2(1) DEFAULT '1' CHECK (activo IN ('0','1')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_info_contacto_location FOREIGN KEY (location_id) REFERENCES sedes(id)
);

CREATE TABLE trabajadores (
    id NUMBER PRIMARY KEY,
    documento_identidad VARCHAR2(50) NOT NULL UNIQUE,
    nombres VARCHAR2(100) NOT NULL,
    apellidos VARCHAR2(100) NOT NULL,
    job NUMBER NOT NULL,
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
    activo VARCHAR2(1) DEFAULT '1' CHECK (activo IN ('0','1')),
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