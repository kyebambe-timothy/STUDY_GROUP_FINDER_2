# Netlify Deployment Plan

This project has:
- `frontend`: Vite + React app (deploy to Netlify)
- `backend`: Express API (deploy separately to a Node host)

## 1) Deploy backend first (blocking)

1. Deploy `backend` to a Node-compatible host (for example Render, Railway, Fly.io, or VPS).
2. Confirm a public backend URL is available, such as:
   - `https://api-yourapp.onrender.com`
3. Ensure backend environment variables are set on that host (DB credentials, JWT secret, etc.).
4. Verify health endpoint:
   - `GET /api/health` returns success.

## 2) Update backend CORS for Netlify domain

Current `backend/server.js` CORS only allows localhost origins.  
Before production, allow:
- Netlify domain (`https://<site>.netlify.app`)
- Custom domain (if any)

Recommended approach:
- Add `ALLOWED_ORIGINS` env var on backend host
- Parse it as comma-separated list
- Allow requests when `origin` is in that list

## 3) Configure Netlify for frontend

In Netlify site settings:
- Base directory: `frontend`
- Build command: `npm run build`
- Publish directory: `dist`

## 4) Configure frontend environment variables in Netlify

Add environment variable in Netlify:
- `VITE_API_BASE_URL=https://your-backend-domain/api`

Reason:
- Frontend API client uses:
  - `import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000/api'`
- Without this variable, production will incorrectly try localhost.

## 5) Add SPA routing fallback

Because React Router is used, add one SPA fallback rule so deep links work on refresh.

Option A (`frontend/public/_redirects`):
`/* /index.html 200`

Option B (`netlify.toml`):
- Use a redirect rule from `/*` to `/index.html` with status `200`.

## 6) Connect repository and branch strategy

1. Connect this Git repository to Netlify.
2. Set production branch (usually `main`).
3. Enable Deploy Previews for PRs.
4. Optionally assign preview backend URL for non-production branches.

## 7) Domain and HTTPS

1. Attach custom domain in Netlify (optional).
2. Confirm HTTPS certificate is active.
3. Add custom domain to backend CORS allowlist.

## 8) Post-deployment validation checklist

- Frontend loads from Netlify URL.
- Register/login works.
- Group/session/post/chat API calls return success.
- Browser has no CORS errors.
- Refreshing deep routes does not return 404.
- Backend logs show incoming requests from Netlify frontend.

## 9) Recommended rollout order

1. Deploy backend
2. Update CORS and verify `/api/health`
3. Set Netlify build settings + env vars
4. Add SPA redirect
5. Deploy frontend on Netlify
6. Run full smoke test
