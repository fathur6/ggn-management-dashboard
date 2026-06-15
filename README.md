This project utilizes Google Apps Script for backend data handling and Google Sheets as the database, served via a React-based frontend styled with Tailwind CSS.

## 🚀 Technology Stack
* **Frontend:** React (CDN), Tailwind CSS, Lucide Icons
* **Backend/API:** Google Apps Script (GAS)
* **Database:** Google Sheets (CSV Export & Apps Script POST)
* **Reporting:** html2canvas, jsPDF
* **Deployment:** Clasp CLI (CI/CD Pipeline)

## 🛠️ Local Development & GitOps Workflow

This project adopts a strictly **GitOps** methodology. The code in this repository acts as the Single Source of Truth. Direct editing in the Google Apps Script cloud editor is highly discouraged.

### Prerequisites
1.  [Node.js](https://nodejs.org/) installed.
2.  [Clasp](https://github.com/google/clasp) (Command Line Apps Script Projects) installed globally:
    ```bash
    npm install -g @google/clasp
    ```
3.  Authenticate Clasp with your Google account:
    ```bash
    clasp login
    ```

### Deployment Commands
To push local changes to Google Apps Script and deploy them instantly, use the following combined command:

```bash
clasp push && clasp deploy
```

## 🌐 Dashboard Features
* **Role-Based Access Control (RBAC):** Separate views for General Staff (Read-only) and PPS Admins (Full Access).
* **Tactical Timeline (Quarterly):** Visual tracking of targets vs. completed projects across Q1 to Q4.
* **Eisenhower Matrix:** Drag-and-drop capability to prioritize projects based on urgency and importance.
* **Sector Breakdown:** Department-specific project tracking (Administration, Academic, Graduate Affairs).
* **Automated PDF Reporting:** One-click PDF generation of the current dashboard state.

## 📝 Language Policy
* **UI/UX (Frontend):** Bahasa Melayu Malaysia.
* **Documentation & Version Control:** English.
