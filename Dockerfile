# ── Stage 1: Build nginx config ───────────────────────────────────────────────
# BUILDPLATFORM = the machine doing the build (your Mac ARM)
FROM --platform=$BUILDPLATFORM nginx:alpine AS builder

# Copy all frontend files
COPY index.html /usr/share/nginx/html/index.html
COPY nginx.conf /etc/nginx/templates/default.conf.template
COPY .env .env

# ── Stage 2: Runtime image ────────────────────────────────────────────────────
# TARGETPLATFORM = the platform the image will RUN on (linux/amd64)
FROM nginx:alpine

# Copy static files from builder
COPY --from=builder /usr/share/nginx/html/index.html /usr/share/nginx/html/index.html
COPY --from=builder /etc/nginx/templates/default.conf.template /etc/nginx/templates/default.conf.template
COPY --from=builder .env .env

EXPOSE 80

# Read BACKEND_HOST from .env, inject into nginx.conf, start nginx
CMD ["/bin/sh", "-c", "export $(grep -v '^#' .env | xargs) && envsubst '$BACKEND_HOST' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]