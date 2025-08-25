# Start from an official nginx base image
FROM nginx:1.27.3-alpine

# Copy only the required files to the image
COPY . /usr/share/nginx/html

# Expose the port where Nginx will run
EXPOSE 7000

CMD ["nginx", "-g", "daemon off;"]
