import { createConsumer } from '@rails/actioncable';

class BaseActionCableConnector {
  constructor(app, pubsubToken) {
    this.consumer = createConsumer();
    this.consumer.subscriptions.create(
      {
        channel: 'RoomChannel',
        pubsub_token: pubsubToken,
      },
      {
        received: this.onReceived,
      }
    );
    this.app = app;
    this.events = {};
    this.isAValidEvent = () => true;
  }

  disconnect() {
    this.consumer.disconnect();
  }

  onReceived = ({ event, data } = {}) => {
    if (this.isAValidEvent(data)) {
      if (this.events[event] && typeof this.events[event] === 'function') {
        this.events[event](data);
      }
    }
  };
}

export default BaseActionCableConnector;
