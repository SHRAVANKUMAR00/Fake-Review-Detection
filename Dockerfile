# Use a specific Python base image that includes build tools
# python:3.9-slim-buster is a good choice as it's stable and based on Debian
# which makes apt-get reliable. It also has a smaller footprint than full images.
FROM python:3.9-slim-buster

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

# Download NLTK data (if not already handled in app.py or a separate script)
# This is a safe way to ensure NLTK data is available in the Docker image
RUN python -c "import nltk; nltk.download('stopwords'); nltk.download('wordnet'); nltk.download('punkt')"

# Expose the port your Flask app will run on
EXPOSE 8000

# Command to run the application using Gunicorn
# This is the same as your Procfile, but now inside Docker
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8000", "app:app"]