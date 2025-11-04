# Deliv - Aplicación de Comida (Food App)

Deliv es una aplicación móvil robusta para la visualización y pedido de comida, desarrollada en Flutter. El proyecto demuestra la implementación de principios de Arquitectura Limpia, gestión de estado con Provider y un sistema de diseño moderno y responsivo basado en Material 3.

##  Características Principales

* **Autenticación de Usuario:** Registro e inicio de sesión local. Los datos del usuario persisten localmente.
* **Exploración de Comidas:** Pantalla principal con búsqueda de platillos por nombre.
* **Filtros Avanzados:** Filtrado de platillos por categoría (Ej. "Beef", "Chicken", "Dessert") y por área geográfica (Ej. "Mexican", "Canadian").
* **Detalle del Platillo:** Vista detallada de cada comida, mostrando imagen, ingredientes, instrucciones y precio.
* **Gestión de Perfil:** Los usuarios pueden actualizar su nombre, correo electrónico y eliminar su cuenta.
* **Favoritos:** Funcionalidad para guardar y gestionar platillos favoritos, con persistencia local usando `sqflite`.
* **Carrito de Compras:** Sistema completo para añadir, eliminar y actualizar las cantidades de los platillos en el carrito.
* **Historial de Pedidos:** Los usuarios pueden ver un historial de todos los pedidos que han realizado.
* **Integración con WhatsApp:** Al finalizar la compra, la aplicación genera un resumen del pedido y lo envía al número de WhatsApp del negocio.
* **UI Moderna y Responsiva:**
  * Diseño basado en **Material 3**.
  * Soporte para **Tema Claro y Oscuro**.
  * Diseño adaptable que ajusta la UI para tablets y dispositivos de escritorio.

##  Arquitectura

El proyecto sigue los principios de **Arquitectura Limpia** (Clean Architecture), separando el código en tres capas principales. La estructura está organizada por **Feature-First**, donde cada funcionalidad (ej. `home`, `cart`, `profile`) contiene sus propias capas de presentación, dominio y datos.

1.  **Presentación (Presentation):**

  * Contiene las Vistas (Screens/Pages) y los ViewModels (Providers).
  * Utiliza **Provider** para la gestión del estado (MVVM), notificando a la UI de los cambios.
  * Maneja la navegación con **go\_router**, protegiendo rutas según el estado de autenticación.

2.  **Dominio (Domain):**

  * Contiene las **Entidades** (Entities) de negocio (ej. `Meal`, `Order`).
  * Define los **Casos de Uso** (UseCases) que encapsulan la lógica de negocio (ej. `GetMealsByCategoryUseCase`, `RegisterUseCase`).
  * Incluye las abstracciones (interfaces) de los **Repositorios** (Repositories).

3.  **Datos (Data):**

  * Implementa los **Repositorios** definidos en el dominio.
  * Contiene los **Modelos** (Models) que extienden las entidades para manejar la serialización (JSON, DB).
  * Define las **Fuentes de Datos** (DataSources):
    * **Remota:** Cliente `http` para consumir la API de `TheMealDB`.
    * **Local:** `sqflite` para persistir el usuario, carrito, favoritos y órdenes.

### Principales Patrones y Conceptos

* **MVVM (Model-View-ViewModel):** `Provider` actúa como ViewModel para exponer el estado y la lógica a la Vista.
* **Repository Pattern:** Abstrae el origen de los datos (API o DB local) del resto de la aplicación.
* **Dependency Injection:** Se realiza una inyección de dependencias manual y centralizada en `lib/core/di/injector.dart`.
* **Manejo de Errores:** Usa el paquete `dartz` para manejar los resultados de los casos de uso mediante `Either<Failure, Success>`, permitiendo un control explícito de fallos.

## 🛠️ Stack Tecnológico

| Categoría | Dependencia | Propósito |
| :--- | :--- | :--- |
| **Framework** | Flutter | SDK principal para UI multiplataforma. |
| **Gestión de Estado** | [provider](https://pub.dev/packages/provider) | Gestión de estado principal y ViewModel (MVVM). |
| **Navegación** | [go\_router](https://pub.dev/packages/go_router) | Navegación declarativa, tipada y con protección de rutas. |
| **Red (Networking)** | [http](https://pub.dev/packages/http) | Cliente HTTP para consumir la API REST de `TheMealDB`. |
| **Base de Datos Local** | [sqflite](https://pub.dev/packages/sqflite) | Persistencia de datos en base de datos SQL local. |
| **Integraciones** | [url\_launcher](https://pub.dev/packages/url_launcher) | Para abrir WhatsApp con el mensaje del pedido. |
| | [image\_picker](https://pub.dev/packages/image_picker) | Para seleccionar la imagen de perfil del usuario. |
| **Variables de Entorno**| [flutter\_dotenv](https://pub.dev/packages/flutter_dotenv) | Carga el número de WhatsApp desde un archivo `.env`. |
| **Utilitarios** | [dartz](https://www.google.com/search?q=https://pub.dev/packages/dartz) | Programación funcional (para `Either<Failure, T>`). |
| | [equatable](https://pub.dev/packages/equatable) | Simplifica la comparación de objetos en entidades y modelos. |
| | [connectivity\_plus](https://pub.dev/packages/connectivity_plus) | Verifica el estado de la conexión a internet. |

##  Instalación y Ejecución

Sigue estos pasos para configurar y ejecutar el proyecto localmente.

1.  **Clonar el repositorio:**

    ```sh
    git clone [URL-DEL-REPOSITORIO]
    cd food_app
    ```

2.  **Instalar dependencias de Flutter:**

    ```sh
    flutter pub get
    ```

3.  **Crear archivo de entorno:**
    En la raíz del proyecto, crea un archivo llamado `.env`.
    Añade el número de teléfono de WhatsApp (con código de país) que recibirá los pedidos:

    ```
    WHATSAPP_PHONE_NUMBER=521234567890
    ```

    *(Este número es utilizado por el `WhatsAppService`)*

4.  **Ejecutar la aplicación:**

    ```sh
    flutter run
    ```

### Plataformas Soportadas

El proyecto está configurado para ejecutarse en:

* **Android**
* **Windows**
