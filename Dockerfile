# Build stage - Use nginx alpine image (lightweight)
FROM nginx:1.25-alpine

# Add labels for metadata
LABEL maintainer="Mahesh <pasapalamahesh2@gmail.com>"
LABEL description="Ecommerce Website Container"
LABEL version="1.0"

# Install curl for health checks
RUN apk add --no-cache curl

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy nginx configuration (optional - for better performance)
RUN mkdir -p /etc/nginx/conf.d

# Copy your project files
COPY . /usr/share/nginx/html/

# Create a health check endpoint
RUN echo "OK" > /usr/share/nginx/html/health.html

# Expose port 80 for HTTP
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD curl -f http://localhost/health.html || exit 1

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]