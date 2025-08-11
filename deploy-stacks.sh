#!/bin/bash

# List of directories for each stack
directories=("angular-python-mongodb" "laravel-vue-mysql" "react-node-postgres-redis")

# Dockerfile creation function
create_dockerfile() {
  local app_name=$1
  local app_dir=$2
  local dockerfile_path=$3

  echo "Creating Dockerfile for $app_name in $dockerfile_path"
  
  # Dockerfile content based on the app_name
  if [[ $app_name == "react" ]]; then
    cat <<EOL > $dockerfile_path
# Step 1: Build the React app
FROM node:16-alpine AS build
WORKDIR /app
COPY ./frontend/package*.json ./
RUN npm install
COPY ./frontend ./  # This works relative to the build context
RUN npm run build --prod

# Step 2: Serve the React app using Nginx
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOL
  elif [[ $app_name == "angular" ]]; then
    cat <<EOL > $dockerfile_path
# Step 1: Build the Angular app
FROM node:16-alpine AS build
WORKDIR /app
COPY ./frontend/package*.json ./
RUN npm install
COPY ./frontend ./  # This works relative to the build context
RUN npm run build --prod

# Step 2: Serve the Angular app using Nginx
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOL
  elif [[ $app_name == "vue" ]]; then
    cat <<EOL > $dockerfile_path
# Step 1: Build the Vue.js app
FROM node:16-alpine AS build
WORKDIR /app
COPY ./frontend/package*.json ./
RUN npm install
COPY ./frontend ./  # This works relative to the build context
RUN npm run build

# Step 2: Serve the Vue.js app using Nginx
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOL
  elif [[ $app_name == "node" ]]; then
    cat <<EOL > $dockerfile_path
# Node.js Backend
FROM node:16-alpine
WORKDIR /app
COPY ./backend/package*.json ./
RUN npm install
COPY ./backend /app
EXPOSE 3000
CMD ["node", "server.js"]
EOL
  elif [[ $app_name == "python" ]]; then
    cat <<EOL > $dockerfile_path
# Python Backend (Flask)
FROM python:3.9-slim
WORKDIR /app
COPY ./backend/requirements.txt .
RUN pip install -r requirements.txt
COPY ./backend /app
EXPOSE 5000
CMD ["python", "app.py"]
EOL
  elif [[ $app_name == "laravel" ]]; then
    cat <<EOL > $dockerfile_path
# PHP Laravel Backend
FROM php:7.4-fpm
WORKDIR /var/www
COPY ./backend /var/www
RUN composer install
EXPOSE 8000
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
EOL
  fi
  echo "$app_name Dockerfile created successfully."
}

# Loop through each directory and check if Docker image exists
for dir in "${directories[@]}"; do
  echo "Deploying stack for: $dir"
  
  # Define the Dockerfile path for each directory
  if [[ $dir == "react-node-postgres-redis" ]]; then
    dockerfile_react="./react-node-postgres-redis/frontend/Dockerfile"
    dockerfile_node="./react-node-postgres-redis/backend/Dockerfile"
    image_name_react="react-frontend"
    image_name_node="node-backend"

    # Create Dockerfile if the image doesn't exist
    if ! docker image inspect $image_name_react > /dev/null 2>&1; then
      create_dockerfile "react" "$dir" $dockerfile_react
      docker build -t $image_name_react ./react-node-postgres-redis/frontend
    else
      echo "React image found, skipping build."
    fi

    if ! docker image inspect $image_name_node > /dev/null 2>&1; then
      create_dockerfile "node" "$dir" $dockerfile_node
      docker build -t $image_name_node ./react-node-postgres-redis/backend
    else
      echo "Node.js image found, skipping build."
    fi

  elif [[ $dir == "angular-python-mongodb" ]]; then
    dockerfile_angular="./angular-python-mongodb/frontend/Dockerfile"
    dockerfile_python="./angular-python-mongodb/backend/Dockerfile"
    image_name_angular="angular-frontend"
    image_name_python="python-backend"

    # Create Dockerfile if the image doesn't exist
    if ! docker image inspect $image_name_angular > /dev/null 2>&1; then
      create_dockerfile "angular" "$dir" $dockerfile_angular
      docker build -t $image_name_angular ./angular-python-mongodb/frontend
    else
      echo "Angular image found, skipping build."
    fi

    if ! docker image inspect $image_name_python > /dev/null 2>&1; then
      create_dockerfile "python" "$dir" $dockerfile_python
      docker build -t $image_name_python ./angular-python-mongodb/backend
    else
      echo "Python image found, skipping build."
    fi

  elif [[ $dir == "laravel-vue-mysql" ]]; then
    dockerfile_vue="./laravel-vue-mysql/frontend/Dockerfile"
    dockerfile_laravel="./laravel-vue-mysql/backend/Dockerfile"
    image_name_vue="vue-frontend"
    image_name_laravel="laravel-backend"

    # Create Dockerfile if the image doesn't exist
    if ! docker image inspect $image_name_vue > /dev/null 2>&1; then
      create_dockerfile "vue" "$dir" $dockerfile_vue
      docker build -t $image_name_vue ./laravel-vue-mysql/frontend
    else
      echo "Vue.js image found, skipping build."
    fi

    # **Updated path**: Use `./laravel-vue-mysql/backend` for building the Laravel backend image
    if ! docker image inspect $image_name_laravel > /dev/null 2>&1; then
      create_dockerfile "laravel" "$dir" $dockerfile_laravel
      docker build -t $image_name_laravel ./laravel-vue-mysql/backend
    else
      echo "Laravel image found, skipping build."
    fi
  fi

  # Navigate to the directory and deploy using Docker Swarm
  cd $dir
  docker stack deploy -c docker-compose.yaml "${dir}-stack"
  cd ..
  
  echo "Deployment for $dir completed."
done

echo "All stacks deployed."
