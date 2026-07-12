/*
 * ============================================================
 * CDS VIEW : I_SalesOrderHeader
 * LAYER    : Interface (reusable, no UI annotations)
 * PURPOSE  : Joins VBAK (sales order header) with VBUK
 *            (overall header status) to expose a clean,
 *            typed header entity for the Sales Order &
 *            Delivery Status Cockpit.
 *
 * TABLES USED
 *   VBAK  – Sales Document: Header Data
 *   VBUK  – Sales Document: Header Status and Administrative Data
 *
 * VERSION NOTES
 *   • VBAK-NETWR renamed to NETWR_AK in some older CDS stubs —
 *     use the physical field NETWR directly; it is stable.
 *   • VBUK.WBSTK (Goods-Movement Status) exists from S/4HANA 1610+;
 *     if you are on an earlier release, comment that field out.
 *   • VBAK.FAKSK (billing block) is used for DeliveryBlockReason here
 *     as a proxy when LIFSK (delivery block) is empty.
 *     Adjust to LIFSK if your process uses the delivery block field
 *     exclusively.
 * ============================================================
 */
@AbapCatalog.sqlViewName: 'ZISOHDR'           -- Generated SQL view name (max 16 chars)
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK      -- Enforce DCL access control (recommended)
@EndUserText.label: 'Sales Order Header – Interface View'
@VDM.viewType: #BASIC                          -- VDM layer: BASIC = interface/reusable

define view I_SalesOrderHeader
  as select from vbak as Header                -- VBAK: Sales Document Header

    /* LEFT OUTER JOIN so orders with no status record still appear.
       VBUK is keyed on VBELN (same as VBAK.VBELN). */
    left outer join vbuk as Status
      on Status.vbeln = Header.vbeln

{
  /* ── Key Field ─────────────────────────────────────────── */
  @ObjectModel.text.association: '_SoldToPartyName'
  key Header.vbeln                as SalesOrder,            -- Sales Document Number

  /* ── Header Administrative Fields ──────────────────────── */
      Header.erdat                as CreationDate,           -- Date on which the record was created
      Header.kunnr                as SoldToParty,            -- Sold-To Party (Customer)
      Header.vkorg                as SalesOrganization,      -- Sales Organisation
      Header.vtweg                as DistributionChannel,    -- Distribution Channel
      Header.spart                as Division,               -- Division
      Header.auart                as SalesOrderType,         -- Sales Document Type (e.g. OR, ZOR)

  /* ── Value & Currency ───────────────────────────────────── */
  /*   @Semantics.amount is placed on the CONSUMPTION view     *
   *   (C_ layer) because @OData.publish requires it there.    *
   *   The raw fields are exposed as-is here.                  */
      Header.netwr                as NetValue,               -- Net Value of the Sales Order
      Header.waerk                as Currency,               -- SD Document Currency

  /* ── Block Reason ───────────────────────────────────────── */
  /*   LIFSK = delivery block at header level.                 *
   *   VERSION NOTE: If your orders use FAKSK (billing block)  *
   *   instead, swap the field reference below.                */
      Header.lifsk                as DeliveryBlockReason,    -- Delivery Block (Header)

  /* ── Overall Status Fields (from VBUK) ─────────────────── */
  /*   These are single-character codes:                       *
   *     ' ' = Not relevant   A = Not yet processed           *
   *     B = Partially        C = Fully processed              */
      Status.gbstk                as OverallProcessingStatus,   -- Overall Processing Status
      Status.lfstk                as OverallDeliveryStatus,     -- Overall Delivery Status
      Status.fkstk                as OverallBillingStatus,      -- Overall Billing Status

  /* ── Goods Movement Status ──────────────────────────────── */
  /*   VERSION NOTE: WBSTK available from S/4HANA 1610+.      *
   *   Comment out if on an earlier patch level.               */
      Status.wbstk                as OverallGoodsMovementStatus -- Goods Movement Status

  /* ── Calculated Criticality (used in Consumption view) ─── */
  /*   Defined here as a CASE expression so the consumption    *
   *   layer can reuse it without repeating logic.             */
      ,
      case Status.lfstk
        when 'A' then 2           -- Not delivered       → Warning  (yellow)
        when 'B' then 2           -- Partially delivered → Warning  (yellow)
        when 'C' then 3           -- Fully delivered     → Good     (green)
        else          1           -- Blocked / unknown   → Error    (red)
      end                         as DeliveryStatusCriticality   -- Integer used by @UI.lineItem criticality:

}
