# CAREOS Render staging deployment

This Blueprint is intentionally a **staging/demo deployment**, not a production clinical environment. It activates `local,render`, provisions synthetic foundation data, and creates the local reference-authority capability. Do not store or enter real patient information.

## Architecture

- `rootopathy-careos-demo`: public React/Nginx web service.
- `rootopathy-careos-demo-backend`: private Spring Boot service.
- `rootopathy-careos-demo-postgres`: private PostgreSQL 18 service with separate migration/runtime roles and a persistent disk.
- `rootopathy-careos-demo-kv`: managed Render Key Value with persistence and no public network access.

All resources are defined in the Singapore region.

## Deploy

1. Merge the Render deployment branch after GitHub quality and security checks pass.
2. In Render, create **New Blueprint Instance** and select this repository.
3. Render reads `render.yaml`.
4. During the initial Blueprint flow, populate every value marked `sync: false`.
5. For both `CAREOS_ALLOWED_ORIGINS` and `CAREOS_BASE_URL`, enter the exact public HTTPS origin of the frontend with no trailing slash. With the default service name this is normally the `rootopathy-careos-demo` Render URL shown by the Blueprint. If Render assigns a different hostname, update both values in the backend service and redeploy it.
6. Set:
   - `CAREOS_BOOTSTRAP_ADMIN_EMAIL`: staging administrator email.
   - `CAREOS_BOOTSTRAP_ADMIN_PASSWORD`: unique strong staging-only password.
   - `CAREOS_SECURITY_MAIL_FROM`: verified sender address.
   - `SMTP_HOST`, `SMTP_USERNAME`, `SMTP_PASSWORD`: authenticated STARTTLS SMTP credentials.
7. Apply the Blueprint.
8. Wait for PostgreSQL and Key Value to be available, then for the backend and frontend to become live.
9. Open the public frontend URL and sign in using the staging bootstrap credentials.

The browser always calls `/api` on the same public frontend origin. Nginx receives the backend's Render private `host:port` through `BACKEND_HOSTPORT` and proxies requests over Render's private network. On Render, Nginx explicitly forwards `X-Forwarded-Proto: https`; local Compose continues to forward its actual scheme.

## Security boundary

This deployment does **not** change CAREOS's `production` profile or its production startup guard. It deliberately uses the existing local/demo authorization boundary so the repository can be exercised on Render without pretending that production clinical, privacy, operational, or infrastructure acceptance exists.

The PostgreSQL service is private and uses separate `careos_migrator` and `careos_app` credentials. The runtime role receives the local-only V115 capability during first database initialization. Render Key Value has an empty public IP allow list and uses `noeviction` with journal-and-snapshot persistence.

Optional document, scanner, notification, job, worker, scheduler and external-provider capabilities remain disabled unless separately configured and accepted.

Before using CAREOS with real clinical data, create a separate production deployment using approved managed infrastructure, production-only credentials, backup/PITR and restore drills, monitoring/on-call, approved object storage and malware scanning, penetration/load testing, and the existing `production` startup guard. Never convert this demo simply by changing its name or entering patient data.

## Troubleshooting

- **PostgreSQL connection failure:** verify the private PostgreSQL service is live and its generated migration/runtime secrets are present on the backend through Blueprint references.
- **Redis/Key Value readiness failure:** verify `rootopathy-careos-demo-kv` is available in Singapore and the backend received its private host/port.
- **502 on `/api`:** verify `BACKEND_HOSTPORT` on the frontend and confirm the private backend is listening on port 8080.
- **Origin/CSRF rejection:** make `CAREOS_ALLOWED_ORIGINS` and `CAREOS_BASE_URL` exactly match the frontend HTTPS origin, without a trailing slash.
- **Login failure:** verify the staging bootstrap email/password supplied during Blueprint creation.
- **Password-reset/invitation email failure:** verify SMTP credentials and sender authorization with the SMTP provider.
