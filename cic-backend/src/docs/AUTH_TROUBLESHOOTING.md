# Authentication Troubleshooting Guide

## 🔍 Issue: Getting 401 Unauthorized Despite Being Logged In

### Common Causes & Solutions

---

## 1. ✅ Cookie Not Being Sent

### Problem

Better-auth uses cookies for session management. If the cookie isn't sent with the request, authentication will fail.

### Solution for Postman/Thunder Client

**The cookie must be sent in the request headers:**

```
Cookie: better-auth.session_token=YOUR_ACTUAL_TOKEN_VALUE
```

**NOT** as a Bearer token in Authorization header!

### How to Get the Cookie:

#### Option A: From Browser DevTools

1. Open your app in browser (`http://localhost:3000`)
2. Login with your credentials
3. Press `F12` → Go to **Application** tab
4. Click **Cookies** → Select `http://localhost:3000`
5. Find `better-auth.session_token`
6. Copy the **Value**

#### Option B: From Network Tab

1. Login to your app
2. Open DevTools → **Network** tab
3. Click any request after login
4. Look at **Request Headers**
5. Find the `Cookie` header
6. Copy the entire `better-auth.session_token=...` part

### In Postman:

1. Go to request **Headers**
2. Add header:
   - **Key**: `Cookie`
   - **Value**: `better-auth.session_token=PASTE_YOUR_TOKEN_HERE`

---

## 2. ✅ CORS Issues

### Problem

If your frontend and backend are on different origins, cookies won't be sent unless CORS is configured correctly.

### Check Your `.env`:

```env
CREDENTIALS=true
CORS_ORIGINS=http://localhost:3000
```

### Your `app.ts` should have:

```typescript
app.use(
  cors({
    origin: ["http://localhost:3000"],
    credentials: true, // MUST be true for cookies
  }),
);
```

---

## 3. ✅ Wrong BETTER_AUTH_URL

### Problem

The `BETTER_AUTH_URL` in your `.env` is currently set to the **frontend URL** (`http://localhost:3000`), but it should be the **backend URL**.

### Current (WRONG):

```env
BETTER_AUTH_URL="http://localhost:3000"  # ❌ This is frontend
```

### Should Be:

```env
BETTER_AUTH_URL="http://localhost:3001"  # ✅ This is backend
```

### Why This Matters:

Better-auth uses this URL for:

- Generating session tokens
- Validating callbacks
- Cookie domain settings

**Update this in your `.env` file and restart the server!**

---

## 4. ✅ Testing from Postman vs Browser

### When Testing from Postman:

Cookies work differently than in a browser. You need to:

1. **Get a valid session token from the browser** (after logging in)
2. **Manually add it to Postman headers**

### The Flow:

```
Browser Login → Get Cookie from DevTools → Copy to Postman → Test API
```

### Postman Headers Example:

```
Cookie: better-auth.session_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## 5. ✅ Session Token Expired

### Problem

Better-auth session tokens can expire. If you logged in a while ago, the token might be invalid.

### Solution:

1. Logout and login again in the browser
2. Get a fresh session token
3. Update the token in Postman

---

## 6. ✅ Different MongoDB Database

### Problem

If you're connecting to a different MongoDB database than where you logged in, the session won't be found.

### Check:

```env
DATABASE_URL=mongodb+srv://...your-actual-database...
```

Make sure both your backend and better-auth are using the **same database**.

---

## 🧪 Debug Mode

I've added debug logging to the `requireAuth` middleware. When you make a request, check your server console for:

```
🔍 Auth Debug - Cookie header: better-auth.session_token=...
🔍 Auth Debug - Authorization header: undefined
🔍 Auth Debug - Session result: ✅ Found
🔍 Auth Debug - User ID: abc123
🔍 Auth Debug - User Email: user@example.com
✅ Auth Success - User authenticated: abc123
```

### If You See:

```
❌ Auth Failed - No session or user found
```

This means:

- Cookie is sent but session is invalid/expired
- Session not found in database
- Wrong database connection

### If You See:

```
🔍 Auth Debug - Cookie header: undefined
```

This means:

- You forgot to add the Cookie header in Postman
- Cookie is not being sent

---

## 🔧 Quick Fix Checklist

- [ ] Update `BETTER_AUTH_URL` to `http://localhost:3001` in `.env`
- [ ] Restart the backend server after `.env` changes
- [ ] Login fresh in the browser to get a new session token
- [ ] Copy the `better-auth.session_token` value from browser cookies
- [ ] Add it as a `Cookie` header in Postman (not Authorization!)
- [ ] Ensure `CREDENTIALS=true` in `.env`
- [ ] Check server console for debug logs when making requests

---

## 📝 Testing Workflow

### Step 1: Start Fresh

```bash
# Update .env with correct BETTER_AUTH_URL
# Restart server
npm run dev:watch
```

### Step 2: Login in Browser

```
1. Go to http://localhost:3000
2. Login with your credentials
3. Open DevTools → Application → Cookies
4. Copy better-auth.session_token value
```

### Step 3: Test in Postman

```
1. Create a new request: GET http://localhost:3001/api/v1/favorites
2. Add Cookie header:
   Key: Cookie
   Value: better-auth.session_token=YOUR_TOKEN_VALUE
3. Send request
4. Check server console for debug logs
```

### Step 4: Check Server Logs

Look for:

- ✅ Green checkmarks = Success
- ❌ Red X marks = Failure
- 🔍 Debug info about what's being sent

---

## 🎯 Most Likely Solution

Based on your setup, **you need to:**

1. **Update `.env`:**

   ```env
   BETTER_AUTH_URL="http://localhost:3001"
   ```

2. **Restart server:**

   ```bash
   # Stop current server (Ctrl+C)
   npm run dev:watch
   ```

3. **Login fresh in browser** to get new session with correct URL

4. **Copy new session token** and update Postman

This should fix the 401 Unauthorized issue! 🎉

---

## Still Having Issues?

Check the debug logs in your terminal. They will show exactly what's happening:

- What cookies are being sent
- Whether a session is found
- What user data is retrieved

Share the debug output for further troubleshooting!

