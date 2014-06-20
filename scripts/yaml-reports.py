#!/usr/bin/env python
# this script monitors the yaml/facts on a node
#
import yaml, time
from optparse import OptionParser
parser = OptionParser()
parser.add_option("-v", "--viewall", action="store_true", dest="VIEWALL", help="View all data", default=False)
parser.add_option("-r", "--resource_status", action="store_true", dest="RESOURCE", help="Check only resource status", default=False)
parser.add_option("-f", "--file", type="string", dest="YAML", help="File to operate on", default=False)

def do_list(arr):
  for key,value in enumerate(arr):
    print "key=%s" % key
    checktype(value)
  
def do_array(arr):
  for key,value in arr.iteritems():
    print "key=%s" % key
    checktype(value)
    
def checktype(checkme):
  if type(checkme) is list:
    do_list(checkme)
  elif type(checkme) in [tuple,dict]:
    do_array(checkme)
  elif type(checkme) is int:
    print "value=%d" % checkme
  elif type(checkme) in [str,bool]:
    print "value=%s" % checkme
  else:
    print type(checkme)
    print "value=%s" % checkme

def viewall(data):
  for key,value in data.iteritems():
    print "key=%s" % key
    checktype(value)
#    time.sleep(1)

def checkresources(data):
  changes=False
  changedfiles=[]
  for key,value in data['resource_statuses'].iteritems():
    if data['resource_statuses'][key]['out_of_sync'] or data['resource_statuses'][key]['changed']:
      changes=True
      print "============="
      print "Resource %s has been changed on this puppet run" % key
      print "Resource defined in %s, line %s" % (data['resource_statuses'][key]['file'],data['resource_statuses'][key]['line'])
      print "Message: %s" % data['resource_statuses'][key]['events'][0]['message']
      print "Property: %s" % data['resource_statuses'][key]['events'][0]['property']
      print "Time: %s" % data['resource_statuses'][key]['events'][0]['time']
      print "Previous value: %s" % data['resource_statuses'][key]['events'][0]['previous_value']
      print "Desired value: %s" % data['resource_statuses'][key]['events'][0]['desired_value']
      changedfiles.append(key)
  if changes:
    print "Here is a list changed files:"
    print changedfiles

def mainloop():
  (options, args) = parser.parse_args()
  if options.YAML:
    print "Opening file ..."
    with open(options.YAML) as f:
      data = yaml.load(f)
      if options.RESOURCE:
        checkresources(data)
      elif options.VIEWALL:
        viewall(data)
      else:
        print "Nothing to do!"
  else:
    print "Pass a file to work on with the -f <file> param"

if __name__=='__main__':
  try:
    mainloop()
  except Exception as e:
    print e
