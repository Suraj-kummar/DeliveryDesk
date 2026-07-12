# Changelog

All notable changes to **DeliveryDesk** are documented here.  
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.1.0] — 2026-07-12

### Added
- Custom dark-theme dashboard replacing SAP Fiori Elements default UI
- KPI summary cards: Total Orders, Delivered, Pending, Blocked
- Animated count-up effect on KPI numbers on page load
- Smart Filter Bar: live search, status chip filters, sales org and order type dropdowns
- Sortable table columns (ascending/descending toggle)
- Colour-coded status badges with glowing animated dot for blocked orders
- Slide-out detail drawer with order info, shipment details, timeline and line items
- Click-to-copy order number with clipboard API and toast feedback
- Dark / Light mode toggle with localStorage persistence
- CSV export of filtered data
- Sparkline trend chart in table header
- Pagination with configurable page size (8 per page)
- Keyboard shortcuts: `ESC` closes drawer, `/` focuses search
- Blocked order rows highlighted with red left border
- Footer with version number, tech stack and copyright
- Print-friendly CSS: hides sidebar/controls, clean table layout for printing
- SEO meta tags, Open Graph markup and emoji favicon
- Expanded mock dataset to 20 realistic sales orders across 4 sales organisations

### Changed
- Replaced `sap.suite.ui.generic.template` Fiori Elements bootstrap with standalone HTML/CSS/JS
- `index.html` no longer requires SAP backend to render — works with built-in mock data

### Fixed
- `node_modules/` excluded from git via `.gitignore`

---

## [1.0.0] — 2026-07-12

### Added
- Initial project structure: ABAP CDS views, Fiori Elements manifest, ui5.yaml
- Interface views: `I_SalesOrderHeader` (VBAK + VBUK), `I_SalesOrderItem` (VBAP + VBUP + LIPS)
- Consumption views: `C_SalesOrderHeader`, `C_SalesOrderItem` with full `@UI.*` annotations
- CDS Access Control (DCL) using `V_VBAK_VKO` authorisation check
- OData V2 service `ZSALESORDER_SRV` via `@OData.publish: true`
- Fiori Elements List Report + Object Page floorplan (zero hand-written XML views)
- `ui5.yaml` with `fiori-tools-proxy` middleware and `deploy-to-abap` task
- Comprehensive `README.md` with architecture diagram, setup guide and design decisions
- `DEPLOYMENT_GUIDE.md` with 12-step SAP activation and Fiori Launchpad registration guide
