# inventario-app

Catálogo de inventario con interfaz web y base de datos local. Este repositorio es el **punto de partida** de la tarea de CI/CD — no incluye `Dockerfile`, workflow de GitHub Actions ni manifiestos de Kubernetes: esos tres se construyen como parte del trabajo asignado.

## Qué es

Una app Node.js/Express con:

- **Interfaz web** (`public/index.html`, `public/app.js`, `public/styles.css`): una tabla de productos con formulario para agregar y botón para eliminar.
- **Base de datos local** (`db.js`): un archivo JSON en `data/products.json` que persiste los productos entre reinicios del proceso — sin motor de base de datos externo ni dependencias nativas.
- **API REST** consumida por la interfaz.

## Ejecutar en local

```bash
npm install
npm start
# abrir http://localhost:3000
```

## Pruebas

```bash
npm test
```

## Endpoints

| Método y ruta | Qué hace |
|---|---|
| `GET /health` | Estado de salud: `200` si el proceso y el archivo de base de datos son accesibles, `500` si no (o si `SIMULATE_FAILURE=true`). |
| `GET /version` | Devuelve `version`, `color` y `hostname` — configurables por variables de entorno `APP_VERSION` / `APP_COLOR`. |
| `GET /api/products` | Lista todos los productos. |
| `GET /api/products/:id` | Devuelve un producto por id. |
| `POST /api/products` | Crea un producto (`name`, `sku`, `stock`, `price`). |
| `PATCH /api/products/:id` | Actualiza campos de un producto. |
| `DELETE /api/products/:id` | Elimina un producto. |
| `GET /` | Sirve la interfaz web. |

## Variables de entorno

| Variable | Por defecto | Para qué |
|---|---|---|
| `PORT` | `3000` | Puerto del servidor. |
| `APP_VERSION` | `v1` | Se muestra en `/version` y en el encabezado de la interfaz. |
| `APP_COLOR` | `blue` | Color del encabezado — útil para distinguir versiones en un despliegue. |
| `SIMULATE_FAILURE` | `false` | Si es `true`, `/health` responde siempre `500`. |
| `DB_PATH` | `./data/products.json` | Ruta del archivo de base de datos local. |

Ejecutar la aplicación:

```bash
npm start
```

Abrir en el navegador:

```
http://localhost:3000
```

---

# Ejecutar pruebas

```bash
npm test
```

Las pruebas verifican:

- Estado del servicio (`/health`)
- Endpoint de versión (`/version`)
- Creación de productos
- Eliminación de productos
- Validación de datos obligatorios

---

# Docker

Construcción de la imagen:

```bash
docker build -t inventario-app:v1 .
```

Ejecución:

```bash
docker run -d -p 3000:3000 inventario-app:v1
```

La imagen se publica automáticamente en GitHub Container Registry mediante GitHub Actions.

---

# Pipeline CI/CD

El pipeline implementado en GitHub Actions realiza automáticamente:

1. Descarga del código.
2. Instalación de dependencias.
3. Ejecución de pruebas.
4. Construcción de la imagen Docker.
5. Escaneo de seguridad con Trivy.
6. Publicación de la imagen en GitHub Container Registry (GHCR).

---

# Kubernetes

Se implementó un despliegue con:

- Deployment
- Service
- Readiness Probe
- Liveness Probe
- Startup Delay
- Rolling Update

Comandos principales:

```bash
kubectl apply -f k8s/
```

Verificar recursos:

```bash
kubectl get pods
kubectl get deployments
kubectl get services
```

---

# Estrategia Blue-Green

Se implementaron dos despliegues:

- Blue
- Green

El cambio de tráfico se realiza modificando el selector del Service.

Ejemplo:

```bash
kubectl patch service inventario-app-service -p '{"spec":{"selector":{"app":"inventario-app","version":"green"}}}'
```

---

# Seguridad

Se añadieron los siguientes mecanismos:

- Secret de Kubernetes para variables sensibles.
- Escaneo automático de vulnerabilidades mediante Trivy.
- Readiness Probe.
- Liveness Probe.

---

# Variables de entorno

| Variable | Descripción |
|----------|-------------|
| PORT | Puerto del servidor |
| APP_VERSION | Versión de la aplicación |
| APP_COLOR | Color de la versión desplegada |
| STARTUP_DELAY_SECONDS | Retraso antes de que la aplicación quede lista |
| SIMULATE_FAILURE | Simulación de fallo del servicio |
| API_KEY | Variable cargada desde Kubernetes Secret |

---

# API REST

| Método | Endpoint | Descripción |
|---------|----------|-------------|
| GET | /health | Estado de salud |
| GET | /version | Información de versión |
| GET | /api/products | Lista productos |
| GET | /api/products/:id | Consulta un producto |
| POST | /api/products | Crear producto |
| PATCH | /api/products/:id | Actualizar producto |
| DELETE | /api/products/:id | Eliminar producto |

---

# Autor

**Edisson Díaz**

Universidad Politécnica Salesiana

Carrera de Ciencias de la Computación