<div align="center">

<img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Package.png" alt="📦" width="80" />

# DeliveryDesk

### SAP S/4HANA Sales Order & Delivery Status Cockpit

[![Version](https://img.shields.io/badge/version-1.3.0-4f8ef7?style=for-the-badge&logo=github)](./CHANGELOG.md)
[![OData](https://img.shields.io/badge/OData-V4%20%2F%20RAP-8b5cf6?style=for-the-badge&logo=sap)](https://developers.sap.com)
[![SAPUI5](https://img.shields.io/badge/SAPUI5-1.120-0070f3?style=for-the-badge&logo=sap)](https://ui5.sap.com)
[![ApexCharts](https://img.shields.io/badge/ApexCharts-3.x-22c55e?style=for-the-badge)](https://apexcharts.com)
[![Three.js](https://img.shields.io/badge/Three.js-r128-06b6d4?style=for-the-badge)](https://threejs.org)
[![License](https://img.shields.io/badge/license-Internal-gray?style=for-the-badge)](#)

<br />

**One screen. No more VA03 → VL03N → VF03.**

DeliveryDesk is a premium SAP Fiori cockpit that gives SD consultants, delivery managers and logistics teams a real-time, beautiful view of the entire order-to-delivery lifecycle — powered by OData V4 via the SAP RESTful ABAP Programming Model (RAP).

<br />

[🚀 Quick Start](#-quick-start) &nbsp;·&nbsp; [🏗 Architecture](#-architecture) &nbsp;·&nbsp; [📡 S/4HANA Integration](#-s4hana-integration) &nbsp;·&nbsp; [🎨 UI Features](#-ui-features) &nbsp;·&nbsp; [📂 Project Structure](#-project-structure)

</div>

---

## ✨ Why DeliveryDesk?

The classic SAP workflow forces you to jump across **5+ transactions** just to get the status of one order:

```
VA03 (view order) → VL03N (check delivery) → VF03 (check invoice) → MB03 (goods issue) → ...
```

DeliveryDesk collapses this into **a single, live dashboard**:

| Old Way | DeliveryDesk |
|---------|-------------|
| 5+ SAP GUI transactions | ✅ One screen |
| No visual charts | ✅ ApexCharts — donut, bars, sparklines |
| Manual refresh | ✅ Auto-refresh every 5 minutes |
| Text-only output | ✅ Delivery progress tracker, badges, animations |
| One order at a time | ✅ All orders, filterable + sortable + searchable |
| Desktop only | ✅ Responsive across breakpoints |

---

## 🖥 UI Features

<table>
<tr>
<td width="50%">

### 📊 Dashboard
- Animated KPI cards with **gradient text values**
- Glassmorphism cards with **backdrop blur**
- **Dot grid + gradient orb** background
- **ApexCharts** donut (status distribution)
- **ApexCharts** bar (orders by Sales Org)
- Mini **sparkline trend** on every KPI

</td>
<td width="50%">

### 📦 Orders Table
- Sortable by any column
- Filter chips (All / Delivered / Partial / Pending / Blocked)
- Org & Type dropdowns
- Live search (`/` shortcut to focus)
- Paginated (8 rows/page)
- Blocked rows highlighted in red

</td>
</tr>
<tr>
<td>

### 🗂 Detail Drawer (3 Tabs)
- **Overview** — all order fields + gradient net value
- **Delivery Track** — animated 5-step progress tracker
- **Line Items** — real SAP items when connected, mock items in demo
- "Release Block" button → calls RAP action on SAP

</td>
<td>

### 📈 Analytics Page
- Status distribution donut
- Org volume bar chart
- Order type breakdown
- Billing performance
- Key metrics summary grid

</td>
</tr>
<tr>
<td>

### 🚚 Deliveries Page
- Progress bar per order
- Carrier + ETA tracking
- Gradient progress fills
- Avg delivery progress KPI

</td>
<td>

### ⚙️ Settings Page
- Live SAP URL configuration
- Test Connection with latency
- Auto-refresh toggle
- Full ABAP activation guide

</td>
</tr>
</table>

### Component Libraries Used

| Library | Version | Purpose |
|---------|---------|---------|
| [ApexCharts](https://apexcharts.com) | Latest | Donut, bar, sparkline charts |
| [Tabler Icons](https://tabler.io/icons) | Latest | 4,000+ sharp SVG icon font |
| [Three.js](https://threejs.org) | r128 | Particle network background |
| [Anime.js](https://animejs.com) | 3.2.1 | All micro-animations & stagger |
| [Inter](https://rsms.me/inter/) + [Plus Jakarta Sans](https://fonts.google.com/specimen/Plus+Jakarta+Sans) | — | Typography |

---

## 🏗 Architecture

```
DeliveryDesk
├── Frontend (SAPUI5 / Vanilla JS SPA)          webapp/
│   └── index.html — single-page cockpit
│       ├── SAPDataService (OData V4 fetch layer)
│       ├── Mock data fallback (demo mode)
│       └── ApexCharts + Tabler Icons + Three.js
│
└── Backend (SAP ABAP / RAP)                    abap/
    ├── CDS Interface Layer                      abap/cds/
    │   ├── I_SalesOrderHeader.asddls   VBAK ⊕ VBUK
    │   ├── I_SalesOrderHeader.asdcls   Access control
    │   ├── I_SalesOrderItem.asddls     VBAP ⊕ VBUP ⊕ LIPS
    │   └── I_SalesOrderItem.asdcls     Access control
    │
    ├── CDS Consumption Layer (UI-annotated)
    │   ├── C_SalesOrderHeader.asddls   @UI annotations + OData
    │   └── C_SalesOrderItem.asddls     Object Page items
    │
    └── RAP Layer (OData V4 Service)             abap/rap/
        ├── R_SalesOrderHeader.asbdef   Behavior definition
        ├── ZBP_SalesOrderHeader.abap   Behavior implementation
        ├── ZSALESORDER_SRV.srvd        Service definition
        └── ZSALESORDER_UI.srvb         Service binding (OData V4)
```

### Data Flow

```
  Browser (webapp/index.html)
        │
        │  GET /sap/opu/odata4/sap/zsalesorder_ui/...
        │      /C_SalesOrderHeader?$expand=_Items&$select=...
        ▼
  SAP Fiori Tools Dev Server  (npm start / fiori run)
        │
        │  Proxy: /sap/ → https://your-s4-system:44301
        ▼
  S/4HANA Application Server
        │
        ├── ZSALESORDER_UI.srvb  (Service Binding → OData V4)
        ├── ZSALESORDER_SRV.srvd (Service Definition)
        ├── C_SalesOrderHeader   (Consumption CDS View)
        │     └── I_SalesOrderHeader  (VBAK JOIN VBUK)
        └── C_SalesOrderItem     (via $expand=_Items)
              └── I_SalesOrderItem   (VBAP JOIN VBUP JOIN LIPS)
```

---

## 📡 S/4HANA Integration

### OData V4 Endpoint

```
Base URL:
/sap/opu/odata4/sap/zsalesorder_ui/srvd/sap/zsalesorder_srv/0001/

Metadata:
GET .../0001/$metadata

Orders List (used by frontend):
GET .../0001/C_SalesOrderHeader
  ?$select=SalesOrder,CreationDate,SoldToParty,SalesOrganization,
           SalesOrderType,NetValue,Currency,DeliveryBlockReason,
           OverallDeliveryStatus,OverallBillingStatus,OverallGoodsMovementStatus
  &$expand=_Items($select=SalesOrderItem,Material,ItemDescription,
                          OrderQuantity,ItemNetValue,DeliveryDocument,
                          PlannedDeliveryDate,ActualGoodsIssueDate)
  &$top=500
  &$orderby=CreationDate desc

Release Block Action:
POST .../0001/C_SalesOrderHeader('<VBELN>')/com.sap.zsalesorder_srv.releaseDeliveryBlock
  Body: {}
  Headers: x-csrf-token: <fetched from $metadata>
```

### Status Code Mapping

The frontend maps raw SAP status codes from `VBUK` to human-readable labels:

| SAP Field | SAP Code | Display Label |
|-----------|----------|---------------|
| `OverallDeliveryStatus` (LFSTK) | `C` | ✅ Delivered |
| `OverallDeliveryStatus` (LFSTK) | `B` | 🟡 Partial |
| `OverallDeliveryStatus` (LFSTK) | `A` / ` ` | 🔵 Pending |
| `DeliveryBlockReason` (LIFSK) | non-empty | 🔴 Blocked |
| `OverallBillingStatus` (FKSTK) | `C` | Billed |
| `OverallBillingStatus` (FKSTK) | `B` | Partial |
| `OverallBillingStatus` (FKSTK) | `A` / ` ` | Not Billed |
| `OverallGoodsMovementStatus` (WBSTK) | `C` | Complete |
| `OverallGoodsMovementStatus` (WBSTK) | `B` | Partial |
| `OverallGoodsMovementStatus` (WBSTK) | `A` / ` ` | Not Done |

---

## 📂 Project Structure

```
DeliveryDesk/
│
├── webapp/
│   └── index.html              # Entire SPA — CSS + HTML + JS (2,000 lines)
│
├── abap/
│   ├── cds/
│   │   ├── I_SalesOrderHeader.asddls   # Interface CDS — joins VBAK + VBUK
│   │   ├── I_SalesOrderHeader.asdcls   # DCL — access control
│   │   ├── I_SalesOrderItem.asddls     # Interface CDS — joins VBAP + VBUP + LIPS
│   │   ├── I_SalesOrderItem.asdcls     # DCL — access control
│   │   ├── C_SalesOrderHeader.asddls   # Consumption CDS — UI annotations
│   │   └── C_SalesOrderItem.asddls     # Consumption CDS — Object Page items
│   │
│   └── rap/
│       ├── R_SalesOrderHeader.asbdef   # RAP Behavior Definition (read-only + releaseBlock)
│       ├── ZBP_SalesOrderHeader.abap   # Behavior Implementation (BAPI_SALESORDER_CHANGE)
│       ├── ZSALESORDER_SRV.srvd        # Service Definition
│       └── ZSALESORDER_UI.srvb         # OData V4 UI Service Binding
│
├── ui5.yaml                    # Fiori Tools dev server config (SAP proxy)
├── package.json                # npm — fiori run, dependencies
├── netlify.toml                # Netlify deployment config
├── CHANGELOG.md                # Version history
└── DEPLOYMENT_GUIDE.md         # Step-by-step BTP deployment guide
```

---

## 🚀 Quick Start

### 1 — Clone & Install

```bash
git clone https://github.com/Suraj-kummar/DeliveryDesk.git
cd DeliveryDesk
npm install
```

### 2 — Run in Demo Mode (no SAP needed)

```bash
npm start
```

Open **http://localhost:8080/index.html**

The app loads with 20 realistic mock orders. All charts, filters, drawer, and animations work fully in demo mode.

### 3 — Connect to a Real S/4HANA System

**Step 1 — Configure the proxy** in `ui5.yaml`:

```yaml
server:
  customMiddleware:
    - name: fiori-tools-proxy
      afterMiddleware: compression
      configuration:
        backend:
          - path: /sap
            url: https://your-s4hana-host:44301   # ← change this
            client: "100"                           # ← your client
```

**Step 2 — Activate ABAP artifacts** in Eclipse ADT (in order):

```
1. I_SalesOrderHeader.asddls  →  I_SalesOrderItem.asddls
2. C_SalesOrderHeader.asddls  →  C_SalesOrderItem.asddls
3. R_SalesOrderHeader.asbdef  →  ZBP_SalesOrderHeader (Quick Fix → Create class)
4. ZSALESORDER_SRV.srvd
5. ZSALESORDER_UI.srvb  →  Click "Publish Locally"
```

**Step 3 — Set the URL in the UI**:

Go to **Settings** → paste your OData V4 base URL → click **Save & Connect**

```
/sap/opu/odata4/sap/zsalesorder_ui/srvd/sap/zsalesorder_srv/0001/
```

---

## 🔑 Authorization Objects Required

| ABAP Auth Object | Field | Value | Purpose |
|-----------------|-------|-------|---------|
| `V_VBAK_VKO` | `VKORG` | Your sales org(s) | Read sales orders |
| `V_VBAK_AAT` | `AUART` | `OR`, `ZOR`, `RE` | Filter by order type |
| `V_VBUK_AAT` | `GBSTK` | `*` | Read overall status |
| `S_SERVICE` | `SRV_NAME` | `ZSALESORDER_SRV` | Execute OData service |
| `V_VBAK_VKO` | `ACTVT` | `02` | Release delivery blocks |

---

## 🧩 SAP Glossary

| Term | Meaning |
|------|---------|
| **VBAK** | Sales order header table |
| **VBAP** | Sales order item table |
| **VBUK** | Overall order status table |
| **VBUP** | Item-level status table |
| **LIPS** | Delivery item table |
| **LIFSK** | Delivery block field on VBAK |
| **LFSTK** | Overall delivery status on VBUK |
| **FKSTK** | Overall billing status on VBUK |
| **WBSTK** | Overall goods movement status on VBUK |
| **CDS** | Core Data Services — modern ABAP query layer |
| **RAP** | RESTful ABAP Programming Model |
| **BDEF** | Behavior Definition (RAP artifact) |
| **OData V4** | Modern REST protocol for SAP APIs |
| **VA03** | SAP GUI transaction — Display Sales Order |
| **VL03N** | SAP GUI transaction — Display Delivery |
| **VF03** | SAP GUI transaction — Display Invoice |

---

## 🛣 Roadmap

- [x] CDS interface views (VBAK/VBAP/VBUK/VBUP/LIPS)
- [x] CDS consumption views with UI annotations
- [x] RAP behavior definition + implementation
- [x] OData V4 service definition & binding
- [x] Frontend OData V4 fetch with status code mapping
- [x] Demo mode with mock fallback
- [x] ApexCharts integration (donut, bar, sparklines)
- [x] Tabler Icons webfont
- [x] Glassmorphism + gradient UI
- [x] Delivery block release action
- [x] Auto-refresh every 5 minutes
- [ ] SAP Work Zone / Fiori Launchpad integration
- [ ] Export to PDF
- [ ] Push notifications via SAP Event Mesh
- [ ] Multi-language (i18n) support
- [ ] SAP Analytics Cloud embedded charts

---

## 📄 Changelog

See [CHANGELOG.md](./CHANGELOG.md) for full version history.

---

<div align="center">

**Built by [Suraj Kumar](https://github.com/Suraj-kummar)**  
SAP SD Consultant & Full-Stack Developer

*Made with ApexCharts · Three.js · Anime.js · Tabler Icons · SAP RAP*

</div>
