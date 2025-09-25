FROM node:14
WORKDIR /app


# Copy source
COPY ./app /app


# create the required file with your name at build time
RUN echo "VINAY KUMAR" > /wizexercise.txt


RUN npm install --production


EXPOSE 3000
CMD ["node", "server.js"]
