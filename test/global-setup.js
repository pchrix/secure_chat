// Configuration globale des tests Playwright
const { chromium } = require('@playwright/test');

async function globalSetup(config) {
  console.log('🚀 Démarrage des tests SecureChat...');
  
  // Configuration du navigateur pour les tests
  const browser = await chromium.launch();
  const context = await browser.newContext();
  const page = await context.newPage();
  
  try {
    // Vérifier que l'application Flutter est accessible
    console.log('🔍 Vérification de l\'accessibilité de l\'application...');
    await page.goto('http://localhost:8080', { 
      waitUntil: 'networkidle',
      timeout: 60000 
    });
    
    // Attendre que Flutter soit complètement chargé
    await page.waitForSelector('#app', { timeout: 30000 });
    console.log('✅ Application Flutter accessible');
    
    // Configuration des tests d'accessibilité
    await setupAccessibilityTesting(page);
    
    // Configuration des métriques de performance
    await setupPerformanceMonitoring(page);
    
    console.log('✅ Configuration globale terminée');
    
  } catch (error) {
    console.error('❌ Erreur lors de la configuration:', error);
    throw error;
  } finally {
    await browser.close();
  }
}

async function setupAccessibilityTesting(page) {
  // Injection de axe-core pour les tests d'accessibilité
  await page.addScriptTag({
    url: 'https://unpkg.com/axe-core@4.7.0/axe.min.js'
  });
  
  // Configuration des règles d'accessibilité
  await page.evaluate(() => {
    if (window.axe) {
      window.axe.configure({
        rules: [
          // Contraste des couleurs
          { id: 'color-contrast', enabled: true },
          // Navigation clavier
          { id: 'keyboard', enabled: true },
          // Labels ARIA
          { id: 'label', enabled: true },
          // Structure des en-têtes
          { id: 'heading-order', enabled: true },
          // Liens valides
          { id: 'link-name', enabled: true },
          // Boutons accessibles
          { id: 'button-name', enabled: true }
        ]
      });
    }
  });
  
  console.log('♿ Configuration accessibilité WCAG 2.1 AA activée');
}

async function setupPerformanceMonitoring(page) {
  // Activation des métriques de performance
  await page.coverage.startJSCoverage();
  await page.coverage.startCSSCoverage();
  
  // Surveillance des erreurs réseau
  page.on('response', response => {
    if (response.status() >= 400) {
      console.warn(`⚠️  Erreur réseau: ${response.status()} - ${response.url()}`);
    }
  });
  
  // Surveillance des erreurs JavaScript
  page.on('pageerror', error => {
    console.error('❌ Erreur JavaScript:', error.message);
  });
  
  // Surveillance des requêtes lentes
  page.on('response', response => {
    const timing = response.timing();
    if (timing && timing.responseEnd > 3000) { // Plus de 3 secondes
      console.warn(`🐌 Requête lente: ${response.url()} - ${timing.responseEnd}ms`);
    }
  });
  
  console.log('📊 Surveillance des performances activée');
}

module.exports = globalSetup;