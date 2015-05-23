#!/usr/bin/python

import commands, time

DEBUG = False

class SmartDisk():
  """
  A class to access information on S.M.A.R.T. disks.

  Usage: (under construction)
  """
  def __init__(self,diskid):
    self.wwn = diskid
    self.vars     = "-"
    self.health   = "-"
    self.selftest = "-"
    self.info     = "-"
    self.identity = commands.getoutput("sudo smartctl -i " + self.wwn).splitlines()
    self.lasttime = -1

  def smart(self):
    t1 = time.time()
    # only read the S.M.A.R.T. data if current data is stale
    # data is considered stale if it is older than 4 minutes
    if ((t1 - self.lasttime) > (4*60)):
      self.vars     = commands.getoutput("sudo smartctl -A " + self.wwn).splitlines()
      self.info     = commands.getoutput("sudo smartctl -i " + self.wwn).splitlines()
      self.health   = commands.getoutput("sudo smartctl -H " + self.wwn).splitlines()
      self.selftest = commands.getoutput("sudo smartctl -l selftest " + self.wwn + "  |grep '\# 1'")
      self.lasttime = t1
    else:
      if DEBUG:print "Using old data: "
    if DEBUG:print self.vars
    return 0

  def getdata(self,id):
    ret = ""
    for line in self.vars:
      if (line != ''):
        ls=line.split()
        if (ls[0] == id):
          if DEBUG:print line.split()
          ret=ls[9]
    return ret

  def gethealth(self):
    ret =""
    if DEBUG:print self.health
    ret = self.health[4]
    return ret

  def getlasttest(self):
    ret =""
    if DEBUG:print self.selftest
    ret = self.selftest
    return ret

  def getinfo(self):
    ret =""
    if DEBUG:print self.wwn
    ret = self.wwn
    return ret


if __name__ == '__main__':

  DEBUG = True

  sda = SmartDisk("/dev/sda -d ata")
  sda.smart()
  print sda.getdata('194')
  sdb = SmartDisk("/dev/sdb -d ata")
  sdb.smart()
  print sdb.getdata('194')
  sdc = SmartDisk("/dev/sdc -d ata")
  sdc.smart()
  print sdc.getdata('194')
  sdd = SmartDisk("/dev/sdd -d ata")
  sdd.smart()
  print sdd.getdata('194')
  print "last test:"
  print sda.getlasttest()
  print "info"
  print sdc.getinfo()
  print "health"
  print sdb.gethealth
  print "data 9"
  print sda.getdata('9')