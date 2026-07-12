/*
 * ============================================================
 * CDS VIEW : C_SalesOrderItem
 * LAYER    : Consumption (UI-annotated)
 * PURPOSE  : Provides the item entity for the Object Page
 *            "Items & Delivery" facet.  Navigated to from
 *            C_SalesOrderHeader via the _Items association.
 *
 * NOTE: This view is NOT annotated with @OData.publish: true.
 *   It is reached via the navigation property on the header
 *   entity — the header entity's OData service automatically
 *   includes this entity set.
 *
 * UI ANNOTATION SUMMARY
 *   @UI.lineItem   → columns in the Object Page line-item table
 *                    (also visible if used in a List Report)
 *   @Semantics.amount → currency formatting for ItemNetValue
 *
 * VERSION NOTES — same as I_SalesOrderItem; see that file.
 * ============================================================
 */
@AbapCatalog.sqlViewName: 'ZCSDITM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Sales Order Item – Consumption View'
@VDM.viewType: #CONSUMPTION

define view C_SalesOrderItem
  as select from I_SalesOrderItem

  /* Back-association to the header — needed for the navigation property */
  association [1..1] to C_SalesOrderHeader as _Header
    on _Header.SalesOrder = $projection.SalesOrder

{
  /* ── Composite Key ──────────────────────────────────────── */
  @UI.lineItem: [{ position: 10, importance: #HIGH, label: 'Item' }]
  key SalesOrder,

  @UI.lineItem: [{ position: 10, importance: #HIGH, label: 'Item' }]
  key SalesOrderItem,

  /* ── Material & Description ─────────────────────────────── */
  @UI.lineItem: [{ position: 20, importance: #HIGH, label: 'Material' }]
      Material,

  @UI.lineItem: [{ position: 30, importance: #HIGH, label: 'Description' }]
      ItemDescription,

  /* ── Quantity ────────────────────────────────────────────── */
  @UI.lineItem: [{ position: 40, importance: #MEDIUM, label: 'Order Qty' }]
  @Semantics.quantity.unitOfMeasure: 'SalesUnit'
      OrderQuantity,

  @Semantics.unitOfMeasure: true
  @UI.hidden: true                             -- Hide UoM column; it's referenced by quantity
      SalesUnit,

  /* ── Item Value ─────────────────────────────────────────── */
  /*   The currency code comes from the HEADER (VBAK.WAERK).   *
   *   We pull it through the _Header association into a        *
   *   calculated field so @Semantics.amount can reference it. *
   *   NOTE: In CDS you can reference association fields in a   *
   *   @Semantics annotation only if the element is in the same *
   *   projection. The cleanest approach is to redeclare        *
   *   _Header.Currency as a local element:                     */
  @UI.lineItem: [{ position: 50, importance: #HIGH, label: 'Item Net Value' }]
  @Semantics.amount.currencyCode: 'ItemCurrency'
      ItemNetValue,

  /* Pull the header currency as a local element for the semantics reference */
  @Semantics.currencyCode: true
  @UI.hidden: true
      _Header.Currency                         as ItemCurrency,

  /* ── Item Status ─────────────────────────────────────────── */
  @UI.lineItem: [{
    position:   60,
    importance: #HIGH,
    label:      'Delivery Status'
    /*
     * TIP: You can add item-level criticality here too if desired,
     * by adding a CASE on ItemDeliveryStatus in I_SalesOrderItem
     * and referencing it via criticality: 'ItemDeliveryStatusCriticality'.
     * Left out here to keep the interface view simple for v1.
     */
  }]
      ItemDeliveryStatus,

  @UI.lineItem: [{ position: 70, importance: #MEDIUM, label: 'Billing Status' }]
      ItemBillingStatus,

  @UI.lineItem: [{ position: 80, importance: #LOW, label: 'Rejection Reason' }]
      RejectionReason,

  /* ── Delivery Information ───────────────────────────────── */
  @UI.lineItem: [{ position: 90, importance: #HIGH, label: 'Delivery Doc' }]
      DeliveryDocument,

  @UI.lineItem: [{ position: 100, importance: #MEDIUM, label: 'Planned GI Date' }]
      PlannedDeliveryDate,

  @UI.lineItem: [{ position: 110, importance: #HIGH, label: 'Actual GI Date' }]
      ActualGoodsIssueDate,

  /* ── Back-navigation ─────────────────────────────────────── */
      _Header
}
