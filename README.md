# 📦 DeliveryDesk — Sales Order & Delivery Status Cockpit

![Version](https://img.shields.io/badge/version-1.1.0-4f8ef7?style=flat-square)
![SAPUI5](https://img.shields.io/badge/SAPUI5-1.120-0070f3?style=flat-square)
![License](https://img.shields.io/badge/license-Internal-gray?style=flat-square)
![Last Commit](https://img.shields.io/badge/last%20commit-2026--07--12-22c55e?style=flat-square)

> A zero-code-view SAP Fiori Elements app that replaces the classic **VA03 → VL03N transaction-hopping** workflow with a single, unified screen for monitoring sales orders and their delivery status.
> 
> 📋 See [CHANGELOG.md](./CHANGELOG.md) for full release history.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Key Design Decisions](#key-design-decisions)
- [Version Compatibility](#version-compatibility)
- [Available npm Scripts](#available-npm-scripts)
- [Roadmap](#roadmap)

---

## Overview

**DeliveryDesk** is an SAP S/4HANA Fiori Elements application built using the **List Report + Object Page** floorplan. It exposes sales order header and item data — including delivery, billing, and goods movement statuses — through an annotation-driven UI with **zero hand-written XML views**.

The app is built on a two-layer CDS architecture:

| Layer | Purpose |
|-------|---------|
| **Interface views** (`I_*`) | Joins raw ABAP tables (`VBAK`, `VBUK`, `VBAP`, `VBUP`, `LIPS`), keeps logic reusable |
| **Consumption views** (`C_*`) | All `@UI.*` and `@OData.*` annotations live here, published as an OData V2 service |

---

## Features

- 🔍 **Smart Filter Bar** — filter by sales order, customer, sales org, type, date range, and status
- 📊 **Colour-coded status** — Fiori criticality integers drive green / amber / red cell colouring with no JavaScript
- 🔗 **Navigation** — drill from the List Report directly to a full Object Page per order
- 📋 **Items table** — line-item detail including delivery, goods movement, and planned delivery date
- 🔒 **Row-level security** — CDS Access Control checks `V_VBAK_VKO` (sales organisation authorisation)
- 📱 **Responsive** — desktop & tablet layouts (phone excluded by design for this operational tool)
- 🎨 **Theme support** — `sap_fiori_3`, `sap_fiori_3_dark`, `sap_horizon`, `sap_horizon_dark`
- ⚡ **Variant management** — SmartVariantManagement enabled for saved filter/column layouts

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│  ABAP Backend (S/4HANA)                                          │
│                                                                  │
│  VBAK + VBUK  ──►  I_SalesOrderHeader  ──►  C_SalesOrderHeader  │
│                         (Interface)          (@OData.publish)    │
│                              │                      │            │
│  VBAP + VBUP                 │              ZSALESORDER_SRV      │
│       + LIPS  ──►  I_SalesOrderItem   ──►  C_SalesOrderItem     │
│                         (Interface)          (via nav property)  │
│                                                                  │
│  DCL access control on I_* views (V_VBAK_VKO)                   │
└─────────────────────────────────┬────────────────────────────────┘
                                  │  OData V2
                                  ▼
┌──────────────────────────────────────────────────────────────────┐
│  Fiori Frontend (SAPUI5 1.120+)                                  │
│                                                                  │
│  List Report  ──(row click)──►  Object Page                     │
│  (C_SalesOrderHeader)           (C_SalesOrderHeader             │
│   SmartTable + FilterBar)        + _Items navigation)           │
│                                                                  │
│  sap.suite.ui.generic.template — annotation-driven, no XML views │
└──────────────────────────────────────────────────────────────────┘
```

---

## Project Structure

```
DeliveryDesk/
│
├── abap/
│   └── cds/
│       ├── I_SalesOrderHeader.asddls    ← Interface view: VBAK + VBUK join
│       ├── I_SalesOrderHeader.asdcls    ← DCL: auth check via V_VBAK_VKO
│       ├── I_SalesOrderItem.asddls      ← Interface view: VBAP + VBUP + LIPS join
│       ├── I_SalesOrderItem.asdcls      ← DCL: inherits conditions from header
│       ├── C_SalesOrderHeader.asddls    ← Consumption view: UI annotations + @OData.publish
│       └── C_SalesOrderItem.asddls      ← Consumption view: item line-item annotations
│
├── webapp/
│   ├── index.html                       ← App entry point (ComponentSupport bootstrap)
│   ├── Component.js                     ← Extends AppComponent (no custom views needed)
│   ├── manifest.json                    ← App descriptor: data source, routing, entity sets
│   ├── i18n/
│   │   └── i18n.properties              ← App title and description strings
│   └── annotations/
│       └── annotation.xml               ← Local annotation overrides (for dev/testing)
│
├── ui5.yaml                             ← UI5 tooling: dev server proxy + deploy-to-ABAP task
├── package.json                         ← npm scripts: start / build / deploy / lint
├── DEPLOYMENT_GUIDE.md                  ← Step-by-step activation and deployment instructions
└── README.md                            ← This file
```

---

## Prerequisites

### Backend
| Requirement | Details |
|------------|---------|
| SAP S/4HANA on-premise | ≥ 1709 (for `@OData.publish`) |
| ABAP version | ≥ 7.52 (for DCL `inheriting conditions`) |
| ABAP Development Tools (ADT) | Eclipse-based IDE for CDS activation |
| Gateway transaction | Access to `/IWFND/MAINT_SERVICE` |
| Authorization | `V_VBAK_VKO` with `ACTVT = 03` (display) |

### Frontend
| Requirement | Details |
|------------|---------|
| Node.js | ≥ 18.x |
| SAPUI5 | ≥ 1.120.0 |
| IDE | SAP Business Application Studio *or* VS Code + SAP Fiori tools extension |

---

## Quick Start

### 1 — Backend Setup

Activate the CDS objects in ADT **in this exact order** (bottom-up, dependencies first):

| # | Object | Type | Source File |
|---|--------|------|------------|
| 1 | `I_SALESORDERHEADER` | CDS Interface View | `abap/cds/I_SalesOrderHeader.asddls` |
| 2 | `I_SALESORDERITEM` | CDS Interface View | `abap/cds/I_SalesOrderItem.asddls` |
| 3 | `C_SALESORDERHEADER` | CDS Consumption View | `abap/cds/C_SalesOrderHeader.asddls` |
| 4 | `C_SALESORDERITEM` | CDS Consumption View | `abap/cds/C_SalesOrderItem.asddls` |
| 5 | `I_SALESORDERHEADER` DCL | Access Control | `abap/cds/I_SalesOrderHeader.asdcls` |
| 6 | `I_SALESORDERITEM` DCL | Access Control | `abap/cds/I_SalesOrderItem.asdcls` |

Then register `ZSALESORDER_SRV` in `/IWFND/MAINT_SERVICE` and verify:

```
GET https://<your-s4-system>/sap/opu/odata/sap/ZSALESORDER_SRV/$metadata
GET https://<your-s4-system>/sap/opu/odata/sap/ZSALESORDER_SRV/C_SalesOrderHeaderSet?$top=5&$format=json
```

### 2 — Frontend Setup

```bash
# 1. Clone or download this repository
git clone <repo-url>
cd DeliveryDesk

# 2. Update ui5.yaml with your S/4HANA system URL
#    (see Configuration section below)

# 3. Install dependencies
npm install

# 4. Start the local dev server
npm start
# Opens http://localhost:8080/index.html
```

> **First-run checklist:**
> - ✅ List Report loads with the Smart Filter Bar
> - ✅ Clicking **Go** returns sales order rows from the backend
> - ✅ Status columns show colour-coded cells (green / amber / red)
> - ✅ Clicking a row navigates to the Object Page
> - ✅ Object Page shows the header section and the Items table

---

## Configuration

Before running, update the following placeholders:

### `ui5.yaml` — Dev Server & Deploy Settings

```yaml
backend:
  - path: /sap
    url: https://YOUR-S4-SYSTEM.yourcompany.com:443   # ← your S/4HANA hostname
    destination: YOUR_S4_DESTINATION                   # ← BTP destination name
    client: "100"                                      # ← your SAP client number

# Deploy task:
target:
  url: https://YOUR-S4-SYSTEM.yourcompany.com:443
  client: "100"
app:
  name: ZSALESORDERCOCKPIT
  package: ZSALES_COCKPIT_PKG
  transport: DEVK900001                                # ← your transport request
```

### `webapp/manifest.json` — App Namespace

Replace `com.yourcompany.salesordercockit` (appears in 3 places) with your actual namespace, e.g. `com.acme.salesordercockit`.

---

## Deployment

### Deploy to ABAP Repository

```bash
npm run deploy
```

This runs `ui5 build --clean-dest` followed by `fiori deploy`, uploading the built webapp to the BSP application `ZSALESORDERCOCKPIT` on your S/4HANA system.

### Register in Fiori Launchpad

After deploying the BSP app:

1. Open **Fiori Launchpad Designer** (`/ui2/flpd_conf`)
2. Create or select a catalog (e.g. `Z_SALES_COCKPIT_CATALOG`)
3. Add a new **App tile**:
   - Title: `Sales Order & Delivery Status`
   - Icon: `sap-icon://sales-order`
   - App Type: `SAPUI5`
   - App ID: `ZSALESORDERCOCKPIT`
4. Create an **Intent** — Semantic Object: `SalesOrder`, Action: `display`
5. Assign users/roles via **PFCG** — include `V_VBAK_VKO` with `ACTVT = 03`

For complete step-by-step instructions, see [`DEPLOYMENT_GUIDE.md`](./DEPLOYMENT_GUIDE.md).

---

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| **Two-layer CDS (I_ / C_)** | Keeps table joins reusable and independent of UI concerns; UI annotations live only in the `C_` consumption layer |
| **`@OData.publish: true` on header only** | Items are accessed via the `_Items` navigation property — avoids double service registration |
| **`criticality` as CASE field (integer)** | Fiori Elements reads `1`/`2`/`3` to colour status cells without any JavaScript; no custom renderer needed |
| **`@Semantics.amount.currencyCode`** | Required for SmartTable to format currency values correctly; must reference the companion `Currency` field |
| **`LEFT OUTER JOIN` on LIPS** | Orders not yet in delivery still appear in the list — critical for early-stage order visibility |
| **`sap.suite.ui.generic.template.AppComponent`** | Standard Fiori Elements V2 template — eliminates hand-written XML views; all layout comes from CDS annotations |
| **`smartVariantManagement: true`** | Allows SD team members to save their own filter/column presets — reduces training overhead |

---

## Version Compatibility

> Review these before activating in your landscape.

| Item | Minimum Version | Field / Object |
|------|----------------|----------------|
| `VBUK.WBSTK` (goods mvt status) | S/4HANA **1610** | `OverallGoodsMovementStatus` in `I_SalesOrderHeader` |
| `@OData.publish: true` | S/4HANA **1709** | `C_SalesOrderHeader` — use `/IWBEP/` manual registration if older |
| `LIPS.EDATU` (planned delivery date) | May be on `VBEP` in some configs | `PlannedDeliveryDate` in `I_SalesOrderItem` — verify per release |
| `sap.suite.ui.generic.template` | SAPUI5 **≥ 1.52** | `Component.js` template libs |
| DCL `inheriting conditions` | ABAP **7.52** | `I_SalesOrderItem.asdcls` — fallback: repeat WHERE clause manually |
| `VBAK.LIFSK` (delivery block) | All S/4HANA | Verify vs. `FAKSK` (billing block) for your SD process |

---

## Available npm Scripts

| Script | Command | Description |
|--------|---------|-------------|
| `start` | `npm start` | Starts the Fiori dev server at `http://localhost:8080` with live reload |
| `build` | `npm run build` | Builds the production bundle into `dist/` |
| `deploy` | `npm run deploy` | Builds and deploys to the ABAP repository via `fiori deploy` |
| `lint` | `npm run lint` | Runs ESLint over the `webapp/` directory |

---

## SAP Object Reference

| Artefact | SAP Object Name | Type |
|----------|----------------|------|
| Interface Header View | `I_SALESORDERHEADER` | CDS Data Definition |
| Interface Item View | `I_SALESORDERITEM` | CDS Data Definition |
| Consumption Header View | `C_SALESORDERHEADER` | CDS Data Definition |
| Consumption Item View | `C_SALESORDERITEM` | CDS Data Definition |
| Header Access Control | `I_SALESORDERHEADER` | CDS DCL |
| Item Access Control | `I_SALESORDERITEM` | CDS DCL |
| OData Service | `ZSALESORDER_SRV` | OData V2 Service (auto-generated) |
| BSP Application | `ZSALESORDERCOCKPIT` | ABAP BSP App |
| ABAP Package | `ZSALES_COCKPIT_PKG` | ABAP Package |

---

## Roadmap

> **⚠️ Phase 2 items must not be started until the read-only v1 is signed off by the team.**

| Feature | Description | Phase |
|---------|------------|-------|
| ✅ **Read-only List Report + Object Page** | Filter, view, and drill into sales order & delivery data | **v1 — current** |
| 🔜 **Release Delivery Block action** | Function Import / RAP action to clear `VBAK.LIFSK`; needs `ACTVT = 02` auth | Phase 2 |
| 🔜 **Overdue order notifications** | Threshold-based alerts via background ABAP job or BTP Alert Notification | Phase 2 |
| 🔜 **Order value by status chart** | `@UI.chart` + `@UI.presentationVariant` on `C_SalesOrderHeader`; adds `sap.viz` dependency | Phase 2+ |

---

## Contributing

1. Create your objects in the `ZSALES_COCKPIT_PKG` ABAP package and assign to a transport
2. For frontend changes, create a feature branch and test locally with `npm start`
3. Ensure `npm run lint` passes before submitting
4. Document any new CDS fields or annotation changes in both the code comments and `DEPLOYMENT_GUIDE.md`

---

## License

Internal project — not for public distribution.  
Refer to your organisation's IP and software policies before sharing outside the company.
