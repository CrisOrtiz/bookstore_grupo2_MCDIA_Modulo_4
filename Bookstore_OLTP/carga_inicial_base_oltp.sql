USE [Bookstore_OLTP];
GO

SET NOCOUNT ON;
BEGIN TRANSACTION;

BEGIN TRY

    ---------------------------------------------------------
    -- 1. TABLAS CATÁLOGO / BASE[cite: 1]
    ---------------------------------------------------------
    -- address_status[cite: 1]
    IF NOT EXISTS (SELECT 1 FROM [dbo].[address_status])
    BEGIN
        INSERT INTO [dbo].[address_status] ([status_id], [address_status])
        VALUES 
            (1, 'Principal / Facturación'),
            (2, 'Secundaria / Envío'),
            (3, 'Antigua / Deshabilitada'),
            (4, 'Temporal');
    END;

    -- order_status[cite: 1]
    IF NOT EXISTS (SELECT 1 FROM [dbo].[order_status])
    BEGIN
        INSERT INTO [dbo].[order_status] ([status_id], [status_value])
        VALUES 
            (1, 'Pendiente de Pago'),
            (2, 'En Preparación'),
            (3, 'Enviado'),
            (4, 'Entregado'),
            (5, 'Cancelado'),
            (6, 'Devuelto');
    END;

    -- shipping_method[cite: 1]
    IF NOT EXISTS (SELECT 1 FROM [dbo].[shipping_method])
    BEGIN
        INSERT INTO [dbo].[shipping_method] ([method_id], [method_name], [cost])
        VALUES 
            (1, 'Envío Terrestre Estándar (3-5 días)', 4.99),
            (2, 'Envío Exprés Nacional (24-48 hrs)', 8.50),
            (3, 'Courier Prioritario (24 hrs)', 14.99),
            (4, 'Envío Mismo Día (Same-Day Delivery)', 24.99),
            (5, 'Courier Internacional DHL/FedEx', 39.50);
    END;

    -- book_language[cite: 1]
    IF NOT EXISTS (SELECT 1 FROM [dbo].[book_language])
    BEGIN
        INSERT INTO [dbo].[book_language] ([language_id], [language_code], [language_name])
        VALUES 
            (1, 'es', 'Español'),
            (2, 'en', 'Inglés'),
            (3, 'fr', 'Francés'),
            (4, 'de', 'Alemán'),
            (5, 'it', 'Italiano'),
            (6, 'pt', 'Portugués'),
            (7, 'ja', 'Japonés'),
            (8, 'zh', 'Chino'),
            (9, 'ru', 'Ruso'),
            (10, 'la', 'Latín');
    END;

    -- country[cite: 1]
    IF NOT EXISTS (SELECT 1 FROM [dbo].[country])
    BEGIN
        INSERT INTO [dbo].[country] ([country_id], [country_name])
        VALUES 
            (1, 'Bolivia'), (2, 'Argentina'), (3, 'Chile'), (4, 'Perú'), (5, 'Colombia'),
            (6, 'México'), (7, 'España'), (8, 'Estados Unidos'), (9, 'Brasil'), (10, 'Uruguay'),
            (11, 'Ecuador'), (12, 'Paraguay'), (13, 'Alemania'), (14, 'Reino Unido'), (15, 'Francia'),
            (16, 'Italia'), (17, 'Canadá'), (18, 'Japón'), (19, 'Portugal'), (20, 'Costa Rica');
    END;

    -- publisher (Editoriales Reales)[cite: 1]
    IF NOT EXISTS (SELECT 1 FROM [dbo].[publisher])
    BEGIN
        INSERT INTO [dbo].[publisher] ([publisher_id], [publisher_name])
        VALUES
            (1, 'Penguin Random House'), (2, 'Grupo Planeta'), (3, 'HarperCollins'), 
            (4, 'Alfaguara'), (5, 'Anagrama'), (6, 'Fondo de Cultura Económica'), 
            (7, 'O Reilly Media'), (8, 'Siglo XXI Editores'), (9, 'Tusquets Editores'), 
            (10, 'Alianza Editorial'), (11, 'Cátedra'), (12, 'Salamandra'), 
            (13, 'Siruela'), (14, 'Debolsillo'), (15, 'Editorial Gredos'), 
            (16, 'Packt Publishing'), (17, 'Addison-Wesley'), (18, 'McGraw-Hill'), 
            (19, 'Editorial Norma'), (20, 'Plaza & Janés');
    END;

    -- author (Autores Reales y Famosos)[cite: 1]
    IF NOT EXISTS (SELECT 1 FROM [dbo].[author])
    BEGIN
        INSERT INTO [dbo].[author] ([author_id], [author_name])
        VALUES
            (1, 'Gabriel García Márquez'), (2, 'Jorge Luis Borges'), (3, 'Mario Vargas Llosa'),
            (4, 'Julio Cortázar'), (5, 'Isabel Allende'), (6, 'Miguel de Cervantes'),
            (7, 'George Orwell'), (8, 'J.K. Rowling'), (9, 'J.R.R. Tolkien'),
            (10, 'Stephen King'), (11, 'Fyodor Dostoevsky'), (12, 'Leo Tolstoy'),
            (13, 'Franz Kafka'), (14, 'Haruki Murakami'), (15, 'Isaac Asimov'),
            (16, 'Arthur Conan Doyle'), (17, 'Agatha Christie'), (18, 'Ernest Hemingway'),
            (19, 'Albert Camus'), (20, 'Virginia Woolf'), (21, 'Edgar Allan Poe'),
            (22, 'Jane Austen'), (23, 'Charles Dickens'), (24, 'Victor Hugo'),
            (25, 'Hermann Hesse'), (26, 'Octavio Paz'), (27, 'Carlos Fuentes'),
            (28, 'Pablo Neruda'), (29, 'Mario Benedetti'), (30, 'Eduardo Galeano'),
            (31, 'Martin Fowler'), (32, 'Robert C. Martin'), (33, 'Kent Beck'),
            (34, 'Andrew Ng'), (35, 'Yuval Noah Harari'), (36, 'Carl Sagan'),
            (37, 'Stephen Hawking'), (38, 'Daniel Kahneman'), (39, 'Malcolm Gladwell'),
            (40, 'Nassim Nicholas Taleb');
    END;

    ---------------------------------------------------------
    -- 2. TABLAS MAESTRAS (Libros, Direcciones, Clientes)[cite: 1]
    ---------------------------------------------------------
    -- book (Catálogo de títulos literarios y técnicos reales)[cite: 1]
    IF NOT EXISTS (SELECT 1 FROM [dbo].[book])
    BEGIN
        -- Tabla temporal con títulos representativos
        DECLARE @RealTitles TABLE (id INT IDENTITY(1,1), title VARCHAR(400), lang INT, pub INT, pages INT, yr INT);
        INSERT INTO @RealTitles (title, lang, pub, pages, yr) VALUES
            ('Cien Años de Soledad', 1, 4, 471, 1967),
            ('El Amor en los Tiempos del Cólera', 1, 4, 368, 1985),
            ('Ficciones', 1, 5, 224, 1944),
            ('El Aleph', 1, 5, 210, 1949),
            ('La Ciudad y los Perros', 1, 2, 448, 1963),
            ('Conversación en La Catedral', 1, 2, 608, 1969),
            ('Rayuela', 1, 4, 600, 1963),
            ('La Casa de los Espíritus', 1, 12, 450, 1982),
            ('Don Quijote de la Mancha', 1, 11, 1080, 1605),
            ('1984', 2, 1, 328, 1949),
            ('Rebelión en la Granja', 1, 14, 144, 1945),
            ('Harry Potter y la Piedra Filosofal', 1, 12, 256, 1997),
            ('El Señor de los Anillos: La Comunidad del Anillo', 1, 9, 423, 1954),
            ('El Resplandor', 1, 14, 688, 1977),
            ('Crimen y Castigo', 1, 10, 672, 1866),
            ('Los Hermanos Karamazov', 1, 15, 1120, 1880),
            ('Guerra y Paz', 1, 10, 1296, 1869),
            ('La Metamorfosis', 1, 10, 128, 1915),
            ('Tokio Blues (Norwegian Wood)', 1, 9, 384, 1987),
            ('Fundación', 1, 14, 256, 1951),
            ('Estudio en Escarlata', 1, 10, 160, 1887),
            ('Diez Negritos (Y no quedó ninguno)', 1, 2, 224, 1939),
            ('El Viejo y el Mar', 1, 14, 128, 1952),
            ('El Extranjero', 1, 10, 160, 1942),
            ('Al Faro', 1, 10, 240, 1927),
            ('Narraciones Extraordinarias', 1, 10, 320, 1845),
            ('Orgullo y Prejuicio', 1, 10, 424, 1813),
            ('Historia de Dos Ciudades', 1, 10, 544, 1859),
            ('Los Miserables', 1, 10, 1200, 1862),
            ('Siddhartha', 1, 10, 160, 1922),
            ('El Laberinto de la Soledad', 1, 6, 350, 1950),
            ('Veinte Poemas de Amor y una Canción Desesperada', 1, 2, 120, 1924),
            ('Las Venas Abiertas de América Latina', 1, 8, 380, 1971),
            ('Clean Code: A Handbook of Agile Software Craftsmanship', 2, 17, 464, 2008),
            ('Refactoring: Improving the Design of Existing Code', 2, 17, 448, 1999),
            ('Designing Data-Intensive Applications', 2, 7, 616, 2017),
            ('Sapiens: De animales a dioses', 1, 14, 496, 2014),
            ('Cosmos', 1, 2, 384, 1980),
            ('Breve Historia del Tiempo', 1, 14, 256, 1988),
            ('Pensar Rápido, Pensar Despacio', 1, 14, 672, 2011);

        -- Generamos 300 libros cruzando ediciones, volúmenes y títulos
        ;WITH Num(n) AS (SELECT 1 UNION ALL SELECT n + 1 FROM Num WHERE n < 300)
        INSERT INTO [dbo].[book] ([book_id], [title], [isbn13], [language_id], [num_pages], [publication_date], [publisher_id])
        SELECT 
            n.n,
            CASE 
                WHEN n.n <= 40 THEN rt.title
                ELSE CONCAT(rt.title, ' (Edición Especial Vol. ', ((n.n - 1) / 40) + 1, ')')
            END,
            CONCAT('978', RIGHT('8400000000' + CAST(n.n * 7393 AS VARCHAR(10)), 10)),
            rt.lang,
            rt.pages + ((n.n * 13) % 50),
            DATEFROMPARTS(rt.yr + ((n.n * 3) % 25), ((n.n * 7) % 12) + 1, ((n.n * 5) % 27) + 1),
            ((rt.pub + n.n) % 20) + 1
        FROM Num n
        JOIN @RealTitles rt ON rt.id = ((n.n - 1) % 40) + 1
        OPTION (MAXRECURSION 300);
    END;

    -- book_author[cite: 1]
    IF NOT EXISTS (SELECT 1 FROM [dbo].[book_author])
    BEGIN
        INSERT INTO [dbo].[book_author] ([book_id], [author_id])
        SELECT 
            b.book_id,
            ((b.book_id - 1) % 40) + 1
        FROM [dbo].[book] b;
    END;

    -- address (300 Direcciones con calles, avenidas y ciudades reales)[cite: 1]
    IF NOT EXISTS (SELECT 1 FROM [dbo].[address])
    BEGIN
        DECLARE @Streets TABLE (id INT IDENTITY(1,1), name VARCHAR(200));
        INSERT INTO @Streets (name) VALUES 
            ('Av. 9 de Julio'), ('Av. Corrientes'), ('Paseo de la Castellana'), ('Gran Vía'),
            ('Av. Reforma'), ('Av. Insurgentes Sur'), ('Av. Providencia'), ('Av. Libertador'),
            ('Av. Las Américas'), ('Av. Heroínas'), ('Av. Ayacucho'), ('Calle Ballivián'),
            ('Calle San Martín'), ('Av. Paulista'), ('Av. Copacabana'), ('Av. 18 de Julio'),
            ('Rambla de Cataluña'), ('Calle Alcalá'), ('Av. Santa Fe'), ('Av. Diagonal');

        DECLARE @Cities TABLE (id INT IDENTITY(1,1), city VARCHAR(100), country_id INT);
        INSERT INTO @Cities (city, country_id) VALUES 
            ('Cochabamba', 1), ('La Paz', 1), ('Santa Cruz de la Sierra', 1),
            ('Buenos Aires', 2), ('Córdoba', 2), ('Rosario', 2),
            ('Santiago', 3), ('Valparaíso', 3), ('Lima', 4), ('Arequipa', 4),
            ('Bogotá', 5), ('Medellín', 5), ('Ciudad de México', 6), ('Guadalajara', 6),
            ('Madrid', 7), ('Barcelona', 7), ('Valencia', 7), ('Miami', 8), ('Nueva York', 8),
            ('São Paulo', 9), ('Río de Janeiro', 9), ('Montevideo', 10), ('Quito', 11);

        ;WITH Num(n) AS (SELECT 1 UNION ALL SELECT n + 1 FROM Num WHERE n < 300)
        INSERT INTO [dbo].[address] ([address_id], [street_number], [street_name], [city], [country_id])
        SELECT 
            n.n,
            CAST(((n.n * 37) % 2500) + 100 AS VARCHAR(10)),
            s.name,
            c.city,
            c.country_id
        FROM Num n
        JOIN @Streets s ON s.id = ((n.n - 1) % 20) + 1
        JOIN @Cities c ON c.id = ((n.n - 1) % 23) + 1
        OPTION (MAXRECURSION 300);
    END;

    -- customer (250 Nombres y Apellidos Reales)[cite: 1]
    IF NOT EXISTS (SELECT 1 FROM [dbo].[customer])
    BEGIN
        DECLARE @FirstNames TABLE (id INT IDENTITY(1,1), name VARCHAR(100));
        INSERT INTO @FirstNames (name) VALUES 
            ('Alejandro'), ('Carlos'), ('Mateo'), ('Sebastián'), ('Lucía'),
            ('Valentina'), ('Sofía'), ('Camila'), ('Diego'), ('Martín'),
            ('Daniel'), ('Joaquín'), ('Mariana'), ('Paula'), ('Valeria'),
            ('Nicolás'), ('Gabriel'), ('Elena'), ('Ignacio'), ('Adriana');

        DECLARE @LastNames TABLE (id INT IDENTITY(1,1), surname VARCHAR(100));
        INSERT INTO @LastNames (surname) VALUES 
            ('Rodríguez'), ('González'), ('Hernández'), ('López'), ('Martínez'),
            ('Pérez'), ('García'), ('Sánchez'), ('Romero'), ('Torres'),
            ('Camacho'), ('Flores'), ('Álvarez'), ('Castillo'), ('Vargas'),
            ('Gutiérrez'), ('Mendoza'), ('Morales'), ('Rojas'), ('Ortiz');

        DECLARE @Domains TABLE (id INT IDENTITY(1,1), domain VARCHAR(100));
        INSERT INTO @Domains (domain) VALUES 
            ('gmail.com'), ('outlook.com'), ('hotmail.com'), ('yahoo.com'), ('icloud.com');

        ;WITH Num(n) AS (SELECT 1 UNION ALL SELECT n + 1 FROM Num WHERE n < 250)
        INSERT INTO [dbo].[customer] ([customer_id], [first_name], [last_name], [email])
        SELECT 
            n.n,
            fn.name,
            ln.surname,
            LOWER(CONCAT(fn.name, '.', ln.surname, n.n, '@', d.domain))
        FROM Num n
        JOIN @FirstNames fn ON fn.id = ((n.n - 1) % 20) + 1
        JOIN @LastNames ln ON ln.id = (((n.n * 7) - 1) % 20) + 1
        JOIN @Domains d ON d.id = ((n.n - 1) % 5) + 1
        OPTION (MAXRECURSION 250);
    END;

    -- customer_address[cite: 1]
    IF NOT EXISTS (SELECT 1 FROM [dbo].[customer_address])
    BEGIN
        INSERT INTO [dbo].[customer_address] ([customer_id], [address_id], [status_id])
        SELECT 
            c.customer_id,
            c.customer_id,
            CASE WHEN c.customer_id % 10 = 0 THEN 2 ELSE 1 END
        FROM [dbo].[customer] c;
    END;

    ---------------------------------------------------------
    -- 3. TABLAS TRANSACCIONALES / HECHOS (Órdenes y Ventas)[cite: 1]
    ---------------------------------------------------------
    -- cust_order (600 órdenes con fechas distribuidas a lo largo de 2024, 2025 y 2026)[cite: 1]
    IF NOT EXISTS (SELECT 1 FROM [dbo].[cust_order])
    BEGIN
        ;WITH Num(n) AS (SELECT 1 UNION ALL SELECT n + 1 FROM Num WHERE n < 600)
        INSERT INTO [dbo].[cust_order] ([order_date], [customer_id], [shipping_method_id], [dest_address_id])
        SELECT 
           DATEADD(
            MINUTE,
            ((n.n * 1373) % 1300000),
            DATETIMEFROMPARTS(2024, 1, 15, 8, 30, 0, 0)
            ),
            ((n.n * 3) % 250) + 1,
            ((n.n * 7) % 5) + 1,
            ((n.n * 3) % 250) + 1
        FROM Num n
        OPTION (MAXRECURSION 600);
    END;

    -- order_line (1,450 líneas de detalle con precios realistas por libro)[cite: 1]
    IF NOT EXISTS (SELECT 1 FROM [dbo].[order_line])
    BEGIN
        INSERT INTO [dbo].[order_line] ([order_id], [book_id], [price])
        SELECT 
            o.order_id,
            ((o.order_id * 11 + itm.seq * 17) % 300) + 1 AS book_id,
            CAST((12.50 + ((o.order_id * 3 + itm.seq * 7) % 45) + CASE WHEN itm.seq = 1 THEN 0.99 ELSE 0.50 END) AS DECIMAL(5,2)) AS price
        FROM [dbo].[cust_order] o
        CROSS JOIN (VALUES (1), (2), (3)) AS itm(seq)
        WHERE (o.order_id % 4 != 0 OR itm.seq <= 2); -- Mezcla órdenes de 2 y 3 ítems
    END;

    -- order_history (Trazabilidad realista de estados de pedido)[cite: 1]
    IF NOT EXISTS (SELECT 1 FROM [dbo].[order_history])
    BEGIN
        -- Paso 1: Pedido recibido
        INSERT INTO [dbo].[order_history] ([order_id], [status_id], [status_date])
        SELECT 
            o.order_id,
            1, -- Pendiente de Pago
            o.order_date
        FROM [dbo].[cust_order] o;

        -- Paso 2: Procesamiento y entrega
        INSERT INTO [dbo].[order_history] ([order_id], [status_id], [status_date])
        SELECT 
            o.order_id,
            CASE 
                WHEN o.order_id % 12 = 0 THEN 5 -- Cancelado
                WHEN o.order_id % 7 = 0 THEN 3  -- Enviado
                ELSE 4                          -- Entregado
            END,
            DATEADD(HOUR, 24 + ((o.order_id * 5) % 72), o.order_date)
        FROM [dbo].[cust_order] o;
    END;

    COMMIT TRANSACTION;
    PRINT '¡Poblado de datos finalizado con éxito!';
    PRINT '600 órdenes, 300 libros, 250 clientes y 1450 líneas con nombres y títulos reales listos para BI.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT CONCAT('Error al poblar la base de datos: ', ERROR_MESSAGE());
END CATCH;
GO