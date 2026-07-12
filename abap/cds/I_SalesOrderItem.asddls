/*
 * ============================================================
 * CDS VIEW : I_SalesOrderItem
 * LAYER    : Interface (reusable, no UI annotations)
 * PURPOSE  : Joins VBAP (sales order items), VBUP (item-level
 *            status), and LIPS (delivery items — via the
 *            reference fields VGBEL / VGPOS) to present a
 *            unified item + delivery record for each order line.
 *
 * TABLES USED
 *   VBAP  – Sales Document: Item Data
 *   VBUP  – Sales Document: Item Status
 *   LIPS  – Delivery: Item Data
 *            (VGBEL = reference document = sales order VBELN)
 *            (VGPOS = reference item    = sales order POSNR)
 *
 * JOIN STRATEGY
 *   VBAP ──┬─ INNER JOIN VBUP  (every item must have a status row)
 *           └─ LEFT OUTER JOIN LIPS  (items may not yet be in delivery)
 *
 * VERSION NOTES
 *   • LIPS.WADAT_IST (Actual GI Date) exists from ECC 6.0+; stable.
 *   • LIPS.EDATU     (Planned Delivery Date) — some systems expose
 *     this on VBEP (schedule lines) rather than LIPS. If LIPS.EDATU
 *     is empty in your system, join VBEP on VBELN/POSNR instead.
 *   • VBAP.NETWR     – Item net value (in document currency).
 *   • The join to LIPS uses VGBEL/VGPOS (backward reference from
 *     the delivery item back to the sales order). This is the
 *     standard SAP approach and works for standard order types.
 *     For third-party or individual purchase orders the reference
 *     might not populate — flag those with QA.
 * ============================================================
 */
@AbapCatalog.sqlViewName: 'ZISDITM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Sales Order Item – Interface View'
@VDM.viewType: #BASIC

define view I_SalesOrderItem
  as select from vbap as Item                  -- VBAP: Sales Document Item

    /* Every item must have a status row in VBUP */
    inner join vbup as ItemStatus
      on  ItemStatus.vbeln = Item.vbeln
      and ItemStatus.posnr = Item.posnr

    /* LEFT JOIN: item may not be shipped yet → no LIPS row */
    left outer join lips as Delivery
      on  Delivery.vgbel = Item.vbeln          -- VGBEL: reference sales order
      and Delivery.vgpos = Item.posnr          -- VGPOS: reference item number

{
  /* ── Composite Key ──────────────────────────────────────── */
  key Item.vbeln                  as SalesOrder,             -- Sales Order Number
  key Item.posnr                  as SalesOrderItem,         -- Sales Order Item Number

  /* ── Item Descriptive Fields ────────────────────────────── */
      Item.matnr                  as Material,               -- Material Number
      Item.arktx                  as ItemDescription,        -- Short Text / Description
      Item.kwmeng                 as OrderQuantity,          -- Order Quantity
      Item.vrkme                  as SalesUnit,              -- Sales Unit (UoM)

  /* ── Item Value ─────────────────────────────────────────── */
  /*   Currency is inherited from the header (VBAK.WAERK).    *
   *   The consumption view joins to the header to pick it up. */
      Item.netwr                  as ItemNetValue,           -- Net Value of Item

  /* ── Item Status (from VBUP) ────────────────────────────── */
      ItemStatus.lfsta            as ItemDeliveryStatus,     -- Item Delivery Status
      ItemStatus.fksta            as ItemBillingStatus,      -- Item Billing Status
      ItemStatus.absta            as RejectionReason,        -- Reason for Rejection

  /* ── Delivery Document (from LIPS) ─────────────────────── */
      Delivery.vbeln              as DeliveryDocument,       -- Outbound Delivery Number
      Delivery.edatu              as PlannedDeliveryDate,    -- Planned Goods Issue Date
      --  VERSION NOTE: If LIPS.EDATU is blank, replace with:
      --    cast('' as abap.dats) as PlannedDeliveryDate,
      --  and fetch it from VBEP.EDATU instead.
      Delivery.wadat_ist          as ActualGoodsIssueDate    -- Actual Goods Issue Date

}
