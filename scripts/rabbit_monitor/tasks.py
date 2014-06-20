import config
from kombu.pools import producers

def hello_task(who="world"):
    print("Hello %s" % (who, ))

def remove_puppet_ssl(hostname=None):
    if hostname:
      print("Worker: Removing ssl cert for %s" % (hostname, ))

def send_as_task(connection, fun, args=(), kwargs={}, priority='mid'):
    payload = {'fun': fun, 'args': args, 'kwargs': kwargs}
    routing_key = config.priority_to_routing_key[priority]

    with producers[connection].acquire(block=True) as producer:
        producer.publish(payload,
                         serializer='pickle',
                         compression='bzip2',
                         exchange=config.task_exchange,
                         declare=[config.task_exchange],
                         routing_key=routing_key)

def logit(msg,isobject=False):
  try:
    if config.debug:
      if isobject:
        pprint(msg)
      else:
        print msg
  except:
    pass

