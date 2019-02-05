<template>
  <div id="background-wrap">
    <div class="bubble x1"></div>
    <div class="bubble x2"></div>
    <div class="bubble x3"></div>
    <div class="bubble x4"></div>
    <div class="bubble x5"></div>
    <div class="bubble x6"></div>
    <div class="bubble x7"></div>
    <div class="bubble x8"></div>
    <div class="bubble x9"></div>
    <div class="bubble x10"></div>
  </div>
</template>

<script>
export default {
  created() {
    // TODO: play sound, change icon
  },
};
</script>

<style scoped>
body {
  background: #00b4ff;
  color: #333;
  font: 100% Lato, Arial, Sans Serif;
  height: 100vh;
  margin: 0;
  padding: 0;
  overflow-x: hidden;
}

#background-wrap {
  top: 0;
  left: 0;
  position: absolute;
  width: 100%;
  height: 100%;
  z-index: -10;
  transform: translateZ(0);
  overflow: hidden;
}

/* KEYFRAMES */

@keyframes animateBubble {
    0% {
        margin-top: 100%;
    }
    100% {
        margin-top: -100%;
    }
}

@keyframes sideWays {
    0% {
        margin-left:0px;
    }
    100% {
        margin-left:50px;
    }
}

/* ANIMATIONS */

.x1 {
  animation: animateBubble 25s linear infinite, sideWays 2s ease-in-out infinite alternate;
  left: -5%;
  top: 5%;
  transform: scale(0.6);
}

.x2 {
  animation: animateBubble 20s linear infinite, sideWays 4s ease-in-out infinite alternate;
  left: 5%;
  top: 80%;
  transform: scale(0.4);
}

.x3 {
  animation: animateBubble 28s linear infinite, sideWays 2s ease-in-out infinite alternate;
  left: 10%;
  top: 40%;
  transform: scale(0.7);
}

.x4 {
  animation: animateBubble 22s linear infinite, sideWays 3s ease-in-out infinite alternate;
  left: 20%;
  top: 0;
  transform: scale(0.3);
}

.x5 {
  animation: animateBubble 29s linear infinite, sideWays 4s ease-in-out infinite alternate;
  left: 30%;
  top: 50%;
  transform: scale(0.5);
}

.x6 {
  animation: animateBubble 21s linear infinite, sideWays 2s ease-in-out infinite alternate;
  left: 50%;
  top: 0;
  transform: scale(0.8);
}

.x7 {
  animation: animateBubble 20s linear infinite, sideWays 2s ease-in-out infinite alternate;
  left: 65%;
  top: 70%;
  transform: scale(0.4);
}

.x8 {
  animation: animateBubble 22s linear infinite, sideWays 3s ease-in-out infinite alternate;
  left: 80%;
  top: 10%;
  transform: scale(0.3);
}

.x9 {
  animation: animateBubble 29s linear infinite, sideWays 4s ease-in-out infinite alternate;
  left: 90%;
  top: 50%;
  transform: scale(0.6);
}

.x10 {
  animation: animateBubble 26s linear infinite, sideWays 2s ease-in-out infinite alternate;
  left: 80%;
  top: 80%;
  transform: scale(0.3);
}

/* OBJECTS */

.bubble {
  border-radius: 50%;
  box-shadow: 0 20px 30px rgba(0, 0, 0, 0.2), inset 0px 10px 30px 5px rgba(180, 200, 255, 1);

  height: 200px;
  position: absolute;
  display: block;
  bottom: 0;
  width: 200px;
}

.bubble:after {
  background: radial-gradient(ellipse at center,  rgba(235,235,255,0.5) 0%,rgba(235,235,255,0) 70%);
  border-radius: 50%;
  box-shadow: inset 0 20px 30px rgba(225, 225, 255, 0.3);

  content: "";
  height: 180px;
  left: 10px;
  position: absolute;
  width: 180px;
}
</style>
