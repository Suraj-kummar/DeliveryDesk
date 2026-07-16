CLASS ZBP_SalesOrderHeader DEFINITION
  PUBLIC
  ABSTRACT
  FINAL
  FOR BEHAVIOR OF R_SalesOrderHeader.

"  The RAP framework generates all required method signatures.
"  In Eclipse ADT, use Quick Fix (Ctrl+1) on the behavior definition
"  to auto-generate the skeleton of this class.
"
"  This stub provides the implementation structure and documentation.

ENDCLASS.

CLASS ZBP_SalesOrderHeader IMPLEMENTATION.
ENDCLASS.

*----------------------------------------------------------------------*
* CLASS lcl_handler (local helper — not exported)
* This is a SEPARATE include or local class in the implementation.
* In ADT the implementing class body goes here.
*----------------------------------------------------------------------*

"=======================================================================
" METHOD : releaseDeliveryBlock
"=======================================================================
" PURPOSE
"   Clears the delivery block on the selected sales order header.
"   Called by the "Request Release" action button in DeliveryDesk.
"
" INPUT
"   keys  — table of { SalesOrder } identifying the selected orders
"
" IMPLEMENTATION LOGIC
"   1. Authority-check V_VBAK_VKO / ACTVT 02 (Change)
"   2. Read VBAK-LIFSK (current delivery block)
"   3. If already blank — raise informational message (no-op)
"   4. Call BAPI_SALESORDER_CHANGE to clear the block:
"        ORDER_HEADER_IN-DLVBLOCK = space
"        ORDER_HEADER_INX-DLVBLOCK = 'X'   (flag = change)
"   5. Call BAPI_TRANSACTION_COMMIT
"   6. Re-read the updated record and return as result
"
" ERROR HANDLING
"   - Authority failure → raise_failed_dep_action (shows auth error)
"   - BAPI RETURN table has E/A messages → mapped to RAP messages
"   - No block found → informational message, no failure
"
" EXAMPLE ABAP CODE (reference implementation):
"-----------------------------------------------------------------------
"  METHOD releaseDeliveryBlock.
"
"    " ── 1. Authority Check ──────────────────────────────────────────
"    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
"      AUTHORITY-CHECK OBJECT 'V_VBAK_VKO'
"        ID 'VKORG' DUMMY
"        ID 'ACTVT' FIELD '02'.
"      IF sy-subrc <> 0.
"        APPEND VALUE #( %tky = <key>-%tky ) TO failed-salesorderheader.
"        APPEND VALUE #( %tky = <key>-%tky
"                        %msg = new_message_with_text(
"                                 severity = if_abap_behv_message=>severity-error
"                                 text     = 'Not authorised to release delivery blocks' )
"                        %element-salesorder = if_abap_behv=>mk-on )
"              TO reported-salesorderheader.
"        CONTINUE.
"      ENDIF.
"    ENDLOOP.
"
"    " ── 2. Call BAPI_SALESORDER_CHANGE ──────────────────────────────
"    LOOP AT keys ASSIGNING FIELD-SYMBOL(<k>).
"      DATA(lv_vbeln) = CONV vbeln( <k>-salesorder ).
"
"      DATA ls_header_in  TYPE bapisdh1.
"      DATA ls_header_inx TYPE bapisdh1x.
"      ls_header_in-dlvblock  = space.   " clear the block
"      ls_header_inx-dlvblock = 'X'.     " mark field as changed
"      ls_header_inx-updateflag = 'U'.
"
"      DATA lt_return TYPE bapiret2_t.
"
"      CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
"        EXPORTING
"          salesdocument    = lv_vbeln
"          order_header_in  = ls_header_in
"          order_header_inx = ls_header_inx
"        TABLES
"          return           = lt_return.
"
"      " Check for errors
"      DATA(lv_error) = VALUE #( lt_return[ type = 'E' ]-message OPTIONAL ).
"      IF lv_error IS NOT INITIAL.
"        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
"        APPEND VALUE #( %tky = <k>-%tky ) TO failed-salesorderheader.
"        APPEND VALUE #( %tky = <k>-%tky
"                        %msg = new_message_with_text(
"                                 severity = if_abap_behv_message=>severity-error
"                                 text     = lv_error )
"                        %element-salesorder = if_abap_behv=>mk-on )
"              TO reported-salesorderheader.
"        CONTINUE.
"      ENDIF.
"
"      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
"        EXPORTING wait = 'X'.
"    ENDLOOP.
"
"    " ── 3. Return updated records ────────────────────────────────────
"    READ ENTITIES OF C_SalesOrderHeader
"      ENTITY SalesOrderHeader
"        ALL FIELDS WITH CORRESPONDING #( keys )
"      RESULT DATA(lt_result)
"      FAILED DATA(ls_failed).
"
"    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky  %param = r ) ).
"  ENDMETHOD.
"=======================================================================
