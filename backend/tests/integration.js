import { spawn } from 'child_process';

const PORT = 3000;
const BASE_URL = `http://localhost:${PORT}/api`;

async function runTests() {
  console.log('\n--- Starting Integration Tests ---');
  
  // 1. Health Check
  const healthRes = await fetch(`http://localhost:${PORT}/`);
  const healthData = await healthRes.json();
  console.log('✔ Health check status:', healthData.status);
  if (healthData.status !== 'healthy') throw new Error('Health check failed!');

  // 2. Login as Admin
  console.log('Logging in as Admin...');
  const loginAdminRes = await fetch(`${BASE_URL}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: 'admin@gachamerch.com', password: 'password123' })
  });
  const loginAdminData = await loginAdminRes.json();
  const adminToken = loginAdminData.token;
  console.log('✔ Admin logged in. Token:', adminToken);
  if (!adminToken || adminToken.length !== 20) throw new Error('Admin token retrieval failed!');

  // 3. Login as User
  console.log('Logging in as User...');
  const loginUserRes = await fetch(`${BASE_URL}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: 'user@gachamerch.com', password: 'password123' })
  });
  const loginUserData = await loginUserRes.json();
  const userToken = loginUserData.token;
  console.log('✔ User logged in. Token:', userToken);
  if (!userToken || userToken.length !== 20) throw new Error('User token retrieval failed!');

  // 4. Get Catalog
  console.log('Fetching weapons catalog...');
  const catalogRes = await fetch(`${BASE_URL}/weapons`);
  const catalogData = await catalogRes.json();
  console.log('✔ Catalog weapons count:', catalogData.data.length);
  if (catalogData.data.length === 0) throw new Error('Catalog is empty!');

  // 5. Admin Create Weapon
  console.log('Admin creating new weapon...');
  const createWeaponRes = await fetch(`${BASE_URL}/weapons`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${adminToken}`
    },
    body: JSON.stringify({
      name: 'Staff of Homa',
      type: 'Polearm',
      description: 'Legendary weapon of Hu Tao.',
      stock: 5,
      image: 'staff_of_homa.png',
      price: 1600000.00
    })
  });
  const createWeaponData = await createWeaponRes.json();
  const weaponId = createWeaponData.data.id;
  console.log('✔ New weapon created. ID:', weaponId);
  if (!weaponId) throw new Error('Weapon creation failed!');

  // 6. User Purchase Weapon (Success)
  console.log('User purchasing weapon (qty 2)...');
  const purchaseRes = await fetch(`${BASE_URL}/transactions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${userToken}`
    },
    body: JSON.stringify({
      weapon_id: weaponId,
      quantity: 2
    })
  });
  const purchaseData = await purchaseRes.json();
  console.log('✔ Purchase success message:', purchaseData.message);
  console.log('✔ Total Price:', purchaseData.data.total_price);
  if (purchaseRes.status !== 201) throw new Error('Purchase failed!');

  // Verify stock is now 3
  const getWeaponRes = await fetch(`${BASE_URL}/weapons/${weaponId}`, {
    headers: { 'Authorization': `Bearer ${userToken}` }
  });
  const getWeaponData = await getWeaponRes.json();
  console.log('✔ Current stock in DB (expected 3):', getWeaponData.data.stock);
  if (parseInt(getWeaponData.data.stock) !== 3) throw new Error('Stock deduction failed!');

  // 7. User Purchase Weapon (Fails due to stock limit)
  console.log('User purchasing weapon (qty 4, exceeding stock of 3)...');
  const purchaseFailRes = await fetch(`${BASE_URL}/transactions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${userToken}`
    },
    body: JSON.stringify({
      weapon_id: weaponId,
      quantity: 4
    })
  });
  const purchaseFailData = await purchaseFailRes.json();
  console.log('✔ Purchase failed expected status (expected 422):', purchaseFailRes.status);
  console.log('✔ Error message returned:', purchaseFailData.message);
  if (purchaseFailRes.status !== 422) throw new Error('Purchase should have failed with status 422!');

  // 8. Admin Soft Delete Weapon
  console.log('Admin deleting weapon...');
  const deleteRes = await fetch(`${BASE_URL}/weapons/${weaponId}`, {
    method: 'DELETE',
    headers: { 'Authorization': `Bearer ${adminToken}` }
  });
  const deleteData = await deleteRes.json();
  console.log('✔ Delete response:', deleteData.message);
  if (deleteRes.status !== 200) throw new Error('Weapon deletion failed!');

  // Verify it is excluded from catalog
  const catalogAfterRes = await fetch(`${BASE_URL}/weapons`);
  const catalogAfterData = await catalogAfterRes.json();
  const found = catalogAfterData.data.some(w => w.id === weaponId);
  console.log('✔ Is deleted weapon present in catalog (expected false):', found);
  if (found) throw new Error('Soft-deleted weapon was found in catalog!');

  console.log('\n====================================');
  console.log('🎉 ALL INTEGRATION TESTS PASSED SUCCESS!');
  console.log('====================================\n');
}

console.log('[Test Setup] Launching API server on port 3000...');
const server = spawn('node', ['src/app.js'], { stdio: 'pipe' });

server.stdout.on('data', (data) => {
  const msg = data.toString();
  if (msg.includes('Genshin Import API is running')) {
    console.log('[Test Setup] Server is up and running.');
    runTests()
      .then(() => {
        server.kill();
        process.exit(0);
      })
      .catch((error) => {
        console.error('\n❌ Test execution failed:', error.message);
        server.kill();
        process.exit(1);
      });
  }
});

server.stderr.on('data', (data) => {
  console.error('[Server Error]', data.toString());
});
