FROM node:18
WORKDIR /app

# Copy package.json and package-lock.json first
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy source code
COPY . .

# Add your name file
RUN echo "VINAY KUMAR" > /wizexercise.txt

EXPOSE 3000
CMD ["node", "server.js"]

