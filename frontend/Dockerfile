FROM nginx:alpine

WORKDIR /usr/share/nginx/html

# Remove default nginx site content
RUN rm -rf /usr/share/nginx/html/*

# Copy web files
COPY web/ /usr/share/nginx/html/

# Add nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]