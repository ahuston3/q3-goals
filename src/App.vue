<template>
  <div id="app">
    <Thermometer msg="Welcome to Your Vue.js App"/>
  </div>
</template>

<script>
import Thermometer from './components/Thermometer.vue'

export default {
  name: 'App',
  components: {
    Thermometer
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
  margin-top: 30px;
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
}
</style>
