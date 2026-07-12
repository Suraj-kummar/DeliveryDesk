/*
 * ============================================================
 * CDS VIEW : C_SalesOrderHeader
 * LAYER    : Consumption (UI-annotated, OData V2 published)
 * PURPOSE  : Exposes the sales order header entity as an OData
 *            V2 service via @OData.publish: true.  All Fiori
 *            Elements UI annotations live here — the interface
 *            view (I_SalesOrderHeader) stays annotation-free
 *            and reusable.
 *
 * OData Service auto-generated: ZSALESORDER_SRV
 * Entity Set auto-generated  : C_SalesOrderHeaderSet
 *
 * UI ANNOTATION SUMMARY
 *   @UI.headerInfo        → Object Page title/description chips
 *   @UI.facet             → Sections on the Object Page
 *   @UI.lineItem          → List Report table columns
 *   @UI.selectionField    → Smart Filter Bar filter fields
 *   @UI.identification    → Header identification section fields
 *   criticality:          → Color-codes a column (1=red,2=amber,3=green)
 *   @Semantics.amount     → Tells OData the currency code column
 *
 * VERSION NOTES — same as I_SalesOrderHeader; see that file.
 * ============================================================
 */

/* ── OData V2 Publication ───────────────────────────────── */
@OData.publish: true                           -- Generates ZSALESORDER_SRV automatically
                                               -- Activate in /IWFND/MAINT_SERVICE after CDS activation

/* ── VDM Layer ──────────────────────────────────────────── */
@VDM.viewType: #CONSUMPTION                    -- Marks this as the UI-facing layer

/* ── SQL View (must be unique, max 16 chars) ─────────────── */
@AbapCatalog.sqlViewName: 'ZCSOHDR'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK

/* ── Search ──────────────────────────────────────────────── */
@Search.searchable: true                       -- Enables the search bar in List Report

/* ── Object Page Header Info ─────────────────────────────── */
/*   typeName     → shown as "Sales Order" label              *
 *   typeNamePlural → plural in the list report title         *
 *   title.value  → the main title of each Object Page        *
 *   description.value → subtitle below the title             */
@UI.headerInfo: {
  typeName:       'Sales Order',
  typeNamePlural: 'Sales Orders',
  title: {
    type:  #STANDARD,
    value: 'SalesOrder'                        -- Shows the order number as the page title
  },
  description: {
    type:  #STANDARD,
    value: 'SoldToParty'                       -- Shows the customer as the subtitle
  }
}

/* ── End-User Label ─────────────────────────────────────── */
@EndUserText.label: 'Sales Order Header – Consumption View'

define view C_SalesOrderHeader
  as select from I_SalesOrderHeader            -- Selects from the interface view (no re-join needed)

  /* Association to item view — drives the "Items" facet on the Object Page */
  association [0..*] to C_SalesOrderItem as _Items
    on _Items.SalesOrder = $projection.SalesOrder

{
  /* ================================================================
   * FACET DEFINITION (Object Page sections)
   * ================================================================
   * Two facets:
   *   1. HeaderIdentification – shows key header fields
   *   2. ItemsTable           – shows the item line-item table
   *
   * @UI.facet must be placed on the SELECT list, not on individual
   * elements. SAP convention is to annotate the key field.
   * ================================================================ */
  @UI.facet: [
    /* Facet 1: Header information block */
    {
      id:            'HeaderIdentification',
      purpose:       #HEADER,                  -- Appears in the page header area
      type:          #IDENTIFICATION_REFERENCE, -- References @UI.identification annotations
      label:         'Order Details',
      position:      10
    },
    /* Facet 2: Line items table */
    {
      id:            'ItemsTable',
      purpose:       #STANDARD,                -- Appears as a section tab
      type:          #LINEITEM_REFERENCE,      -- References @UI.lineItem on C_SalesOrderItem
      label:         'Order Items & Delivery',
      position:      20,
      targetElement: '_Items'                  -- Navigates to the _Items association
    }
  ]

  /* ── Key ────────────────────────────────────────────────── */
  /*   @UI.lineItem      → column in the List Report table    *
   *   @UI.selectionField → filter field in the filter bar    *
   *   @UI.identification → field on the Object Page header   */
  @UI.lineItem:       [{ position: 10, importance: #HIGH, label: 'Sales Order' }]
  @UI.identification: [{ position: 10, label: 'Sales Order' }]
  @Search.defaultSearchElement: true           -- Also searchable via the search box
  key SalesOrder,

  /* ── Creation Date ─────────────────────────────────────── */
  @UI.lineItem:       [{ position: 20, importance: #HIGH, label: 'Created On' }]
  @UI.selectionField: [{ position: 20 }]       -- Filter: date range picker in Smart Filter Bar
  @UI.identification: [{ position: 20, label: 'Created On' }]
      CreationDate,

  /* ── Sold-To Party ─────────────────────────────────────── */
  @UI.lineItem:       [{ position: 30, importance: #HIGH, label: 'Sold-To Party' }]
  @UI.selectionField: [{ position: 10 }]       -- Filter: customer number search help
  @UI.identification: [{ position: 30, label: 'Sold-To Party' }]
  @Search.defaultSearchElement: true
      SoldToParty,

  /* ── Sales Organisation ─────────────────────────────────── */
  @UI.lineItem:       [{ position: 40, importance: #MEDIUM, label: 'Sales Org' }]
  @UI.identification: [{ position: 40, label: 'Sales Organisation' }]
      SalesOrganization,

  /* ── Distribution Channel ───────────────────────────────── */
  @UI.identification: [{ position: 50, label: 'Distribution Channel' }]
      DistributionChannel,

  /* ── Division ───────────────────────────────────────────── */
  @UI.identification: [{ position: 60, label: 'Division' }]
      Division,

  /* ── Sales Order Type ───────────────────────────────────── */
  @UI.lineItem:       [{ position: 50, importance: #MEDIUM, label: 'Order Type' }]
  @UI.selectionField: [{ position: 30 }]       -- Filter: dropdown / value help for order type
  @UI.identification: [{ position: 70, label: 'Order Type' }]
      SalesOrderType,

  /* ── Net Value (with currency-code semantics) ───────────── */
  /*   @Semantics.amount.currencyCode must reference the        *
   *   FIELD NAME of the currency column in THIS view.          *
   *   Without this, amounts render as plain numbers.           */
  @UI.lineItem:       [{ position: 60, importance: #HIGH, label: 'Net Value' }]
  @UI.identification: [{ position: 80, label: 'Net Value' }]
  @Semantics.amount.currencyCode: 'Currency'   -- Points to the Currency field below
      NetValue,

  /* ── Currency ───────────────────────────────────────────── */
  /*   Hidden from UI but referenced by NetValue semantics.     *
   *   Do NOT add @UI.lineItem here — it clutters the table.    */
  @Semantics.currencyCode: true
      Currency,

  /* ── Delivery Block ─────────────────────────────────────── */
  @UI.lineItem:       [{ position: 70, importance: #HIGH, label: 'Delivery Block' }]
  @UI.selectionField: [{ position: 40 }]       -- Filter: shows orders that are blocked
  @UI.identification: [{ position: 90, label: 'Delivery Block Reason' }]
      DeliveryBlockReason,

  /* ── Overall Processing Status ──────────────────────────── */
  @UI.lineItem:       [{ position: 80, importance: #MEDIUM, label: 'Processing Status' }]
  @UI.identification: [{ position: 100, label: 'Overall Processing Status' }]
      OverallProcessingStatus,

  /* ── Overall Delivery Status (with criticality coloring) ── */
  /*   criticality: 'DeliveryStatusCriticality'                *
   *     → Fiori Elements reads the integer field and applies  *
   *       the corresponding status color to this column.      *
   *   criticalityRepresentation: #WITHOUT_ICON               *
   *     → Shows color only; remove to also show status icon.  */
  @UI.lineItem: [{
    position:                   90,
    importance:                 #HIGH,
    label:                      'Delivery Status',
    criticality:                'DeliveryStatusCriticality',
    criticalityRepresentation:  #WITHOUT_ICON
  }]
  @UI.selectionField: [{ position: 50 }]       -- Filter: filter by delivery status code
  @UI.identification: [{ position: 110, label: 'Overall Delivery Status' }]
      OverallDeliveryStatus,

  /* ── Overall Billing Status ─────────────────────────────── */
  @UI.lineItem:       [{ position: 100, importance: #MEDIUM, label: 'Billing Status' }]
  @UI.identification: [{ position: 120, label: 'Overall Billing Status' }]
      OverallBillingStatus,

  /* ── Goods Movement Status ──────────────────────────────── */
  /*   VERSION NOTE: Comment out if below S/4HANA 1610.        */
  @UI.lineItem:       [{ position: 110, importance: #LOW, label: 'GI Status' }]
  @UI.identification: [{ position: 130, label: 'Goods Movement Status' }]
      OverallGoodsMovementStatus,

  /* ── Criticality Integer ────────────────────────────────── */
  /*   Referenced by the OverallDeliveryStatus lineItem above. *
   *   Should NOT appear as a column itself (no @UI.lineItem). *
   *   The annotation below hides it from the default column   *
   *   selection while keeping it accessible to the framework. */
  @UI.hidden: true
      DeliveryStatusCriticality,

  /* ── Navigation to Items ────────────────────────────────── */
  /*   Expose the association so the OData service includes    *
   *   an Items navigation property on the header entity.      */
      _Items
}
