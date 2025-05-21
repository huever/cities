
# 📖 README — Test iOS (Ualá)

## 📱 Descripción

Este proyecto es una prueba técnica para una posición iOS, donde se desarrolla una app de gestión de ciudades con búsqueda, favoritos y visualización en mapa, compatible tanto con iPad y iPhone y SplitView.  
Se utilizó **SwiftData** como motor de persistencia local, combinando **SwiftUI**, **asynchronous tasks** y paginado eficiente para manejar grandes volúmenes de datos.

## 🛠️ Tecnologías y herramientas

- `SwiftUI`
- `SwiftData`
- `MapKit`
- `Swift Concurrency (async/await)`
- `XCTest` para unit tests

## 📂 Arquitectura

Se aplicó un patrón **MVVM** clásico:

- `CitiesListView`: Vista principal con listado de ciudades, buscador y favoritos.
- `CitiesListViewModel`: Encargado de manejar lógica de negocio, persistencia y API calls.
- `MapView`: Mapa para mostrar ubicación de cada ciudad.
- `CityItem`: Modelo de datos persistente con SwiftData.

## 📌 Decisiones Técnicas

- **Persistencia con SwiftData**: Elegí SwiftData por su integración nativa con SwiftUI y la facilidad para definir modelos con `@Model`.
  
- **Manejo de grandes volúmenes de datos**:  
  El JSON original contenía **+200.000 objetos**, lo que volvía lento el parsing y persistencia en un único hilo.  
  Para solucionarlo:
  - Dividí el array en *chunks* de **50 elementos**.
  - Usé `withThrowingTaskGroup` para distribuirlos en **varios threads concurrentes**.
  - Cada task trabaja con su propio `ModelContext`, evitando conflictos de acceso y mejorando tiempos de procesamiento.
  
- **Paginado eficiente**:  
  Implementé paginado local de **15 objetos por fetch** desde SwiftData, evitando cargar toda la base en memoria.  
  Esto además mejora UX en la UI al scrollear.

- **Buscador reactivo y filtro de favoritos**:  
  La búsqueda se reactualiza automáticamente al modificar el texto o el estado de favoritos.
  Al estar en un iPad el mapa se ira actualizando segun la búsqueda

## 🧪 Tests

Se incluyeron tests para:
- Verificar paginado.
- Validar búsqueda.
- Testear persistencia y favoritos.

## ✨ Cositas extra

- Diseño limpio y adaptable.
- Indicador de progreso durante importación de datos.
- Modo de sincronización manual.
- Custom `NavigationSplitView` para separar listado y mapa en pantallas grandes.
- Bandera de cada pais segun el **Country Code**

## 🚀 Cómo correrlo

1. Clonar el repo.
2. Abrir el proyecto en **Xcode 16+**.
3. Correr la app en **iPhone o iPad Simulator**.
4. Desde la barra de navegación, presionar `Sincronizar...` para descargar los datos. (solo la primera vez)
5. Buscar, marcar favoritos y explorar el mapa.
6. Si se desea se puede sincronizar nuevamente, se evitaran guardar los ids duplicados
