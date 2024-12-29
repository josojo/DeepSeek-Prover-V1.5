#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Update and initialize git submodules
echo "Updating and initializing git submodules..."
git submodule update --init --recursive

# Install specific version of torch
echo "Installing torch..."
pip install torch==2.2.1

# Install other Python dependencies
echo "Installing Python dependencies..."
pip install -r requirements.txt

# Update package lists for upgrades and new package installations
echo "Updating package lists..."
sudo apt update

# Install tmux if not already installed
if ! command_exists tmux; then
    echo "Installing tmux..."
    sudo apt install -y tmux
else
    echo "tmux is already installed."
fi

# Install lsof if not already installed
if ! command_exists lsof; then
    echo "Installing lsof..."
    sudo apt install -y lsof
else
    echo "lsof is already installed."
fi

# List open files and network connections on port 8080
echo "Listing open files and network connections on port 8080..."
sudo lsof -i :8080 || echo "No process is using port 8080."

# Kill the process using port 8080 if it exists
if sudo lsof -i :8080 | grep -q 'LISTEN'; then
    echo "Killing process on port 8080..."
    sudo kill -9 $(sudo lsof -i :8080 | awk 'NR==2 {print $2}')
else
    echo "No process to kill on port 8080."
fi

# Run the Python server
echo "Running the Python server..."
python3 server/api.py