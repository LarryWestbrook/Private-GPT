#!/bin/bash

# Actualizar paquetes e instalar dependencias
apt update -y && apt upgrade -y
apt install curl -y
apt install git -y
apt install python3-pip -y
apt install pipx -y
apt install make -y

# Instalar Ollama
curl -fsSL https://ollama.com/install.sh | sh
systemctl stop ollama
systemctl disable ollama

# Clonar el repositorio de privateGPT
git clone https://github.com/imartinez/privateGPT
cd privateGPT

# Instalar poetry usando pipx
pipx install poetry
export PATH=$PATH:~/.local/bin

# Instalar dependencias con poetry
poetry install --extras "ui llms-ollama embeddings-ollama vector-stores-qdrant"
poetry add ebookLib html2text

# Iniciar el servidor de Ollama y descargar modelos
ollama serve &
ollama pull mistral
ollama pull nomic-embed-text

# Ejecutar privateGPT
PGPT_PROFILES=ollama make run

# Configurar entorno virtual (opcional si ya configuraste antes)
git clone https://github.com/imartinez/privateGPT
python3 -m venv privateGPT
source privateGPT/bin/activate
cd privateGPT
pipx install poetry
export PATH=$PATH:~/.local/bin
poetry install --extras "ui llms-ollama embeddings-ollama vector-stores-qdrant"
poetry add ebookLib html2text
pip install torch

# Iniciar el servidor de Ollama y descargar modelos
ollama serve &
ollama pull mistral
ollama pull nomic-embed-text

# Ejecutar privateGPT
PGPT_PROFILES=ollama make run

# Configurar usuario y locales
adduser ia
usermod -aG sudo ia
apt install locales -y
dpkg-reconfigure locales
apt install python3-torch -y

# Configuración para Llama2 (opcional)
# Parar el servidor de Ollama
# ollama run llama2
# nano settings.yaml
# nano settings-ollama.yaml
