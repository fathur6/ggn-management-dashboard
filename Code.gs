/**
 * ============================================================================
 * GGN MANAGEMENT DASHBOARD - GOOGLE APPS SCRIPT BACKEND
 * ============================================================================
 *
 * Repository: ggn-management-dashboard
 * Script ID: __SCRIPT_ID__
 * Deployment ID: __DEPLOYMENT_ID__
 * Web App URL: __GOOGLE_SCRIPT_URL__
 * Target Spreadsheet ID: __SPREADSHEET_ID__
 *
 * DEPLOYMENT SETTINGS (SOP):
 * 1. Execute As: "User accessing the web app" (to trigger Google OAuth)
 * 2. Who has access: "Anyone with Google account" (or UniSZA domain)
 * 3. Deployment Method (To keep URL unchanged):
 * `clasp push && clasp deploy -i __DEPLOYMENT_ID__ -d "Update version"`
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
      "admin@example.com", "user1@example.com", "user2@example.com", 
      "user3@example.com", "user4@example.com", "user5@example.com", 
      "user6@example.com", "user7@example.com", "user8@example.com", 
      "user9@example.com", "user10@example.com", "user11@example.com"
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

/**
 * Mengendalikan permintaan HTTP POST dari Frontend untuk operasi CRUD Projek
 */
function doPost(e) {
  var data = JSON.parse(e.postData.contents);

  // Menggunakan openById bagi menyokong Local Development Workflow (Standalone Script)
  var sheet = SpreadsheetApp.openById("__SPREADSHEET_ID__").getSheetByName("Status Projek PPS");
  if (!sheet) {
    return ContentService.createTextOutput(JSON.stringify({ "status": "ralat", "mesej": "Sheet 'Status Projek PPS' tidak dijumpai" })).setMimeType(ContentService.MimeType.JSON);
  }

  // FUNGSI 1: TAMBAH PROJEK BARU
  if (data.action === 'add') {
    sheet.appendRow([
      data.Timestamp, data.Jabatan, data.Projek, data.TarikhMula, 
      data.Kemajuan, data.TarikhAsal, data.TarikhSebenar, data.Kepentingan, data.Catatan
    ]);
    return ContentService.createTextOutput(JSON.stringify({ "status": "berjaya" })).setMimeType(ContentService.MimeType.JSON);
  }
  
  // FUNGSI 2: KEMASKINI PROJEK
  if (data.action === 'update') {
    var dataRange = sheet.getDataRange();
    var values = dataRange.getValues();
    
    for (var i = 1; i < values.length; i++) {
      if (values[i][2] === data.oldProjek) { 
        var rowNum = i + 1; 
        sheet.getRange(rowNum, 1).setValue(data.Timestamp);
        sheet.getRange(rowNum, 2).setValue(data.Jabatan);
        sheet.getRange(rowNum, 3).setValue(data.Projek);
        sheet.getRange(rowNum, 4).setValue(data.TarikhMula);
        sheet.getRange(rowNum, 5).setValue(data.Kemajuan);
        sheet.getRange(rowNum, 6).setValue(data.TarikhAsal);
        sheet.getRange(rowNum, 7).setValue(data.TarikhSebenar);
        sheet.getRange(rowNum, 8).setValue(data.Kepentingan); 
        sheet.getRange(rowNum, 9).setValue(data.Catatan);     
        return ContentService.createTextOutput(JSON.stringify({ "status": "berjaya dikemaskini" })).setMimeType(ContentService.MimeType.JSON);
      }
    }
  }

  // FUNGSI 3: BUANG PROJEK
  if (data.action === 'delete') {
    var dataRange = sheet.getDataRange();
    var values = dataRange.getValues();
    
    for (var i = 1; i < values.length; i++) {
      if (values[i][2] === data.oldProjek) { 
        var rowNum = i + 1;
        sheet.deleteRow(rowNum); 
        return ContentService.createTextOutput(JSON.stringify({ "status": "berjaya dipadam" })).setMimeType(ContentService.MimeType.JSON);
      }
    }
  }
}