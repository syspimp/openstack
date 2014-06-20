from kombu import Exchange, Queue

## debug switch
debug=True

## manually set the domain
domain = '<%= @rabbitdomain %>'

## queue to monitor
watch_q = '<%= @rabbit_q %>'

## names of the scripts
workername='<%= @workername %>'
monitorname='<%= @monitorname %>'

## controller info
openstack_controller='<%= @controller %>'
rabbit_host='amqp://<%= @rabbitcreds %>@'+ openstack_controller +'//'

## not used, callback wont daemonize
worker_log_file="/tmp/%s.log" % workername
monitor_log_file="/tmp/%s.log" % monitorname

## used to check status
worker_pid_file="/tmp/%s.pid" % workername
monitor_pid_file="/tmp/%s.pid" % monitorname


task_exchange = Exchange('nova', type='topic', durable=False)
worker_queues = [Queue(watch_q + '_hipri', task_exchange, routing_key=watch_q + '_hipri'),
               Queue(watch_q + '_midpri', task_exchange, routing_key=watch_q + '_midpri'),
               Queue(watch_q + '_lopri', task_exchange, routing_key=watch_q + '_lopri')]
monitor_queues = [Queue('notifications.info', task_exchange, durable=False, routing_key='notifications.info')]

priority_to_routing_key = {'high': watch_q + '_hipri',
                           'mid': watch_q + '_midpri',
                           'low': watch_q + '_lopri'}

# list of events to listen for,
## for now, any compute related
## full list: https://wiki.openstack.org/wiki/SystemUsageData
## examples: http://paste.openstack.org/show/54140/
compute_events = [
        'compute.instance.create.end',
        'compute.instance.create.error',
        'compute.instance.create.start',
        'compute.instance.create_ip.end',
        'compute.instance.create_ip.start',
        'compute.instance.delete.end',
        'compute.instance.delete.start',
        'compute.instance.delete_ip.end',
        'compute.instance.delete_ip.start',
        'compute.instance.exists',
        'compute.instance.exists.verified.old',
        'compute.instance.finish_resize.end',
        'compute.instance.finish_resize.start',
        'compute.instance.live_migration.post.dest.end',
        'compute.instance.live_migration.post.dest.start',
        'compute.instance.live_migration.pre.end',
        'compute.instance.live_migration.pre.start',
        'compute.instance.live_migration._post.end',
        'compute.instance.live_migration._post.start',
        'compute.instance.power_off.end',
        'compute.instance.power_off.start',
        'compute.instance.power_on.end',
        'compute.instance.power_on.start',
        'compute.instance.reboot.end',
        'compute.instance.reboot.start',
        'compute.instance.rebuild.end',
        'compute.instance.rebuild.start',
        'compute.instance.rescue.end',
        'compute.instance.rescue.start',
        'compute.instance.resize.confirm.end',
        'compute.instance.resize.confirm.start',
        'compute.instance.resize.end',
        'compute.instance.resize.prep.end',
        'compute.instance.resize.prep.start',
        'compute.instance.resize.revert.end',
        'compute.instance.resize.revert.start',
        'compute.instance.resize.start',
        'compute.instance.resume',
        'compute.instance.shutdown.end',
        'compute.instance.shutdown.start',
        'compute.instance.snapshot.end',
        'compute.instance.snapshot.start',
        'compute.instance.suspend',
        'compute.instance.unrescue.end',
        'compute.instance.unrescue.start',
        'compute.instance.update',
        'compute.instance.volume.attach',
        'compute.instance.volume.detach'
]

