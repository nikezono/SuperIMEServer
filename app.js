
/**
 * Module dependencies.
 */
var http     = require('http');  
var express = require('express')
, routes = require('./routes')
, user = require('./routes/user')
, http = require('http')
, path = require('path');

var app = express();

app.configure(function(){
    app.set('port', process.env.PORT || 2342);
    app.set('views', __dirname + '/views');
    app.set('view engine', 'jade');
    app.use(express.favicon());
    app.use(express.logger('dev'));
    app.use(express.bodyParser());
    app.use(express.methodOverride());
    app.use(app.router);
    app.use(express.static(path.join(__dirname, 'public')));
    });

app.configure('development', function(){
    app.use(express.errorHandler());
    });

app.get('/', function(req,response){
    var mode = req.query.mode;
    var text = req.query.text;
    text = encodeURIComponent(text);
    response.contentType('application/json');

    //モードごとの分岐
    if(mode == 0){//かな漢字変換

      //Googleかな漢字変換APIを使う
      http.get({
        host: 'www.google.com',
        path: '/transliterate?langpair=ja-Hira|ja&text='+text
      }, function(res) {
        var body = '';
        res.on('data', function(data) {
          body += data;
        });
        res.on('end', function() {
          var Results = JSON.parse(body);
          var candidates = new Array();
          Results[0][1].forEach(function(phrase){
            candidates.push(phrase);
            for(var num = 1;num < Results.length;num++){
              Results[num][1].forEach(function(text){
                candidates.push(phrase + text);
              });
            }
          });
          //GoogleサジェストAPIを使う
          
          response.send(candidates);
        });
      });
    }
});
app.get('/users', user.list);

http.createServer(app).listen(app.get('port'), function(){
    console.log("Express server listening on port " + app.get('port'));
    });
