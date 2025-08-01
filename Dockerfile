# Use a specific Python base image that includes build tools
# python:3.9-slim-bookworm is based on Debian 12, which is actively maintained and more current.
FROM python:3.9-slim-bookworm

# Set the working directory in the container
WORKDIR /app

# Install system dependencies needed for scipy/numpy compilation
# gfortran is the Fortran compiler
# build-essential includes gcc, g++ and other tools
RUN apt-get update && apt-get install -y \
    gfortran \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements.txt and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of your application code
COPY . .

# Download NLTK data (this is done during the build process)
RUN python -c "import nltk; nltk.download('stopwords'); nltk.download('wordnet'); nltk.download('punkt')"

# Expose the port your Flask app will run on
EXPOSE 8000

# Command to run the application using Gunicorn
# IMPORTANT: Use the full path to gunicorn to ensure it's found at runtime.
CMD ["/usr/local/bin/gunicorn", "-w", "4", "-b", "0.0.0.0:8000", "app:app"]
