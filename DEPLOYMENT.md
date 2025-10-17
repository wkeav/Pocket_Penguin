# Pocket Penguin - GitHub Pages Deployment

This document explains how to deploy the Pocket Penguin Flutter web app to GitHub Pages.

## 🚀 Automatic Deployment

The app is automatically deployed to GitHub Pages whenever you push to the `main` branch.

### Deployment URL
Once deployed, your app will be available at:
```
https://[your-username].github.io/Pocket_Penguin/
```

## 📋 Prerequisites

1. **GitHub Repository**: Your code must be in a GitHub repository
2. **GitHub Pages Enabled**: Pages must be enabled in your repository settings
3. **Actions Permissions**: GitHub Actions must have write permissions for Pages

## ⚙️ Setup Instructions

### 1. Enable GitHub Pages
1. Go to your repository on GitHub
2. Click on **Settings** tab
3. Scroll down to **Pages** section
4. Under **Source**, select **GitHub Actions**
5. Save the settings

### 2. Configure Repository Permissions
1. In repository **Settings** → **Actions** → **General**
2. Under **Workflow permissions**, select **Read and write permissions**
3. Check **Allow GitHub Actions to create and approve pull requests**
4. Save changes

### 3. Deploy Your App
1. Push your code to the `main` branch
2. The deployment will start automatically
3. Check the **Actions** tab to monitor deployment progress
4. Once complete, your app will be live at the GitHub Pages URL

## 🔧 Manual Deployment

If you need to trigger deployment manually:

1. Go to **Actions** tab in your repository
2. Select **Deploy Flutter Web to GitHub Pages** workflow
3. Click **Run workflow**
4. Select the branch (usually `main`)
5. Click **Run workflow**

## 🐛 Troubleshooting

### Common Issues

**1. Deployment Fails**
- Check the Actions tab for error messages
- Ensure all dependencies are properly listed in `pubspec.yaml`
- Verify Flutter version compatibility

**2. App Not Loading**
- Check if the base href is correct in the deployment workflow
- Verify the 404.html file is properly configured for SPA routing
- Clear browser cache and try again

**3. Routing Issues**
- The app uses client-side routing, so direct URL access might not work initially
- The custom 404.html file handles this by redirecting to the main app

### Build Optimization

The deployment workflow includes several optimizations:

- **Release Build**: Uses `--release` flag for optimized performance
- **Base Href**: Correctly configured for GitHub Pages subdirectory
- **SPA Routing**: Custom 404.html ensures proper routing
- **Caching**: Flutter dependencies are cached for faster builds

## 📱 Features

- **Responsive Design**: Works on desktop, tablet, and mobile
- **PWA Ready**: Can be installed as a Progressive Web App
- **Fast Loading**: Optimized build for quick loading times
- **SEO Friendly**: Proper meta tags and structure

## 🔄 Updating the App

To update your deployed app:

1. Make your changes to the code
2. Commit and push to `main` branch
3. The deployment will automatically trigger
4. Wait for the deployment to complete (usually 2-5 minutes)
5. Your changes will be live!

## 📊 Monitoring

- **Deployment Status**: Check the Actions tab for deployment progress
- **Build Logs**: View detailed logs in the Actions workflow
- **Performance**: Monitor app performance using browser dev tools

## 🛡️ Security Considerations

- **HTTPS**: GitHub Pages automatically provides HTTPS
- **Content Security**: No sensitive data should be stored in client-side code
- **API Security**: If connecting to backend APIs, ensure proper CORS configuration

## 📞 Support

If you encounter issues:

1. Check the GitHub Actions logs
2. Verify repository permissions
3. Ensure GitHub Pages is properly configured
4. Check the Flutter web documentation for specific issues

---

**Happy Deploying! 🐧**
