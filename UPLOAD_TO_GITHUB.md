# Upload this project to GitHub

## Option A — GitHub website (easiest)

1. Sign in to GitHub.
2. Click the **+** icon in the top-right corner.
3. Choose **New repository**.
4. Repository name: `procurement-analytics-portfolio`
5. Description: `Procurement analytics portfolio project using MySQL, Power BI, DAX, Power Query and advanced SQL.`
6. Select **Public** if you want recruiters to view it.
7. Do **not** initialize with another README because this package already contains one.
8. Click **Create repository**.
9. On the new repository page, click **uploading an existing file**.
10. Drag the **contents** of the `procurement-analytics-portfolio` folder into the upload area. Keep the folder structure.
11. Commit message: `Initial procurement analytics portfolio project`
12. Click **Commit changes**.
13. Open the repository home page and confirm the README and dashboard images render correctly.
14. Click the gear icon next to **About** and add topics such as `power-bi`, `mysql`, `sql`, `data-analysis`, `procurement`, and `portfolio-project`.

## Option B — Git command line

```bash
git init
git add .
git commit -m "Initial procurement analytics portfolio project"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/procurement-analytics-portfolio.git
git push -u origin main
```

## Before publishing

- Add your final `.pbix` file to `powerbi/` if you want to share it publicly.
- Check the screenshots one last time for any unwanted local or personal information.
- Keep the note that the dataset is synthetic.
- Do not describe the department budget analysis as validated budget overspend; the project explicitly flags a scale/business-definition mismatch.
