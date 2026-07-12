/**
 * Component.js
 * ─────────────────────────────────────────────────────────────
 * Root UI Component for the Sales Order & Delivery Status Cockpit.
 *
 * For a Fiori Elements List Report + Object Page application the
 * Component extends sap.suite.ui.generic.template.AppComponent,
 * NOT the vanilla sap.ui.core.UIComponent.  The template component
 * provides:
 *   • automatic routing based on manifest.json "sap.ui5.routing"
 *   • header bar, variant management, share functionality
 *   • OData model binding wired to the entity sets
 *
 * You do NOT need to hand-write XML views or controllers for the
 * List Report or Object Page — the framework generates them from
 * the manifest and the OData annotations.
 *
 * WHEN YOU WOULD MODIFY THIS FILE
 *   Only if you add custom extensions (e.g., a custom action
 *   button handler or a custom column in Phase 2).  For the
 *   read-only v1 you can leave this exactly as generated.
 */
sap.ui.define([
  "sap/suite/ui/generic/template/AppComponent"
], function (AppComponent) {
  "use strict";

  return AppComponent.extend("com.yourcompany.salesordercockit.Component", {

    metadata: {
      /**
       * manifest: "json" tells the framework to read all configuration
       * (models, routing, service URLs, annotations) from manifest.json
       * rather than declaring them here in code.
       */
      manifest: "json"
    }

    /**
     * No init() override needed for the basic read-only app.
     *
     * Phase 2 extension point — if you later add a "Release Delivery
     * Block" action button, you would register a custom controller
     * extension here, e.g.:
     *
     *   init: function () {
     *     AppComponent.prototype.init.apply(this, arguments);
     *     // register controller extensions, custom actions …
     *   }
     */
  });
});
