# 📦 DeliveryDesk — Sales Order & Delivery Status Cockpit

![Version](https://img.shields.io/badge/version-1.2.0-4f8ef7?style=flat-square)
![SAPUI5](https://img.shields.io/badge/SAPUI5-1.120-0070f3?style=flat-square)
![OData](https://img.shields.io/badge/OData-V4-8b5cf6?style=flat-square)
![Three.js](https://img.shields.io/badge/Three.js-r128-06b6d4?style=flat-square)
![Anime.js](https://img.shields.io/badge/Anime.js-3.2.1-22c55e?style=flat-square)
![License](https://img.shields.io/badge/license-Internal-gray?style=flat-square)
![Last Commit](https://img.shields.io/badge/last%20commit-2026--07--13-22c55e?style=flat-square)

> A **zero-code-view** SAP Fiori application that eliminates the classic multi-transaction SAP GUI workflow — no more jumping between **VA03 → VL03N → VF03**. Everything you need to monitor, track and manage sales orders and their delivery lifecycle is in one single, beautiful screen.

📋 **[View Changelog](./CHANGELOG.md)** &nbsp;·&nbsp; 🚀 **[Live Demo on Netlify](#deployment)** &nbsp;·&nbsp; 🎯 **[Quick Start](#quick-start)**

---

## 📸 What It Looks Like

| Dashboard | Deliveries | Analytics |
|-----------|-----------|-----------|
| Dark-theme KPI cards with animated rings | Live shipment tracker with progress bars | 4 real-time charts with animated bars |

| Blocked Orders | Detail Drawer | Settings |
|---------------|--------------|---------|
| Red-highlighted rows, release button | Animated step-by-step delivery tracker | Toggle switches, SAP connection config |

---

## 🧠 Before You Read — Key Terms Explained

If you're new to SAP SD (Sales & Distribution) or web tech, here's what every term in this project means:

### 🏢 SAP Terms

| Term | Full Form | What It Means |
|------|-----------|---------------|
| **SAP** | Systems, Applications & Products | The world's largest ERP (Enterprise Resource Planning) software company. Used by 400,000+ businesses worldwide to manage finance, logistics, HR, and sales. |
| **S/4HANA** | SAP Business Suite 4 SAP HANA | SAP's modern ERP platform, running on the HANA in-memory database. Think of it as the "engine" behind a company's entire operations. |
| **HANA Cloud** | SAP HANA Cloud | A cloud-based, in-memory database-as-a-service. Instead of hosting the database on your own servers, it runs on SAP's cloud infrastructure. Extremely fast for analytics. |
| **SD** | Sales & Distribution | A module (department) inside SAP that handles all sales processes — creating orders, pricing, delivery, billing, and customer management. |
| **VA03** | View Sales Order (Transaction) | The SAP GUI screen code to *display* a sales order. You type `VA03` in the SAP transaction bar to open it. |
| **VL03N** | Display Outbound Delivery | The SAP GUI screen to view a delivery document (whether goods have been shipped). |
| **VF03** | Display Billing Document | The SAP GUI screen to view an invoice/billing document. |
| **Sales Order** | — | A legal document created when a customer places an order. Contains what the customer wants, quantity, price, delivery date, etc. |
| **Delivery Document** | — | A document created when the warehouse starts processing the order for shipment. Linked to the sales order. |
| **Billing Document** | — | An invoice generated after goods are shipped. Linked to both the sales order and delivery. |
| **GI (Goods Issue)** | — | The act of physically moving goods out of the warehouse. Once GI is posted, stock decreases and the delivery is "done". |
| **VBAK** | — | The SAP database table that stores **sales order header** data (order number, customer, total value, etc.). |
| **VBAP** | — | The SAP database table that stores **sales order item** data (material, quantity, price per line). |
| **VBUK** | — | The SAP database table that stores **overall status** of a sales order (delivery status, billing status, etc.). |
| **VBUP** | — | The SAP database table that stores **item-level status** of a sales order. |
| **CDS View** | Core Data Services View | A modern way to define database queries directly on the ABAP layer. Like a SQL view, but with built-in metadata, annotations, and associations. Used to define what data the OData service exposes. |
| **OData** | Open Data Protocol | A REST-based protocol (like an API standard) that SAP uses to expose data to frontend apps. V2 is the older version, V4 is the modern one with better filtering, querying, and performance. |
| **OData V2** | — | The older SAP OData standard. Used by classic Fiori Elements apps. Auto-generated using `@OData.publish: true` on a CDS view. |
| **OData V4** | — | The modern SAP OData standard. More powerful, supports complex queries, streaming, and is required for SAP Fiori Elements V4 and RAP. |
| **RAP** | RESTful ABAP Programming Model | SAP's modern backend framework for building OData V4 services. Instead of auto-generating a service, you explicitly define: a CDS view, a behavior definition, a service definition, and a service binding. Much more structured and scalable than V2. |
| **Behavior Definition (BDEF)** | — | An ABAP RAP artifact that defines what *actions* are allowed on an entity — e.g., create, update, delete, or custom actions like "Release Block". |
| **Service Definition** | — | An ABAP RAP artifact that says which CDS views are exposed in the OData service (like a manifest for the API). |
| **Service Binding** | — | An ABAP RAP artifact that actually *publishes* the service — binds it to a protocol (OData V2 or V4) and makes it accessible via a URL. |
| **Fiori Elements** | — | An SAP framework that auto-generates UI (List Reports, Object Pages, etc.) from metadata annotations on CDS views. You write annotations, Fiori Elements draws the screen — no manual UI coding required. |
| **List Report** | — | A Fiori Elements screen template that shows a table of records with a filter bar (like a search + table). This is the main screen in DeliveryDesk. |
| **Object Page** | — | A Fiori Elements screen template that shows detailed information about a single record (like clicking into one sales order). |
| **Annotation** | — | Metadata added to CDS fields using `@UI.*`, `@Semantics.*` etc. These tell Fiori Elements how to render the field — as a table column, a filter, a chart, etc. |
| **DCL / Access Control** | Data Control Language | ABAP CDS files (`.asdcls`) that define who can see which data, based on authorization fields like sales organization. |
| **PFCG Role** | Profile Generator | The SAP tool used to assign authorizations to users (on-premise). Replaced by BTP IAM Role Collections in the cloud. |
| **BTP** | SAP Business Technology Platform | SAP's cloud platform where modern Fiori apps are hosted, configured, and authenticated. Includes services like XSUAA, HTML5 App Repository, Destinations, etc. |
| **XSUAA** | Extended Services for User Account and Authentication | The OAuth2-based authentication service on BTP. Replaces the classic SAP logon. Users log in once and get a token (JWT) that the app uses. |
| **MTA** | Multi-Target Application | A way to package a BTP app with all its dependencies (frontend module, XSUAA config, destination config) into one deployable archive (`.mtar` file). |
| **Sales Org** | Sales Organisation | A unit in SAP that represents a selling entity — e.g., `1010 = Germany`, `2020 = UK`. Each order is assigned to one sales org. |
| **Sold-To Party** | — | The customer who placed the order. There can also be a Ship-To Party (where goods are delivered) and Bill-To Party (who gets the invoice). |
| **Delivery Block** | — | A manual or automatic flag on a sales order that prevents delivery processing until it is removed. E.g., "Credit Block" means the customer's credit limit is exceeded. |

### 💻 Web Technology Terms

| Term | What It Means |
|------|---------------|
| **Three.js** | A JavaScript library for creating 3D graphics in the browser using WebGL. In this project, it powers the animated particle network background. |
| **Anime.js** | A lightweight JavaScript animation library. Used for staggered page load animations, count-up numbers, progress bars, drawer transitions, and all micro-animations. |
| **WebGL** | Web Graphics Library — a browser API that allows GPU-accelerated 2D and 3D graphics. Three.js uses WebGL under the hood. |
| **SPA** | Single Page Application — a web app that never fully reloads the page. Navigation between pages just swaps out HTML content using JavaScript (like what we built in DeliveryDesk). |
| **Router** | The JavaScript code that decides which "page" to show based on which nav item was clicked. Our `goTo()` function is the router. |
| **Canvas API** | A browser API for drawing 2D graphics with JavaScript. Used to draw the donut chart and analytics charts. |
| **CDN** | Content Delivery Network — a global network of servers that hosts files (like libraries). We load Three.js and Anime.js from Cloudflare's CDN so you don't need to install them. |
| **LocalStorage** | A browser feature that lets a website save small amounts of data on your computer (persisted between sessions). Used to remember your dark/light mode preference. |
| **Clipboard API** | A browser API that lets JavaScript copy text to the clipboard. Used for the "click order number to copy" feature. |
| **CSS Variables** | Custom properties in CSS (e.g., `--accent: #4f8ef7`) that make theming easy. Changing one variable updates the whole UI. |
| **Netlify** | A free cloud hosting platform for static websites. Since DeliveryDesk's frontend is pure HTML/CSS/JS, it can be deployed to Netlify in minutes. |

---

## ✨ Features

### 📊 Dashboard (Home)
- **5 KPI Cards** — Total Orders, Delivered, Pending/Partial, Blocked, Total Net Value
- **Animated SVG ring gauges** on each KPI card
- **Count-up number animation** on page load (Anime.js)
- **Status donut chart** — visual breakdown of all orders by delivery status
- **Sales Org bar chart** — order volume per sales organisation
- **Activity feed** — last 5 order events with timestamps

### 🚚 Deliveries Page
- Full shipment tracker for all 20 orders
- Animated **progress bars** (green = delivered, blue = in transit, red = blocked)
- Carrier name, ETA, GI Status per row
- Click any row to open the **detail drawer**

### 📊 Analytics Page
- **4 animated charts**: Status distribution, Orders by Org, Orders by Type, Billing performance
- **Key metrics summary**: Delivery rate %, Billing rate %, Average order value

### 💰 Billing Page
- Invoice register showing billing status for all orders
- KPI cards: Fully Billed, Partial, Not Billed, Returns, Billing Rate %
- Color-coded billing status badges

### 🚫 Blocked Orders Page
- Red-bordered table of all blocked orders
- Block reason badge (Credit Block, Payment Overdue, Export License, etc.)
- **"Request Release"** button — sends notification toast (connected to SAP in real implementation)

### ⏰ Overdue Page
- Automatically detects orders where ETA < today and delivery isn't complete
- Shows "X days late" badge
- **"Escalate"** button for carrier escalation workflow

### ⚙️ Settings Page
- Dark/Light mode toggle
- Particle background toggle
- SAP OData V4 service URL configuration
- Notification preferences

### 🔐 Authorizations Page
- Current user profile with session status
- Assigned BTP IAM Role Collections
- ABAP Authorization Object table (V_VBAK_VKO, S_SERVICE, etc.)

### 🎨 UI / UX Features
- **Three.js** animated particle network background with mouse parallax
- **Anime.js** staggered entrance animations on every page
- **Dark mode** (default) + Light mode toggle with localStorage persistence
- **Live clock** in the topbar (real-time HH:MM:SS)
- **Keyboard shortcuts**: `ESC` closes drawer, `/` focuses search
- **Click-to-copy** order number with clipboard API feedback
- **Notification bell** with dropdown panel
- **Detail drawer** with animated delivery progress steps
- **CSV export** of filtered data
- **Print-friendly** CSS (sidebar/controls hidden when printing)
- **Responsive** layout (collapses sidebar on mobile)

---

## 🏗️ Project Architecture

```
DeliveryDesk/
│
├── 📁 webapp/                          ← Frontend (Fiori / HTML5 app)
│   ├── index.html                      ← Main app — all UI, Three.js, Anime.js
│   ├── manifest.json                   ← SAP app descriptor (routing, data sources)
│   ├── Component.js                    ← SAPUI5 app component bootstrap
│   └── i18n/
│       └── i18n.properties             ← Internationalisation strings
│
├── 📁 abap/                            ← ABAP backend artifacts
│   ├── cds/
│   │   ├── I_SalesOrderHeader.asddls   ← Interface CDS view (joins VBAK + VBUK)
│   │   ├── I_SalesOrderHeader.asdcls   ← DCL access control
│   │   ├── I_SalesOrderItem.asddls     ← Interface CDS view (joins VBAP + VBUP)
│   │   ├── I_SalesOrderItem.asdcls     ← DCL access control
│   │   ├── C_SalesOrderHeader.asddls   ← Consumption CDS (UI annotations)
│   │   └── C_SalesOrderItem.asddls     ← Consumption CDS (UI annotations)
│   └── rap/                            ← RAP artifacts (OData V4)
│       ├── R_SalesOrderHeader.asbdef   ← Behavior Definition (read-only)
│       ├── ZBP_SalesOrderHeader.abap   ← Behavior Implementation class
│       ├── ZSALESORDER_SRV.srvd        ← Service Definition
│       └── ZSALESORDER_UI.srvb         ← Service Binding (OData V4 UI)
│
├── 📄 ui5.yaml                         ← UI5 tooling config (dev server, proxy, deploy)
├── 📄 netlify.toml                     ← Netlify deployment config
├── 📄 mta.yaml                         ← BTP Multi-Target Application descriptor
├── 📄 xs-security.json                 ← XSUAA OAuth2 configuration
├── 📄 package.json                     ← Node.js dependencies
├── 📄 .gitignore                       ← Git ignore rules
├── 📄 README.md                        ← This file
├── 📄 CHANGELOG.md                     ← Version history
└── 📄 DEPLOYMENT_GUIDE.md              ← Step-by-step SAP activation guide
```

---

## 🔄 How It Works — End to End

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER'S BROWSER                           │
│                                                                  │
│  index.html → Three.js (particles) + Anime.js (animations)      │
│            → JavaScript SPA Router (goTo function)              │
│            → 8 Pages: Home, Deliveries, Analytics, Billing,      │
│                        Blocked, Overdue, Settings, Auth          │
└────────────────────────────┬────────────────────────────────────┘
                             │ OData V4 requests (in production)
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    SAP BTP (Cloud)                               │
│                                                                  │
│  HTML5 App Repository  →  Destination Service  →  XSUAA         │
└────────────────────────────┬────────────────────────────────────┘
                             │ Proxied to S/4HANA
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                  SAP S/4HANA System                             │
│                                                                  │
│  Service Binding (ZSALESORDER_UI / OData V4)                    │
│       ↓                                                          │
│  Service Definition (ZSALESORDER_SRV)                           │
│       ↓                                                          │
│  RAP Behavior Definition (R_SalesOrderHeader)                   │
│       ↓                                                          │
│  Consumption CDS View (C_SalesOrderHeader)                      │
│       ↓                                                          │
│  Interface CDS View (I_SalesOrderHeader)                        │
│       ↓                                                          │
│  Database Tables: VBAK + VBUK + VBAP + VBUP + LIPS             │
│       ↓                                                          │
│  SAP HANA Cloud (in-memory DB)                                  │
└─────────────────────────────────────────────────────────────────┘
```

> **📌 Current State**: The frontend currently runs with **mock data** (20 hardcoded orders). The ABAP backend code is written and ready — it just needs to be activated inside an SAP S/4HANA system.

---

## ⚡ Quick Start

### Prerequisites
- [Node.js](https://nodejs.org/) v18 or higher
- [npm](https://npmjs.com/) v9 or higher
- Git

### 1. Clone the Repository

```bash
git clone https://github.com/Suraj-kummar/DeliveryDesk.git
cd DeliveryDesk
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Run Locally

```bash
npm start
```

This starts the **SAP Fiori Tools dev server** at:

```
http://localhost:8080/index.html
```

The browser opens automatically. Hot-reload is enabled — save a file and the browser refreshes instantly.

### 4. Or just open directly

Since the frontend is pure HTML, you can also just double-click `webapp/index.html` and open it in any browser — no server needed!

---

## 🚀 Deployment

### Option A — Netlify (Easiest, Free)

1. Go to [netlify.com](https://netlify.com) and sign in
2. Click **"Add new site" → "Import an existing project"**
3. Connect GitHub → select **`Suraj-kummar/DeliveryDesk`**
4. Settings are auto-detected from `netlify.toml`:
   - **Publish directory**: `webapp`
   - **Build command**: *(none needed)*
5. Click **Deploy** ✅

The `netlify.toml` file in this repo handles everything:
```toml
[build]
  publish = "webapp"

[[redirects]]
  from = "/*"
  to   = "/index.html"
  status = 200
```

### Option B — SAP BTP Cloud Foundry

> Requires an SAP BTP account with Cloud Foundry environment enabled.

```bash
# Install MTA Build Tool
npm install -g mbt

# Build the MTA archive
mbt build

# Deploy to Cloud Foundry
cf deploy mta_archives/DeliveryDesk_1.2.0.mtar
```

### Option C — SAP ABAP Repository (On-Premise)

```bash
# Deploy frontend to ABAP system (BSP)
npm run deploy
```

Configure your system details in `ui5.yaml` first:
```yaml
deploy-to-abap:
  target:
    url: https://your-sap-system:44301
    client: '100'
    package: ZDELIVERYDESK
    transport: DEVK123456
```

---

## 🔧 SAP Backend Activation (ABAP System Required)

If you have access to an SAP S/4HANA system, follow these steps to activate the real backend:

### Step 1: Activate CDS Views (in order)
1. Open **Eclipse ADT** (ABAP Development Tools)
2. Activate in this order (dependencies first):
   - `I_SalesOrderHeader` → `I_SalesOrderItem`
   - `C_SalesOrderHeader` → `C_SalesOrderItem`

### Step 2: Activate RAP Behavior
1. Activate `R_SalesOrderHeader` (Behavior Definition)
2. Create class `ZBP_SalesOrderHeader` → activate

### Step 3: Publish OData V4 Service
1. Activate `ZSALESORDER_SRV` (Service Definition)
2. Activate `ZSALESORDER_UI` (Service Binding)
3. In the Service Binding editor → click **"Publish Locally"**
4. Test the service URL in the preview

### Step 4: Assign Authorizations
1. Create a PFCG role with object `V_VBAK_VKO`
2. Set field `VKORG` to your sales organisations
3. Assign the role to your user

### Step 5: Run the Fiori App
```bash
npm start
```
Now the app fetches real data from SAP instead of mock data.

---

## 📱 Pages & Navigation

| Page | URL Hash | Description |
|------|---------|-------------|
| **Sales Orders** | `#home` | Main dashboard with KPI cards, charts, full order table |
| **Deliveries** | `#deliveries` | Shipment tracker with carrier, ETA, progress bars |
| **Analytics** | `#analytics` | 4 charts: status donut, org bars, type bars, billing |
| **Billing** | `#billing` | Invoice register with billing status and net values |
| **Blocked Orders** | `#blocked` | Filtered view of blocked orders with release action |
| **Overdue** | `#overdue` | Orders past ETA with days-overdue and escalate action |
| **Settings** | `#settings` | App preferences, SAP connection config |
| **Authorizations** | `#auth` | BTP roles, ABAP auth objects, user profile |

---

## ⌨️ Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `/` | Jump focus to the search bar |
| `ESC` | Close the detail drawer |

---

## 🛠️ Tech Stack

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| Frontend Core | HTML5 + CSS3 + JavaScript | ES2022 | Structure, styling, logic |
| 3D Background | [Three.js](https://threejs.org/) | r128 | Animated particle network |
| Animations | [Anime.js](https://animejs.com/) | 3.2.1 | All UI transitions & micro-animations |
| Fonts | [Inter (Google Fonts)](https://fonts.google.com/specimen/Inter) | — | Premium typography |
| SAP UI Framework | SAPUI5 | 1.120.12 | Dev server, OData binding |
| SAP App Pattern | Fiori Elements V4 | — | List Report + Object Page |
| SAP Backend | ABAP RAP | — | OData V4 service generation |
| SAP Database | SAP HANA Cloud | — | In-memory real-time DB |
| Authentication | XSUAA / OAuth2 | — | BTP single sign-on |
| Hosting | Netlify / BTP CF | — | Static hosting / enterprise |
| Version Control | Git + GitHub | — | Source code management |

---

## 📊 Mock Data Overview

The app ships with **20 realistic mock sales orders** to demonstrate all functionality without an SAP backend:

| Field | Values |
|-------|--------|
| Sales Orgs | Germany (1010), UK (2020), USA (3030), India (4040) |
| Order Types | OR — Standard, ZOR — Urgent, RE — Returns |
| Delivery Status | Delivered, Pending, Partial, Blocked |
| Billing Status | Billed, Partial, Not Billed |
| Block Reasons | Credit block, Payment overdue, Export license, Min. order value |
| Carriers | DHL, FedEx, UPS, Royal Mail, Blue Dart, TNT, Delhivery, Schenker |
| Currencies | EUR, GBP, USD, INR |

---

## 👤 Author

**Suraj Kumar**
- SAP SD Consultant
- GitHub: [@Suraj-kummar](https://github.com/Suraj-kummar)

---

## 📄 License

This project is for internal/educational use.
All SAP-related terms, logos, and concepts are the property of SAP SE.

---

## 📋 Changelog

See [CHANGELOG.md](./CHANGELOG.md) for a full list of changes across versions.

**Latest — v1.2.0** (2026-07-13)
- Full SPA routing: 8 working pages
- Three.js animated particle background with mouse parallax
- Anime.js animations throughout
- Donut chart, org bar charts, analytics page
- Blocked orders with release action
- Overdue orders with escalation
- Settings page with toggle switches
- Authorization page with ABAP auth objects

