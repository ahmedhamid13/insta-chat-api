class Message < ApplicationRecord
  # relations
  belongs_to :chat
  has_one :system_application, through: :chat
  
  # validations
  validates :number, :chat, presence: true
  validates :body, length: { maximum: 5000 }, allow_nil: true
  validates :number, uniqueness: { scope: [:system_application] }
  validates :number, numericality: { greater_than_or_equal_to: 0 }
  validates :number,
            inclusion: { in: ->(i) { [i.number_was] } },
            on: :update
  # call backs
  before_validation :generate_number, on: :create

  private
  
  def generate_number
    chat&.with_lock do
      messages = chat.messages
      self.number = messages.empty? ? 1 : (messages.last.number + 1)
      # chat.update(messages_count: chat.messages_count + 1)
    end
  end
end
