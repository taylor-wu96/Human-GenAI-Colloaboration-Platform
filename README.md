# Human Gen-AI Collaboration Experiment Project

## Overview
This is a research platform in conducting human-Gen AI collarboration. This platform is implement by Backend for Forntend (BFF) pattern. The backend is implemented by Ruby on Rails and the frontend is implemented by Vue.js. The backend is responsible for handling the request from frontend and interacting with OpenAI API (Default is GPT 4o). The frontend is responsible for rendering the UI and sending request to backend.


## Requirements
- Ruby
- net/http, uri, json, dotenv Ruby gems
- OpenAI API Key
- Npm and Element plus

## Installation
- Clone the repository. `git clone git@github.com:taylor-wu96/Human-GenAI-Colloaboration-Platform.git`
- Run `bundle install` to install the required Ruby gems.
- Run `npm install` to install the required Node modules.
- Create a .env file in the root directory and add your OpenAI API key as `OPENAI_API_KEY=your_api_key_here`.

## Database Setting
- Run `rake db:drop` to clean the database.
- Run `rake db:migrate` to create the database.

## SQS Task Random assignment
we implement Task Random Assignment using Amazon Simple Queueing Services. You could follow the steps to set up the SQS through API
- Add and Set `/backend_app/environments/secrets.yml` from the given `sample_secrets.yml`
- After launch the server, you could know the detailed information of SQS from the following API.
  - `/queue` to get the information of SQS.
  - `/reset-queue` to clear and refill the queue to the original state.
    - try `?num=<Number>` to set the queue to the size you want
  - `/clear-queue` to clear and make the queue become empty
  - `/reset-queue-imbalance` to set the queue with the tasks with imbalance quantity.
    - `?task_typeA=<Number>&task_typeB=<Number>` to set the imbalance quantity of each task type.

## How to run the server
- #### In the frontend part, you could either run as prod or dev mode.
  - Run `npm run prod` to use webpack to bundled the compiled file.
  - Run `npm run dev` to start the development server.
- #### In the backend part, you could use `puma config.ru` to start the server.

## Fast Data Collection
- `/task-to-csv?user_id=1` will generate a csv file for the user with id 1. if you need to download all of user_id's data, you could use `/task-to-csv?user_id=1` to generate a csv file for all users.
- same usage as `/chat-to-csv` | `message-to-csv` | `behavior-to-csv` | `/error-log-to-csv`

## How to made some customizations

- In `/frontend_app/constant/Constants.vue` file, you could set the scenario text you want to use in the platform.
- In `/backend_app/controllers/app.rb` file, you could set the scenario and the base role you want GPT to play in `    BASE_PROMPT` and set the welcome message in `WELCOME_MESSAGE`

## Contributing
If you'd like to contribute, please fork the repository and make changes as you'd like. Pull requests are warmly welcome.

## License
This project is licensed under the MIT License.

