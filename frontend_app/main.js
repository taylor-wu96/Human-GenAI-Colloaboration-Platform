import { createApp } from "vue";
import App from './App.vue' //Our .vue startup file
import './static/global.css'      
import router from './router'
import store from "./store";
import 'element-plus/dist/index.css'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'

const app = createApp(App)
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
  app.component(key, component)
}

app.use(router).use(store).mount('#app'); 
