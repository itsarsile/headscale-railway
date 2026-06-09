# Headscale & Headplane on Railway

This repository is a ready-to-deploy template for running [Headscale](https://github.com/juanfont/headscale) (an open-source, self-hosted implementation of the Tailscale control server) alongside [Headplane](https://github.com/tale/headplane) (a web UI for managing your Headscale network).

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new)

*(Note: Once you publish this repository as a template on Railway, you can update the link above to point directly to your specific Template ID)*

## Architecture

This template utilizes Railway's native **Docker Compose** support to automatically provision two separate services that communicate over Railway's private network:

1. **`headscale`**: The core API and coordination server.
2. **`headplane`**: The Web UI dashboard for managing users and machines.

## Deployment Instructions

Due to the security model of Headplane, deployment is a simple two-step process.

### Step 1: Initial Deployment

1. Click the **Deploy on Railway** button above (or connect this repository to a new Railway project).
2. Railway will automatically detect the `docker-compose.yml` file and start building both services.
3. Railway will prompt you for variables:
   *   **`COOKIE_SECRET`**: Enter a long, random string. This is used to secure your web sessions in Headplane.
   *   **`HEADPLANE_API_KEY`**: Leave this as the default (`replace_me_after_deployment`) for now.

Wait for both services to deploy. Headplane may show an error initially—this is normal because it doesn't have a valid API key yet!

### Step 2: Generate the API Key

Once the `headscale` service is running, you need to generate an API key so Headplane can manage your network:

1. In your Railway Dashboard, click on your **`headscale`** service.
2. Go to the **Terminal** tab.
3. Run the following command to generate a key that lasts for 90 days:
   ```bash
   headscale apikeys create --expiration 90d
   ```
4. Copy the long key output.
5. Go back to your Railway project and click on the **`headplane`** service.
6. Go to the **Variables** tab.
7. Find the `HEADPLANE_API_KEY` variable and replace its value with the key you just copied.
8. Railway will automatically restart Headplane with the new key.

You can now open the public URL for your Headplane service and start managing your Headscale network!
