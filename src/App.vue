<template>
  <div class="app">
    <h1>Путевой лист автомобиля</h1>
    
    <div class="form-container">
      <h2>Новый путевой лист</h2>
      
      <form @submit.prevent="addWaybill">
        <div class="form-group">
          <label for="driver">ФИО водителя:</label>
          <input 
            type="text" 
            id="driver" 
            v-model="newWaybill.driver" 
            placeholder="Иванов Иван Иванович"
            required
          />
        </div>

        <div class="form-group">
          <label for="vehicle">Автомобиль:</label>
          <input 
            type="text" 
            id="vehicle" 
            v-model="newWaybill.vehicle" 
            placeholder="ГАЗель А123ВС77"
            required
          />
        </div>

        <div class="form-group">
          <label for="date">Дата:</label>
          <input 
            type="date" 
            id="date" 
            v-model="newWaybill.date" 
            required
          />
        </div>

        <div class="form-row">
          <div class="form-group">
            <label for="startOdometer">Начальный пробег (км):</label>
            <input 
              type="number" 
              id="startOdometer" 
              v-model.number="newWaybill.startOdometer" 
              min="0"
              required
            />
          </div>

          <div class="form-group">
            <label for="endOdometer">Конечный пробег (км):</label>
            <input 
              type="number" 
              id="endOdometer" 
              v-model.number="newWaybill.endOdometer" 
              min="0"
            />
          </div>
        </div>

        <div class="form-group">
          <label for="route">Маршрут:</label>
          <textarea 
            id="route" 
            v-model="newWaybill.route" 
            placeholder="Москва - Подольск - Москва"
            rows="3"
          ></textarea>
        </div>

        <div class="form-group">
          <label for="fuel">Расход топлива (л):</label>
          <input 
            type="number" 
            id="fuel" 
            v-model.number="newWaybill.fuel" 
            min="0"
            step="0.1"
          />
        </div>

        <button type="submit" class="btn-primary">Добавить путевой лист</button>
      </form>
    </div>

    <div class="waybills-list">
      <h2>Список путевых листов</h2>
      
      <div v-if="waybills.length === 0" class="empty-state">
        <p>Путевые листы еще не добавлены</p>
      </div>

      <table v-else class="waybills-table">
        <thead>
          <tr>
            <th>Дата</th>
            <th>Водитель</th>
            <th>Автомобиль</th>
            <th>Пробег (км)</th>
            <th>Маршрут</th>
            <th>Топливо (л)</th>
            <th>Действия</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(waybill, index) in waybills" :key="waybill.id">
            <td>{{ formatDate(waybill.date) }}</td>
            <td>{{ waybill.driver }}</td>
            <td>{{ waybill.vehicle }}</td>
            <td>{{ calculateDistance(waybill) }}</td>
            <td>{{ waybill.route || '-' }}</td>
            <td>{{ waybill.fuel || '-' }}</td>
            <td>
              <button @click="deleteWaybill(index)" class="btn-danger">Удалить</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'App',
  data() {
    return {
      newWaybill: {
        driver: '',
        vehicle: '',
        date: new Date().toISOString().split('T')[0],
        startOdometer: 0,
        endOdometer: 0,
        route: '',
        fuel: 0
      },
      waybills: [
        {
          id: 1,
          driver: 'Петров Петр Петрович',
          vehicle: 'Ford Transit А456ВС99',
          date: '2024-01-15',
          startOdometer: 15000,
          endOdometer: 15250,
          route: 'Москва - Химки - Москва',
          fuel: 25.5
        },
        {
          id: 2,
          driver: 'Сидоров Сидор Сидорович',
          vehicle: 'ГАЗель В789СМ77',
          date: '2024-01-16',
          startOdometer: 32000,
          endOdometer: 32180,
          route: 'Москва - Мытищи - Королёв',
          fuel: 18.2
        }
      ]
    }
  },
  methods: {
    addWaybill() {
      const waybill = {
        ...this.newWaybill,
        id: Date.now()
      }
      this.waybills.push(waybill)
      this.resetForm()
    },
    deleteWaybill(index) {
      if (confirm('Вы уверены, что хотите удалить этот путевой лист?')) {
        this.waybills.splice(index, 1)
      }
    },
    resetForm() {
      this.newWaybill = {
        driver: '',
        vehicle: '',
        date: new Date().toISOString().split('T')[0],
        startOdometer: 0,
        endOdometer: 0,
        route: '',
        fuel: 0
      }
    },
    calculateDistance(waybill) {
      if (waybill.endOdometer && waybill.startOdometer) {
        return waybill.endOdometer - waybill.startOdometer
      }
      return '-'
    },
    formatDate(dateString) {
      const options = { year: 'numeric', month: 'long', day: 'numeric' }
      return new Date(dateString).toLocaleDateString('ru-RU', options)
    }
  }
}
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  background-color: #f5f5f5;
  color: #333;
}

.app {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

h1 {
  text-align: center;
  color: #2c3e50;
  margin-bottom: 30px;
  font-size: 2.5rem;
}

h2 {
  color: #34495e;
  margin-bottom: 20px;
  border-bottom: 2px solid #3498db;
  padding-bottom: 10px;
}

.form-container {
  background: white;
  padding: 30px;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  margin-bottom: 30px;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 600;
  color: #555;
}

.form-group input,
.form-group textarea {
  width: 100%;
  padding: 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
  transition: border-color 0.3s;
}

.form-group input:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #3498db;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

.btn-primary {
  background-color: #3498db;
  color: white;
  padding: 12px 30px;
  border: none;
  border-radius: 4px;
  font-size: 16px;
  cursor: pointer;
  transition: background-color 0.3s;
  width: 100%;
}

.btn-primary:hover {
  background-color: #2980b9;
}

.btn-danger {
  background-color: #e74c3c;
  color: white;
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  font-size: 14px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.btn-danger:hover {
  background-color: #c0392b;
}

.waybills-list {
  background: white;
  padding: 30px;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.empty-state {
  text-align: center;
  padding: 40px;
  color: #999;
  font-size: 18px;
}

.waybills-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 20px;
}

.waybills-table th,
.waybills-table td {
  padding: 12px;
  text-align: left;
  border-bottom: 1px solid #ddd;
}

.waybills-table th {
  background-color: #f8f9fa;
  font-weight: 600;
  color: #2c3e50;
}

.waybills-table tr:hover {
  background-color: #f5f5f5;
}

@media (max-width: 768px) {
  .form-row {
    grid-template-columns: 1fr;
  }
  
  .waybills-table {
    font-size: 14px;
  }
  
  .waybills-table th,
  .waybills-table td {
    padding: 8px;
  }
}
</style>
