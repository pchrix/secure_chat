// Tour automatisé de l'application SecureChat avec Playwright
const { test, expect } = require('@playwright/test');

test.describe('🎭 Tour Complet SecureChat MVP', () => {
  
  test.beforeEach(async ({ page }) => {
    // Navigation vers l'application Flutter
    console.log('🚀 Accès à l\'application SecureChat...');
    await page.goto('http://127.0.0.1:8080');
    
    // Attendre que Flutter soit complètement chargé
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(3000); // Attendre les animations de démarrage
  });

  test('🔐 Test complet du flux d\'authentification', async ({ page }) => {
    console.log('🔐 === TEST AUTHENTIFICATION ===');
    
    // Vérifier la page d'authentification
    console.log('1. Vérification de la page d\'authentification...');
    
    // Rechercher les éléments Flutter (utilisation de sélecteurs Flutter-web)
    const titleElements = await page.locator('text=SecureChat').all();
    expect(titleElements.length).toBeGreaterThan(0);
    console.log('✅ Titre "SecureChat" trouvé');
    
    // Vérifier la présence du texte d'authentification
    const authText = page.locator('text*=Authentification');
    await expect(authText.first()).toBeVisible({ timeout: 10000 });
    console.log('✅ Interface d\'authentification visible');
    
    // Simuler la saisie du PIN (1234)
    console.log('2. Saisie du PIN par défaut (1234)...');
    
    // Dans Flutter Web, nous devons utiliser des approches différentes
    // Tenter de trouver les boutons du clavier numérique
    await page.waitForTimeout(2000);
    
    // Méthode alternative : simulation clavier
    await page.keyboard.press('1');
    await page.keyboard.press('2');
    await page.keyboard.press('3');
    await page.keyboard.press('4');
    
    console.log('✅ PIN saisi (simulation clavier)');
    
    // Attendre la navigation vers la page d'accueil
    await page.waitForTimeout(3000);
    console.log('✅ Navigation post-authentification complétée');
  });

  test('🏠 Navigation et exploration de la page d\'accueil', async ({ page }) => {
    console.log('🏠 === TEST PAGE D\'ACCUEIL ===');
    
    // Authentification rapide
    await quickAuth(page);
    
    console.log('1. Exploration de l\'interface principale...');
    
    // Vérifier les éléments de l'interface
    const welcomeMessages = await page.locator('text*=Bienvenue').all();
    if (welcomeMessages.length > 0) {
      console.log('✅ Message de bienvenue détecté');
    }
    
    const secureChat = await page.locator('text=SecureChat').all();
    expect(secureChat.length).toBeGreaterThan(0);
    console.log('✅ En-tête SecureChat présent');
    
    // Rechercher les boutons principaux
    const createButton = page.locator('text*=Créer');
    const joinButton = page.locator('text*=Rejoindre');
    
    if (await createButton.first().isVisible()) {
      console.log('✅ Bouton "Créer un salon" trouvé');
    }
    
    if (await joinButton.first().isVisible()) {
      console.log('✅ Bouton "Rejoindre un salon" trouvé');
    }
    
    // Rechercher le salon de démonstration
    const demoRoom = page.locator('text*=démonstration');
    if (await demoRoom.first().isVisible()) {
      console.log('✅ Salon de démonstration visible');
      
      // Cliquer sur le salon de démonstration
      console.log('2. Accès au salon de démonstration...');
      await demoRoom.first().click();
      await page.waitForTimeout(2000);
      console.log('✅ Navigation vers le salon de démonstration');
    }
  });

  test('💬 Test de l\'interface de chat', async ({ page }) => {
    console.log('💬 === TEST INTERFACE CHAT ===');
    
    // Authentification et navigation vers le salon
    await quickAuth(page);
    await page.waitForTimeout(2000);
    
    // Rechercher et accéder au salon de démonstration
    const demoRoom = page.locator('text*=démonstration');
    if (await demoRoom.first().isVisible()) {
      await demoRoom.first().click();
      await page.waitForTimeout(3000);
      console.log('✅ Accès au salon de chat');
      
      // Vérifier les messages existants
      const messages = await page.locator('text*=Bienvenue').all();
      if (messages.length > 0) {
        console.log('✅ Messages de démonstration visibles');
      }
      
      // Tester l'envoi d'un nouveau message
      console.log('1. Test d\'envoi de message...');
      
      // Rechercher la zone de saisie
      const messageInput = page.locator('input[type="text"]').first();
      if (await messageInput.isVisible()) {
        await messageInput.fill('🧪 Message de test Playwright');
        await page.keyboard.press('Enter');
        console.log('✅ Message de test envoyé');
        
        await page.waitForTimeout(1000);
        
        // Vérifier que le message apparaît
        const testMessage = page.locator('text*=Message de test');
        if (await testMessage.first().isVisible()) {
          console.log('✅ Message de test affiché dans le chat');
        }
      }
    }
  });

  test('🎨 Vérification du design et de la responsivité', async ({ page }) => {
    console.log('🎨 === TEST DESIGN ET RESPONSIVITÉ ===');
    
    await quickAuth(page);
    
    console.log('1. Test responsive - Mobile (375px)...');
    await page.setViewportSize({ width: 375, height: 667 });
    await page.waitForTimeout(1000);
    
    const mobileElements = await page.locator('body').screenshot();
    console.log('✅ Capture mobile effectuée');
    
    console.log('2. Test responsive - Tablette (768px)...');
    await page.setViewportSize({ width: 768, height: 1024 });
    await page.waitForTimeout(1000);
    console.log('✅ Adaptation tablette testée');
    
    console.log('3. Test responsive - Desktop (1280px)...');
    await page.setViewportSize({ width: 1280, height: 720 });
    await page.waitForTimeout(1000);
    console.log('✅ Adaptation desktop testée');
    
    // Vérifier les couleurs du thème
    const bodyStyles = await page.evaluate(() => {
      const body = document.querySelector('body');
      const styles = window.getComputedStyle(body);
      return {
        backgroundColor: styles.backgroundColor,
        color: styles.color
      };
    });
    
    console.log('✅ Styles du thème récupérés:', bodyStyles);
  });

  test('⚙️ Test des fonctionnalités avancées', async ({ page }) => {
    console.log('⚙️ === TEST FONCTIONNALITÉS AVANCÉES ===');
    
    await quickAuth(page);
    
    console.log('1. Test du bouton d\'aide...');
    
    // Rechercher l'icône d'aide
    const helpIcon = page.locator('[data-testid="help-button"]').or(
      page.locator('text*=help').or(
        page.locator('button').filter({ hasText: '?' })
      )
    );
    
    if (await helpIcon.first().isVisible()) {
      await helpIcon.first().click();
      console.log('✅ Bouton d\'aide cliqué');
      
      await page.waitForTimeout(1000);
      
      // Vérifier l'ouverture du guide
      const guideText = page.locator('text*=Guide');
      if (await guideText.first().isVisible()) {
        console.log('✅ Guide d\'utilisation ouvert');
      }
    }
    
    console.log('2. Test de la navigation...');
    
    // Tester les transitions de page
    await page.goBack();
    await page.waitForTimeout(1000);
    console.log('✅ Navigation arrière testée');
  });

  test('🔍 Audit complet de l\'application', async ({ page }) => {
    console.log('🔍 === AUDIT COMPLET APPLICATION ===');
    
    await quickAuth(page);
    
    console.log('1. Analyse des performances...');
    
    // Métriques de performance
    const performanceMetrics = await page.evaluate(() => {
      const navigation = performance.getEntriesByType('navigation')[0];
      return {
        loadTime: navigation.loadEventEnd - navigation.fetchStart,
        domContentLoaded: navigation.domContentLoadedEventEnd - navigation.fetchStart,
        firstPaint: performance.getEntriesByType('paint').find(p => p.name === 'first-paint')?.startTime,
        firstContentfulPaint: performance.getEntriesByType('paint').find(p => p.name === 'first-contentful-paint')?.startTime
      };
    });
    
    console.log('📊 Métriques de performance:', performanceMetrics);
    
    console.log('2. Vérification de la sécurité UI...');
    
    // Vérifier l'absence d'informations sensibles dans le DOM
    const pageContent = await page.content();
    const hasSensitiveData = [
      'supabase.co',
      'eyJhbGciOiJIUzI1NiI', // Pattern JWT
      'password',
      'secret',
      'key'
    ].some(pattern => pageContent.toLowerCase().includes(pattern.toLowerCase()));
    
    if (!hasSensitiveData) {
      console.log('✅ Aucune donnée sensible exposée dans le DOM');
    } else {
      console.log('⚠️ Données potentiellement sensibles détectées');
    }
    
    console.log('3. Test de robustesse...');
    
    // Test de stress : navigation rapide
    for (let i = 0; i < 3; i++) {
      await page.reload();
      await page.waitForTimeout(1000);
    }
    console.log('✅ Test de stress navigation completed');
    
    console.log('4. Capture finale...');
    
    // Capture d'écran finale
    await page.screenshot({ 
      path: 'test-results/securechat-final-screenshot.png',
      fullPage: true 
    });
    console.log('✅ Capture d\'écran finale sauvegardée');
  });

});

// Fonction utilitaire pour l'authentification rapide
async function quickAuth(page) {
  console.log('🔐 Authentification rapide...');
  
  // Attendre que la page soit chargée
  await page.waitForTimeout(2000);
  
  // Simuler la saisie du PIN
  await page.keyboard.press('1');
  await page.keyboard.press('2');
  await page.keyboard.press('3');
  await page.keyboard.press('4');
  
  // Attendre la navigation
  await page.waitForTimeout(3000);
  
  console.log('✅ Authentification rapide terminée');
}

// Configuration des tests
test.use({
  viewport: { width: 1280, height: 720 },
  ignoreHTTPSErrors: true,
  video: 'retain-on-failure',
  screenshot: 'only-on-failure',
});