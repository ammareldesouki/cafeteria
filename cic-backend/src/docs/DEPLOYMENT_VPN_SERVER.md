# Deploying to the organization's VPN server (replacing Railway)

This backend used to run on Railway (public HTTPS URL, automatic TLS, automatic deploy-on-push via `railway.json`). The organization has since provided its own server, reachable over its FortiClient VPN, to self-host on instead. This doc covers what's different and how to actually get the app running there.

**Target machine:** `Mobile-Student` (`10.10.13.3`, domain `cic-cbu.loc`) — a **Windows** machine on the org's internal network. It arrives bare; you're setting it up as the app server from scratch, not deploying onto something already configured. That changes a few things below versus a typical Linux VPS (notably: `pm2 startup` doesn't work on Windows — see "Starting the app" below).

## What changes vs. Railway

- **No automatic deploy.** Railway rebuilt and redeployed on every git push. Here, you `git pull` (or copy the build) onto the server yourself and restart the process manually.
- **No automatic TLS.** Railway terminated HTTPS at its edge (`app.set("trust proxy", 1)` in `app.ts` exists because of this). The Node process itself only ever spoke plain HTTP. On the new server you either serve plain HTTP over the VPN tunnel (the VPN's own encryption covers transport), or put a reverse proxy (nginx) in front with a cert if you want `https://` end to end.
- **No managed process supervisor.** Railway kept the process alive. Here you need **pm2**, which this repo already ships config for: [`ecosystem.config.cjs`](../../ecosystem.config.cjs) and the `deploy:prod` / `deploy:dev` npm scripts.
- **Env vars live in a real `.env` file on the server**, not a dashboard.

## One-time server setup (on `Mobile-Student`, over RDP)

1. Connect to the VPN (FortiClient), then RDP into `10.10.13.3`.
2. Install [Node.js 20+ for Windows](https://nodejs.org/) (the LTS `.msi` installer), then `npm install -g pm2`.
3. Clone the repo (Git for Windows, or `git clone` from an existing checkout) and `cd cic-backend`.
4. Copy `.env.example` to `.env` and fill in real values:
   - `DATABASE_URL` — the org's MongoDB server address, reachable from this host
   - `BETTER_AUTH_URL` — `http://10.10.13.3:3001` (or `https://...` if you set up a reverse proxy with TLS)
   - `CORS_ORIGINS` — comma-separated origins that will call this API (the Flutter app doesn't send an `Origin` header, so this mainly matters if/when there's a web admin panel)
   - `PORT` — `3001` (matches `ecosystem.config.cjs` and the code's default — keep these in sync if you ever change it)
5. `npm install && npm run build`
6. Open the port to other machines on the network — from an elevated PowerShell:
   ```powershell
   New-NetFirewallRule -DisplayName "OnTheWay API" -Direction Inbound -LocalPort 3001 -Protocol TCP -Action Allow
   ```

## Starting the app (Windows — `pm2 startup` won't work here)

`pm2 startup` only generates init scripts for Linux/macOS (systemd, launchd, etc.) — it's a no-op on Windows. To keep the app running after you log off RDP or the machine reboots, install pm2 as an actual Windows Service instead:

```powershell
npm run deploy:prod              # pm2 start ecosystem.config.cjs --only prod — confirm it runs first
npm install -g pm2-windows-service
pm2-service-install               # installs pm2 itself as a Windows Service; say yes when it asks to run `pm2 save`
pm2 save                          # persists prod as the process list the service resurrects on boot
```

After this, the `prod` app survives RDP logoff and machine reboot, since it's owned by a Windows Service rather than your interactive session.

Useful pm2 commands while iterating: `pm2 status`, `pm2 logs prod`, `pm2 restart prod`, `pm2 reload prod` (zero-downtime, since `exec_mode: "cluster"` is set).

To redeploy after a code change: `git pull && npm install && npm run build && pm2 reload ecosystem.config.cjs --only prod`.

The `deploy.production` block at the bottom of `ecosystem.config.cjs` is written for `pm2 deploy` over SSH (Linux-style) and doesn't fit an RDP/Windows target — ignore it, or delete it, and just run the steps above by hand / via a small PowerShell script on the machine.

## Pointing the Flutter app at the new server

Update `ApiConstat.baseUrl` in [`cafeteria/lib/core/constants/api.dart`](../../../cafeteria/lib/core/constants/api.dart) from the Railway URL to `http://10.10.13.3:3001/api/v1`.

If you're serving plain HTTP (no reverse proxy/TLS):
- **Android** blocks cleartext HTTP by default on API 28+ — add a network security config allowing your server's host, or set `android:usesCleartextTraffic="true"` in `AndroidManifest.xml` for testing.
- **iOS** App Transport Security blocks plain HTTP by default — add an `NSAppTransportSecurity` exception for the server's host in `Info.plist`.

Either of these works for internal testing; for anything closer to production, putting nginx + a cert in front of the Node process so the app can just use `https://` avoids both.

## Who can reach the server

`10.10.13.3` is a private address on the org's internal network (`cic-cbu.loc`, DNS `10.10.9.4`/`10.10.8.1`). Right now, only devices connected to the VPN (or already sitting on that same internal network, e.g. office Wi-Fi if it's the same subnet/routed) can reach the backend. Before rolling this out to real users, confirm with the organization whether staff will reach the app over the same office network the server is on (no VPN needed on their phones) or whether every device running the app needs FortiClient too — that materially affects rollout, and is still worth a quick confirmation even though the deployment itself can proceed without it.
