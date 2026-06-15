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
 * 3. Deployment Method: `clasp push && clasp deploy`
 * ============================================================================
 */

function doGet() {
  const userEmail = Session.getActiveUser().getEmail();
  const template = HtmlService.createTemplateFromFile('index');
  
  // Dapatkan senarai admin dari memori Apps Script
  const props = PropertiesService.getScriptProperties();
  let admins = props.getProperty('ADMIN_EMAILS');
  
  // Jika senarai kosong (kali pertama run), masukkan senarai asal yang anda berikan
  if (!admins) {
    const defaultAdmins = [
      "pps@unisza.edu.my", "fathurrahman@unisza.edu.my", "mutiasobihah@unisza.edu.my", 
      "whishamudin@unisza.edu.my", "yusnitayusof@unisza.edu.my", "fairuznasir@unisza.edu.my", 
      "fatinhannani@unisza.edu.my", "ariffahimi@unisza.edu.my", "azuhazana@unisza.edu.my", 
      "afiqahnorozi@unisza.edu.my", "muhammadhamizan@unisza.edu.my", "shuhadaaziz@unisza.edu.my"
    ];
    admins = JSON.stringify(defaultAdmins);
    props.setProperty('ADMIN_EMAILS', admins);
  }
  
  template.userEmail = userEmail;
  template.adminList = admins;

  return template.evaluate()
    .setTitle('Pelan Taktikal PPS')
    .addMetaTag('viewport', 'width=device-width, initial-scale=1')
    .setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL);
}

/**
 * Fungsi untuk dipanggil dari Frontend bagi menyimpan senarai Admin terkini
 */
function saveAdminsToServer(newAdminsList) {
  PropertiesService.getScriptProperties().setProperty('ADMIN_EMAILS', JSON.stringify(newAdminsList));
  return true;
}