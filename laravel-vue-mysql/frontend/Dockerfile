    # Use a Node.js base image
    FROM node:lts-alpine

    # Set the working directory inside the container
    WORKDIR /app

    # Copy package.json and package-lock.json to install dependencies
    COPY package*.json ./

    # Install dependencies
    RUN npm install

    # Copy the rest of the application files
    COPY . .

    # Build the Vue.js application for production (optional, for production deployments)
    # RUN npm run build

    # Expose the port your Vue.js app runs on (e.g., 8080 for dev server, 80 for production with Nginx)
    EXPOSE 5173

    # Command to run the application
    CMD ["npm", "run", "dev"]