#!/bin/bash
# privategpt documentation
# https://docs.privategpt.dev/installation/getting-started/installation
set -e

# PostgreSQL settings
PG_DB_NAME="ollama_db"
PG_USER="ollama_user"
PG_PASSWORD="pAsSw0Rd"  # Change this to a secure password

# Define the PID file
PID_FILE="/tmp/private_gpt.pid"

function install_ollama(){
    if ! command -v ollama &> /dev/null; then
        echo "ollama not installed, installing..."
        curl -fsSL https://ollama.com/install.sh | sh
        ollama pull mistral
        ollama pull nomic-embed-text
    fi
}


# Function to check if the script is already running
is_running() {
    if [ -f "$PID_FILE" ]; then
        local pid
        pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null; then
            return 0  # Process is running
        else
            rm "$PID_FILE"
        fi
    fi
    return 1  # Process is not running
}


# Function to install and configure PostgreSQL
function setup_postgresql() {
    echo "Checking if PostgreSQL is installed..."
    if ! command -v psql &> /dev/null; then
        echo "PostgreSQL not installed, installing..."
        # Install the necessary software properties common package
        sudo apt-get install -y software-properties-common

        # Import the PostgreSQL signing key
        wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

        # Add the PostgreSQL repository to your system
        sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main"

        # Update the package lists again to include the new PostgreSQL repository
        sudo apt-get update -y 
        sudo apt install postgresql-16 postgresql-contrib postgresql-16-pgvector -y 

        # Start the PostgreSQL service
        sudo systemctl start postgresql
        sudo systemctl enable postgresql
    fi

    # Create a database and a user
    sudo -u postgres psql -c "CREATE DATABASE $PG_DB_NAME;"
    sudo -u postgres psql -c "CREATE USER $PG_USER WITH PASSWORD '$PG_PASSWORD';"
    sudo -u postgres psql -c "ALTER USER $PG_USER  WITH SUPERUSER;"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $PG_DB_NAME TO $PG_USER;"
    sudo -u postgres psql -c "create extension vector;"
    # list databases to test 
    sudo -u postgres psql -c "\l"
}

is_ollama_running() {
    # Check if any process contains 'ollama serve' in its command line
    if ps aux | grep -v grep | grep 'ollama serve' > /dev/null; then
        return 0  # ollama is running
    else
        return 1  # ollama is not running
    fi
}

# Check if any flags are provided
if [ $# -eq 0 ]; then
    echo "No flags provided. Use -h for help."
    exit 1
fi

GIT_USER="tosin2013"  # Replace with your actual git username
REPO_URL="https://github.com/imartinez/privateGPT"
REPO_DIR="/home/$USER/privateGPT"
MODELS_DIR="/opt/models"  # Updated models directory

INSTALL=false
RUN=false
HELP=false

while getopts ":irh" opt; do
case $opt in
    i)
    INSTALL=true
    ;;
    r)
    RUN=true
    ;;
    h)
    HELP=true
    ;;
    \?)
    echo "Invalid option: -$OPTARG" >&2
    ;;
esac
done

if $HELP; then
    echo "Usage: $0 [-i] [-r] [-h]"
    echo "Options:"
    echo "  -i     Install dependencies and clone the repository"
    echo "  -r     Run the script"
    echo "  -h     Display this help message"
    exit 0
fi

if $INSTALL; then
    # Create MODELS_DIR if it does not exist
    if [ ! -d "$MODELS_DIR" ]; then
        sudo mkdir -p "$MODELS_DIR"
        if [ $? -ne 0 ]; then
            echo "Error: Unable to create directory $MODELS_DIR. Please run with appropriate permissions."
            exit 1
        fi
    fi

    sudo add-apt-repository ppa:deadsnakes/ppa
    sudo apt update
    sudo apt install python3.11-full -y
    sudo apt install python3.11-dev -y
    sudo apt install build-essential -y
    sudo apt install cmake -y
    sudo apt install python3-poetry -y
    sudo snap install yq --channel=v3/stable
    gcc --version
    g++ --version

    python3.11 --version

    # Clone the repository
    git clone "$REPO_URL" "$REPO_DIR"
    cd "$REPO_DIR"

    python3.11 -m venv .venv && source .venv/bin/activate 

    # Check if Poetry is installed, install it if it's not
    if ! command -v poetry &> /dev/null
    then
        echo "Poetry not installed, installing..."
        curl -sSL https://install.python-poetry.org | python3 -
        poetry install --extras "llms-ollama ui vector-stores-postgres embeddings-ollama storage-nodestore-postgres"

        yq write -i settings-ollama-pg.yaml 'postgres.password' "${PG_PASSWORD}"
        yq write -i settings-ollama-pg.yaml 'postgres.user' "${PG_USER}"
        yq write -i settings-ollama-pg.yaml 'postgres.database' "${PG_DB_NAME}"
    fi
    setup_postgresql
    install_ollama
fi

if $RUN; then
    cd "$REPO_DIR"
    python3.11 -m venv .venv && source .venv/bin/activate 

    if ! is_ollama_running; then
        nohup ollama serve > ollama.log 2>&1 &
        echo "Started ollama."
    else
        echo "ollama is already running."
    fi

    # Continue with the rest of your script... 
        # Check if the script is already running
    if ps aux | grep private_gpt | grep -v grep > /dev/null; then
        echo "The script is already running."
    else
        # Run the script in the background
        source .venv/bin/activate
        curl -sSL https://install.python-poetry.org | python3 -
        deactivate
        source .venv/bin/activate
        poetry install --extras "llms-ollama ui vector-stores-postgres embeddings-ollama storage-nodestore-postgres"
        ollama pull mistral
        ollama pull nomic-embed-text
        nohup bash -c "PGPT_PROFILES=ollama-pg make run" > /dev/null 2>&1 | tee -a /tmp/ollama-pg.log &
        echo "The script is now running in the background."
    fi
fi