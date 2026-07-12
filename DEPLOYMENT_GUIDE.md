# Deployment Guide: Sales Order & Delivery Status Cockpit

> **Prerequisites**: SAP S/4HANA on-premise, ADT (ABAP Development Tools) installed in Eclipse,  
> access to `/IWFND/MAINT_SERVICE`, SAP Business Application Studio or VS Code + SAP Fiori tools extension.

---

## Phase 1 — Backend: ABAP CDS Views

### Step 1 — Create a Development Package

Before creating any objects, create a package to house them.

1. In ADT, right-click the **Project** → **New → ABAP Package**
2. Name: `ZSALES_COCKPIT_PKG`
3. Description: `Sales Order Delivery Cockpit`
4. Assign a **Workbench Transport Request** (create one if needed)
5. Click **Finish**

---

### Step 2 — Activate CDS Views in Dependency Order

CDS views must be activated **bottom-up** (dependencies before dependants).  
Activate in this exact sequence:

| Order | Artefact | Type | File |
|-------|----------|------|------|
| 1 | `I_SalesOrderHeader` | CDS View (Interface) | `abap/cds/I_SalesOrderHeader.asddls` |
| 2 | `I_SalesOrderItem` | CDS View (Interface) | `abap/cds/I_SalesOrderItem.asddls` |
| 3 | `C_SalesOrderHeader` | CDS View (Consumption) | `abap/cds/C_SalesOrderHeader.asddls` |
| 4 | `C_SalesOrderItem` | CDS View (Consumption) | `abap/cds/C_SalesOrderItem.asddls` |
| 5 | `I_SalesOrderHeader` DCL | Access Control | `abap/cds/I_SalesOrderHeader.asdcls` |
| 6 | `I_SalesOrderItem` DCL | Access Control | `abap/cds/I_SalesOrderItem.asdcls` |

**How to create each CDS view in ADT:**

1. Right-click `ZSALES_COCKPIT_PKG` → **New → Other ABAP Repository Object**
2. Filter for **"Core Data Services"** → select **"Data Definition"**
3. Name: e.g. `I_SALESORDERHEADER` (ADT normalises the case)
4. Description as per the file header comment
5. Click **Next** — select your transport request — **Finish**
6. ADT opens a skeleton. **Replace the entire content** with the code from the corresponding `.asddls` file in this project.
7. Press **Ctrl+F3** (or right-click → **Activate**) to activate.
8. Check the **Problems** view — resolve any errors before moving to the next object.

> **Tip**: If you get a "SQL view name already exists" error, the `@AbapCatalog.sqlViewName` value  
> (`ZISOHDR`, `ZISDITM`, `ZCSOHDR`, `ZCSDITM`) is taken. Append a digit (e.g. `ZISOHDR2`) and update the annotation.

---

### Step 3 — Verify the CDS Views with the Data Preview

1. In ADT, right-click `C_SalesOrderHeader` → **Open With → Data Preview**
2. You should see rows from `VBAK`/`VBUK` with all projected fields.
3. Right-click `C_SalesOrderItem` → **Data Preview** — confirm delivery data appears.

If the data preview is empty but no errors show, check:
- That `VBUK` has rows for the orders in your system (it's populated by SD processing).
- That `LIPS.VGBEL` is populated for delivered items.

---

## Phase 2 — Register the OData V2 Service

The `@OData.publish: true` annotation on `C_SalesOrderHeader` **automatically creates** the OData service  
artefact (`ZSALESORDER_SRV`) during CDS activation.  You still need to register it in the gateway.

### Step 4 — Activate the Service in `/IWFND/MAINT_SERVICE`

1. Open SAP GUI → Transaction `/IWFND/MAINT_SERVICE`
2. Click **Add Service** (top-left button)
3. In the system alias field enter your backend system alias (often `LOCAL` for single-system landscapes)
4. Click **Get Services**
5. In the filter, search for `ZSALESORDER`
6. Select `ZSALESORDER_SRV` and click **Add Selected Services**
7. Accept the package assignment prompt — use `ZSALES_COCKPIT_PKG` or `$TMP` for testing
8. Click **OK** / **Save**

> **Expected result**: The service appears in the service list with a green status indicator.

---

### Step 5 — Test the Service Metadata Endpoint

Before touching the frontend, verify the backend is working correctly.

**In a browser (or Postman)**, open:

```
https://YOUR-S4-SYSTEM.yourcompany.com/sap/opu/odata/sap/ZSALESORDER_SRV/$metadata
```

You should see an XML document containing:
- `EntityType Name="C_SalesOrderHeaderType"` with all projected properties
- `EntityType Name="C_SalesOrderItemType"`
- A `NavigationProperty` from `C_SalesOrderHeaderType` to `C_SalesOrderItemType`
- Annotation elements (from the `@UI.*` and `@Semantics.*` annotations)

**Also test the entity set** to confirm data returns:

```
https://YOUR-S4-SYSTEM.yourcompany.com/sap/opu/odata/sap/ZSALESORDER_SRV/C_SalesOrderHeaderSet?$top=5&$format=json
```

> **Troubleshooting**:  
> - **401 Unauthorized**: Check your user has `V_VBAK_VKO` authorization with display activity.  
> - **404 Not Found**: The service wasn't registered correctly — repeat Step 4.  
> - **Empty results but 200 OK**: The access control (DCL) is filtering everything — temporarily set  
>   `@AccessControl.authorizationCheck: #NOT_REQUIRED` on the interface views during testing,  
>   then restore `#CHECK` before go-live.

---

## Phase 3 — Frontend: Fiori Elements App

### Step 6 — Set Up Your Development Environment

**Option A — SAP Business Application Studio (BAS)** *(recommended)*

1. Open your BAS Dev Space (type: SAP Fiori)
2. Clone or upload this project folder to your workspace

**Option B — VS Code with SAP Fiori tools**

1. Install the **SAP Fiori tools** extension pack from the VS Code Marketplace
2. Open the project folder (`DeliveryDesk/`) in VS Code

---

### Step 7 — Update Configuration Placeholders

Before running, update these values in `ui5.yaml`:

| Placeholder | Replace With |
|-------------|-------------|
| `YOUR-S4-SYSTEM.yourcompany.com` | Your S/4HANA system hostname |
| `YOUR_S4_DESTINATION` | The BTP Destination name pointing to your system |
| `100` (client) | Your SAP client number |
| `DEVK900001` (transport) | Your actual transport request number |

And in `manifest.json`, replace `com.yourcompany.salesordercockit` with your actual namespace  
(e.g. `com.acme.salesordercockit`) in all three places it appears.

---

### Step 8 — Install Dependencies and Run Locally

```bash
# From the DeliveryDesk/ project root:
npm install

# Start the dev server — opens browser at http://localhost:8080/index.html
npm start
```

The Fiori tools proxy (`fiori-tools-proxy` middleware in `ui5.yaml`) will forward all  
`/sap/opu/odata/...` requests to your backend system.  
You'll be prompted for credentials on the first request.

> **First run checklist**:  
> ✅ List Report loads and shows the Smart Filter Bar  
> ✅ Clicking **Go** loads sales order rows from the backend  
> ✅ Status column shows colour-coded cells (green/amber/red)  
> ✅ Clicking a row navigates to the Object Page  
> ✅ Object Page shows the header identification section and the Items table

---

### Step 9 — (Alternative) Generate via Fiori App Wizard

If you prefer to generate the app from scratch via the wizard (rather than using the files here):

1. In BAS: **File → New Project from Template** → **SAP Fiori application**
2. Select **List Report Object Page**  
3. Data source: **Connect to a System** → select your system/destination  
4. OData service: `ZSALESORDER_SRV`  
5. Main Entity: `C_SalesOrderHeader`  
6. Navigation Entity: `_Items` → `C_SalesOrderItem`  
7. Module name: `sales-order-cockpit`  
8. Namespace: `com.yourcompany`  
9. Finish — the wizard generates the `manifest.json`, `Component.js`, and `index.html`.

The wizard-generated files will be functionally equivalent to the ones in this project.  
The CDS annotation-driven approach means you don't configure columns or filters in the wizard — they come from the backend.

---

## Phase 4 — Deploy to Fiori Launchpad

### Step 10 — Deploy to ABAP Repository

```bash
npm run deploy
```

This runs `ui5 build` followed by `fiori deploy`.  The `deploy-to-abap` task in `ui5.yaml` uploads  
the built webapp to the ABAP repository (`ZSALESORDERCOCKPIT`) in your system.

> **First-time deploy**: You'll be prompted for credentials.  
> Use a transport request that targets your **production transport route**.

Alternatively, deploy manually via **SAP Business Application Studio**:
1. Right-click the `dist/` folder → **Deploy → Deploy to ABAP repository**
2. Fill in system, client, BSP application name, and transport.

---

### Step 11 — Register in the Fiori Launchpad

1. Open the **SAP Fiori Launchpad Designer** (`/ui2/flpd_conf`)
2. Create or select a **Catalog** (e.g. `Z_SALES_COCKPIT_CATALOG`)
3. Add a new **App** tile:
   - Title: `Sales Order & Delivery Status`
   - Subtitle: `Monitor SD orders in one view`
   - Icon: `sap-icon://sales-order`
   - App Type: `SAPUI5`
   - Application Namespace: `com.yourcompany.salesordercockit`
   - Application ID: `ZSALESORDERCOCKPIT` (the BSP app name from Step 10)
4. Create an **Intent** for semantic object-based navigation:
   - Semantic Object: `SalesOrder`
   - Action: `display`
5. Assign the tile to a **Group** visible to the SD team

---

### Step 12 — Assign to Users / Roles

1. In PFCG, open the role you want to assign the app to (e.g. `Z_ROLE_SD_DISPLAY`)
2. Go to the **Menu** tab → add the Fiori tile
3. On the **Authorizations** tab, ensure `V_VBAK_VKO` (display, `ACTVT = 03`) is included  
   for the relevant sales organisations
4. Generate the profile and assign to users

---

## Phase 5 — Version Compatibility Checks

Review these before activating in your system:

| Item | Check | Field / Object |
|------|-------|----------------|
| **VBUK.WBSTK** | Available from S/4HANA 1610 | `OverallGoodsMovementStatus` in `I_SalesOrderHeader` |
| **LIPS.EDATU** | May be on VBEP in some configurations | `PlannedDeliveryDate` in `I_SalesOrderItem` |
| **@OData.publish** | Available from S/4HANA 1709 onward | `C_SalesOrderHeader` — use `/IWBEP/` manually if older |
| **sap.suite.ui.generic.template** | Available in SAPUI5 ≥ 1.52 | `Component.js` — use Fiori Elements V2 template libs |
| **inheriting conditions** | DCL `inheriting conditions` keyword ≥ ABAP 7.52 | `I_SalesOrderItem.asdcls` — fallback: repeat the WHERE clause |
| **VBAK.LIFSK** | Delivery block field — verify this vs FAKSK (billing block) for your process | `DeliveryBlockReason` in `I_SalesOrderHeader` |

---

## Quick Reference: Object Names

| Artefact | SAP Object Name | Type |
|---------|----------------|------|
| Interface Header View | `I_SALESORDERHEADER` | CDS Data Definition |
| Interface Item View | `I_SALESORDERITEM` | CDS Data Definition |
| Consumption Header View | `C_SALESORDERHEADER` | CDS Data Definition |
| Consumption Item View | `C_SALESORDERITEM` | CDS Data Definition |
| Header DCL | `I_SALESORDERHEADER` | CDS Access Control |
| Item DCL | `I_SALESORDERITEM` | CDS Access Control |
| OData Service | `ZSALESORDER_SRV` | OData Service (auto-generated) |
| BSP App | `ZSALESORDERCOCKPIT` | ABAP BSP Application |
| Package | `ZSALES_COCKPIT_PKG` | ABAP Package |

---

## Phase 2 — Stretch Goals (Do NOT implement yet)

The following features are planned for a later phase.  **Implement only after the read-only v1 is working and signed off.**

> ⚠️ **Phase 2 items change data or add significant complexity — confirm with the team before starting.**

| Feature | Notes | When to start |
|---------|-------|--------------|
| **Release Delivery Block** action button | Needs a Function Import or RAP action on the OData service.  Modifies `VBAK.LIFSK` — requires `ACTVT = 02` (change) authorization.  Discuss FI vs. RAP approach first. | After read-only go-live |
| **Overdue order notification** | Threshold-based alert — needs a background ABAP job or BTP Alert Notification Service.  Confirm whether on-premise or BTP notification is preferred. | After read-only go-live |
| **Order value by status chart** | Add `@UI.chart` annotation on `C_SalesOrderHeader` + `@UI.presentationVariant` referencing a `DataPoint`. Needs `sap.viz` dependency.  Non-breaking — can be added incrementally. | Anytime after v1 |
