#!/usr/bin/env python

from kombu.mixins import ConsumerMixin
#from kombu.log import get_logger
from kombu.utils import kwdict, reprcall

import config
import tasks


#logger = get_logger(__name__)

def process_task(body, message):
    fun = body['fun']
    args = body['args']
    kwargs = body['kwargs']
    #logger.info('Got task: %s', reprcall(fun.__name__, args, kwargs))
    logit("Got task : %s" % reprcall(fun.__name__, args, kwargs))
    try:
        fun(*args, **kwdict(kwargs))
    except Exception as exc:
        #logger.error('task raised exception: %r', exc)
        logit("task raised exception: %r" % exc)
    message.ack()

if __name__ == '__main__':
    from kombu import Connection
    #from kombu.utils.debug import setup_logging
    # setup root logger
    #setup_logging(loglevel='INFO', loggers=[''])

    with Connection(config.rabbit_host) as conn:
     with conn.Consumer(config.worker_queues, callbacks=[process_task]):
        while True:
            try:
                conn.drain_events()
            except KeyboardInterrupt:
                logit("bye bye")
                break

