#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2015 Sean Kirmani <sean@kirmani.io>
#
# Distributed under terms of the MIT license.

import base64
import cv2
import json
import os

from flask import abort
from flask import Flask
from flask import jsonify
from flask import render_template
from flask import request
from flask import send_file


LOCKS_DATA_FILE = os.path.join(os.path.dirname(__file__),
    'data/locks.json')

app = Flask(__name__, static_url_path='')
app.secret_key = 'drew_heilman'

GENERIC_ERROR_MESSAGE = "Error: Somthing Dun Goofed. Coding is hard. :("

@app.route('/')
def Home():
  return 'Hello'

@app.route('/lock/id/<lock_id>', methods=['GET', 'POST', 'DELETE'])
def LockId(lock_id=None):
  locks = _LoadLocks()
  if request.method == 'POST':
    request_image = request.form.get('image') if request.form.get('image') else "NULL"
    locks[lock_id] = {
          "waiting": True,
          "approved": False,
          "image": request_image,
          "time": request.form.get('time') if request.form.get('time') else "NULL",
        }
    # Face recognition
    image = cv2.imread(_SaveImage(locks[lock_id]))
    faceCascade = cv2.CascadeClassifier("/var/www/kirmani.io/api/codered/public_html/haarcascade_frontalface_default.xml")
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    faces = faceCascade.detectMultiScale(
        gray,
        scaleFactor=1.1,
        minNeighbors=5,
        minSize=(30, 30),
        flags = cv2.cv.CV_HAAR_SCALE_IMAGE
        )
    print("Found {0} faces!".format(len(faces)))
    locks[lock_id]["faces"] = [{"x": int(face[0]), "y": int(face[1]), "w": int(face[2]), "h": int(face[3])} for face in faces]
    print(locks[lock_id]["faces"])
    _WriteLocks(locks)
    print("Added Lock with ID: %s" % lock_id)
    return jsonify(result=locks[lock_id])
  if request.method == 'GET':
    if lock_id not in locks:
      return ("Error: Lock %s doesn't exist" % lock_id)
    return jsonify(result=locks[lock_id])
  if request.method == 'DELETE':
    if lock_id not in locks:
      return ("Error: Lock %s doesn't exist" % lock_id)
    del locks[lock_id]
    _WriteLocks(locks)
    return ("Successfully removed lock with ID: %s" % lock_id)
  return GENERIC_ERROR_MESSAGE

@app.route('/lock/id/<lock_id>/approve', methods=['PUT'])
def LockIdApprove(lock_id=None):
  locks = _LoadLocks()
  if request.method == 'PUT':
    if lock_id not in locks:
      return ("Error: Lock %s doesn't exist" % lock_id)
    locks[lock_id]["waiting"] = False
    locks[lock_id]["approved"] = True
    _WriteLocks(locks)
    print("Approved Lock with ID: %s" % lock_id)
    return jsonify(result=locks[lock_id])
  return GENERIC_ERROR_MESSAGE

@app.route('/lock/id/<lock_id>/deny', methods=['PUT'])
def LockIdDeny(lock_id=None):
  locks = _LoadLocks()
  if request.method == 'PUT':
    if lock_id not in locks:
      return ("Error: Lock %s doesn't exist" % lock_id)
    locks[lock_id]["waiting"] = False
    locks[lock_id]["approved"] = False
    _WriteLocks(locks)
    print("Approved Lock with ID: %s" % lock_id)
    return jsonify(result=locks[lock_id])
  return GENERIC_ERROR_MESSAGE

@app.route('/lock/list', methods=['GET'])
def LockList():
  locks = _LoadLocks()
  return jsonify(result=[lock for lock in locks])

@app.route('/lock/open', methods=['PUT'])
def LockOpen():
  locks = _LoadLocks()
  locks["OVERRIDE"] = {
      "action": "open"
      }
  _WriteLocks(locks)
  return jsonify(result=locks["OVERRIDE"])

@app.route('/lock/close', methods=['PUT'])
def LockClose():
  locks = _LoadLocks()
  locks["OVERRIDE"] = {
      "action": "close"
      }
  _WriteLocks(locks)
  return jsonify(result=locks["OVERRIDE"])

def _SaveImage(lock):
  if lock["image"] != "NULL":
    imgdata = base64.b64decode(lock["image"])
    filename = "/var/www/kirmani.io/api/codered/public_html/data/images/" + str(lock["time"]) + ".png"
    with open(filename, 'wb') as f:
      f.write(imgdata)
      return filename

@app.route('/static/images', defaults={'path': ''})
@app.route('/static/images/<path:path>')
def StaticImage(path):
  BASE_DIR = '/var/www/kirmani.io/api/codered/public_html/data/images'
  abs_path = os.path.join(BASE_DIR, path)

  if not os.path.exists(abs_path):
    return abort(404)
  if os.path.isfile(abs_path):
    return send_file(abs_path)
  files = os.listdir(abs_path)
  return render_template('files.html', files=files)

def _LoadLocks():
  try:
    with open(LOCKS_DATA_FILE, 'r+') as f:
      return json.load(fp=f)
  except IOError:
    return {}

def _WriteLocks(data):
  j = json.dumps(data, indent=4)
  with open(LOCKS_DATA_FILE, 'w') as f:
    f.write(j)

if __name__ == '__main__':
  port = int(os.environ.get('PORT', 33507))
  app.run(host='0.0.0.0', port=port, debug=True)
