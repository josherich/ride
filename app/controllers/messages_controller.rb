class MessagesController < ApplicationController
	before_filter :get_conversation, :get_mailbox

	def index
		@messages = @conversation.messages
		respond_to do |format|
			format.js {
				render 'conversations/update_chat'
			}
		end
	end

	# reply in a conversation
	def update
		last_receipt = @mailbox.receipts_for(@conversation).last
		@receipt = current_user.reply_to_all(last_receipt, params[:body])
		respond_to do |format|
			format.js
		end
	end

	def show
	end

	def edit
	end

	def create
	end

	def destroy
	end

	private

	def get_conversation
		@conversation = current_user.mailbox.conversations.find_by_id(params[:id])
	end

	def get_mailbox
		@mailbox = current_user.mailbox
	end
end
	