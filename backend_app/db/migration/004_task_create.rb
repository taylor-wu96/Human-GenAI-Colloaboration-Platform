# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    # Create behaviors table
    create_table(:tasks) do
      primary_key :id
      foreign_key :chat_id, :chats # Links message to a specific chat
      String :task_name
      String :final_submission
      String :message_id
      String :task_finished_time
      String :receipt_handle
      Integer :word_editing_count
      Integer :word_deleted_count
      Integer :character_revision_count
      DateTime :created_at
      DateTime :updated_at

      # unique %i[course_id name]
    end
  end
end
