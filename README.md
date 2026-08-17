# Módulo 4 - DATA MANAGEMENT AND BUSINESS INTELLIGENCE
**MCDIA - SOE UAGRM**

## GRUPO 2
### Integrantes del grupo:
- Oliver Camacho Velasco
- Griselda Merino Herbas
- Eberth Canaviri Calle
- Cristhian Ortiz Mercado
---
Flujo del proyecto:
<img width="764" height="360" alt="image" src="https://github.com/user-attachments/assets/37d1fdeb-9581-4f81-b66e-3a8ccd02bd3a" />

---
### Reporte POWER BI - Bookstore
<img width="1222" height="675" alt="image" src="https://github.com/user-attachments/assets/8f557295-5831-45c3-abb7-65fd777b20d7" />

### Ejecuciones:
### Bookstore OLAB

<img width="729" height="735" alt="image" src="https://github.com/user-attachments/assets/1a81756f-504e-4c85-a620-6315ae3b2af3" />


### Bookstore ETL

- Main

<img width="954" height="388" alt="image" src="https://github.com/user-attachments/assets/1b24bca8-718b-45a9-8fce-b6e0b6b1641e" />

- Book

<img width="317" height="553" alt="image" src="https://github.com/user-attachments/assets/e26b3df9-ebea-4d50-9540-59ca8ac54559" />

- Customer

<img width="348" height="629" alt="image" src="https://github.com/user-attachments/assets/db6a5d51-338c-44a3-aeff-1778f32e3dcb" />

- Shipping Method

<img width="416" height="607" alt="image" src="https://github.com/user-attachments/assets/6397fea6-c2ff-4c3f-a2ae-0b9614868596" />

- Fact Orders

<img width="387" height="621" alt="image" src="https://github.com/user-attachments/assets/92eab619-7641-4346-97e0-7719845fd621" />


### Bookstore DW

<img width="633" height="139" alt="image" src="https://github.com/user-attachments/assets/31aaa7f4-0167-4119-89aa-9ee1fa2f0c9e" />

<img width="1352" height="982" alt="image" src="https://github.com/user-attachments/assets/3701f8fe-12c5-4dd0-ae76-1be59ae451dd" />


### Bookstore OLTP

<img width="576" height="152" alt="image" src="https://github.com/user-attachments/assets/a60f3118-b84a-4a86-b715-a0f1baea8faf" />

<img width="1302" height="824" alt="image" src="https://github.com/user-attachments/assets/465d8f5a-076b-4cc8-b256-592c1895e4ec" />

---

# INSTALACIÓN
## Requisitos Previos

Antes de empezar, asegúrate de tener instalado:
* **Visual Studio**.
* **SQL Server**.

---

## Guía de Instalación y Ejecución Local

### 1. Clonar el repositorio
Abre tu terminal y ejecuta:
```bash
git clone https://github.com/CrisOrtiz/bookstore_tarea_1.2_MCDIA_Modulo_4.git
cd bookstore_tarea_1.2_MCDIA_Modulo_4 
```
### 2. Abrir el proyecto
- Abre Visual Studio.
- Ve al menú superior y selecciona Archivo > Abrir > Proyecto o solución... (o haz doble clic sobre el archivo .sln / .slnx dentro de la carpeta clonada).

### 3. Compilar la solución
- En el menú superior, selecciona Compilar > Compilar solución (o presiona la combinación de teclas Ctrl + Mayús + B).
- Verifica en la ventana Salida (en la parte inferior) que el proceso finalice con Compilación: 1 correctos, 0 errores.

### 4. Publicar la base de datos
- Ve al panel del Explorador de soluciones (habitualmente a la derecha).
- Haz clic derecho sobre el proyecto de base de datos y selecciona la opción Publicar....
-En la ventana emergente, haz clic en el botón Editar... (debajo de Conexión a base de datos de destino).
- Selecciona o escribe el nombre de tu servidor local de SQL Server. 💡 Puedes saber cual es tu local server name ejecutando en terminal: ```hostname```
- En el campo Nombre de la base de datos, escribe: Bookstore.
- Haz clic en Aceptar para cerrar la ventana de conexión.
- Haz clic en el botón Publicar (en la esquina inferior derecha).

<img width="1000" height="430" alt="image" src="https://github.com/user-attachments/assets/8716c3b6-3694-4dc8-b5b9-bef8f170e756" />

---

## ETL local con variables de entorno

Para evitar commits de configuraciones locales (como connection managers con Data Source de cada equipo), el repositorio ignora estos archivos:
- Bookstore_ETL/*.conmgr
- Bookstore_ETL/bin/
- Bookstore_ETL/obj/
- Bookstore_ETL/.env.local

Flujo recomendado:
1. Copia Bookstore_ETL/.env.example a Bookstore_ETL/.env.local.
2. Ajusta los valores a tu entorno local de SQL Server.
3. Ejecuta el script Bookstore_ETL/scripts/Generate-ConnectionManagers.ps1.
4. Trabaja normalmente en paquetes ETL necesarios (por ejemplo DimCustomer.dtsx o DimShippingMethod.dtsx) sin subir archivos locales de conexión.

Nota: al compilar el proyecto Bookstore_ETL, el repositorio ejecuta automaticamente la generacion de connection managers locales (Directory.Build.targets). Si .env.local no existe, se crea con valores por defecto.

Ejemplo de ejecución:
```powershell
powershell -ExecutionPolicy Bypass -File .\Bookstore_ETL\scripts\Generate-ConnectionManagers.ps1
```
