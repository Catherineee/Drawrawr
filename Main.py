#!/usr/bin/python2
#  ____                _____                  ___   ___
# |    \ ___ ___ _ _ _| __  |___ _ _ _ ___   |_  | |   |
# |  |  |  _| .'| | | |    -| .'| | | |  _|  |  _|_| | | 
# |____/|_| |__,|_____|__|__|__,|_____|_|    |___|_|___|
# ------------ A social website for artists ------------

__version__ = '2.0'
__author__  = 'DrawRawr'

import web

from Config import *
from Crypto import *
from Database import *

urls = (
  '/',                      'index',
  '/art/(.*)',              'art',
  '/users/login',           'login',
  '/users/signup',          'signup',
  '/policy/(.*)',           'policy',
  '/util/redirect/(.*)',    'redirect',
  '/(.*)',                  'userpage',
)

app = web.application(urls, globals())
db  = web.database(dbn='mysql', db=mysqlDatabase, user=mysqlUsername)
session = web.session.Session(app, web.session.DiskStore('sessions'), initializer={})

render = web.template.render('templates', base='layout', globals={'session':session})
render_plain = web.template.render('templates/')

def userPassCheck(username,password):
  if len (db.select("users", where="username='"+username+"' and hash='"+password+"'") ) > 0:
    return True
  else: return False

def userExists(username):
  if len (db.select("users", where="username='"+username+"'") ) > 0:
    return True
  else: return False

class index():
  def GET(self):
    session.username = "arfenhauze"
    return render.index()

class userpage():
  def GET(self,name):
    return render.user(name)

class art():
  def GET(self,artID):
    return render.art(artID)

class login():
  def POST(self,username,password):
    if userPassCheck(username,password):
      return render.index()
    else:
      return render.art("anus")

class signup():
  def GET(self):
    return render.signup()
  def POST(self):
    data = web.input()
    if not userExists(data.username):
      db.insert("users",username=data.username,hash=data.password)

class policy():
  def GET(self,page):
    if   page == 'terms-of-service':
      return render.tos()
    elif page == 'staff':
      return render.staff()
    else:
      raise app.notfound()

class redirect():
  def POST(self,pageToRedirectTo):
    raise web.seeother("/"+pageToRedirectTo)

def notfound(): 
  return web.notfound(render.notfound())

app.notfound = notfound

if __name__ == "__main__": app.run()
