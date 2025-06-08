# backend/Dockerfile

# Use an official Node.js runtime as a parent image
FROM node:current-slim

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json first to leverage Docker layer caching
COPY package*.json ./

# Install app dependencies
RUN npm install --only=production

# Bundle app source
COPY . .

# Your app binds to port 8080, so expose it
EXPOSE 8080

# Define the command to run your app
CMD [ "node", "index.js" ]