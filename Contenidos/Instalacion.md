# Instalación

## Requisitos básicos para ejecutar PrivateGPT

- Actualizamos los paquetes e instalamos los paquetes que necesitaremos.

```sh 
sudo apt update -y 
sudo apt upgrade -y
sudo apt install curl git pip pipx make -y
```

## Procederemos a instalar Ollama

```sh
curl -fsSL https://ollama.com/install.sh | sh
```
 **Descargamos en binario de Ollama**
 
 Ollama se distribuye como un binario autónomo. Descárgalo en un directorio que esté en tu PATH.

 ```sh
sudo curl -L https://ollama.com/download/ollama-linux-amd64 -o /usr/bin/ollama
sudo chmod +x /usr/bin/ollama
 ```

Inicializamos el servicio:

```sh
sudo systemctl daemon-reload
sudo systemctl enable ollama
```

## Requisitos básicos para ejecutar PrivateGPT

- Instalamos Python 3.11 si aun no lo tenemos instalado. No se admiten versiones anteriores

```sh
# Abrir sources.list y agregar el repositorio
sudo nano /etc/apt/sources.list
# Añadir esta línea al final del archivo
deb http://ppa.launchpad.net/deadsnakes/ppa/ubuntu focal main
# Guardar y cerrar el archivo 

# Importar la clave GPG
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6A755776

# Actualizar la lista de paquetes
sudo apt update

# Instalar Python 3.11
sudo apt install python3.11
sudo apt install python3.11-venv

# Verificar la instalación
python3.11 --version
```
- Ahora instalaremos poetry 

```sh
pipx install poetry
export PATH=$PATH:~/.local/bin
```
- Clonamos el repositorio PrivateGPT e instalamos dependencias:

```sh
  git clone https://github.com/zylon-ai/private-gpt
  python3 -m venv private-gpt
  source private-gpt/bin/activate
  cd private-gpt
  poetry install --extras "ui llms-ollama embeddings-ollama vector-stores-qdrant"
 poetry add ebookLib html2text
 poetry install --extras "ui"
 poetry run python scripts/setup
 pip install torch
```
## Instalamos Cuda-Toolkit

CUDA (Compute Unified Device Architecture) es una plataforma de computación paralela desarrollada por NVIDIA que permite utilizar las GPU para realizar cómputos de propósito general. CUDA Toolkit es el conjunto de herramientas y bibliotecas que se utilizan para desarrollar, compilar y ejecutar aplicaciones que aprovechan las GPU de NVIDIA.

```sh
wget https://developer.download.nvidia.com/compute/cuda/12.5.0/local_installers/cuda-repo-debian12-12-5-local_12.5.0-555.42.02-1_amd64.deb

sudo dpkg -i cuda-repo-debian12-12-5-local_12.5.0-555.42.02-1_amd64.deb
sudo cp /var/cuda-repo-debian12-12-5-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo add-apt-repository contrib
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-5
```

- Drivers

```sh
sudo apt-get install -y cuda-drivers
sudo apt-get install -y nvidia-kernel-open-dkms
sudo apt-get install -y cuda-drivers
```

## Configuración local impulsada por Ollama

La forma más sencilla de ejecutar PrivateGPT de forma totalmente local es depender de Ollama para el LLM. Ollama proporciona LLM local e incrustaciones muy fáciles de instalar y usar, abstrayendo la complejidad del soporte de GPU. Es la configuración recomendada para el desarrollo local.

Instalamos los modelos que se utilizarán la cunfiguración predeterminada de ollama

```sh
ollama pull mistral
ollama pull nomic-embed-text
```
- Ahora, inicie el servicio Ollama (iniciará un servidor de inferencia local, que servirá tanto para el LLM como para las incrustaciones):

```sh
ollama serve 
```
- Una vez instalado, puede ejecutar PrivateGPT. Asegúrese de tener un Ollama funcionando ejecutándose localmente antes de ejecutar el siguiente comando.

```sh
set PGPT_PROFILES=ollama make run
```

- PrivateGPT utilizará el settings-ollama.yamlarchivo de configuración ya existente, que ya está configurado para usar Ollama LLM and Embeddings, y Qdrant. Revísalo y adáptalo a tus necesidades (diferentes modelos, diferente puerto de Ollama, etc.)

La interfaz de usuario estará disponible en `http://localhost:8001`

