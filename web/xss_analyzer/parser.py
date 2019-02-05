#!/usr/bin/python
import sys
from BaseHTTPServer import BaseHTTPRequestHandler
from httplib import HTTPResponse
from StringIO import StringIO


#parse boundary to know which field
def parse_boundary(boundary):
	boundary = boundary.strip()
	data = {}
	data['boundary_id'] = boundary[2:len(boundary)-4]
	data['boundary_section'] = boundary[len(boundary)-3:len(boundary)-2]
	return data

#to parse log header
def parse_logHeader(segment):
	segment = segment.strip()
	data = segment.split(' ')
	time_data = data[0] + " " + data[1]
	return {'time':time_data, 'id':data[2], 's_ip':data[3], 's_port':data[4], 'd_ip':data[5], 'd_port':data[6]}

#test
def test_parse_logHeader():
	seg = "[18/Aug/2009:08:25:15 +0100] SopXW38EAAE9YbLQ 192.168.3.1 2387 192.168.3.111 8080"
	a = parse_logHeader(seg)
	print a.keys()
	print a.values()


#class of HTTPRequest, will be used to create fake socket, we just need to parse HTTP request
class HTTPRequest(BaseHTTPRequestHandler):
    def __init__(self, request_text):
        self.rfile = StringIO(request_text)
        self.raw_requestline = self.rfile.readline()
        self.error_code = self.error_message = None
        self.parse_request()

    def send_error(self, code, message):
        self.error_code = code
        self.error_message = message

#for http request parsing
def parse_request_header(seg):
	request = HTTPRequest(seg)
	req_data = {}
	req_data['error_code'] = request.error_code
	req_data['command'] = request.command
	req_data['path'] = request.path
	req_data['request_version'] = request.request_version
	for header in request.headers.keys():
		req_data[header] = request.headers[header]
	return req_data

#for parsing request body, POST data
def parse_request_body(seg):
	# image data ------WebKitFormBoundaryj7kWKa9WlL4SCt9n
	seg = seg.strip()
	return {'request_body':seg}

#fake socket class with cooperation with HTTPResponse in order to parse HTTP response
class FakeSocket():
    def __init__(self, response_str):
        self._file = StringIO(response_str)
    def makefile(self, *args, **kwargs):
        return self._file

#to parse http response
def parse_response_header(seg):
	source = FakeSocket(seg)
	response = HTTPResponse(source)
	response.begin()
	http_v = {10:'HTTP/1.0', 11:'HTTP/1.1'}
	res_data = {}
	res_data['status'] = response.status
	res_data['response_version'] = http_v[response.version]
	data = response.getheaders()
	for h in data:
		res_data[str(h[0])] = h[1]
	return res_data


#receives a section and outputs a parsed string
def parse_section2string(partA,partB,partC,partF):

	parsed_string = ""
	if partA:

		if 's_ip' in partA:
			parsed_string += partA['s_ip'] + " - - "

		if 'time' in partA:
			parsed_string += partA['time'] + " "

	if partB:
		if 'command' in partB:
			parsed_string += "\"" + partB['command'] + " "
		if 'path' in partB:
			parsed_string += partB['path'] + " "
	if partC:
		if 'request_body' in partC:
			parsed_string = parsed_string[:-1]
			#TODO
			parsed_string += "/" + partC['request_body'] + " "
	if partB:
		if 'request_version' in partB:
			parsed_string += partB['request_version'] + "\" "
	if partF:
		if 'status' in partF:
			parsed_string += str(partF['status']) + " "
		if 'content-length' in partF:
			parsed_string += partF['content-length'] + " "
	if partB:
		if 'referer' in partB:
			parsed_string += "\"" + partB['referer'] + "\" "
		if 'user-agent' in partB:
			parsed_string += "\"" + partB['user-agent'] + "\" "

	parsed_string += "\n"

	return parsed_string

#to parse a single transaction
def parse_single_transaction(transaction_data):
	partA = {}
	partB = {}
	partC = {}
	partF = {}
	data = transaction_data.splitlines()
	for i in range(0, len(data) -1):
		if data[i].strip():
			if data[i].startswith("--"):
				segment = ""
				boundary = parse_boundary(data[i])
				if boundary['boundary_section'] == 'Z':
					break
				i = i + 1
				while not data[i].startswith("--"):
					segment = segment + data[i] + "\r\n"
					i = i + 1

				if boundary['boundary_section'] == 'A':
					partA = parse_logHeader(segment)
				if boundary['boundary_section'] == 'B':
					partB = parse_request_header(segment)
				if boundary['boundary_section'] == 'C':
					partC = parse_request_body(segment)
				if boundary['boundary_section'] == 'F':
					partF = parse_response_header(segment)
				
				parsed_data = parse_section2string(partA,partB,partC,partF)
	return parsed_data



#to parse a log file
def parse_log_file(filename):
	with open(filename, "r") as log_file:
		data = log_file.readlines()
	log_file.close()

	with open('output.log', 'w') as new_log:

		for i in range(0, len(data) -1):
			if data[i].strip():
				if data[i].startswith("--"):
					if parse_boundary(data[i])['boundary_section'] == 'A':
						section = ""
						while parse_boundary(data[i])['boundary_section'] != 'Z':
							section = section + data[i]
							i = i + 1
						section = section + data[i]

						parsed_section = parse_single_transaction(section)
						new_log.write(parsed_section)
	new_log.close()
	


#real time parsing of data received by pipe
def parse_log_pipe():
	while(1):
		line = sys.stdin.readline()
		if line.strip():
			if line.startswith("--"):
				if parse_boundary(line)['boundary_section'] == 'A':
					section = ""
					while parse_boundary(line)['boundary_section'] != 'Z':
						section = section + line
						line = sys.stdin.readline()
					section = section + line

					parsed_section = parse_single_transaction(section)
					parsed_section=parsed_section[:-1]
					print parsed_section
#main

#parse_single_transaction(trans)
#parse_log_file("/home/gdsg7675/parser/logs_project/modsec.log")
parse_log_pipe()

