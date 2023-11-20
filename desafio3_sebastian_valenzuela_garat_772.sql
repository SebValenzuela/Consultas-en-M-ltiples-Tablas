-- Creación tabla usuarios

CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    email VARCHAR,
    nombre VARCHAR,
    apellido VARCHAR,
    rol VARCHAR
);

INSERT INTO usuarios (id, email, nombre, apellido, rol) VALUES 
(DEFAULT, 'lgutierrez@gmail.com', 'Leonardo', 'Gutierrez', 'administrador'), 
(DEFAULT, 'chernandez@gmail.com', 'Carlos', 'Hernandez', 'user'), 
(DEFAULT, 'msanchez@gmail.com', 'Miguel', 'Sanchez', 'user'), 
(DEFAULT, 'jmedina@gmail.com', 'Javier', 'Medina', 'user'), 
(DEFAULT, 'despinosa@gmail.com', 'Daniel', 'Espinosa', 'user');

-- Creación tabla post

CREATE TABLE post (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR,
    contenido TEXT,
    fecha_creacion DATE,
    fecha_actualizacion DATE,
    destacado BOOLEAN,
    usuario_id BIGINT,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

INSERT INTO post (id, titulo, contenido, fecha_creacion, fecha_actualizacion, destacado, usuario_id) VALUES 
(DEFAULT, 'Introducción al desarrollo web', 'Aprende del mundo del desarrollo web', '2023-06-01', '2023-06-01', TRUE, 1),
(DEFAULT, 'CSS Avanzado', 'Aprende a darle estilo a tu web', '2023-07-01', '2023-07-01', FALSE, 2),
(DEFAULT, 'Javascript', 'Aprende a darle animación a tu web', '2023-08-01', '2023-08-01', FALSE, 3),
(DEFAULT, 'React I', 'Crea páginas dinámicas', '2023-09-01', '2023-09-01', TRUE, 4),
(DEFAULT, 'React II', 'Crea páginas dinámicas con rutas', '2023-10-01', '2023-10-01', TRUE, NULL);

-- Creación tabla comentarios

CREATE TABLE comentarios (
    id SERIAL PRIMARY KEY,
    contenido VARCHAR,
    fecha_creacion TIMESTAMP,
    usuarios_id BIGINT,
    post_id BIGINT
);

INSERT INTO comentarios (id, contenido, fecha_creacion, usuarios_id, post_id) VALUES 
(DEFAULT, 'El lenguaje html es la estructura base de un proyecto web', '2023-06-01', 1, 1),
(DEFAULT, 'El lenguaje css es la estructura de diseño de tu proyecto web', '2023-07-01', 2, 1),
(DEFAULT, 'El javascript es el lenguaje donde puedes animar tu páginaa web', '2023-08-01', 3, 1),
(DEFAULT, 'En React I puedes crear páginas dínamicas', '2023-09-01', 1, 2),
(DEFAULT, 'En React II puedes crear páginas dínamicas con rutas incorporadas', '2023-10-01', 2, 2);

-- PUNTO 1

SELECT
    post.id AS post_id,
    post.titulo AS post_titulo,
    post.contenido AS post_contenido,
    post.fecha_creacion AS post_fecha_creacion,
    post.fecha_actualizacion AS post_fecha_actualizacion,
    post.destacado AS post_destacado,
    usuarios.id AS autor_id,
    usuarios.nombre AS autor_nombre,
    usuarios.apellido AS autor_apellido,
    usuarios.email AS autor_email,
    comentarios.id AS comentario_id,
    comentarios.contenido AS comentario_contenido,
    comentarios.fecha_creacion AS comentario_fecha_creacion
FROM post
JOIN usuarios ON post.usuario_id = usuarios.id
LEFT JOIN comentarios ON post.id = comentarios.post_id;

-- PUNTO 2

SELECT
    u.nombre AS usuario_nombre,
    u.email AS usuario_email,
    p.titulo AS post_titulo,
    p.contenido AS post_contenido
FROM usuarios u JOIN post p ON u.id = p.usuario_id;

-- PUNTO 3

SELECT
    p.id AS post_id,
    p.titulo AS post_titulo,
    p.contenido AS post_contenido
FROM post p JOIN usuarios u ON p.usuario_id = u.id
WHERE u.rol = 'administrador';

-- PUNTO 4

SELECT
    u.id AS usuario_id,
    u.email AS usuario_email,
    COUNT(p.id) AS cantidad_posts
FROM usuarios u LEFT JOIN post p ON u.id = p.usuario_id
GROUP BY u.id, u.email;

-- PUNTO 5

SELECT u.email AS usuario_con_mas_posts
FROM usuarios u
    LEFT JOIN post p ON u.id = p.usuario_id
GROUP BY u.email
ORDER BY COUNT(p.id) DESC;
-- LIMIT 1; el limit está comentado por un error de sintaxis

-- PUNTO 6

SELECT
    u.id AS usuario_id,
    u.email AS usuario_email,
    MAX(p.fecha_actualizacion) AS fecha_ultimo_post
FROM usuarios u
    LEFT JOIN post p ON u.id = p.usuario_id
GROUP BY u.id, u.email;

-- PUNTO 7

SELECT
    p.id AS post_id,
    p.titulo AS post_titulo,
    p.contenido AS post_contenido,
    COUNT(c.id) AS cantidad_comentarios
FROM
    post p
LEFT JOIN
    comentarios c ON p.id = c.post_id
GROUP BY
    p.id, p.titulo, p.contenido
ORDER BY
    COUNT(c.id) DESC;
-- LIMIT 1; el limit está comentado por un error de sintaxis

-- PUNTO 8

SELECT
    p.titulo AS post_titulo,
    p.contenido AS post_contenido,
    c.contenido AS comentario_contenido,
    u.email AS usuario_email
FROM
    post p
LEFT JOIN
    comentarios c ON p.id = c.post_id
LEFT JOIN
    usuarios u ON c.usuarios_id = u.id;

-- PUNTO 9

WITH ComentariosNumerados AS (
    SELECT
        c.id AS comentario_id,
        c.contenido AS comentario_contenido,
        c.fecha_creacion,
        u.email AS usuario_email,
        ROW_NUMBER() OVER (PARTITION BY u.id ORDER BY c.fecha_creacion DESC) AS num_fila
    FROM comentarios c
    JOIN usuarios u ON c.usuarios_id = u.id
)
SELECT usuario_email, comentario_contenido
FROM ComentariosNumerados
WHERE num_fila = 1;

-- PUNTO 10

SELECT u.email AS usuario_email
FROM usuarios u
LEFT JOIN comentarios c ON u.id = c.usuarios_id
WHERE c.id IS NULL;