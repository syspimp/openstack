#!/usr/bin/env python
#
# this monitors vm creation/deletion by watching for nova-compute
# notifications in its rabbit queue
#
# run this in a screen shell, ie screen -d -m /root/rabbit-openstack-monitor.py
# it wont run as a background or daemon because of callback function

from kombu import Connection, Exchange, Queue
from pprint import pprint
import os
import config
import tasks

def process_msg(body, message):
  try:
    print '='*80
    if body['event_type'] in config.compute_events:
        print 'event: %s' % body['event_type']
        print 'hostname: %s' % body['payload']['hostname']
        try:
          if 'new_task_state' in body['payload']:
            print 'current_task: %s' %  body['payload']['new_task_state']
            print 'state: %s' %  body['payload']['state']
            print 'on_node: %s' %  body['payload']['host']
          ## compute vm tasks
          if body['event_type'] == 'compute.instance.update' or body['event_type'] == 'compute.instance.delete.end':
            if body['payload']['state'] == 'deleted' or body['payload']['new_task_state'] == 'deleting':
              try:
                send_as_task(conn, fun=tasks.remove_puppet_ssl, args=(body['payload']['hostname'], ), kwargs={},
                   priority='high')
                logit("Sent task to remove %s ssl cert from puppet!" % body['payload']['hostname'])
              except Exception,e:
                logit("Exception in process_msg. Could not remove %s from puppet!" % body['payload']['hostname'])
                for i in e:
                  logit("%s" % e)
        except Exception,e:
          logit("Exception in process_msg. Dumping msg:")
          for i in e:
            logit("%s" % e)
          logit(body,True)
        print 'state: %s' %  body['payload']['state']
#        print 'on_node: %s' %  body['payload']['node']
        print 'created_at: %s' %  body['payload']['created_at']
        print 'deleted_at: %s' %  body['payload']['deleted_at']
        print 'user: %s' %  body['_context_user_name']
        print 'project: %s' %  body['_context_project_name']
    message.ack()
  except Exception,e:
    logit('Exception in process_msg: ignoring event... but dumping exception and msg.')
    for i in e:
      logit("%s" % e)
    logit(body,True)

with open(config.pid_file, 'w') as the_file:
    pid=os.getpid()
    the_file.write("%d" % os.getpid())
    the_file.close()

with Connection(config.rabbit_host) as conn:
  with conn.Consumer(config.monitor_queues, callbacks=[process_msg]):
    while True:
      try:
        conn.drain_events()
      except KeyboardInterrupt:
        break

