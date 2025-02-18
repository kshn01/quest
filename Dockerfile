FROM node:22-alpine3.20

# Create the directory in the container
WORKDIR /usr/src/app

# Copy the package.json and package-lock.json
COPY package*.json ./

# Install the dependencies
RUN npm install

# Copy the application code to the container
COPY  . .

# Expose the port that your application listens on
EXPOSE 3000

# Start the application
CMD ["node", "src/000.js"]