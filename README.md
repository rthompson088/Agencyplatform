# True Agency Platform

A two-sided platform for insurance/financial agencies — an **Agent View** for individual agents to track their book of business, production, and training, and an **Owner View** for agency owners to see aggregate performance across all agents.

This is currently a front-end prototype (static HTML/CSS/JS, no real database yet). It's structured as a starting point to evolve into a full app with real login and live data.

## Files
- `index.html` — sign-in / landing page, routes to Agent or Owner view
- `agent.html` — agent dashboard (book of business, production, training, dial tracker)
- `owner.html` — owner dashboard (leaderboard, team rollup, activity feed, agent drill-down)

## How to get this onto GitHub (no coding required)

1. Go to [github.com](https://github.com) and create a free account if you don't have one.
2. Click the **+** icon top right → **New repository**.
3. Name it `true-agency-platform`, leave it Public or Private (your choice), don't check any of the "initialize with" boxes, then click **Create repository**.
4. On the next page, look for **"uploading an existing file"** (a blue link in the instructions).
5. Drag and drop all three `.html` files from this folder into the upload box.
6. Scroll down, click **Commit changes**.

That's it — your code is now on GitHub.

## How to get it live on the web

1. Go to [vercel.com](https://vercel.com) or [netlify.com](https://netlify.com) and sign up using your GitHub account (this links them automatically).
2. Click **Add New Project** (Vercel) or **Add new site → Import an existing project** (Netlify).
3. Select the `true-agency-platform` repository you just created.
4. Leave all settings as default and click **Deploy**.
5. Within a minute, you'll get a live URL like `true-agency-platform.vercel.app`.

From then on, any time the files in your GitHub repository are updated, the live site updates automatically — no redeploying by hand.

## What's next

This version has no real login or database — the sign-in form doesn't check anything, and all the numbers (production, agents, leaderboard) are placeholder data. The next phase is connecting a real backend (Supabase) for authentication and live data, so agents and owners are seeing real information instead of fixed examples.
