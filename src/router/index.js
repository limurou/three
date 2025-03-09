import { createRouter, createWebHashHistory } from 'vue-router';
import Home from '../views/Home.vue';
import About from '../views/About.vue';
import Contact from '../views/Contact.vue';
import WebGL from '../views/WebGL.vue';
import Wave from '../views/Wave.vue';
import Galaxy from '../views/Galaxy.vue';
import GalaxyMove from '../views/GalaxyMove.vue';
import Smoke from '../views/Smoke.vue';
import Soldier from '../views/Soldier.vue';
import Show from '../views/Show.vue';
import FireWork from '../views/FireWork.vue';

const routes = [
  { path: '/', component: Show },
  { path: '/home', component: Home },
  { path: '/about', component: About },
  { path: '/contact', component: Contact },
  { path: '/webgl', component: WebGL },
  { path: '/wave', component: Wave },
  { path: '/galaxy', component: Galaxy },
  { path: '/galaxymove', component: GalaxyMove },
  { path: '/smoke', component: Smoke },
  { path: '/soldier', component: Soldier },
  { path: '/firework', component: FireWork },
];

const router = createRouter({
  history: createWebHashHistory(),
  routes
});

export default router;