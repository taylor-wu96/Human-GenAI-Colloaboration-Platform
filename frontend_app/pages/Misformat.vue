<template>
  <div class="misformat-page">
    <el-row class="brand-area">
      <img src="../static/logo.png" alt="PopAi" style="width: 40px; height: 40px; margin-right: 10px;" /> 
      <div class="brand-class">
        GoThere | Your Travel Ideas Workspace
      </div> 
    </el-row>
    <el-card class="misformat-card">
      <img src="../static/missing.png" alt="Finish" class="misformat-img" /> 
      <div  class="misformat-text"> This URL is not valid.<br/> Please check the link on the pre-survey again!!</div> 
      <el-button size="large" color="#626aef" round class="misformat-link" onclick="">Contact us</el-button>
    </el-card>
  </div>
</template>

<script>
export default {

}
</script>

<style scoped>
.brand-area{
  padding: 0 10px;
  display: flex;
  flex-direction: row;
  justify-content: flex-start;
  align-items: center;
  
}
.brand-class{
  font-weight: bold;
  font-size: 1.1rem;
  word-wrap: break-word;
  display: inline-block;
}
.misformat-page {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  height: 100vh;
  gap: 20px;
}

.misformat-card {
  max-width: 800px;
  width: 80%;
  padding: 40px 60px;
  display: flex !important;
  gap: 20px;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}
.misformat-img{
  width: 100%;
  height: auto;
  display: block;
  /* margin: auto; */
  margin-bottom: 20px;
}
.misformat-text{
  font-size: 20px;
  font-weight: bold;
  text-align: center;
  margin-bottom: 20px;
}
.misformat-link{
  font-size: 16px;
  text-align: center;
  display: block;
  margin: 0 auto;
}

</style>
