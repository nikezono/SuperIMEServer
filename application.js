var restify = require('restify');
var server = restify.createServer();
server.use(restify.bodyParser());

var mongoose = require('mongoose');
var db = mongoose.connect('mongodb://localhost/candidate');
var Schema = mongoose.Schema;

var candidateSchema = new Schema({
image: String,
text:String,
description: String,
date:Date
});

mongoose.model('candidate', candidateSchema);
var Candidate = mongoose.model('candidate');

function getCandidate(req, res, next){
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "X-Requested-With");
  res.send("aaa");
      });
}

function postCandidate(req, res, next){
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "X-Requested-With");
  var candidate = new Candidate();
  candidate.name = req.params.mode;
  candidate.comment = req.params.text;
  candidate.date = new Date;
  candidate.save(function(arr, data){
      res.send(data);
      });
}

server.get('/', getCandidate);
server.post('/', postCandidate);

server.listen(8080, function() {
    console.log('%s listening at %s', server.name, server.url);
    });
