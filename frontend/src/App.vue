<template>
  <div id="app">
    <h1>料理レシピ管理サイト</h1>
    <p>開発環境のセットアップが完了しました！</p>
    <div class="status">
      <h2>API接続テスト</h2>
      <button @click="testApi">APIヘルスチェック</button>
      <p v-if="apiStatus">{{ apiStatus }}</p>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue'

export default {
  name: 'App',
  setup() {
    const apiStatus = ref('')

    const testApi = async () => {
      try {
        const response = await fetch('/api/health')
        const data = await response.json()
        apiStatus.value = `✅ API接続成功: ${data.status} (${data.timestamp})`
      } catch (error) {
        apiStatus.value = `❌ API接続失敗: ${error.message}`
      }
    }

    return {
      apiStatus,
      testApi
    }
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}

.status {
  margin-top: 2rem;
  padding: 2rem;
  background: #f5f5f5;
  border-radius: 8px;
  display: inline-block;
}

button {
  padding: 0.5rem 1rem;
  background: #42b983;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
}

button:hover {
  background: #38a271;
}
</style>