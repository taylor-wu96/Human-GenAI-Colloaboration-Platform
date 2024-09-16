<template>
  <div id="app">
    <el-container style="height: 100vh;">
      <el-container class="dashboard" style="height:100%">
        <el-main>
          <el-row :gutter="20" class="brand-area">
            <img src="../static/logo.png" alt="PopAi" style="width: 40px; height: 40px; margin-right: 10px;" /> 
            <div class="brand-class">
              Co-here | Your Travel Ideas Workspace
            </div> 
            <el-button style="margin-left:8px;" round ref="infoRef" size="small" type="info" icon="InfoFilled" @click="open = true">
              Help
            </el-button>   
             </el-row>
          <el-row  :gutter="20">
            <el-col :xs="24" :sm="24" :md="14" :lg="13" :xl="13" class="task-area cloudy-glass">
              <el-card ref="scenarioRef" class="scenario">
                <div class="scenario-scroll">
                  <div class="scenario-title">
                    Your Task
                  </div>
                  <div  v-html="scenarioText">
                  </div>
                </div>
              </el-card>
              <el-card ref="noteRef" class="note">
                <el-scrollbar always height="100%" >
                  <div class="scenario-title">
                  Your Answer
                  <el-text size="small" tag="i"> Enter the your ideas for Part 1 and Part 2 below </el-text>
                </div>
                <el-input
                  ref="textareaRef"
                  name="NoteArea"
                  v-model="textArea"
                  type="textarea"
                  placeholder="Please AVOID leaving this window for the duration of this task – using external tools might reduce your final reward."
                  :autosize="{ minRows: textAreaRowRef , maxRows: textAreaRowRef}"
                  @input="handleInput($event, textArea)"

                  @keydown.ctrl.a="handleHighlight"
                  @keydown.meta.a="handleHighlight"
                 
                  @copy="handleCopy"
                  @cut="handleCopy"
                  @paste="handlePaste"
                  @mouseup="handleMouseUp"
                  @focusin="startFocusTime"
                  @focusout="endFocusTime"
                />
                <div class="note_panel">
                  <div class="text-area_info">
                    <div><el-icon size="small"><Finished /></el-icon> Word count: {{ textAreaWordCount }} ( {{minWords}}-{{maxWords}} max ) </div>
                    <div> <el-icon size="small"><Timer /></el-icon>Try to finish in:&nbsp; <span v-html="timeSeconds"></span> </div>
                    <div class="notice">
                      <el-text size="small">* Please <b>AVOID</b> leaving this window for the duration of this task – using external tools might reduce your final reward.</el-text>
                    </div>
                  </div>
                  <el-form ref="submitTaskRef"  label-width="auto" class="submit_block">
                    <el-form-item label="I have finished">
                      <!-- active-icon="Check" inactive-icon="Close" -->
                        <el-switch v-model="hasFinishTask" :before-change="checkTaskFinish"  />
                      </el-form-item>
                      <el-form-item>
                        <el-button  type="info" :disabled="!hasFinishTask" round @click="onSubmitTask">Submit</el-button>
                      </el-form-item>
                  </el-form>

                  
                </div>

                <!-- <p>{{highlightedText}}</p> -->

                </el-scrollbar>
                

            </el-card>
            </el-col>
            <el-col v-if="!mobileDrawer" ref="chatBotRef"  :xs="24" :sm="24" :md="10" :lg="11" :xl="11" class="chat-area cloudy-glass invisible">
              <!-- Chat messages will go here -->
              <div style="padding:5px 4px">
                  <el-popover
                    placement="top-start"
                    title="AI Assistant"
                    :width="400"
                    trigger="hover"
                    content="AI Assistant is a chatbot powered by GPT-4o. It can help you with various tasks. especially for text-related tasks."
                  >
                    <template #reference>
                       <el-text  size="large" tag="b" class="chat-title"> AI Assistant
                  <el-tag size="small" type='info' effect="dark"
                  round>Powered by ChatGPT</el-tag>   </el-text>  
                    </template>
                  </el-popover>
              </div>
              <el-scrollbar max-height="100%" height="100%" ref="scrollContainer">
                <div v-for="message in messages" :key="message.id" class="message">
                  <el-card>
                    <div class="dialogue"  v-if="message.sender === 'user'" :id="'user_question_block_' + message.id" @mouseup="handleMouseUp" @copy="handleCopy">
                      <el-avatar :size="28" class="avatar user-bg" icon="UserFilled" />
                      <div>
                         <div class="user-title "  :id="'user_question_tag_' + message.id">
                          You
                        </div>
                        <div :id="'user_question_' + message.id" v-html="message.text"></div>
                      </div>

                    </div>
                    <div  class="dialogue" v-else :id="'ai_feedback_block_' + message.id"   @mouseup="handleMouseUp" @copy="handleCopy">
                      <el-avatar :size="28" class="avatar bot-bg"   icon="ChatLineRound" />
                      <div>
                        <div class="user-title"  :id="'ai_feedback_tag_' + message.id" >
                          Chatbot
                        </div>
                        <div  :id="'ai_feedback_' + message.id" style="word-wrap: break-word; white-space: pre-wrap; line-height:1.1" v-html="message.text"></div>
                        <!-- <el-tooltip :id="'icon_' + message.id" placement="bottom">
                          <template  #content> Copy </template>
                          <el-button :id="'button_' + message.id" size="small" type="info" plain  @click="handleCopiedButton" round >
                          <el-icon :id="'button_' + message.id" ><CopyDocument :id="'button_' + message.id" /> </el-icon>
                        </el-button>
                        </el-tooltip> -->
                        <!-- <span v-if="isLastChatbotMessage(message)">
                          <el-button :disabled="MIN_TEMP>=currentTemp" @click="resentMessage(false)" size="small" type="info" plain round>
                           Give me more various idea!
                          </el-button>
                          <el-button :disabled="MAX_TEMP<=currentTemp" @click="resentMessage(true)" size="small" type="info" plain round>
                            Give me more cautious idea!
                          </el-button>

                        </span>                      -->
                      </div>
                    </div>
                  </el-card>
                </div>
              </el-scrollbar>
              <el-card ref="chatInputRef" class="bar">
                <el-input
                  type="textarea"
                  :autosize="{ minRows: 1 , maxRows: 6}"
                  id="PromptArea"
                  class="prompt_input"
                  name="PromptArea"
                  v-model="userInput"
                  placeholder="Type your message here..."
                  resize="none"
                  @input="handlePromptInput($event, userInput)"
                  @keydown.ctrl.a="handleHighlight"
                  @keydown.meta.a="handleHighlight"
                  @copy="handleCopy"
                  @cut="handleCopy"
                  @paste="handlePaste"
                  @mouseup="handleMouseUp"
                  @focusin="startFocusTime"
                  @focusout="endFocusTime"

                >
                </el-input>
                <el-button class="submit-chatbot" :disabled="messageSending" :loading="messageSending" @click="sendMessage">      
                      <Promotion v-show="!messageSending"  style="width:24px; vertical-align:middle;  padding:0;" />
                </el-button>
              </el-card>
            </el-col>
          </el-row>
        </el-main>
        <!-- Drawer Code For  Mobile -->
        <el-button v-if="mobileDrawer" ref="chatBotRef" class="mobile-drawer"  style="margin-left: 16px" @click="drawer = true">
            <img src="../static/logo.png" alt="PopAi" style="width: 36px; height: 36px;" /> 
        </el-button>

        <!-- @closed="scrollToBottom()"  -->
        <el-drawer class="inner-drawer" @open="scrollToBottom();" v-model="drawer" size="80%" title="AI Assistant" >
           <div class="m-chat-area">
              <el-scrollbar class="scroll-bar" ref="scrollContainer">
                <div v-for="message in messages" :key="message.id" class="message">
                  <el-card>
                    <div class="dialogue"  v-if="message.sender === 'user'" :id="'user_question_block_' + message.id" @mouseup="handleMouseUp" @copy="handleCopy">
                      <el-avatar :size="28" class="avatar user-bg" icon="UserFilled" />
                      <div>
                         <div class="user-title"  :id="'user_question_tag_' + message.id">
                          You
                        </div>
                        <!-- <el-tag size="small" :id="'user_question_tag_' + message.id">You</el-tag> -->
                        <!-- style="white-space: pre-line"  -->
                        <div :id="'user_question_' + message.id" v-html="message.text"></div>
                      </div>

                    </div>
                    <div  class="dialogue" v-else :id="'ai_feedback_block_' + message.id"   @mouseup="handleMouseUp" @copy="handleCopy">
                      <el-avatar :size="28" class="avatar bot-bg"   icon="ChatLineRound" />
                      <div>
                        <div class="user-title"  :id="'ai_feedback_tag_' + message.id" >
                          Chatbot
                        </div>
                        <!-- <el-tag  :id="'ai_feedback_tag_' + message.id" size="small" type="success">Chatbot</el-tag> -->
                        <!-- style="white-space: pre-line"  -->
                        <div  :id="'ai_feedback_' + message.id" style="word-wrap: break-word; white-space: pre-wrap; line-height:1.1" v-html="message.text"></div>
                        <!-- <el-tooltip :id="'icon_' + message.id" placement="bottom">
                          <template  #content> Copy </template>
                          <el-button :id="'button_' + message.id" size="small" type="info" plain  @click="handleCopiedButton" round >
                          <el-icon :id="'button_' + message.id" ><CopyDocument :id="'button_' + message.id" /> </el-icon>
                        </el-button>
                        </el-tooltip> -->
                        <!-- <span v-if="isLastChatbotMessage(message)">
                          <el-button :disabled="MIN_TEMP>=currentTemp" @click="resentMessage(false)" size="small" type="info" plain round>
                           Give me more various idea!
                          </el-button>
                          <el-button :disabled="MAX_TEMP<=currentTemp" @click="resentMessage(true)" size="small" type="info" plain round>
                            Give me more cautious idea!
                          </el-button>

                        </span>                      -->
                      </div>
                    </div>
                  </el-card>
                </div>
              </el-scrollbar>
              <el-card ref="chatInputRef" class="bar">
                <el-input
                  type="textarea"
                  :autosize="{ minRows: 1 , maxRows: 6}"
                  id="prompt_input"
                  class="PromptArea"
                  name="PromptArea"
                  v-model="userInput"
                  placeholder="Type your message here..."
                  @input="handlePromptInput($event, userInput)"
                  @keydown.ctrl.a="handleHighlight"
                  @keydown.meta.a="handleHighlight"
                  @copy="handleCopy"
                  @cut="handleCopy"
                  @paste="handlePaste"
                  @mouseup="handleMouseUp"
                  @focusin="startFocusTime"
                  @focusout="endFocusTime"
                >
                </el-input>
                <el-button class="submit-chatbot" :disabled="messageSending" :loading="messageSending" @click="sendMessage">      
                      <Promotion v-show="!messageSending"  style="width:24px; vertical-align:middle;  padding:0;" />
                </el-button>
              </el-card>
            </div>
        </el-drawer>

        <!-- Tour Code -->
        <el-tour :close-on-press-escape="attendTour" :show-close="attendTour" @finish="tourFinished" :mask="{ color: 'rgba(0, 0, 0, 0.82)' }" v-model="open" type="default" class="web-tour" :content-style="{ borderRadius:'12px' ,boxShadowing:'rgba(0, 0, 0, 0.16) 0px 3px 6px, rgba(0, 0, 0, 0.23) 0px 3px 6px'}" >
          <el-tour-step  :next-button-props="{children:'Next, see the introduction ...' }" title="Co-here Intro Video" :content-style="{ maxWidth: '800px' ,minHeight:'520px', width:'80%', padding:'20px 40px',borderRadius:'12px' ,boxShadowing:'rgba(0, 0, 0, 0.16) 0px 3px 6px, rgba(0, 0, 0, 0.23) 0px 3px 6px'}">
            <div class="video">
              <iframe width="560" height="500" src="https://www.youtube-nocookie.com/embed/2B4wmbdMrc4?si=6vW6uB7JPcdf9OX7&autoplay=1" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
            </div>
          </el-tour-step>


          <el-tour-step title="Introduction" :next-button-props=" {children:'Next, see where to do the task...'}" :content-style="{ maxWidth: '800px', width:'80%', padding:'40px',borderRadius:'12px' ,boxShadowing:'rgba(0, 0, 0, 0.16) 0px 3px 6px, rgba(0, 0, 0, 0.23) 0px 3px 6px'}">
            <h2>About the Task: </h2>
            <br/>
            <div style="font-size: 1.125rem;line-height: 150%;font-weight: 400; ">We are developing a website to gather people's ideas for travel - we will give you a short task to complete. We hope to leverage your ideas to help us come up with better plans within a limited time. <br/> To reward the best participants, we will select the top submissions based on completeness, originality, and clarity.These top participants <span style="color: #eb7b5b;font-weight:bold;">will receive additional rewards </span>, which will be distributed through Prolific and communicated via private messages.</div>
            <br/>
            <div style="font-size: 1.125rem;line-height: 150%;font-weight: 400;">
              <ul style="padding: 10px;">
                <li>
                  During the task, you may use your existing knowledge and the AI assistant we provide. 
                </li>
                <li>
                  Avoid searching for information on other websites.The accuracy of the facts is not our primary concern. 
                </li>
                <li>
                  <span style="color: #eb7b5b;font-weight:bold;">Instead, we are interested to hear your own authentic ideas.</span> .
                </li>
              </ul>
            </div>
            <br/>
            <div style="font-size: 1.125rem;line-height: 150%;font-weight: 400;">
              Below, we will provide <span style="color: #eb7b5b;font-weight:bold;"> a step-by-step introduction </span> to the website's interface to help you quickly navigate the system.
            </div>
          </el-tour-step>
         
          <el-tour-step
            :target="scenarioRef?.$el"
            title="Scenario"
            :next-button-props=" {children:'Next, see where where to enter your answer...'}"
            
          >
          <div style="font-size: 0.9rem;line-height: 150%;font-weight: 400; padding: 0px 10px;">
              <ul >
                <li>
                  Here, you will see the details of the scenario for the task.
                </li>
                <li>
                  Fulfill the requirements to finish the task.
                </li>
                <li>
                  Scroll down to see the full details.
                </li>
              </ul>
            </div>
            
          </el-tour-step>
          <el-tour-step
            :target="noteRef?.$el"
            title="Your Answer"
            :next-button-props=" {children:'Next, see the AI assistant that you can use...'}"
            
          >
            <div style="font-size: 0.9rem;line-height: 150%;font-weight: 400; padding: 0px 10px;">
              <ul >
                <li>
                  Keep all of your notes and answer here before submission.
                </li>
                <li>
                  See the word counts and elapsed time below the response area.
                </li>
                <li>
                  expect to complete your answer around 10 minutes. If you go over this time, system will notify you.
                </li>
              </ul>
            </div>
          </el-tour-step> 

               <!-- placement="left-start" -->
          <el-tour-step
            :placement="!mobileDrawer?'left':'top-start'"
            :target="chatBotRef?.$el"
            title="AI Assistant"
            :next-button-props=" {children:'Next, see where you can ask questions...'}"
          >
            <div style="font-size: 0.9rem;line-height: 150%;font-weight: 400; padding: 0px 10px;">
              AI Assistant is a chatbot service designed for travel-related tasks.  <br/>
              With the most powerful AI model, it helps you generate and refine ideas   <br/>
              Please scroll down to see the latest message.
            </div>
          </el-tour-step>

          <el-tour-step
            :target="chatInputRef?.$el"
            title="Question to AI"
            description="Type the question you want to ask the AI assistant here, and then click the send button to await a response."
            :next-button-props=" {children:'Next, see how to submit your answer...'}"
          />
          <el-tour-step
            :target="submitTaskRef?.$el"
            title="Submit Task"
            
          >
            <div style="font-size: 0.9rem;line-height: 150%;font-weight: 400; padding: 0px 10px;">
              <ol>
                <li>Open the toggle below to confirm that you have finished your final answer.</li>
                <li>Then click the button to submit the task.</li>
              </ol>
            </div>
          
          </el-tour-step>

          <el-tour-step
            :target="infoRef?.$el"
            title="Want to see the tour again?"
            description="Just click this button to see the tour again."
            :next-button-props=" {children:`Let's Start!`}"
          />
          <template #indicators="{ current, total }">
            <el-text> Step : {{ current + 1 }} / {{ total }}</el-text>
          </template>
        </el-tour>

      </el-container>
    </el-container>
  </div>
</template>

<script>
import Constants from "../constant/Constants.vue";
import axios from "axios";
import {marked} from "marked";
import { ref, watch, nextTick } from 'vue';
import { onMounted, onUnmounted ,h } from 'vue';
import { useRoute , useRouter } from 'vue-router';
import { watchEffect } from 'vue';
import { ElMessage,ElNotification  } from 'element-plus'
import { useStore } from 'vuex'



export default {
  setup() {

    const drawer = ref(false)
    const hasFinishTask = ref(false);
    const ipAddress = ref('');
    const messages = ref([]);
    const textAreaWordCount = ref(0);
    const scenarioText = ref('');
    const minWords = Constants.ACCEPTABLE_MIN_WORDS;
    const maxWords = Constants.ACCEPTABLE_MAX_WORDS;
    const userInput = ref('');
    const textArea = ref('');
    const textareaRef = ref(null); // Add this line to define a ref for the textarea
    const highlightedText=ref('');
    const route = useRoute();
    const router = useRouter();
    const user_id = ref('anonymous');
    let promptStartTime=0
    let promptEndTime=0
    const wordEditingCount=ref(0)
    
    const wordDeletingCount=ref(0)
    const characterRevisionCount=ref(0)
    let previousCharacterCount=0
    let timeId

    // Timer
    const TIME_GAP =Constants.TIME_GAP;
    const MISSION_TIME = Constants.MISSION_TIME;
    const MISSION_EXPIRE_TIME = Constants.MISSION_EXPIRE_TIME;
    const timeSeconds = ref("10m:00s");
    

    const missionTimeStamp = ref(new Date().getTime());


    // streaming variables
    const messageSending = ref(false);

    // shared store variables

    const store = useStore()
    const updateSharedVariable = (obj) => {
      store.commit('updateSharedVariable', obj)
    }


    const currentTemp=ref(Constants.DEFAULTS_TEMP)
    const MAX_TEMP=Constants.MAX_TEMP
    const MIN_TEMP=Constants.MIN_TEMP
    // try to fix the mounted issue
    let focus_leave=new Date().getTime();

    //  test for tour
    const chatInputRef = ref(null)
    const scenarioRef = ref(null)
    const noteRef = ref(null)
    const chatBotRef = ref(null)
    const submitTaskRef = ref(null)
    const infoRef = ref(null)
    const scrollContainer = ref(null);

    const mobileDrawer = ref(window.innerWidth<992?true:false)
    const open = ref(true)
    const attendTour=ref(false)
    let localData ={}

    // input row
    const textAreaRowRef = ref(8);

    // watchEffect(async () => {
    //   // ...
    //   console.log('Change Url:');
    //   user_id.value = route.query[Constants.URL_USER_PARAMS] || 'anonymous';
    //   if(user_id.value === 'anonymous'){
    //     router.push({ path: '/missing' })
    //   }
    //   updateSharedVariable({'user_id': user_id.value});
    //   localData['user_id'] = user_id.value
    //   if (!localStorage.getItem(user_id.value)) {
    //     localStorage.setItem(user_id.value, JSON.stringify(localData));
    //   } else {
    //     const data = await localStorage.getItem(user_id.value);
    //     localData = JSON.parse(data);
    //     textArea.value = localData['storage_notes']||'';
    //     wordEditingCount = localData['word_editing_count']||0;
    //     wordDeletingCount = localData['word_deleted_count']||0;
    //     characterRevisionCount = localData['character_revision_count']||0;
    //     if(textArea.value){
    //       previousCharacterCount = textArea.value.length;
    //       textAreaWordCount.value = textArea.value.trim().split(/\s+|\n+/).length;
    //     }
    //     if(localData['tour']===false){
    //       open.value = localData['tour'];
    //       timeId = setInterval(setTimer, TIME_GAP*1000);
    //     }
    //   }
    // });

    const readStorage=async()=> {
      user_id.value = route.query[Constants.URL_USER_PARAMS] || 'anonymous';
      if(user_id.value === 'anonymous'){
        router.push({ path: '/missing' })
      }
      updateSharedVariable({'user_id': user_id.value});
      localData['user_id'] = user_id.value
      if (!localStorage.getItem(user_id.value)) {
        localStorage.setItem(user_id.value, JSON.stringify(localData));
      } else {
        const data = await localStorage.getItem(user_id.value);
        localData = JSON.parse(data);
        textArea.value = localData['storage_notes']||'';
        wordEditingCount.value = localData['wordEditingCount']||0;
        wordDeletingCount.value = localData['wordDeletingCount']||0;
        characterRevisionCount.value = localData['characterRevisionCount']||0;
        if(textArea.value){
          previousCharacterCount = textArea.value.length;
          textAreaWordCount.value = textArea.value.trim().split(/\s+|\n+/).length;
        }
        missionTimeStamp.value=localData['missionTimeStamp']||new Date().getTime();
        if(localData['tour']===false){
          open.value = localData['tour'];
          attendTour.value = !localData['tour'];
          timeId = setInterval(setTimer, TIME_GAP*1000);
        }
      }
    };

    watch(messages, () => {
      // Wait for the next DOM update to scroll
      nextTick(() => {
        scrollToBottom();
      });
    }, { deep: true });


    // console.log('Query Parameters:', route.query);
    onMounted(async() => {
      focus_leave=new Date().getTime();
      document.addEventListener('keydown', handleHighlight);
      await readStorage();
      await checkFinishTask(); 
      await initialMessages();
      await getTask();
      await getIPFromAmazon();
      await updateIp();
      sendBehavior({
            id: Date.now(),
            content: 'User is open the page on' + Date.now().toString(),
            type: 'Initial',
            target_object: 'Page',
            log_time: new Date().toISOString(),
       }); 
      document.addEventListener('visibilitychange',handleVisibilityChange);  
    })

    // Don't forget to clean up the event listener on component unmount
    onUnmounted(() => {
      document.removeEventListener('visibilitychange',handleVisibilityChange);
      document.removeEventListener('keydown', handleHighlight);
      // remove the interval in timer
      clearInterval(timeId);
    });


    // Tour 
    const tourFinished = () => {
      console.log('Tour Finished');
      if(localData['tour']===undefined || localData['tour']===true){
          missionTimeStamp.value=new Date().getTime()
          localData['missionTimeStamp']=missionTimeStamp.value;
          timeId = setInterval(setTimer, TIME_GAP*1000); 
        }
      localData['tour']=false;
      attendTour.value=true;
      localStorage.setItem(user_id.value, JSON.stringify(localData));
    };

    // Timer
    function setTimer() {
    
      // if(missionTimeStamp.value===0){
      //   missionTimeStamp.value=new Date().getTime()
      // };
      let currentTime = new Date().getTime();
      // console.log('Current Time:',missionTimeStamp,"  : ", currentTime);

      let missionTimeLeft=MISSION_TIME-Math.floor((currentTime-missionTimeStamp.value)/1000);
      if( missionTimeLeft <= 0 && missionTimeLeft >= -TIME_GAP){
        ElNotification({
          title: 'Reminder',
          message: `You have spent ${Math.floor(MISSION_TIME/60)} minutes on the task.`,
          type: 'info',
        })
        timeSeconds.value = `<span style="color: rgb(190, 79, 79);"> Please submit as soon as possible!</span>`;
      }
      else if(missionTimeLeft >0){
        timeSeconds.value = " " + pad(Math.floor(missionTimeLeft / 60)) +"m:"+ pad(missionTimeLeft % 60)+"s";
      }
    }

    function pad(val) {
      let valString = val + "";
      if (valString.length < 2) {
        return "0" + valString;
      } else {
        return valString;
      }
    }


    // Chat to bottom
    async function scrollToBottom() {
      try{
        if (scrollContainer.value) {
          scrollContainer.value.setScrollTop(1e16);
        }
      }catch(error){
        console.error('Failed to scroll to bottom:', error);
      }
      // scrollContainer.value.setScrollTop(1e16);
    }

    // Error Prevention
    // TODO: check the error handling
    const checkTaskFinish= () => {
      if(!hasFinishTask.value){
        if(textAreaWordCount.value>=minWords && textAreaWordCount.value<=maxWords){
          return new Promise((resolve) => {
            setTimeout(() => {
              ElNotification({
                title: 'Notice',
                message: 'You can submit the task now.',
                type: 'success',
              })
              return resolve(true)
            }, 100)
          })
        }else{
            return new Promise((_, reject) => {
              setTimeout(() => {
                ElNotification({
                    title: 'Warning',
                    message: `Task not finished. Please write between ${minWords} and ${maxWords}  words.`,
                    type: 'warning',
                })
                return reject(new Error('Error'))
              }, 100)
            })
        }
      }else{
        return true;
      }

    }
    

    // API related
    const initialMessages = async ()=>{

      try {
        let api_url = "/messages";
        if(user_id.value !== 'anonymous'){
          api_url = `/messages?user_id=${user_id.value}`;
        } 
        const { data } = await axios.get(api_url);
        messages.value = data.map( (chat)=>{
          return {
            id: chat.created_at,
            text: marked(chat.response),
            sender: chat.role,
          }
        
        }); // Assuming the data is an array of messages
        nextTick(() => {
          scrollToBottom();
        });
      } catch (error) {
        console.error("Failed to fetch initial messages:", error);
        sendError({error_message:"Failed to fetch initial messages:"+ error});
      }
    
    }

    const sendMessage = async() => {
      if (userInput.value.trim()) {
        // messages.value.push({ id: Date.now(), text: userInput.value, sender: 'user' });
        // Here you'd typically send the message to your backend for processing
        createMessage(marked(userInput.value),'user');

        // API for none streaming version
        // getResponse(userInput.value);
        // API for streaming version
        await streamingResponse();

        userInput.value = ''; // Clear input after sending
        // console.log('User Prompt Time:', (promptEndTime-promptStartTime)/1000);
        promptStartTime=0;
        promptEndTime=0;
      }
      else{
        ElNotification({
          title: 'Notice',
          message: "The message can't be empty!",
          type: 'warning',
        })
      }
    };


  const sendBehavior = async (behavior) => {
    if (behavior) {
      let api_url = "/behavior";
      if (user_id.value !== 'anonymous') {
        api_url = `/behavior?user_id=${user_id.value}`;
      }
      try {
        const { data } = await axios.post(api_url, behavior);
        // console.log('Response Behavior', data);
      } catch (error) {
        console.error('Failed to send behavior:', error);
        sendError({error_message:"Failed to send behavior:"+ error});
        
        // Handle specific error scenarios here if needed
      }
    }
  }
  const sendError = async (error) => {
    if (error) {
      let api_url = "/error-log";
      if (user_id.value !== 'anonymous') {
        api_url = `/error-log?user_id=${user_id.value}`;
      }
      try {
        const { data } = await axios.post(api_url, error);
        // console.log('Response Behavior', data);
      } catch (err) {
        console.error('Failed to send error:', err);
        // Handle specific error scenarios here if needed
      }
    }
  }

  const checkFinishTask = async () => {
    try {
      let api_url = "/task";
      if(user_id.value !== 'anonymous'){
        api_url = `/task?user_id=${user_id.value}`;
      }
      const { data } = await axios.get(api_url);
      if(data.final_submission){
        router.push({ path: '/submitted' })
      }
    }
    catch (error) {
      sendError({error_message:"Failed to fetch task:"+ error});
      console.error('Failed to fetch task:', error);
    }
  
  }

  const getTask = async () => {
    if(!localData['task']||localData['task'].expire_time < new Date().getTime()){
      //if no task in local storage or task is expired
      try {
        let api_url = "/random-task";
        if(user_id.value !== 'anonymous'){
          api_url = `/random-task?user_id=${user_id.value}`;
        } 
        const { data } = await axios.get(api_url);
        console.log('Task:', data);
        // delete data['final_submission']
        // delete data['chat_id']
        // message_id
        // receipt_handle
        data.expire_time = new Date().getTime() + MISSION_EXPIRE_TIME*1000;
        localData['task']=data;
        localStorage.setItem(user_id.value, JSON.stringify(localData))
      } catch (error) {
        console.error('Failed to fetch task:', error);
        location.reload();
        sendError({error_message:"Failed to fetch task:"+ error});
      }
    }
    if(localData['task'].task_name==='CREATIVE'){
        scenarioText.value = Constants.CREATIVE;
      }
    else{
      scenarioText.value = Constants.PRACTICAL;
    }

  }

  const onSubmitTask = async () => {
    try {
      let api_url = "/submit-task";
      if(user_id.value !== 'anonymous'){
        api_url = `/submit-task?user_id=${user_id.value}`
        ;
      } 
      const missionTime=Math.floor((new Date().getTime()-missionTimeStamp.value)/1000);
      const { data } = await axios.post(api_url,
        {task_description: textArea.value , 
          message_id: localData['task'].message_id,
          receipt_handle: localData['task'].receipt_handle,
          task_name:localData['task'].task_name,
          task_finished_time:missionTime,
          word_editing_count: wordEditingCount.value,
          word_deleted_count: wordDeletingCount.value,
          character_revision_count: characterRevisionCount.value});
      ElNotification({
          title: 'Finish',
          message: "You have Successfully Submit the task!",
          type: 'success',
      })
      updateSharedVariable({submitted: true});
      router.push({ path: '/submitted' })
    } catch (error) {
      console.error('Failed to Submit task:', error);
      sendError({error_message:"Failed to Submit task:"+ error});
    }
  }

  const updateIp = async () => {
    try {
      let api_url = "/update_ip";
      if(user_id.value !== 'anonymous'){
        api_url = `/update_ip?user_id=${user_id.value}`
        ;
      } 
      const { data } = await axios.post(api_url,{ip_address: ipAddress.value});
      // console.log('IP value:',ipAddress.value);
      // console.log('Update IP:', data);
    } catch (error) {
      console.error('Failed to update IP:', error);
      sendError({error_message:"Failed to update IP:"+ error});
    }

  }

  let controller = null; 
  const streamingResponse = async () => {
    messageSending.value = true;
    let insufficient=false;
    let save_message = '';
    let streaming_message = '';
    let api_url = "/openAI-streaming";
    if(user_id.value !== 'anonymous'){
      api_url = `/openAI-streaming?user_id=${user_id.value}`
      ;
    } 
    controller = new AbortController();
    const signal = controller.signal;
    try {
      const receivedMessage ={
        id: Date.now(),
        text: '',
        sender: 'assistant',
      };
      messages.value.push(receivedMessage);
      if(promptEndTime===0){
        promptEndTime=new Date().getTime();
      }
      
      const response = await fetch(api_url,
      {
        method: "POST",
        headers: {
        "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message_content: userInput.value,
          system_temp: currentTemp.value,
          role: "user",
          prompt_time: (promptEndTime-promptStartTime)/1000,
        }),
        signal,
      });
      promptStartTime=0;
      promptEndTime=0;
      userInput.value = '';
      // disabled the sender button
      const reader = response.body.getReader();
      const decoder = new TextDecoder("utf-8",{ stream: true });

      while(true){
        const {done, value} = await reader.read();
        if(done){
          break;
        }
        const chunk = decoder.decode(value);

        const lines = chunk.split("\n");
        if(insufficient){
          lines[0] = save_message + lines[0];
          insufficient=false;
        }
        console.log('Streaming Lines:', lines);
        // const parsedLines = lines.filter((line) => line.trim() !== ''  && !line.includes("[DONE]"))
        //                         .map((line)=>line.replace(/^data: /, "").trim())
        //                         .map((line) => JSON.parse(line));

        const parsedLines = lines
              .filter((line) => line.trim() !== "" && !line.includes("\[DONE\]"))
              .map((line) => line.replace(/^data: /, "").trim())
              .map((line) => {
                try {
                  return JSON.parse(line);
                } catch (error) {
                  console.error("Failed to parse JSON line:", line);
                  // sendError({error_message:"Failed to parse JSON line:"+ line});
                  insufficient=true;
                  save_message = line;

                  console.error(error);
                  return null; // or handle the error in a different way
                }
              })
              .filter((parsedLine) => parsedLine !== null); // Filter out null values caused by parsing errors

        // console.log('Streaming Response:', parsedLines);
        for ( const parsedLine of parsedLines){
          const {choices} = parsedLine;
          const { delta } = choices[0];
          const { content } = delta;
          if(content){
            streaming_message += content;
            messages.value[messages.value.length - 1]["text"] = marked(streaming_message);
          }         
          // console.log('Store to messages:', messages.value[messages.value.length - 1]);
          // console.log('Streaming Response:', streaming_message);
          // createMessage(marked(parsedLine.response), "assistant");
        }

      }

      // console.log('Streaming Response:', data);
    } catch (error) {
      if(signal.aborted){
        console.error('Request Aborted:', error);
      }else{
        console.error('Failed to Streaming:', error);
        sendError({error_message:"Failed to Streaming:"+ error});
      }
    }finally{
      controller = null;
      messageSending.value = false;
      // send API to backend
      await storeMessage(streaming_message,'assistant');
    }
  }

  const storeMessage = async (message,role) => {
    try{
      const postData = {
        message_content: message,
        system_temp: currentTemp.value,
        role: role,
      };
      console.log('Post Data:', postData);
        let api_url = "/message";
        if(user_id.value !== 'anonymous'){
          api_url = `/message?user_id=${user_id.value}`;
        } 
      const { data } = await axios.post(api_url, postData);
      console.log('Store Message:', data);

    }catch(error){
      console.error('Failed to store message:', error);
      sendError({error_message:"Failed to store message:"+ error});
    }
  }

    

    //Create a message
    function createMessage(message,identity) {
      let id = 0;
      if (messages.value[messages.value.length - 1]) {
        id = messages.value[messages.value.length - 1].id + 1;
      }
      messages.value.push({
        id: Date.now(),
        text: message,
        sender: identity || "user",
        temp: currentTemp.value,
      });
    }
    // Get response from the backend

    async function getResponse(message) {
      const postData = {
        message_content: message,
        system_temp: currentTemp.value,
        role: "user",
      };
        let api_url = "/openai";
        if(user_id.value !== 'anonymous'){
          api_url = `/openai?user_id=${user_id.value}`;
        } 
      const { data } = await axios.post(api_url, postData);
      // console.log(data);
      createMessage(marked(data.response), "assistant");
    }


    // Event listeners
    let focusTimeStart = 0;
    let focusTimeEnd = 0;
    const handleInput = (e, value) => {
      let inputValue;
      if (e && e.target) {
        inputValue = e.target.value;
      } else {
        inputValue = value;
      }
      if (inputValue !== undefined) {
        if(previousCharacterCount ===inputValue.length-1 || previousCharacterCount ===inputValue.length+1){
          characterRevisionCount.value+=1;
          localData['characterRevisionCount']=characterRevisionCount.value;
        }
        previousCharacterCount = textArea.value.length;
        textArea.value = inputValue;
        localData['storage_notes']=inputValue
        
        // localStorage.setItem('storage_notes', inputValue);
        // console.log('Input Value:', inputValue, inputValue.split(/\s+|\n+/).length);
        const words = inputValue.trim().split(/\s+|\n+/);
        let previousWordCount = textAreaWordCount.value;
        // If the trimmed inputValue is empty, set word count to 0, else to the length of the words array
        textAreaWordCount.value = inputValue.trim() ? words.length : 0;
        if (previousWordCount !== textAreaWordCount.value) {
          // console.log('Word Add/Remove:', inputValue);
          sendBehavior({
            id: Date.now(),
            content: inputValue,
            type: 'Word Add/Remove',
            target_object: 'NoteArea',
            log_time: new Date().toISOString(),
          })
          if(textAreaWordCount.value<minWords || textAreaWordCount.value>maxWords){
            hasFinishTask.value = false;
          }
        }
        if(previousWordCount === textAreaWordCount.value-1){    
          wordEditingCount.value+=1;
          localData['wordEditingCount']=wordEditingCount.value;
        }else if(previousWordCount > textAreaWordCount.value){
          wordDeletingCount.value+=previousWordCount - textAreaWordCount.value;
          localData['wordDeletingCount']=wordDeletingCount.value;
      }
      localStorage.setItem(user_id.value, JSON.stringify(localData));
    };
  };
    const handlePromptInput = (e, value) => {
      let promptInputValue;
      if (e && e.target) {
        promptInputValue = e.target.value;
      } else {
        promptInputValue = value;
      }
      if(promptInputValue!==undefined){     
        if(promptStartTime===0){
          promptStartTime=new Date().getTime();
        }
        else{
          promptEndTime=new Date().getTime();
        }
      }
    };
    // unused function
    const clearTextArea = () => {
       ElMessageBox.confirm('Are you sure to delete all of the text?')
        .then(() => {
          textArea.value = '';
          textAreaWordCount.value = 0; // Explicitly set word count to 0 here
          localData['storage_notes']=''
          localStorage.setItem(user_id.value, JSON.stringify(localData));

          handleInput(null, ''); 
          sendBehavior({
            id: Date.now(),
            content: 'User Cleared TextBox',
            type: 'Clear',
            target_object: 'NoteArea',
            log_time: new Date().toISOString(),
          })  
          highlightedText.value='User Cleared TextBox:'
          done()
        })
        .catch((err) => {
        })

     
    };
    // unused function
    const handleCopiedButton = async(e) => {
      // console.log(e.target);
      let targetElement = e.target;
      if(!targetElement.id){
        targetElement = e.target.parentElement;
      }
      // console.log(targetElement.id);
      const messageId = targetElement.id.split('_')[1]; // Extract the message ID from the parent element's ID
      const aiResponseElement = document.getElementById(`ai_feedback_${messageId}`);
      // console.log('Response element:', aiResponseElement);
      const copiedText = aiResponseElement.textContent;
      sendBehavior({
        id: Date.now(),
        content: copiedText,
        type: 'Copy',
        target_object: aiResponseElement.name||aiResponseElement.id||aiResponseElement.nodeName,
        log_time: new Date().toISOString(),
      })

      const tempInput = document.createElement('textarea');
      tempInput.value = copiedText;
      document.body.appendChild(tempInput);
      tempInput.select();
      document.execCommand('copy');
      document.body.removeChild(tempInput);

      highlightedText.value='Copied from Button: '+copiedText
    };


    const handleCopy = (e) => {
      // console.log(e.clipboardData.getData('text/plain'));
      // console.log('Copied Text:', window.getSelection().toString());
      // console.log('Copied Text:', e.target.parentElement.id);
      const targetElementName=e.target.closest('.dialogue')||e.target.name||e.target.nodeName;
      console.log('Copy Target:', targetElementName);
      sendBehavior({
        id: Date.now(),
        content: window.getSelection().toString(),
        type: 'Copy',
        target_object: targetElementName,
        log_time: new Date().toISOString(),
      })
      highlightedText.value='Copied Text:'+window.getSelection().toString()+ ' from '+ targetElementName
    };

    const handlePaste = async (e) => {
      const pastedText = await e.clipboardData.getData('text');
      // console.log('Pasted Text:', pastedText);
      const  targetElementName=e.target.closest('.dialogue')||e.target.name||e.target.nodeName;
      sendBehavior({
        id: Date.now(),
        content: pastedText,
        type: 'Paste',
        target_object: targetElementName,
        log_time: new Date().toISOString(),
      })
      highlightedText.value='Copied Text:'+ pastedText + ' from '+ targetElementName
    };

    // Highlight all text
    const handleHighlight = (e) => {
      
      if ((e.ctrlKey || e.metaKey) && e.key === 'a') {
        // Trigger your highlight logic here
        console.log('Ctrl+A or Command+A pressed');
        // Your existing logic for selecting text...
        let selectedText = '';
        if (textareaRef.value && textareaRef.value.$refs.textarea) {;
          const textarea = textareaRef.value.$refs.textarea;
          selectedText = textarea.value;
        }
        //  console.log('select:', selectedText);
        if (selectedText) {
          const targetElementName=e.target.closest('.dialogue')||e.target.name||e.target.nodeName;
          console.log('targetElementName:', targetElementName);
          sendBehavior({
            id: Date.now(),
            content: selectedText,
            type: 'HighlightAll',
            target_object: targetElementName,
            log_time: new Date().toISOString(),
          })
          highlightedText.value = 'Selected Text: ' + selectedText + ' from '+ targetElementName;
        } 
      }
    };
    // Highlight text
    const handleMouseUp = (e) => {
      // console.log('Mouse Up');

      let selectedText = '';
      // Check if the event's target is the textarea
      if (e.target === textareaRef.value.$refs.textarea) {
        const start = e.target.selectionStart;
        const end = e.target.selectionEnd;
        selectedText = e.target.value.substring(start, end);
      } else {
        // For other elements, continue using window.getSelection
        selectedText = window.getSelection().toString();
      }
      if (selectedText !== '') {
        // Do something with the selected text
        // console.log('Highlight Text:', selectedText);
        const targetElementName=e.target.closest('.dialogue')||e.target.name||e.target.nodeName;
        console.log('targetElementName:', targetElementName);
        // targetElementName.split('_');
        sendBehavior({
          id: Date.now(),
          content: selectedText,
          type: 'Highlight',
          target_object: targetElementName,
          log_time: new Date().toISOString(),
        })
        highlightedText.value='Highlight Text:'+ selectedText+ ' from '+ targetElementName;
      }
      // Update the session storage
      // console.log('textArea Text:', textArea.value);
      // localStorage.setItem('storage_notes', textArea.value);

    };

    const startFocusTime = () => {
      if (focusTimeStart === 0) {
        focusTimeStart = new Date().getTime();
      }
    };

    const endFocusTime = (e) => {
      focusTimeEnd = new Date().getTime();
      // console.log('Time Spent:', (focusTimeEnd - focusTimeStart) / 1000);
      highlightedText.value='Focus Time Spent:'+ (focusTimeEnd - focusTimeStart) / 1000
      const targetElementName = e.target.name||e.target.id||e.target.nodeName;
      sendBehavior({
        id: Date.now(),
        content: (focusTimeEnd - focusTimeStart) / 1000,
        type: 'FOCUS_TIME',
        target_object: targetElementName,
        log_time: new Date(focusTimeEnd).toISOString(),
      })
      focusTimeStart = 0;
    };

    const handleVisibilityChange= () => {
      console.log('Visibility Change:', document.visibilityState);

      if (document.visibilityState === 'visible') {
        // console.log('User is focused on the page');
        sendBehavior({
            id: Date.now(),
            content: (new Date().getTime()-focus_leave)/1000,
            type: 'Leaving Time',
            target_object: 'Page',
            log_time: new Date().toISOString(),
        })  
        highlightedText.value='User is focused on the page'
      } else {
        sendBehavior({
            id: Date.now(),
            content: (new Date().getTime()-focus_leave)/1000,
            type: 'Stay Time',
            target_object: 'Page',
            log_time: new Date().toISOString(),
        })  
        // console.log('User has left the page');
        // Perform actions when the page is not in focus
      }
      focus_leave=new Date().getTime();
    };
    
    window.addEventListener('resize', () => {
      if(window.innerWidth<992){
        // console.log("Window width:", window.innerWidth); 
        // console.log('Mobile View');
        mobileDrawer.value = true;
      }
      else{
        mobileDrawer.value = false;
      }
      if(window.innerHeight<768){
        textAreaRowRef.value = 6;
      }
      else if(window.innerHeight<992){
        textAreaRowRef.value = 8;
      }
      else if (window.innerHeight<1024){
        textAreaRowRef.value = 10;
      }
      else{
        textAreaRowRef.value = 12;
      }
    })

    // const onSubmitTask = async () => {
    //   console.log('Task Submitted:', textArea.value);
    //   sendBehavior({
    //     id: Date.now(),
    //     content: textArea.value,
    //     type: 'Task Submission',
    //     target_object: 'textarea',
    //     log_time: new Date().toISOString(),
    //   })
    //   highlightedText.value='Task Submitted:'+ textArea.value
    // };


    // unused function
    // The UI conditions parts
    const isLastChatbotMessage = (message) => {
      const lastIndex = messages.value.length - 1;
      const lastMessage = messages.value[lastIndex];
      return message.id === lastMessage.id && lastMessage.sender === 'assistant';
    };

    // unused function
    // Resent the chatbot message
    const resentMessage = (up) => {
      const RESENT_PROMPT="Give me another idea?"
      if(up){
        currentTemp.value+=0.1;
      }
      else{
        currentTemp.value-=0.1;
      }
      createMessage(marked(RESENT_PROMPT),'user')
      getResponse(RESENT_PROMPT)
    };


    // Listen the ipAddress
    const getIPFromAmazon=async()=> {
      await fetch("https://checkip.amazonaws.com/").then(res => res.text()).then(data => {
        ipAddress.value = data;
        })
    }

    return { messages,
      attendTour,
      timeSeconds,
      messageSending,
      minWords,
      maxWords, 
      userInput, 
      scenarioRef,
      noteRef,
      chatBotRef,
      submitTaskRef,
      chatInputRef,
      infoRef,
      open,
      tourFinished,
      scenarioText,
      textArea,
      textAreaWordCount,
      checkTaskFinish,
      onSubmitTask,
      handleInput,
      handlePromptInput,
      handleCopiedButton, 
      clearTextArea,
      textareaRef,
      sendMessage,
      highlightedText,
      handleHighlight,
      handleCopy,
      handlePaste,
      handleMouseUp,
      startFocusTime,
      hasFinishTask,
      endFocusTime,
      drawer,
      mobileDrawer,
      scrollToBottom,
      scrollContainer,
      isLastChatbotMessage,
      MAX_TEMP,
      MIN_TEMP,
      currentTemp,
      resentMessage,
      textAreaRowRef,
    };
  },
};
</script>

<style scoped>
/* Add your styles here scoped */

*{
  padding: 0;
  margin: 0;
  box-sizing: border-box;
  -webkit-font-smoothing: antialiased;
}

.chat-area,
.task-area {
  margin: 10px;
  max-height: calc(100vh - 120px); /* Adjust the value based on your layout */
  /* height:calc(100vh - 100px) ; */
  
}
.m-chat-area{
  width: 100%;
  height: 100%;
  flex: 2;
  position: relative;
  padding-bottom: 80px !important;
  
}
.m-chat-area>>>.el-card{
  box-shadow: none;
  border: none;
  margin: 0px;
  unicode-bidi: isolate;
  word-wrap: break-word;
  font-size: 1rem;
  line-height: 1.5rem;
  padding: 0px 0px;

}
.m-chat-area>>>.el-card__body{
  padding: 8px 0px;
}
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

.dashboard {
  max-width: 1600px;
  margin: auto;
  display: flex;
  flex-direction: row; /* Change flex-direction to row */
  flex: 1; /* Added */
  height: 100%; /* Added */
}

.task-area {
  display: flex !important; 
  flex-direction: column; /* Added */
  align-items: center;
  flex: 1;  

  /* gap: 10px; */

  /* padding-right: 20px; Add some spacing between columns */
}

.chat-area {
  /* flex: 2; */
  position: relative;
  padding-bottom: 150px !important;
  }


.cloudy-glass {
  background: rgba(255, 255, 255, 0.45);
  box-shadow: 0 4px 2px 0 rgba(31, 38, 135, 0.15);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  /* padding: 20px; */
}

.scenario,
.note {
  position: relative;
  box-sizing: border-box;
  /* flex: 1; */
  flex-grow: 1;
  height: 50%;
  padding: 12px;
  width: 100%;

}
.scenario>>>.el-card__body{
  overflow: hidden;
  height: 100%;
  padding: 0;
}
.scenario-scroll{
  padding: 0;
  height: 100%;
  overflow-y: scroll; 
  padding-bottom:60px ;
}
/* scenario-scroll */
.note{
  overflow-y: scroll; 
}


.scenario{
  /* padding-right: 30px; */
  -webkit-user-select: none; /* Safari */
  -ms-user-select: none; /* IE 10 and IE 11 */
  user-select: none; /* Standard syntax */
  overflow: hidden;
  padding: 10px 20px;
  cursor: not-allowed;
}
/* .scenario::after {
  content: "» » » »";
  display: block;
  width: 10px;
  position: fixed;
  right: 6px;
  top: 40px;
  font-size: 1.5rem;
  writing-mode: vertical-rl;
  text-orientation: mixed;
} */
.scenario::before{
  content: "";
  left: 0;
  right: 0;
  bottom: 0;
  width: 100%;
  height: 80px;
  background: linear-gradient(rgba(179, 179, 179, 0.001), rgb(255, 255, 255)) ;
  position: absolute;
  z-index: 1;
}
.note_panel{
  width: 100%;
  display: flex;
  /* align-items: center; */
  margin-top: 8px;
  justify-content: space-between;
}

.text-area_info{
  display: flex;
  flex-direction: column;
  align-items: baseline;
  justify-items: start;
  text-align: left;

}
.text-area_info>div{
  font-size: 0.8rem;
  display: block;
  line-height: 1.6;
  color: #353535;
  /* padding: 2px 0; */
  margin: 0;
  display: flex;
  align-items: center;
}

.chat-title{
  display: flex;
  gap: 4px;
  align-items: center;
  padding: 10px 0;
}

.bar>>>.el-textarea__inner{
  width: 100%;
  border: none;
  box-shadow: none;
  border-radius: 12px;
  background: #E9EEF6 ;
  padding: 16px 12px; 
  padding-right: 60px;
  /* min-height:1.5rem; */
  font-size: 1rem;
  /* min-height: 50px; */
  /* height: 100%; */
}

.bar>>>.el-input__wrapper,
.bar>>>.el-input-group__append
 {
  /* width: 100%; */
  border-radius: 0;
  font-size: 1rem;
  /* border-radius: 100px !important ; */
  /* border: 4px solid #dcdfe6; */
  box-shadow: none;
  background: transparent;
  line-height: 4;
  padding: 4px 8px;
  color: #5F6367;
  /* background-color: #ffffff; */

}



.bar>>>.el-input-group__append{
  background: #1b1b1b;
  color: #ffffff;
  border-radius: 16px ;
  padding: 0px 12px 8px 12px;
  
  vertical-align: middle;
  /* border: 2px #6b8ea2 solid; */
  /* font-size: 0.8rem; */
}
.bar>>>.el-input-group__append>span {
 display: flex !important;
 align-items: center;
 justify-content: center;
}
.note>>>.el-textarea{
  height: 100%;

}
.note .notice .el-text {
  display: inline;
}
.note>>>.el-textarea__inner{
  border-radius: 10px;
  border: none;
  background: #E9EEF6;
  padding: 10px;
  resize: none;
  display: block;
  height: 100%;
  min-height: 100% !important;
  /* max-height: 100%; */
}
.bar{
  background: transparent;
  box-shadow: none;
  border-radius: 0;
 

}

.task-area>>>.el-card,
.chat-area>>>.el-card{
  background: #ffffff;
  box-shadow: none;
  border: none;
  border-radius: 10px;
  margin: 8px 4px;
  /* margin-block-start: 1em;
  margin-block-end: 1em;
  margin-inline-start: 0px;
  margin-inline-end: 0px; */
  unicode-bidi: isolate;
  word-wrap: break-word;
  font-size: 1rem;
  line-height: 1.5rem;
}

.chat-area>>>.bar.el-card{
 box-shadow: rgba(67, 71, 85, 0.27) 0px 0px 0.25em, rgba(90, 125, 188, 0.05) 0px 0.25em 1em;
}

.bar {
  
  position: absolute;
  bottom: -8px;
  left: -4px;
  right: -4px; /* Add this to make the bar span the entire width */
  z-index: 1;
}

.dialogue{
  display: flex;
  align-items: start;
  gap: 8px;
}

.avatar{
  flex-shrink: 0;
}
.user-bg{
  /* background: #abd5ff; */
   /* background: #e5ecf7; */
    background: #48566d;
   /* background: #79bcff; */
    /* background: #409EFF; */

}
.bot-bg{
  background: #f8b932;
    /* background: #90c874; */
  /* background: #67C23A; */
}

.scenario-title{
  font-size: 1.1rem;
  font-weight: bold;
  margin-bottom: 10px;
}

.submit_block{
  min-width: 160px;
  flex: 1;
  display: flex;
  flex-direction:column ;
  /* justify-content: end; */
  align-items: flex-end;
}
.submit_block>>>.el-form-item{
  /* padding: 0; */
  margin: 0;
  margin-bottom:6px;
}

.mobile-drawer{
  position: fixed;
  display: flex;
  width: 56px;
  height: 56px;
  align-items: center;
  justify-content: center;
  vertical-align: middle;
  right: 20px;
  bottom: 20px;
  z-index: 1000;
  box-shadow: #5F6367 0px 0px 10px 0px;
  padding: 10px;
  border: none;
  border-radius: 50%;
  background: #ffffff;
  transition: all 0.3s;
  -webkit-backface-visibility: hidden;
}
.mobile-drawer>span{
  display: flex;
  align-items: center;
  justify-content: center;
}

.scroll-bar{
  transition: all 0.3s ease-in-out;
}
.user-title{
  font-weight: 600;
  -webkit-user-select: none;
  user-select: none;
  font-size: 1rem;
  line-height: 1.5em;
  display: block;
}

.scenario::-webkit-scrollbar {
  width: 12px;
  left:-100px;
  z-index: 1000;

 
}
.scenario::-webkit-scrollbar-track {
   /* background: #1b1b1b; */
   background: #d6dfec;
    border-radius: 8px;
     margin-block: 15px;
   /* color: #000; */
   /* width: 2px; */
}
.scenario::-webkit-scrollbar-thumb {
  position: absolute;
  right: 3px;
  border-radius: 8px;
  /* border: 4px solid  #48566d; */
  border:4px solid #ffd885;
  background-clip: content-box;
  /* -webkit-box-shadow: -2px 0px 1px  #48566d ; */
  /* display: block; */
  background-color: rgb(255, 255, 255);
  /* filter: drop-shadow(5px 5px 5px rgba(0, 0, 0, 0.8)); */
  /* background: #48566d; */
  /* -webkit-box-shadow: 0 0 1px rgba(255, 255, 255, .5); */
}






.el-tour .el-tour__content{
  max-width: 800px;
  width: 80% ;
  padding: 100px;
}

.bar .submit-chatbot{
  /* background: #3a3a3d; */
  background: #48566d;
  color: #ffffff;  
  vertical-align: middle;
  border-radius: 10px ;
  padding: 16px 4px;
  vertical-align: middle;
  position: absolute;
  bottom: 28px;
  right: 30px;
  z-index: 100;
}

.m-chat-area .bar .submit-chatbot{
  /* position: absolute; */
  bottom: 14px;
  right: 12px;
}

.submit-chatbot >>>.el-icon.is-loading{
  width:24px; 
  height: auto;
  vertical-align:middle;  
  padding:0;
  font-size: 1.1rem;
}
.video{
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 0px 0px 20px 0px;
}
iframe{
  width: 100%;
  border: none;
  border-radius: 10px;
}




@media (min-width:992px) {
  .mobile-drawer{
    display: none;
  }
}
@media (max-width:992px) {
  .invisible{
    display: none !important;
  }
}


</style>

