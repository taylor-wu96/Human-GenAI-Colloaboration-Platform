require 'aws-sdk-sqs'
require 'ostruct'
require_relative '../models/tasks'

module RubyOpenAI
  # set up for the random task queue
  class RandomQueue
    TASK_TYPES = %w[CREATIVE PRACTICAL].freeze
    def initialize(config)
      @sqs = Aws::SQS::Client.new(
        access_key_id: config.AWS_SQS_ACCESS_KEY_ID,
        secret_access_key: config.AWS_SQS_SECRET_ACCESS_KEY,
        region: config.AWS_REGION
      )
      @queue = Aws::SQS::Queue.new(url: config.AWS_SQS_URL, client: @sqs)
      @attributes = @sqs.get_queue_attributes(
        queue_url: config.AWS_SQS_URL,
        attribute_names: ['All']
      )
      @url = config.AWS_SQS_URL
    end

    def random_task
      fill_task(10) if queue_size.to_i <= 2
      task = @queue.receive_messages({
                                       max_number_of_messages: 1,
                                       receive_request_attempt_id: 'String'
                                     })
      if task.first.nil?
        fill_task(10)
        if Random.rand(0..1) < 0.5
          return { message_id: 'error', receipt_handle: 'error',
                   task_name: TASK_TYPES[0] }.to_json
        end
        return { message_id: 'error', receipt_handle: 'error', task_name: TASK_TYPES[1] }.to_json

      end
      { message_id: task.first.data.message_id, receipt_handle:      task.first.data.receipt_handle,
        task_name: JSON.parse(task.first.data.body)['task'] }.to_json
    rescue Aws::SQS::Errors::ReceiptHandleIsInvalid
      raise ArgumentError, "Input receipt \"#{task}\" is not a valid receipt"
    rescue StandardError => e
      raise RuntimeError, 'Could not send the delete request to SQS', e
    end

    def finish_task(task)
      @queue.delete_messages(
        entries: [
          {
            id: task.message_id,
            receipt_handle: task.receipt_handle
          }
        ]
      )
    rescue Aws::SQS::Errors::ReceiptHandleIsInvalid
      raise ArgumentError, "Input receipt \"#{task}\" is not a valid receipt"
    rescue StandardError => e
      raise RuntimeError, 'Could not send the delete request to SQS', e
    end

    def fill_task(num_of_task = 400)
      (1..num_of_task).each do |i|
        @queue.send_message(queue_url: @queue, message_body: { task: i.even? ? TASK_TYPES[0] : TASK_TYPES[1] }.to_json)
      end
    end

    def fill_task_imbalance(taskdata)
      task_arr = []
      # print('task data:', taskdata)
      TASK_TYPES.each do |task|
        # print('task:', task)
        num_of_task = taskdata[task].to_i
        # print('num_of_task:', num_of_task)
        (1..num_of_task).each do |_num|
          # print('task:', task, num)
          task_arr.push(task)
        end
      end
      task_arr.shuffle!
      print('task_arr:', task_arr)
      # for i in task_arr do
      #   @queue.send_message(queue_url: @queue,
      #                       message_body: { task: i }.to_json)
      # end
      (1..task_arr.length).each do |i|
        @queue.send_message(queue_url: @queue,
                            message_body: { task: task_arr[i] }.to_json)
      end
    end

    def clear_queue
      @sqs.purge_queue(queue_url: @url)
    end

    def queue_size
      @attributes.attributes['ApproximateNumberOfMessages']
    end

    def queue_attributes
      @attributes = @sqs.get_queue_attributes(
        queue_url: @url,
        attribute_names: ['All']
      )
      @attributes
    end
  end
end
