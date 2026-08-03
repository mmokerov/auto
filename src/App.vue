<template>
  <div class="app-container">
    <div class="background-gradient"></div>
    
    <header class="header">
      <h1>🚗 Путевой лист</h1>
      <p class="subtitle">Учет автомобильных перевозок</p>
    </header>

    <main class="main-content">
      <section class="card form-card">
        <h2>✨ Новый путевой лист</h2>
        <form @submit.prevent="createWaybill" class="waybill-form">
          <div class="form-group">
            <label for="driver">Водитель</label>
            <input type="text" id="driver" v-model="newWaybill.driver" placeholder="Иванов И.И." required />
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="vehicle">Автомобиль</label>
              <input type="text" id="vehicle" v-model="newWaybill.vehicle" placeholder="А 123 АА 777" required />
            </div>
            <div class="form-group">
              <label for="date">Дата</label>
              <input type="date" id="date" v-model="newWaybill.date" required />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="startMileage">Пробег начало (км)</label>
              <input type="number" id="startMileage" v-model.number="newWaybill.startMileage" placeholder="0" required min="0" />
            </div>
            <div class="form-group">
              <label for="endMileage">Пробег конец (км)</label>
              <input type="number" id="endMileage" v-model.number="newWaybill.endMileage" placeholder="0" required min="0" />
            </div>
          </div>

          <div class="form-group">
            <label for="route">Маршрут</label>
            <input type="text" id="route" v-model="newWaybill.route" placeholder="Москва - Тверь - Москва" required />
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="fuel">Топливо (л)</label>
              <input type="number" id="fuel" v-model.number="newWaybill.fuel" placeholder="0" required min="0" step="0.1" />
            </div>
            <div class="form-group">
              <label for="fuelCost">Стоимость топлива (₽)</label>
              <input type="number" id="fuelCost" v-model.number="newWaybill.fuelCost" placeholder="0" required min="0" />
            </div>
          </div>

          <button type="submit" class="btn-submit" :disabled="loading">
            {{ loading ? 'Сохранение...' : '➕ Создать путевой лист' }}
          </button>
        </form>
      </section>

      <section class="card list-card">
        <h2>📋 История путевых листов</h2>
        
        <div v-if="loading" class="loading-state">
          <div class="spinner"></div>
          <p>Загрузка данных...</p>
        </div>

        <div v-else-if="waybills.length === 0" class="empty-state">
          <p>📭 Нет записей</p>
          <p class="empty-hint">Создайте первый путевой лист</p>
        </div>

        <div v-else class="waybills-list">
          <div v-for="waybill in waybills" :key="waybill.id" class="waybill-item">
            <div class="waybill-header">
              <span class="date-badge">{{ formatDate(waybill.date) }}</span>
              <button @click="deleteWaybill(waybill.id)" class="btn-delete" title="Удалить">🗑️</button>
            </div>
            
            <div class="waybill-body">
              <div class="info-row"><span class="label">👤 Водитель:</span><span class="value">{{ waybill.driver }}</span></div>
              <div class="info-row"><span class="label">🚗 Автомобиль:</span><span class="value">{{ waybill.vehicle }}</span></div>
              <div class="info-row"><span class="label">🛣️ Маршрут:</span><span class="value">{{ waybill.route }}</span></div>
              
              <div class="stats-grid">
                <div class="stat-item"><span class="stat-label">Пробег</span><span class="stat-value">{{ calculateDistance(waybill.startMileage, waybill.endMileage) }} км</span></div>
                <div class="stat-item"><span class="stat-label">Топливо</span><span class="stat-value">{{ waybill.fuel }} л</span></div>
                <div class="stat-item"><span class="stat-label">Стоимость</span><span class="stat-value">{{ formatCurrency(waybill.fuelCost) }}</span></div>
                <div class="stat-item"><span class="stat-label">Расход</span><span class="stat-value">{{ calculateConsumption(waybill) }} л/100км</span></div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'

const API_URL = import.meta.env.VITE_API_URL || '/api/waybills'

const newWaybill = ref({
  driver: '',
  vehicle: '',
  date: new Date().toISOString().split('T')[0],
  startMileage: 0,
  endMileage: 0,
  route: '',
  fuel: 0,
  fuelCost: 0
})

const waybills = ref([])
const loading = ref(false)

const fetchWaybills = async () => {
  loading.value = true
  try {
    const response = await axios.get(API_URL)
    waybills.value = response.data || []
  } catch (error) {
    console.error('Ошибка загрузки:', error)
  } finally {
    loading.value = false
  }
}

const createWaybill = async () => {
  if (!newWaybill.value.driver || !newWaybill.value.vehicle) return
  
  loading.value = true
  try {
    await axios.post(API_URL, { ...newWaybill.value })
    newWaybill.value = {
      driver: '',
      vehicle: '',
      date: new Date().toISOString().split('T')[0],
      startMileage: 0,
      endMileage: 0,
      route: '',
      fuel: 0,
      fuelCost: 0
    }
    await fetchWaybills()
  } catch (error) {
    console.error('Ошибка создания:', error)
    alert('Ошибка при создании путевого листа')
  } finally {
    loading.value = false
  }
}

const deleteWaybill = async (id) => {
  if (!confirm('Вы уверены, что хотите удалить эту запись?')) return
  
  loading.value = true
  try {
    await axios.delete(`${API_URL}/${id}`)
    await fetchWaybills()
  } catch (error) {
    console.error('Ошибка удаления:', error)
    alert('Ошибка при удалении записи')
  } finally {
    loading.value = false
  }
}

const calculateDistance = (start, end) => Math.max(0, end - start)

const calculateConsumption = (waybill) => {
  const distance = calculateDistance(waybill.startMileage, waybill.endMileage)
  if (distance === 0) return 0
  return ((waybill.fuel / distance) * 100).toFixed(1)
}

const formatDate = (dateString) => {
  const options = { day: 'numeric', month: 'long', year: 'numeric' }
  return new Date(dateString).toLocaleDateString('ru-RU', options)
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('ru-RU', { style: 'currency', currency: 'RUB', minimumFractionDigits: 0 }).format(value)
}

onMounted(() => {
  fetchWaybills()
})
</script>

<style>
* { margin: 0; padding: 0; box-sizing: border-box; }

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%);
  min-height: 100vh;
  color: #2d3748;
}

.app-container {
  position: relative;
  min-height: 100vh;
  padding: 20px;
}

.background-gradient {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: 
    radial-gradient(circle at 20% 80%, rgba(120, 119, 198, 0.3) 0%, transparent 50%),
    radial-gradient(circle at 80% 20%, rgba(255, 119, 198, 0.3) 0%, transparent 50%);
  pointer-events: none;
  z-index: 0;
}

.header {
  text-align: center;
  margin-bottom: 30px;
  position: relative;
  z-index: 1;
  color: white;
  text-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
}

.header h1 { font-size: 2.5rem; font-weight: 700; margin-bottom: 8px; }
.subtitle { font-size: 1.1rem; opacity: 0.9; font-weight: 300; }

.main-content {
  max-width: 800px;
  margin: 0 auto;
  position: relative;
  z-index: 1;
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.card {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border-radius: 24px;
  padding: 28px;
  box-shadow: 0 8px 32px rgba(31, 38, 135, 0.15), inset 0 1px 0 rgba(255, 255, 255, 0.3);
  border: 1px solid rgba(255, 255, 255, 0.18);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.card:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 40px rgba(31, 38, 135, 0.2);
}

.card h2 { font-size: 1.5rem; margin-bottom: 24px; font-weight: 600; }

.waybill-form { display: flex; flex-direction: column; gap: 20px; }

.form-group { display: flex; flex-direction: column; gap: 8px; }

.form-group label {
  font-size: 0.9rem;
  font-weight: 600;
  color: #718096;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.form-group input {
  padding: 14px 18px;
  border: 2px solid rgba(102, 126, 234, 0.2);
  border-radius: 16px;
  font-size: 1rem;
  background: rgba(255, 255, 255, 0.8);
  transition: all 0.3s ease;
  outline: none;
}

.form-group input:focus {
  border-color: #667eea;
  background: white;
  box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1);
  transform: scale(1.02);
}

.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }

.btn-submit {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 16px 24px;
  border-radius: 16px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
}

.btn-submit:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.5);
}

.btn-submit:disabled { opacity: 0.7; cursor: not-allowed; }

.waybills-list { display: flex; flex-direction: column; gap: 16px; }

.waybill-item {
  background: rgba(255, 255, 255, 0.6);
  border-radius: 20px;
  padding: 20px;
  border: 1px solid rgba(255, 255, 255, 0.3);
  transition: all 0.3s ease;
}

.waybill-item:hover {
  background: rgba(255, 255, 255, 0.8);
  transform: scale(1.02);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.waybill-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.date-badge {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 6px 14px;
  border-radius: 20px;
  font-size: 0.9rem;
  font-weight: 600;
  box-shadow: 0 2px 10px rgba(102, 126, 234, 0.3);
}

.btn-delete {
  background: rgba(229, 62, 62, 0.1);
  border: none;
  padding: 8px 12px;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 1.2rem;
}

.btn-delete:hover {
  background: rgba(229, 62, 62, 0.2);
  transform: scale(1.1);
}

.waybill-body { display: flex; flex-direction: column; gap: 12px; }

.info-row { display: flex; gap: 12px; align-items: baseline; }
.info-row .label { font-weight: 600; color: #718096; font-size: 0.9rem; min-width: 100px; }
.info-row .value { color: #2d3748; font-weight: 500; }

.stats-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
  margin-top: 8px;
  padding-top: 16px;
  border-top: 1px solid rgba(102, 126, 234, 0.2);
}

.stat-item { display: flex; flex-direction: column; gap: 4px; }
.stat-label { font-size: 0.8rem; color: #718096; text-transform: uppercase; letter-spacing: 0.5px; }
.stat-value { font-size: 1.1rem; font-weight: 700; color: #667eea; }

.loading-state, .empty-state { text-align: center; padding: 40px 20px; color: #718096; }

.spinner {
  width: 40px; height: 40px;
  border: 4px solid rgba(102, 126, 234, 0.2);
  border-top-color: #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 16px;
}

@keyframes spin { to { transform: rotate(360deg); } }

.empty-hint { font-size: 0.9rem; opacity: 0.8; margin-top: 8px; }

@media (max-width: 600px) {
  .app-container { padding: 16px; }
  .header h1 { font-size: 2rem; }
  .card { padding: 20px; border-radius: 20px; }
  .form-row, .stats-grid { grid-template-columns: 1fr; }
  .info-row { flex-direction: column; gap: 4px; }
  .info-row .label { min-width: auto; }
}
</style>
