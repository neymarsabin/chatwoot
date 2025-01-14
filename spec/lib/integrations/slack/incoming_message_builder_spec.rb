require 'rails_helper'

describe Integrations::Slack::IncomingMessageBuilder do
  let(:account) { create(:account) }
  let(:message_params) { slack_message_stub }
  let(:verification_params) { slack_url_verification_stub }

  let(:hook) { create(:integrations_hook, account: account, reference_id: message_params[:event][:channel]) }
  let!(:conversation) { create(:conversation, identifier: message_params[:event][:thread_ts]) }

  describe '#perform' do
    context 'when url verification' do
      it 'return challenge code as response' do
        builder = described_class.new(verification_params)
        response = builder.perform
        expect(response[:challenge]).to eql(verification_params[:challenge])
      end
    end

    context 'when message creation' do
      it 'creates message' do
        messages_count = conversation.messages.count
        builder = described_class.new(message_params)
        builder.perform
        expect(conversation.messages.count).to eql(messages_count + 1)
      end

      it 'does not create message for invalid event type' do
        messages_count = conversation.messages.count
        message_params[:type] = 'invalid_event_type'
        builder = described_class.new(message_params)
        builder.perform
        expect(conversation.messages.count).to eql(messages_count)
      end

      it 'does not create message for invalid event name' do
        messages_count = conversation.messages.count
        message_params[:event][:type] = 'invalid_event_name'
        builder = described_class.new(message_params)
        builder.perform
        expect(conversation.messages.count).to eql(messages_count)
      end
    end
  end
end
