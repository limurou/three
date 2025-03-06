<script setup>
import { useRouter } from 'vue-router';

const router = useRouter();

function handleSelect(index) {
  if (index === '1') {
    router.push('/webgl');
  }
  else if (index === '2') {
    router.push('/about');
  }
  else if (index === '3') {
    router.push('/contact');
  }
}
</script>

<template>
  <div class="common-layout">
    <el-container>
      
      <el-container>
        <el-aside style="width: 200px; height: 100vh;">
          <div style="padding:10px; font-size:2em">webgl</div>
          <el-menu default-active="1" class="el-menu-vertical-demo" @select="handleSelect">
            <el-menu-item index="1" class="menu-item">
              <div class="img-container">
                <img src="./assets/1.jpg" alt="Option 1" class="img" />
              </div>
              <div class="title">Option 1</div>
            </el-menu-item>
            <el-menu-item index="2" class="menu-item">
              <div class="img-container">
                <img src="/src/assets/1.jpg" alt="Option 2" class="img" />
              </div>
              <div class="title">Option 2</div>
            </el-menu-item>
            <el-menu-item index="3" class="menu-item">
              <div class="img-container">
                <img src="/src/assets/1.jpg" alt="Option 3" class="img" />
              </div>
              <div class="title">Option 3</div>
            </el-menu-item>
            <el-menu-item index="4" class="menu-item" @click="router.push('/home')">
              <div class="img-container">
                <img src="/src/assets/1.jpg" alt="Option 3" class="img" />
              </div>
              <div class="title">Option 4</div>
            </el-menu-item>
            <el-menu-item index="4" class="menu-item" @click="router.push('/wave')">
              <div class="img-container">
                <img src="/src/assets/1.jpg" alt="Option 3" class="img" />
              </div>
              <div class="title">Option 5</div>
            </el-menu-item>
            <el-menu-item index="4" class="menu-item" @click="router.push('/galaxy')">
              <div class="img-container">
                <img src="/src/assets/1.jpg" alt="Option 3" class="img" />
              </div>
              <div class="title">星空</div>
            </el-menu-item>
            <el-menu-item index="4" class="menu-item" @click="router.push('/galaxymove')">
              <div class="img-container">
                <img src="/src/assets/1.jpg" alt="Option 3" class="img" />
              </div>
              <div class="title">星空</div>
            </el-menu-item>
            <el-menu-item index="4" class="menu-item" @click="router.push('/smoke')">
              <div class="img-container">
                <img src="/src/assets/1.jpg" alt="Option 3" class="img" />
              </div>
              <div class="title">烟雾</div>
            </el-menu-item>
            <el-menu-item index="4" class="menu-item" @click="router.push('/soldier')">
              <div class="img-container">
                <img src="/src/assets/1.jpg" alt="Option 3" class="img" />
              </div>
              <div class="title">士兵</div>
            </el-menu-item>
            
          </el-menu>
        </el-aside>
        <el-main class="main-content">
          <router-view />
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<style scoped>
.header {
  background-color: skyblue;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 3.2em; /* 设置为最大号字体 */
}

.menu-item {
  width: 100%;
  height: 150px; /* 根据需要调整高度 */
  display: flex;
  flex-direction: column;
  align-items: center;
}

.img-container {
  width: 100%;
  height: 100px; /* 根据需要调整高度 */
  display: flex;
  justify-content: center;
  align-items: center;
}

.img {
  max-width: 100%;
  max-height: 100%;
}

.el-main {
  padding: 0px;
  height: 100vh; /* 设置高度为 100vh - 100px */
  overflow: hidden; /* 禁止元素溢出 */
}

.main-content {
  width: 100%;
  height: 100%;
}
</style>
