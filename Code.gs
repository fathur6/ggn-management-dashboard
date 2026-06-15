/**
 * ============================================================================
 * GGN MANAGEMENT DASHBOARD - GOOGLE APPS SCRIPT BACKEND
 * ============================================================================
 *
 * Repository: ggn-management-dashboard
 * Script ID: 1QeAMMWgUbJuCWrgXZybiuFCc5L9yCK3ywF6KnSpmFScxld9JCBSLc_eF
 * Web App URL: https://script.google.com/macros/s/AKfycbza27T_x_wropHa1aQcBgjfZuQnB72Zds1PaXLk8ICHZ7_JudpTGjz2Uc1DjxlfoBM9/exec
 *
 * DEPLOYMENT SETTINGS (SOP):
 * 1. Execute As: "User accessing the web app" (to trigger Google OAuth)
 * 2. Who has access: "Anyone with Google account" (or UniSZA domain)
 * 3. Deployment Method: Always deploy via clasp CLI to maintain GitOps workflow:
 * `clasp push && clasp deploy`
 * ============================================================================
 */

/**
 * Main function to serve the Web App
 * This handles Google OAuth authentication automatically based on deployment settings.
 */
function doGet() {
  // Get active user email via Google OAuth
  const userEmail = Session.getActiveUser().getEmail();
  
  // Create HTML Template from index.html
  const template = HtmlService.createTemplateFromFile('index');
  
  // Pass variables to the frontend if needed
  template.userEmail = userEmail;

  return template.evaluate()
    .setTitle('Pelan Taktikal PPS')
    .addMetaTag('viewport', 'width=device-width, initial-scale=1')
    .setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL); // Critical for Google Sites embedding
}

/**
 * Helper function to include other files if necessary
 */
function include(filename) {
  return HtmlService.createHtmlOutputFromFile(filename).getContent();
}