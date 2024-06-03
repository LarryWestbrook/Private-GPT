# Conceptos principales

PrivateGPT es un servicio que incluye un conjunto de primitivas AI RAG en un conjunto completo de API que proporciona un marco de desarrollo GenAI privado, seguro, personalizable y fácil de usar.

Utiliza FastAPI y LLamaIndex como marcos centrales. Estos se pueden personalizar cambiando la base del código.

Admite una variedad de proveedores de LLM, proveedores de incrustaciones y almacenes de vectores, tanto locales como remotos. Estos se pueden cambiar fácilmente sin cambiar el código base.

## Configuraciones de instalación disponibles

Estos son los 3 componentes principales para la instalación:

- LLM: el gran proveedor de modelos de lenguaje utilizado para la inferencia. Puede ser local, remoto o incluso OpenAI.
- Incrustaciones: el proveedor de incrustaciones utilizado para codificar la entrada, los documentos y las consultas de los usuarios. Al igual que el LLM, puede ser local, remoto o incluso OpenAI.
- Almacén de vectores: el almacén utilizado para indexar y recuperar los documentos.

Hay un componente adicional que se puede habilitar o deshabilitar: la interfaz de usuario. Es una UI de Gradio que permite interactuar con la API de una manera más fácil de usar.

## Configuraciones y dependencias

Su configuración será la combinación de las diferentes opciones disponibles. Encontrarás configuraciones recomendadas en la sección de instalación . PrivateGPT utiliza poesía para gestionar sus dependencias. Puede instalar las dependencias para las diferentes configuraciones ejecutando `poetry install --extras "<extra1> <extra2>..."`. Los extras son las diferentes opciones disponibles para cada componente. Por ejemplo, para instalar las dependencias para una configuración local con UI y qdrant como base de datos vectorial, Ollama como LLM y HuggingFace como incrustaciones locales, ejecutaría

```sh
poetry install --extras "ui vector-stores-qdrant llms-ollama embeddings-huggingface".
```

## Instalaciones y configuración

PrivateGPT usa yaml para definir su configuración en archivos llamados `settings-<profile>.yaml`. Se pueden crear diferentes archivos de configuración en el directorio raíz del proyecto. PrivateGPT cargará la configuración al inicio desde el perfil especificado en la `PGPT_PROFILES` variable de entorno. Por ejemplo, ejecutando:

```sh
PGPT_PROFILES=ollama make run
```

cargará la configuración desde `settings.yaml` y `settings-ollama.yaml`.

`settings.yaml` siempre está cargado y contiene la configuración predeterminada.
`settings-ollama.yaml` se carga si el `ollama` perfil se especifica en la PGPT_PROFILESvariable de entorno. Puede anular la configuración predeterminada.`settings.yaml`.

# Acerca de las configuraciones totalmente locales 

Para ejecutar PrivateGPT en una configuración completamente local, deberá ejecutar LLM, Embeddings y Vector Store localmente.

## Incrustaciones
Para incrustaciones locales hay dos opciones:

- (Recomendado) Puede utilizar la opción 'ollama' en PrivateGPT, que se conectará a su instancia local de Ollama. Ollama simplifica mucho la instalación de LLM locales.
- Puedes usar la opción 'incrustaciones-huggingface' en PrivateGPT, que usará HuggingFace.
Para que HuggingFace LLM funcione (la segunda opción), debe descargar el modelo de incrustaciones a la `models` carpeta. Puedes hacerlo ejecutando el `setup` script:

```sh
poetry run python scripts/setup
```

## LLM
Para LLM local hay dos opciones:

- (Recomendado) Puede utilizar la opción 'ollama' en PrivateGPT, que se conectará a su instancia local de Ollama. Ollama simplifica mucho la instalación de LLM locales.

- Puedes usar la opción 'llms-llama-cpp' en PrivateGPT, que usará LlamaCPP. Funciona muy bien en Mac con Metal la mayoría de las veces (aprovecha Metal GPU), pero puede ser complicado en ciertas distribuciones de Linux y Windows, dependiendo de la GPU. En el documento de instalación encontrará guías y solución de problemas.

Para que el LLM con tecnología LlamaCPP funcione (la segunda opción), debe descargar el modelo LLM a la modelscarpeta. Puedes hacerlo ejecutando el setupscript: 

```sh
poetry run python scripts/setup
```

