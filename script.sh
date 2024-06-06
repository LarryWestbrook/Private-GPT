#!/bin/bash

# Actualizar paquetes e instalar dependencias
apt update -y && apt upgrade -y
apt install curl git python3-pip python3-venv -y
apt install locales -y
apt install make -y

# Instalar Ollama
curl -fsSL https://ollama.com/install.sh | sh
systemctl stop ollama
systemctl disable ollama

# Clonar el repositorio de privateGPT
git clone https://github.com/imartinez/privateGPT
cd privateGPT

# Configurar entorno virtual y Python versión 3.11
python3.11 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install poetry
export PATH=$PATH:~/.local/bin

# Instalar dependencias con poetry
poetry install --extras "ui llms-ollama embeddings-ollama vector-stores-qdrant"
poetry add ebookLib html2text torch

# Iniciar el servidor de Ollama y descargar modelos
ollama serve &
sleep 10  # Esperar un poco antes de continuar para asegurarse de que Ollama se haya iniciado completamente
ollama pull mistral
ollama pull llama3
ollama pull nomic-embed-text

# Ejecutar privateGPT
PGPT_PROFILES=ollama poetry run python -m private_gpt
