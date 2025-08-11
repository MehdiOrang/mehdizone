# Node.js Backend
FROM node:18-alpine
WORKDIR /app
COPY ./package*.json ./
RUN npm install
COPY ./ /app
EXPOSE 3001
CMD ["node", "server.js"]
