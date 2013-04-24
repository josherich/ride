class ConversationsController < ApplicationController
	before_filter :get_conversations, :check_conversation

	def index
		respond_to do |format|
			# format.html { render @conversations if request.xhr? }
			format.js
		end
	end

	def show
		@conversation = @conversations.find_by_id(params[:id])
		@messages = @conversation.messages

		respond_to do |format|
			format.html {
				render 'show'
			}
			format.js
		end
	end

	def udpate
	end

	def destroy
		@conversation.move_to_trash(current_user)
		respond_to do |format|
			format.js {
				render 'conversations/destroy'
			}
		end
	end
	
	# redirct from contacts view, new conversation
	def create
		recipients = conversation_params(:recipients).split(',')
		conversation = current_user.send_message(recipients, *conversation_params(:body, :subject)).conversation
		
		respond_to do |format|
			format.js {
				render 'conversations/update_conversations'
			}
		end
	end

	# reply to a specific conversation, in conversation view, update using ajax
	def reply
		receipt = @mailbox.receipts_for(@conversation).last
		current_user.reply_to_sender(receipt, params[:body])
		respond_to do |format|
			format.js
		end
	end

	def trash
		@conversation.move_to_trash(current_user)
		respond_to do |format|
			format.js {
				render 'conversations/update_conversations'
			}
		end
	end

	def untrash
		@conversation.untrash(current_user)
		respond_to do |format|
			format.js {
				render 'conversations/update_conversations'
			}
		end
	end

	private
	
	def get_conversations
		@mailbox ||= current_user.mailbox
		@conversations = @mailbox.conversations
	end

	def check_conversation
		if params[:id].present?
			@conversation ||= current_user.mailbox.conversations.find(params[:id])
		end
		# if @conversation.nil? or !@conversation.is_participant?(current_user)
		# 	redirct_to conversations_path
		# 	return
		# end
	end

end