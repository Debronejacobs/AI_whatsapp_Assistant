# Use a base image with Python
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file first to leverage Docker cache.
# This path is relative to the build context (which is ./client)
COPY requirements.txt ./

# Install dependencies using pip.
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code from the client directory into the container
# The source path '.' is relative to the build context (which is ./client)
COPY . ./

# Expose the port the FastAPI app runs on
EXPOSE 8001

# Command to run the application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8001"]