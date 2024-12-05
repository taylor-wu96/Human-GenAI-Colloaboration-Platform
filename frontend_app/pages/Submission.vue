<template>
  <div class="submission-page">
    <el-row class="brand-area">
      <img src="../static/logo.png" alt="PopAi" style="width: 40px; height: 40px; margin-right: 10px;" /> 
      <div class="brand-class">
        GoThere | Your Travel Ideas Workspace
      </div> 
    </el-row>
    <el-card class="submission-card">
      <img src="../static/finish.png" alt="Finish" class="submit-img" /> 
      <div  class="submit-text"> Your answer is recorded.</div>
      <el-button 
      size="large" 
      color="#626aef" 
      tag="a"
      :href="surveyUrl"
      target="_blank" 
      round 
      class="submit-link"> Complete the short post-survey to finish!</el-button>
    </el-card>
  </div>
</template>

<script>
import { computed ,onMounted } from 'vue'
import { useStore } from 'vuex'
import { useRouter } from 'vue-router'
import Constants from "../constant/Constants.vue";


export default {
  setup() {
    const store = useStore()
    const sharedVariable = computed(() => store.getters.getSharedVariable)
    const router = useRouter()
    const surveyUrl = computed(() => {
      const userId = sharedVariable.value.user_id;
      return userId ? Constants.POST_SURVEY_URL+'?'+Constants.URL_USER_PARAMS+'='+userId : 'https://test.com/';
    });
    

    onMounted(() => {
      console.log(sharedVariable.value)
       if (!sharedVariable.value.user_id || sharedVariable.value.user_id === "anonymous"
       ) {
         router.push('/missing')

       }

    })

    
    return { sharedVariable,surveyUrl }
  }


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
.submission-page {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  height: 100vh;
  gap: 20px;
}

.submission-card {
  max-width: 800px;
  width: 80%;
  padding: 40px 60px;
  display: flex !important;
  gap: 20px;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}
.submit-img{
  width: 100%;
  height: auto;
  display: block;
  /* margin: auto; */
  margin-bottom: 20px;
}
.submit-text{
  font-size: 20px;
  font-weight: bold;
  text-align: center;
  margin-bottom: 20px;
}
.submit-link{
  font-size: 16px;
  text-align: center;
  display: block;
  margin: 0 auto;
}

</style>
