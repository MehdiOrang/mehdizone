
````
# Project Setup for Backend and Frontend

This guide provides detailed steps for setting up both the **backend** and **frontend** of your project. It covers the installation of dependencies, the configuration of different stacks, and how to resolve any installation issues, such as those related to Composer.

---

## **1. Installing Composer (for PHP Backend)**

### **Error: "The installation directory '/usr/local/bin' is not writable"**

If you encounter the error `The installation directory '/usr/local/bin' is not writable` while installing Composer, follow these steps to resolve it:

#### **Steps to Install Composer:**

1. **Download Composer Installer**:
   First, download the Composer installer:
   ```bash
   curl -sS https://getcomposer.org/installer | php
````

2. **Move Composer to a Writable Directory**:
   You need `sudo` access to move Composer to `/usr/local/bin`. Run the following command:

   ```bash
   sudo mv composer.phar /usr/local/bin/composer
   ```

3. **Verify Installation**:
   Confirm that Composer has been successfully installed by checking its version:

   ```bash
   composer --version
   ```

#### **Alternative Installation Directory**:

If you don't want to modify system directories, you can install Composer in a directory where you have write access and update your `PATH`:

1. **Install Composer to a Local Directory**:

   ```bash
   curl -sS https://getcomposer.org/installer | php
   mkdir -p $HOME/bin
   mv composer.phar $HOME/bin/composer
   ```

2. **Update PATH**:
   Add this line to your `~/.bashrc` or `~/.zshrc` (depending on your shell):

   ```bash
   export PATH="$HOME/bin:$PATH"
   ```

3. **Reload the shell**:

   ```bash
   source ~/.bashrc    # For Bash users
   source ~/.zshrc     # For Zsh users
   ```

4. **Verify Installation**:

   ```bash
   composer --version
   ```

---

## **2. Setting Up Your Frontend and Backend Locally**

Below are the detailed steps for setting up the **React**, **Angular**, and **Vue.js** frontends along with their respective **Node.js**, **Python**, and **Laravel** backends.

### **Frontend Setup (React, Angular, and Vue.js)**

#### **For React (Frontend)**

1. **Install React**:
   Use the following command to create your React app:

   ```bash
   npm init react-app my-app
   cd my-app
   ```

2. **Run React App**:
   Start the React development server:

   ```bash
   npm start
   ```

   Your React app should be available at `http://localhost:3000`.

#### **For Angular (Frontend)**

1. **Install Angular CLI**:
   Install Angular CLI globally on your system:

   ```bash
   npm install -g @angular/cli
   ```

2. **Create an Angular Project**:
   Create a new Angular project:

   ```bash
   ng new frontend --routing --style=scss
   cd frontend
   ```

3. **Run Angular App**:
   Start the Angular development server:

   ```bash
   ng serve
   ```

   Your Angular app should be available at `http://localhost:4200`.

#### **For Vue.js (Frontend)**

1. **Install Vue CLI**:
   Install Vue CLI globally:

   ```bash
   npm install -g @vue/cli
   ```

2. **Create a Vue.js Project**:
   Create a new Vue.js project:

   ```bash
   vue create frontend
   cd frontend
   ```

3. **Run Vue.js App**:
   Start the Vue.js development server:

   ```bash
   npm run serve
   ```

   Your Vue.js app should be available at `http://localhost:8080`.

---

### **Backend Setup (Node.js, Python, and Laravel)**

#### **For Node.js (Backend)**

1. **Create a Backend Directory**:
   Inside your project folder, create a `backend` directory and initialize a Node.js app:

   ```bash
   mkdir backend
   cd backend
   npm init -y
   npm install express pg redis
   ```

2. **Create `server.js`**:
   Example `server.js` for your Node.js backend:

   ```javascript
   const express = require("express");
   const { Pool } = require("pg");
   const redis = require("redis");

   const app = express();
   const port = 3000;

   const pool = new Pool({
     user: 'myuser',
     host: 'db',
     database: 'mydatabase',
     password: 'mypassword',
     port: 5432,
   });

   const redisClient = redis.createClient({
     host: 'redis',
     port: 6379,
   });

   app.get("/", (req, res) => {
     res.send("Hello from Node.js backend");
   });

   app.listen(port, () => {
     console.log(`Server is running on http://localhost:${port}`);
   });
   ```

#### **For Python (Backend)**

1. **Set Up Virtual Environment**:
   Create and activate a virtual environment:

   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Linux/Mac
   .\venv\Scripts\activate   # On Windows
   ```

2. **Install Flask and PyMongo**:
   Install Flask and MongoDB dependencies:

   ```bash
   pip install Flask pymongo
   ```

3. **Create `app.py`**:
   Example `app.py` for your Python Flask backend:

   ```python
   from flask import Flask
   from pymongo import MongoClient

   app = Flask(__name__)

   client = MongoClient("mongodb://mongo:27017/")
   db = client["mydatabase"]

   @app.route("/")
   def hello():
       return "Hello from Python Flask backend"

   if __name__ == "__main__":
       app.run(debug=True, host="0.0.0.0", port=5000)
   ```

#### **For Laravel (Backend)**

1. **Create a Laravel Project**:

   ```bash
   composer create-project --prefer-dist laravel/laravel backend
   cd backend
   php artisan serve --host=0.0.0.0 --port=8000
   ```

---

## **3. Running Everything Locally with Docker**

Once your backend and frontend are set up, use Docker to run your applications:

1. **Docker Compose Setup**:
   In the root directory of your project, create a `docker-compose.yml` to configure all services (frontend, backend, database, etc.).

2. **Example `docker-compose.yml`**:
   Here’s an example for a project with React, Node.js, PostgreSQL, and Redis:

   ```yaml
   version: '3'
   services:
     frontend:
       build:
         context: ./frontend
       ports:
         - "80:80"
       depends_on:
         - backend

     backend:
       build:
         context: ./backend
       ports:
         - "3000:3000"
       environment:
         - POSTGRES_HOST=db
         - POSTGRES_PORT=5432
         - POSTGRES_DB=mydatabase
         - POSTGRES_USER=myuser
         - POSTGRES_PASSWORD=mypassword
       depends_on:
         - db
         - redis

     db:
       image: postgres:latest
       environment:
         - POSTGRES_USER=myuser
         - POSTGRES_PASSWORD=mypassword
         - POSTGRES_DB=mydatabase

     redis:
       image: redis:alpine
       ports:
         - "6379:6379"
   ```

3. **Build and Run**:
   Build and start the Docker containers:

   ```bash
   docker-compose up --build
   ```

This will run all your services locally. The frontend will be available on the respective ports, and the backend services will be connected.

---

### **4. Final Verification**

After running the above steps:

* **React**: `http://localhost:3000`
* **Angular**: `http://localhost:4200`
* **Vue.js**: `http://localhost:8080`
* **Node.js Backend**: `http://localhost:3000`
* **Python Flask Backend**: `http://localhost:5000`
* **Laravel Backend**: `http://localhost:8000`

---

### **Troubleshooting**

* If you encounter any issues during the setup, check the permissions for files and directories, particularly when running commands like `sudo` or installing dependencies globally.
* Ensure all necessary ports (like `3000`, `5000`, `4200`, etc.) are available and not being used by other applications.

---

