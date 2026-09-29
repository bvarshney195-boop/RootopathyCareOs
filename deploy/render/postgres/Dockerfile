FROM postgres:18-alpine@sha256:d3e1620b530c944afa6e887d22eb899824da68e19c52024bf98f5220c88a65b2
COPY --chown=postgres:postgres deploy/postgres/init/001-create-runtime-role.sh /docker-entrypoint-initdb.d/001-create-runtime-role.sh
RUN chmod 0555 /docker-entrypoint-initdb.d/001-create-runtime-role.sh
USER postgres
EXPOSE 5432
