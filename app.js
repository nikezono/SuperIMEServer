
/**
 * Module dependencies.
 */
var http     = require('http');
var express = require('express')
, routes = require('./routes')
, user = require('./routes/user')
, http = require('http')
, path = require('path');

var redis = require("redis"),
    db = redis.createClient();

db.on("error", function (err) {
      console.log("Error " + err);
  });

var app = express();

db.set("string","string success",redis.print);

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
    var cand = req.query.cand;
    var hira = req.query.hira;
    response.contentType('application/json');

    var candidates = new Array();

    //モードごとの分岐
    if(mode == 0){//かな漢字変換
      hiraURI = encodeURIComponent(hira);

      //redis側でデータを取得済みであればそれを使う
      var exists = false;
      db.get("kana:"+hiraURI,function(err,reply){
        exists = reply;

        if(exists != null){
          db.get("kana:"+hiraURI,function(err,value){
           console.log("get = "+value);
           candidates = value.split(",");
           response.send(candidates);
          });
        }else{
        //Googleかな漢字変換APIを使う

        http.get({
          host: 'www.google.com',
          path: '/transliterate?langpair=ja-Hira|ja&text='+hiraURI
        }, function(res) {
          var body = '';
          res.on('data', function(data) {
            body += data;
          });
          res.on('end', function() {
            //console.log("Body:"+body);
            var Results = JSON.parse(body);
              //再起
            //console.log("Results:"+Results);
            for(var i = 0;i<Results.length;i++){
              if(i == 0){
                //console.log(Results[0][1]);
                Results[0][1].forEach(function(w){
                  if(w==hira){}else{
                    candidates.push(w);
                  }
                });
              }else{
                candidates = GoogleTransliterate(candidates,Results[i],hira);
              }
            }
            //GoogleサジェストAPIを使う
            //http.get({
            //  host:'www.google.com',
            //  path:'/complete/search?output=toolbar&hl=ja&q='+cand
            //}, function(res){
            //  });
            candidates.unshift(hira);
            db.set("kana:"+hiraURI,candidates,redis.print);
            response.send(candidates);
          });
        });
      }
    });
      //類語
    }else if(mode == 1){


      //英和和英
    }else if(mode == 2){


      //画像
    }else if(mode == 3){
      console.log(hira);
      hira = encodeURIComponent(hira);
      http.get({
        host: 'api.tiqav.com',
        path: '/search.json?callback=&q='+ hira
      }, function(res) {
        var body = '';
        res.on('data', function(data) {
          body += data;
        });
        res.on('end', function() {
          var Results = JSON.parse(body);
          //console.log(Results);
          Results.forEach(function(image){
            candidates.push("http://tiqav.com/" + image.id + "." + image.ext);
          });
          response.send(candidates)
        });
      });
    }
  });

http.createServer(app).listen(app.get('port'), function(){
    console.log("Express server listening on port " + app.get('port'));
});

function GoogleTransliterate(array1,array2,hira){
  var res = [];
  array1.forEach(function(phrase){
    array2[1].forEach(function(word){
      if(hira == phrase+word){}else{
        res.push(phrase+word);
      }
    });
  });
  return res;
}
